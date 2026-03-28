package sqlite

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"ai-developer/services/sync-api/internal/domain"

	_ "modernc.org/sqlite"
)

type Store struct {
	db  *sql.DB
	now func() time.Time
}

func Open(path string) (*Store, error) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	return &Store{
		db:  db,
		now: time.Now,
	}, nil
}

func (s *Store) Close() error {
	return s.db.Close()
}

func (s *Store) Migrate(ctx context.Context) error {
	_, err := s.db.ExecContext(ctx, schema)
	return err
}

func (s *Store) PushChanges(ctx context.Context, req domain.PushRequest) (domain.PushResponse, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return domain.PushResponse{}, err
	}
	defer tx.Rollback()

	response := domain.PushResponse{
		Accepted:  make([]domain.SyncChange, 0, len(req.Changes)),
		Conflicts: make([]domain.SyncConflict, 0),
	}

	for _, change := range req.Changes {
		headRevision, exists, err := selectHead(ctx, tx, change.EntityType, change.EntityID)
		if err != nil {
			return domain.PushResponse{}, err
		}

		if exists && headRevision == change.RevisionID {
			response.Accepted = append(response.Accepted, change)
			continue
		}
		if exists && headRevision != change.BaseRevisionID {
			response.Conflicts = append(response.Conflicts, domain.SyncConflict{
				EntityType:             change.EntityType,
				EntityID:               change.EntityID,
				RevisionID:             change.RevisionID,
				ExpectedBaseRevisionID: change.BaseRevisionID,
				ActualBaseRevisionID:   headRevision,
			})
			continue
		}
		if !exists && change.BaseRevisionID != "" {
			response.Conflicts = append(response.Conflicts, domain.SyncConflict{
				EntityType:             change.EntityType,
				EntityID:               change.EntityID,
				RevisionID:             change.RevisionID,
				ExpectedBaseRevisionID: change.BaseRevisionID,
				ActualBaseRevisionID:   "",
			})
			continue
		}

		_, err = tx.ExecContext(
			ctx,
			`INSERT INTO sync_changes (
				entity_type, entity_id, revision_id, base_revision_id, operation, payload, updated_at, device_id, created_at
			) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			change.EntityType,
			change.EntityID,
			change.RevisionID,
			change.BaseRevisionID,
			change.Operation,
			string(change.Payload),
			change.UpdatedAt.UTC().Format(time.RFC3339Nano),
			change.DeviceID,
			s.now().UTC().Format(time.RFC3339Nano),
		)
		if err != nil {
			if isUniqueConstraintError(err) {
				response.Accepted = append(response.Accepted, change)
				continue
			}
			return domain.PushResponse{}, err
		}

		_, err = tx.ExecContext(
			ctx,
			`INSERT INTO entity_heads (entity_type, entity_id, revision_id, updated_at)
			 VALUES (?, ?, ?, ?)
			 ON CONFLICT(entity_type, entity_id)
			 DO UPDATE SET revision_id = excluded.revision_id, updated_at = excluded.updated_at`,
			change.EntityType,
			change.EntityID,
			change.RevisionID,
			change.UpdatedAt.UTC().Format(time.RFC3339Nano),
		)
		if err != nil {
			return domain.PushResponse{}, err
		}

		response.Accepted = append(response.Accepted, change)
	}

	if err := tx.Commit(); err != nil {
		return domain.PushResponse{}, err
	}

	cursor, err := s.currentCursor(ctx)
	if err != nil {
		return domain.PushResponse{}, err
	}
	response.LatestCursor = cursor
	return response, nil
}

func (s *Store) PullChanges(ctx context.Context, req domain.PullRequest) (domain.PullResponse, error) {
	rows, err := s.db.QueryContext(
		ctx,
		`SELECT sequence, entity_type, entity_id, revision_id, base_revision_id, operation, payload, updated_at, device_id
		 FROM sync_changes
		 WHERE sequence > ?
		 ORDER BY sequence ASC
		 LIMIT ?`,
		req.Cursor,
		req.Limit+1,
	)
	if err != nil {
		return domain.PullResponse{}, err
	}
	defer rows.Close()

	response := domain.PullResponse{
		Changes: make([]domain.SyncChange, 0, req.Limit),
	}

	for rows.Next() {
		var (
			sequence       int64
			entityType     string
			entityID       string
			revisionID     string
			baseRevisionID string
			operation      string
			payload        string
			updatedAtRaw   string
			deviceID       string
		)
		if err := rows.Scan(
			&sequence,
			&entityType,
			&entityID,
			&revisionID,
			&baseRevisionID,
			&operation,
			&payload,
			&updatedAtRaw,
			&deviceID,
		); err != nil {
			return domain.PullResponse{}, err
		}

		if len(response.Changes) == req.Limit {
			response.HasMore = true
			break
		}

		updatedAt, err := time.Parse(time.RFC3339Nano, updatedAtRaw)
		if err != nil {
			return domain.PullResponse{}, err
		}

		response.Changes = append(response.Changes, domain.SyncChange{
			EntityType:     entityType,
			EntityID:       entityID,
			RevisionID:     revisionID,
			BaseRevisionID: baseRevisionID,
			Operation:      operation,
			UpdatedAt:      updatedAt,
			DeviceID:       deviceID,
			Payload:        json.RawMessage(payload),
		})
		response.NextCursor = sequence
	}

	if err := rows.Err(); err != nil {
		return domain.PullResponse{}, err
	}

	return response, nil
}

func (s *Store) SaveAITask(ctx context.Context, task domain.AITask) error {
	var completedAt any
	if task.CompletedAt != nil {
		completedAt = task.CompletedAt.UTC().Format(time.RFC3339Nano)
	}

	_, err := s.db.ExecContext(
		ctx,
		`INSERT INTO ai_tasks (id, kind, status, input_payload, output_payload, created_at, completed_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		task.ID,
		task.Kind,
		task.Status,
		string(task.InputPayload),
		string(task.OutputPayload),
		task.CreatedAt.UTC().Format(time.RFC3339Nano),
		completedAt,
	)
	return err
}

func (s *Store) currentCursor(ctx context.Context) (int64, error) {
	row := s.db.QueryRowContext(ctx, `SELECT COALESCE(MAX(sequence), 0) FROM sync_changes`)
	var cursor int64
	if err := row.Scan(&cursor); err != nil {
		return 0, err
	}
	return cursor, nil
}

func selectHead(ctx context.Context, tx *sql.Tx, entityType string, entityID string) (string, bool, error) {
	row := tx.QueryRowContext(
		ctx,
		`SELECT revision_id FROM entity_heads WHERE entity_type = ? AND entity_id = ?`,
		entityType,
		entityID,
	)
	var revisionID string
	if err := row.Scan(&revisionID); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", false, nil
		}
		return "", false, err
	}
	return revisionID, true, nil
}

func isUniqueConstraintError(err error) bool {
	return err != nil && strings.Contains(strings.ToLower(err.Error()), "constraint")
}
