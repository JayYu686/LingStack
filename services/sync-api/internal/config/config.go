package config

import "os"

type Config struct {
	Address      string
	DatabasePath string
}

func Load() Config {
	return Config{
		Address:      getEnv("SYNC_API_ADDR", ":8080"),
		DatabasePath: getEnv("SYNC_API_DB_PATH", "data/sync.db"),
	}
}

func getEnv(key string, fallback string) string {
	if value, ok := os.LookupEnv(key); ok && value != "" {
		return value
	}
	return fallback
}
