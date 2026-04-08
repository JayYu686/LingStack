package domain

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

const (
	TransportStreamableHTTP = "streamable_http"
	OperationUpsert         = "upsert"
	OperationDelete         = "delete"
)

type SyncChange struct {
	EntityType     string          `json:"entityType"`
	EntityID       string          `json:"entityId"`
	RevisionID     string          `json:"revisionId"`
	BaseRevisionID string          `json:"baseRevisionId"`
	Operation      string          `json:"operation"`
	UpdatedAt      time.Time       `json:"updatedAt"`
	DeviceID       string          `json:"deviceId"`
	Payload        json.RawMessage `json:"payload"`
}

func (c SyncChange) Validate() error {
	if strings.TrimSpace(c.EntityType) == "" {
		return errors.New("entityType is required")
	}
	if strings.TrimSpace(c.EntityID) == "" {
		return errors.New("entityId is required")
	}
	if strings.TrimSpace(c.RevisionID) == "" {
		return errors.New("revisionId is required")
	}
	if c.BaseRevisionID != "" && strings.TrimSpace(c.BaseRevisionID) == "" {
		return errors.New("baseRevisionId must not be whitespace")
	}
	if strings.TrimSpace(c.Operation) == "" {
		return errors.New("operation is required")
	}
	if c.Operation != OperationUpsert && c.Operation != OperationDelete {
		return fmt.Errorf("unsupported operation %q", c.Operation)
	}
	if c.UpdatedAt.IsZero() {
		return errors.New("updatedAt is required")
	}
	if strings.TrimSpace(c.DeviceID) == "" {
		return errors.New("deviceId is required")
	}
	if len(c.Payload) == 0 {
		return errors.New("payload is required")
	}
	return nil
}

type SyncConflict struct {
	EntityType             string `json:"entityType"`
	EntityID               string `json:"entityId"`
	RevisionID             string `json:"revisionId"`
	ExpectedBaseRevisionID string `json:"expectedBaseRevisionId"`
	ActualBaseRevisionID   string `json:"actualBaseRevisionId"`
}

type PushRequest struct {
	DeviceID string       `json:"deviceId"`
	Changes  []SyncChange `json:"changes"`
}

type PushResponse struct {
	Accepted     []SyncChange   `json:"accepted"`
	Conflicts    []SyncConflict `json:"conflicts"`
	LatestCursor int64          `json:"latestCursor"`
}

type PullRequest struct {
	DeviceID string `json:"deviceId"`
	Cursor   int64  `json:"cursor"`
	Limit    int    `json:"limit"`
}

type PullResponse struct {
	Changes    []SyncChange `json:"changes"`
	NextCursor int64        `json:"nextCursor"`
	HasMore    bool         `json:"hasMore"`
}

type McpProbeRequest struct {
	BaseURL     string            `json:"baseUrl"`
	Transport   string            `json:"transport"`
	Headers     map[string]string `json:"headers"`
	BearerToken string            `json:"bearerToken"`
}

func (r McpProbeRequest) Header() http.Header {
	headers := make(http.Header, len(r.Headers)+3)
	for key, value := range r.Headers {
		headers.Set(key, value)
	}
	headers.Set("Accept", "application/json, text/event-stream")
	headers.Set("Content-Type", "application/json")
	if token := strings.TrimSpace(r.BearerToken); token != "" {
		headers.Set("Authorization", "Bearer "+token)
	}
	return headers
}

type McpProbeResponse struct {
	Healthy      bool           `json:"healthy"`
	StatusCode   int            `json:"statusCode"`
	BodyPreview  string         `json:"bodyPreview,omitempty"`
	Capabilities map[string]any `json:"capabilities,omitempty"`
	ServerInfo   map[string]any `json:"serverInfo,omitempty"`
	ProtocolVersion string      `json:"protocolVersion,omitempty"`
	Error        string         `json:"error,omitempty"`
}

type McpInvokeTestRequest struct {
	BaseURL     string            `json:"baseUrl"`
	Transport   string            `json:"transport"`
	Headers     map[string]string `json:"headers"`
	BearerToken string            `json:"bearerToken"`
	Method      string            `json:"method"`
	Params      json.RawMessage   `json:"params"`
}

func (r McpInvokeTestRequest) Header() http.Header {
	return McpProbeRequest{
		BaseURL:     r.BaseURL,
		Transport:   r.Transport,
		Headers:     r.Headers,
		BearerToken: r.BearerToken,
	}.Header()
}

type McpInvokeTestResponse struct {
	StatusCode int             `json:"statusCode"`
	Body       json.RawMessage `json:"body,omitempty"`
	Error      string          `json:"error,omitempty"`
}

type AISummarizeSnippetRequest struct {
	DeviceID     string   `json:"deviceId"`
	Language     string   `json:"language"`
	Title        string   `json:"title"`
	Content      string   `json:"content"`
	ExistingTags []string `json:"existingTags"`
}

type AIClassifyAssetRequest struct {
	DeviceID  string `json:"deviceId"`
	AssetType string `json:"assetType"`
	Title     string `json:"title"`
	Content   string `json:"content"`
}

type AISuggestion struct {
	Summary    string   `json:"summary"`
	Tags       []string `json:"tags"`
	Confidence float64  `json:"confidence"`
}

type AITask struct {
	ID            string          `json:"id"`
	Kind          string          `json:"kind"`
	Status        string          `json:"status"`
	InputPayload  json.RawMessage `json:"inputPayload"`
	OutputPayload json.RawMessage `json:"outputPayload"`
	CreatedAt     time.Time       `json:"createdAt"`
	CompletedAt   *time.Time      `json:"completedAt,omitempty"`
}

func NormalizeTransport(transport string) string {
	if strings.TrimSpace(transport) == "" {
		return TransportStreamableHTTP
	}
	return strings.TrimSpace(transport)
}
