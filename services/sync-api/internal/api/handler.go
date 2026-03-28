package api

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"time"

	"ai-developer/services/sync-api/internal/domain"
	"ai-developer/services/sync-api/internal/service"
)

type Handler struct {
	service *service.Service
}

func NewHandler(svc *service.Service) http.Handler {
	handler := &Handler{service: svc}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", handler.handleHealth)
	mux.HandleFunc("GET /v1/catalog/bootstrap", handler.handleCatalogBootstrap)
	mux.HandleFunc("GET /v1/catalog/resources", handler.handleCatalogResources)
	mux.HandleFunc("GET /v1/catalog/resources/{id}", handler.handleCatalogResource)
	mux.HandleFunc("GET /v1/catalog/collections", handler.handleCatalogCollections)
	mux.HandleFunc("POST /v1/sync/push", handler.handlePush)
	mux.HandleFunc("POST /v1/sync/pull", handler.handlePull)
	mux.HandleFunc("POST /v1/mcp/probe", handler.handleProbeMCP)
	mux.HandleFunc("POST /v1/mcp/invoke-test", handler.handleInvokeMCP)
	mux.HandleFunc("POST /v1/ai/summarize-snippet", handler.handleSummarizeSnippet)
	mux.HandleFunc("POST /v1/ai/classify-asset", handler.handleClassifyAsset)
	return withLogging(mux)
}

func (h *Handler) handleHealth(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (h *Handler) handleCatalogBootstrap(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, h.service.CatalogBootstrap())
}

func (h *Handler) handleCatalogResources(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"resources": h.service.ListCatalogResources(
			r.URL.Query().Get("type"),
			r.URL.Query().Get("query"),
		),
	})
}

func (h *Handler) handleCatalogResource(w http.ResponseWriter, r *http.Request) {
	resourceID := r.PathValue("id")
	envelope, ok := h.service.GetCatalogResource(resourceID)
	if !ok {
		writeError(w, http.StatusNotFound, errors.New("catalog resource not found"))
		return
	}
	writeJSON(w, http.StatusOK, envelope)
}

func (h *Handler) handleCatalogCollections(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"collections": h.service.ListCatalogCollections(),
	})
}

func (h *Handler) handlePush(w http.ResponseWriter, r *http.Request) {
	var req domain.PushRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.PushChanges(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *Handler) handlePull(w http.ResponseWriter, r *http.Request) {
	var req domain.PullRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.PullChanges(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *Handler) handleProbeMCP(w http.ResponseWriter, r *http.Request) {
	var req domain.McpProbeRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.ProbeMCP(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *Handler) handleInvokeMCP(w http.ResponseWriter, r *http.Request) {
	var req domain.McpInvokeTestRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.InvokeMCPTest(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *Handler) handleSummarizeSnippet(w http.ResponseWriter, r *http.Request) {
	var req domain.AISummarizeSnippetRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.SummarizeSnippet(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *Handler) handleClassifyAsset(w http.ResponseWriter, r *http.Request) {
	var req domain.AIClassifyAssetRequest
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	resp, err := h.service.ClassifyAsset(r.Context(), req)
	if err != nil {
		writeError(w, http.StatusBadRequest, err)
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startedAt := time.Now()
		next.ServeHTTP(w, r)
		slog.Info("request", "method", r.Method, "path", r.URL.Path, "duration", time.Since(startedAt))
	})
}

func decodeJSON(r *http.Request, destination any) error {
	defer r.Body.Close()
	body, err := io.ReadAll(io.LimitReader(r.Body, 1<<20))
	if err != nil {
		return err
	}
	decoder := json.NewDecoder(bytes.NewReader(body))
	decoder.DisallowUnknownFields()
	return decoder.Decode(destination)
}

func writeError(w http.ResponseWriter, statusCode int, err error) {
	writeJSON(w, statusCode, map[string]string{"error": err.Error()})
}

func writeJSON(w http.ResponseWriter, statusCode int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(payload)
}
