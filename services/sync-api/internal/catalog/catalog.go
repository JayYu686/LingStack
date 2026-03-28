package catalog

import (
	_ "embed"
	"encoding/json"
	"strings"

	"ai-developer/services/sync-api/internal/domain"
)

//go:embed bootstrap.json
var bootstrapJSON []byte

type Store struct {
	bootstrap domain.CatalogBootstrap
	byID      map[string]domain.CatalogResourceEnvelope
}

func Load() (*Store, error) {
	var bootstrap domain.CatalogBootstrap
	if err := json.Unmarshal(bootstrapJSON, &bootstrap); err != nil {
		return nil, err
	}

	store := &Store{
		bootstrap: bootstrap,
		byID:      make(map[string]domain.CatalogResourceEnvelope, len(bootstrap.Resources)),
	}

	for _, resource := range bootstrap.Resources {
		store.byID[resource.ID] = domain.CatalogResourceEnvelope{Resource: resource}
	}
	for _, detail := range bootstrap.PromptDetails {
		envelope := store.byID[detail.ResourceID]
		envelope.PromptDetail = &detail
		store.byID[detail.ResourceID] = envelope
	}
	for _, detail := range bootstrap.SkillDetails {
		envelope := store.byID[detail.ResourceID]
		envelope.SkillDetail = &detail
		store.byID[detail.ResourceID] = envelope
	}
	for _, detail := range bootstrap.MCPDetails {
		envelope := store.byID[detail.ResourceID]
		envelope.MCPDetail = &detail
		store.byID[detail.ResourceID] = envelope
	}

	return store, nil
}

func (s *Store) Bootstrap() domain.CatalogBootstrap {
	return s.bootstrap
}

func (s *Store) ListResources(resourceType string, query string) []domain.CatalogResource {
	typeFilter := strings.TrimSpace(strings.ToLower(resourceType))
	query = strings.TrimSpace(strings.ToLower(query))

	results := make([]domain.CatalogResource, 0, len(s.bootstrap.Resources))
	for _, resource := range s.bootstrap.Resources {
		if typeFilter != "" && resource.Type != typeFilter {
			continue
		}
		if query != "" && !matchesQuery(resource, query) {
			continue
		}
		results = append(results, resource)
	}
	return results
}

func (s *Store) ResourceEnvelope(id string) (domain.CatalogResourceEnvelope, bool) {
	envelope, ok := s.byID[id]
	return envelope, ok
}

func (s *Store) Collections() []domain.CatalogCollection {
	return s.bootstrap.Collections
}

func matchesQuery(resource domain.CatalogResource, query string) bool {
	if strings.Contains(strings.ToLower(resource.Title), query) {
		return true
	}
	if strings.Contains(strings.ToLower(resource.Summary), query) {
		return true
	}
	if strings.Contains(strings.ToLower(resource.Scenario), query) {
		return true
	}
	for _, tag := range resource.Tags {
		if strings.Contains(strings.ToLower(tag), query) {
			return true
		}
	}
	return false
}
