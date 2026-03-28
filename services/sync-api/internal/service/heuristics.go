package service

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"regexp"
	"slices"
	"strings"

	"ai-developer/services/sync-api/internal/domain"
)

var tokenPattern = regexp.MustCompile(`[A-Za-z_][A-Za-z0-9_]{2,}`)

func buildSuggestion(kind string, title string, content string, existingTags []string) domain.AISuggestion {
	lines := strings.Count(content, "\n") + 1
	tokens := tokenPattern.FindAllString(strings.ToLower(content), -1)
	frequency := map[string]int{}
	for _, token := range tokens {
		switch token {
		case "func", "return", "const", "type", "class", "import", "from", "package", "var", "let", "public", "private":
			continue
		default:
			frequency[token]++
		}
	}

	type pair struct {
		token string
		count int
	}

	candidates := make([]pair, 0, len(frequency))
	for token, count := range frequency {
		candidates = append(candidates, pair{token: token, count: count})
	}
	slices.SortFunc(candidates, func(a pair, b pair) int {
		if a.count == b.count {
			return strings.Compare(a.token, b.token)
		}
		return b.count - a.count
	})

	tags := make([]string, 0, 5)
	baseKind := strings.ToLower(strings.TrimSpace(kind))
	if baseKind != "" {
		tags = append(tags, baseKind)
	}
	for _, tag := range existingTags {
		cleaned := strings.ToLower(strings.TrimSpace(tag))
		if cleaned != "" && !slices.Contains(tags, cleaned) {
			tags = append(tags, cleaned)
		}
	}
	for _, candidate := range candidates {
		if len(tags) >= 5 {
			break
		}
		if !slices.Contains(tags, candidate.token) {
			tags = append(tags, candidate.token)
		}
	}

	titlePart := strings.TrimSpace(title)
	if titlePart == "" {
		titlePart = fmt.Sprintf("%s asset", baseKind)
	}

	summary := fmt.Sprintf("%s with %d lines and focus on %s.", titlePart, lines, strings.Join(tags, ", "))
	return domain.AISuggestion{
		Summary:    summary,
		Tags:       tags,
		Confidence: 0.62,
	}
}

func newID() string {
	buffer := make([]byte, 16)
	if _, err := rand.Read(buffer); err != nil {
		panic(err)
	}
	return hex.EncodeToString(buffer)
}
