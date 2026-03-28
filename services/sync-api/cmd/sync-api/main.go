package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"ai-developer/services/sync-api/internal/catalog"
	"ai-developer/services/sync-api/internal/api"
	"ai-developer/services/sync-api/internal/config"
	"ai-developer/services/sync-api/internal/service"
	sqlitestore "ai-developer/services/sync-api/internal/storage/sqlite"
)

func main() {
	cfg := config.Load()

	if err := os.MkdirAll(filepath.Dir(cfg.DatabasePath), 0o755); err != nil {
		slog.Error("create data directory", "error", err)
		os.Exit(1)
	}

	store, err := sqlitestore.Open(cfg.DatabasePath)
	if err != nil {
		slog.Error("open sqlite store", "error", err)
		os.Exit(1)
	}
	defer store.Close()

	if err := store.Migrate(context.Background()); err != nil {
		slog.Error("run migrations", "error", err)
		os.Exit(1)
	}

	catalogStore, err := catalog.Load()
	if err != nil {
		slog.Error("load catalog", "error", err)
		os.Exit(1)
	}

	svc := service.New(store, catalogStore)
	server := &http.Server{
		Addr:              cfg.Address,
		Handler:           api.NewHandler(svc),
		ReadTimeout:       10 * time.Second,
		ReadHeaderTimeout: 10 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	slog.Info("sync api listening", "addr", cfg.Address, "db", cfg.DatabasePath)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		slog.Error("server stopped", "error", err)
		os.Exit(1)
	}
}
