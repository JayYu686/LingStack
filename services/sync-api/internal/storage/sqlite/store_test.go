package sqlite

import (
	"context"
	"path/filepath"
	"testing"
	"time"

	"ai-developer/services/sync-api/internal/domain"
)

func TestPushAndPullChanges(t *testing.T) {
	t.Parallel()

	store, err := Open(filepath.Join(t.TempDir(), "sync.db"))
	if err != nil {
		t.Fatalf("open store: %v", err)
	}
	defer store.Close()

	if err := store.Migrate(context.Background()); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	change := domain.SyncChange{
		EntityType:     "prompt_template",
		EntityID:       "prompt-1",
		RevisionID:     "rev-1",
		BaseRevisionID: "",
		Operation:      domain.OperationUpsert,
		UpdatedAt:      time.Date(2026, 3, 28, 8, 30, 0, 0, time.UTC),
		DeviceID:       "iphone-15",
		Payload:        []byte(`{"title":"Review prompt"}`),
	}

	pushResponse, err := store.PushChanges(context.Background(), domain.PushRequest{
		DeviceID: "iphone-15",
		Changes:  []domain.SyncChange{change},
	})
	if err != nil {
		t.Fatalf("push changes: %v", err)
	}
	if len(pushResponse.Accepted) != 1 {
		t.Fatalf("expected 1 accepted change, got %d", len(pushResponse.Accepted))
	}
	if pushResponse.LatestCursor == 0 {
		t.Fatalf("expected latest cursor to be set")
	}

	pullResponse, err := store.PullChanges(context.Background(), domain.PullRequest{
		DeviceID: "ipad-pro",
		Cursor:   0,
		Limit:    50,
	})
	if err != nil {
		t.Fatalf("pull changes: %v", err)
	}
	if len(pullResponse.Changes) != 1 {
		t.Fatalf("expected 1 pulled change, got %d", len(pullResponse.Changes))
	}
	if pullResponse.Changes[0].RevisionID != "rev-1" {
		t.Fatalf("unexpected revision id %q", pullResponse.Changes[0].RevisionID)
	}
}

func TestDetectsConflicts(t *testing.T) {
	t.Parallel()

	store, err := Open(filepath.Join(t.TempDir(), "sync.db"))
	if err != nil {
		t.Fatalf("open store: %v", err)
	}
	defer store.Close()

	if err := store.Migrate(context.Background()); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	baseChange := domain.SyncChange{
		EntityType:     "snippet",
		EntityID:       "snippet-1",
		RevisionID:     "rev-a",
		BaseRevisionID: "",
		Operation:      domain.OperationUpsert,
		UpdatedAt:      time.Now().UTC(),
		DeviceID:       "device-a",
		Payload:        []byte(`{"title":"Initial"}`),
	}
	if _, err := store.PushChanges(context.Background(), domain.PushRequest{
		DeviceID: "device-a",
		Changes:  []domain.SyncChange{baseChange},
	}); err != nil {
		t.Fatalf("seed change: %v", err)
	}

	conflictChange := domain.SyncChange{
		EntityType:     "snippet",
		EntityID:       "snippet-1",
		RevisionID:     "rev-b",
		BaseRevisionID: "rev-missing",
		Operation:      domain.OperationUpsert,
		UpdatedAt:      time.Now().UTC(),
		DeviceID:       "device-b",
		Payload:        []byte(`{"title":"Conflict"}`),
	}
	response, err := store.PushChanges(context.Background(), domain.PushRequest{
		DeviceID: "device-b",
		Changes:  []domain.SyncChange{conflictChange},
	})
	if err != nil {
		t.Fatalf("push conflict change: %v", err)
	}
	if len(response.Conflicts) != 1 {
		t.Fatalf("expected 1 conflict, got %d", len(response.Conflicts))
	}
}
