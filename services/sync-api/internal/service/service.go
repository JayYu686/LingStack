package service

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"ai-developer/services/sync-api/internal/catalog"
	"ai-developer/services/sync-api/internal/domain"
)

type Store interface {
	PushChanges(context.Context, domain.PushRequest) (domain.PushResponse, error)
	PullChanges(context.Context, domain.PullRequest) (domain.PullResponse, error)
	SaveAITask(context.Context, domain.AITask) error
}

type Service struct {
	store      Store
	catalog    *catalog.Store
	httpClient *http.Client
	now        func() time.Time
}

func New(store Store, catalogStore *catalog.Store) *Service {
	return &Service{
		store: store,
		catalog: catalogStore,
		httpClient: &http.Client{
			Timeout: 12 * time.Second,
		},
		now: time.Now,
	}
}

func (s *Service) PushChanges(ctx context.Context, req domain.PushRequest) (domain.PushResponse, error) {
	if strings.TrimSpace(req.DeviceID) == "" {
		return domain.PushResponse{}, errors.New("deviceId is required")
	}
	if len(req.Changes) == 0 {
		return domain.PushResponse{}, errors.New("changes must not be empty")
	}
	for _, change := range req.Changes {
		if err := change.Validate(); err != nil {
			return domain.PushResponse{}, err
		}
	}
	return s.store.PushChanges(ctx, req)
}

func (s *Service) PullChanges(ctx context.Context, req domain.PullRequest) (domain.PullResponse, error) {
	if strings.TrimSpace(req.DeviceID) == "" {
		return domain.PullResponse{}, errors.New("deviceId is required")
	}
	if req.Limit <= 0 || req.Limit > 200 {
		req.Limit = 50
	}
	return s.store.PullChanges(ctx, req)
}

func (s *Service) CatalogBootstrap() domain.CatalogBootstrap {
	return s.catalog.Bootstrap()
}

func (s *Service) ListCatalogResources(resourceType string, query string) []domain.CatalogResource {
	return s.catalog.ListResources(resourceType, query)
}

func (s *Service) GetCatalogResource(id string) (domain.CatalogResourceEnvelope, bool) {
	return s.catalog.ResourceEnvelope(id)
}

func (s *Service) ListCatalogCollections() []domain.CatalogCollection {
	return s.catalog.Collections()
}

func (s *Service) ProbeMCP(ctx context.Context, req domain.McpProbeRequest) (domain.McpProbeResponse, error) {
	if err := validateBaseURL(req.BaseURL); err != nil {
		return domain.McpProbeResponse{}, err
	}
	if domain.NormalizeTransport(req.Transport) != domain.TransportStreamableHTTP {
		return domain.McpProbeResponse{}, fmt.Errorf("unsupported transport %q", req.Transport)
	}

	body, err := json.Marshal(map[string]any{
		"jsonrpc": "2.0",
		"id":      "probe",
		"method":  "initialize",
		"params": map[string]any{
			"protocolVersion": "2025-06-18",
			"capabilities":    map[string]any{},
			"clientInfo": map[string]any{
				"name":    "ai-developer-sync-api",
				"version": "0.1.0",
			},
		},
	})
	if err != nil {
		return domain.McpProbeResponse{}, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, req.BaseURL, bytes.NewReader(body))
	if err != nil {
		return domain.McpProbeResponse{}, err
	}
	httpReq.Header = req.Header()

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		return domain.McpProbeResponse{
			Healthy:    false,
			StatusCode: http.StatusBadGateway,
			Error:      err.Error(),
		}, nil
	}
	defer resp.Body.Close()

	payload, _ := io.ReadAll(io.LimitReader(resp.Body, 16*1024))
	result := domain.McpProbeResponse{
		Healthy:     resp.StatusCode >= 200 && resp.StatusCode < 300,
		StatusCode:  resp.StatusCode,
		BodyPreview: strings.TrimSpace(string(payload)),
	}

	var decoded struct {
		Result struct {
			Capabilities    map[string]any `json:"capabilities"`
			ServerInfo      map[string]any `json:"serverInfo"`
			ProtocolVersion string         `json:"protocolVersion"`
		} `json:"result"`
	}
	if err := json.Unmarshal(payload, &decoded); err == nil {
		if len(decoded.Result.Capabilities) > 0 {
			result.Capabilities = decoded.Result.Capabilities
		}
		if len(decoded.Result.ServerInfo) > 0 {
			result.ServerInfo = decoded.Result.ServerInfo
		}
		if strings.TrimSpace(decoded.Result.ProtocolVersion) != "" {
			result.ProtocolVersion = decoded.Result.ProtocolVersion
		}
	}

	return result, nil
}

