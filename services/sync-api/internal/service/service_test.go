package service

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"ai-developer/services/sync-api/internal/catalog"
	"ai-developer/services/sync-api/internal/domain"
)

type fakeStore struct{}

func (fakeStore) PushChanges(context.Context, domain.PushRequest) (domain.PushResponse, error) {
	return domain.PushResponse{}, nil
}

func (fakeStore) PullChanges(context.Context, domain.PullRequest) (domain.PullResponse, error) {
	return domain.PullResponse{}, nil
}

func (fakeStore) SaveAITask(context.Context, domain.AITask) error {
	return nil
}

func newTestService(t *testing.T) *Service {
	t.Helper()
	catalogStore, err := catalog.Load()
	if err != nil {
		t.Fatalf("load catalog: %v", err)
	}
	return New(fakeStore{}, catalogStore)
}

func TestProbeMCPParsesProtocolVersionAndServerInfo(t *testing.T) {
	svc := newTestService(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		payload := map[string]any{
			"jsonrpc": "2.0",
			"id":      "probe",
			"result": map[string]any{
				"protocolVersion": "2025-06-18",
				"serverInfo": map[string]any{
					"name":    "demo-mcp",
					"version": "1.2.3",
				},
				"capabilities": map[string]any{
					"tools":     true,
					"resources": true,
				},
			},
		}
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	resp, err := svc.ProbeMCP(context.Background(), domain.McpProbeRequest{
		BaseURL:   server.URL,
		Transport: domain.TransportStreamableHTTP,
	})
	if err != nil {
		t.Fatalf("probe mcp: %v", err)
	}
	if !resp.Healthy {
		t.Fatalf("expected healthy response, got %#v", resp)
	}
	if resp.ProtocolVersion != "2025-06-18" {
		t.Fatalf("unexpected protocol version: %q", resp.ProtocolVersion)
	}
	if resp.ServerInfo["name"] != "demo-mcp" {
		t.Fatalf("unexpected server info: %#v", resp.ServerInfo)
	}
	if _, ok := resp.Capabilities["tools"]; !ok {
		t.Fatalf("expected tools capability, got %#v", resp.Capabilities)
	}
}

func TestProbeMCPRejectsUnsupportedTransport(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.ProbeMCP(context.Background(), domain.McpProbeRequest{
		BaseURL:   "https://example.com/mcp",
		Transport: "stdio",
	})
	if err == nil {
		t.Fatal("expected transport validation error")
	}
}

func TestInvokeMCPTestReturnsJSONBody(t *testing.T) {
	svc := newTestService(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		payload := map[string]any{
			"jsonrpc": "2.0",
			"id":      "invoke-test",
			"result": []any{"a", "b"},
		}
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	resp, err := svc.InvokeMCPTest(context.Background(), domain.McpInvokeTestRequest{
		BaseURL:   server.URL,
		Transport: domain.TransportStreamableHTTP,
		Method:    "tools/list",
		Params:    json.RawMessage(`{}`),
	})
	if err != nil {
		t.Fatalf("invoke mcp test: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("unexpected status code: %d", resp.StatusCode)
	}
	if len(resp.Body) == 0 {
		t.Fatal("expected response body")
	}
}