func (s *Service) InvokeMCPTest(ctx context.Context, req domain.McpInvokeTestRequest) (domain.McpInvokeTestResponse, error) {
	if err := validateBaseURL(req.BaseURL); err != nil {
		return domain.McpInvokeTestResponse{}, err
	}
	if strings.TrimSpace(req.Method) == "" {
		return domain.McpInvokeTestResponse{}, errors.New("method is required")
	}

	params := req.Params
	if len(params) == 0 {
		params = json.RawMessage("{}")
	}
	body, err := json.Marshal(map[string]any{
		"jsonrpc": "2.0",
		"id":      "invoke-test",
		"method":  req.Method,
		"params":  json.RawMessage(params),
	})
	if err != nil {
		return domain.McpInvokeTestResponse{}, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, req.BaseURL, bytes.NewReader(body))
	if err != nil {
		return domain.McpInvokeTestResponse{}, err
	}
	httpReq.Header = req.Header()

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		return domain.McpInvokeTestResponse{
			StatusCode: http.StatusBadGateway,
			Error:      err.Error(),
		}, nil
	}
	defer resp.Body.Close()

	payload, _ := io.ReadAll(io.LimitReader(resp.Body, 64*1024))
	return domain.McpInvokeTestResponse{
		StatusCode: resp.StatusCode,
		Body:       json.RawMessage(payload),
	}, nil
}

func (s *Service) SummarizeSnippet(ctx context.Context, req domain.AISummarizeSnippetRequest) (domain.AITask, error) {
	if strings.TrimSpace(req.DeviceID) == "" {
		return domain.AITask{}, errors.New("deviceId is required")
	}
	if strings.TrimSpace(req.Language) == "" {
		return domain.AITask{}, errors.New("language is required")
	}
	if strings.TrimSpace(req.Content) == "" {
		return domain.AITask{}, errors.New("content is required")
	}

	suggestion := buildSuggestion(req.Language, req.Title, req.Content, req.ExistingTags)
	return s.saveTask(ctx, "summarize_snippet", req, suggestion)
}

func (s *Service) ClassifyAsset(ctx context.Context, req domain.AIClassifyAssetRequest) (domain.AITask, error) {
	if strings.TrimSpace(req.DeviceID) == "" {
		return domain.AITask{}, errors.New("deviceId is required")
	}
	if strings.TrimSpace(req.AssetType) == "" {
		return domain.AITask{}, errors.New("assetType is required")
	}
	if strings.TrimSpace(req.Content) == "" {
		return domain.AITask{}, errors.New("content is required")
	}

	suggestion := buildSuggestion(req.AssetType, req.Title, req.Content, nil)
	return s.saveTask(ctx, "classify_asset", req, suggestion)
}

func (s *Service) saveTask(ctx context.Context, kind string, input any, suggestion domain.AISuggestion) (domain.AITask, error) {
	inputPayload, err := json.Marshal(input)
	if err != nil {
		return domain.AITask{}, err
	}
	outputPayload, err := json.Marshal(map[string]any{
		"suggestion": suggestion,
	})
	if err != nil {
		return domain.AITask{}, err
	}

	completedAt := s.now().UTC()
	task := domain.AITask{
		ID:            newID(),
		Kind:          kind,
		Status:        "completed",
		InputPayload:  inputPayload,
		OutputPayload: outputPayload,
		CreatedAt:     completedAt,
		CompletedAt:   &completedAt,
	}
	if err := s.store.SaveAITask(ctx, task); err != nil {
		return domain.AITask{}, err
	}
	return task, nil
}

func validateBaseURL(rawURL string) error {
	parsed, err := url.Parse(strings.TrimSpace(rawURL))
	if err != nil {
		return err
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return errors.New("baseUrl must use http or https")
	}
	if parsed.Host == "" {
		return errors.New("baseUrl host is required")
	}
	return nil
}
