package domain

type CatalogBootstrap struct {
	Version         string                 `json:"version"`
	GeneratedAt     string                 `json:"generatedAt"`
	Resources       []CatalogResource      `json:"resources"`
	PromptDetails   []PromptResourceDetail `json:"promptDetails"`
	SkillDetails    []SkillResourceDetail  `json:"skillDetails"`
	MCPDetails      []MCPResourceDetail    `json:"mcpDetails"`
	Collections     []CatalogCollection    `json:"collections"`
	CollectionItems []CollectionItem       `json:"collectionItems"`
}

type CatalogResource struct {
	ID                 string   `json:"id"`
	Type               string   `json:"type"`
	Title              string   `json:"title"`
	Summary            string   `json:"summary"`
	Scenario           string   `json:"scenario"`
	PrimaryCategory    string   `json:"primaryCategory"`
	Difficulty         string   `json:"difficulty"`
	Tags               []string `json:"tags"`
	PrimaryActionLabel string   `json:"primaryActionLabel"`
	IsFeatured         bool     `json:"isFeatured"`
	CreatedAt          string   `json:"createdAt"`
	UpdatedAt          string   `json:"updatedAt"`
}

type PromptVariable struct {
	Name         string   `json:"name"`
	Type         string   `json:"type"`
	Description  string   `json:"description"`
	DefaultValue string   `json:"defaultValue"`
	Options      []string `json:"options"`
}

type PromptResourceDetail struct {
	ResourceID      string           `json:"resourceId"`
	TemplateBody    string           `json:"templateBody"`
	Variables       []PromptVariable `json:"variables"`
	WhenToUse       string           `json:"whenToUse"`
	AvoidWhen       string           `json:"avoidWhen"`
	ExampleInput    string           `json:"exampleInput"`
	ExampleOutput   string           `json:"exampleOutput"`
	SupportedModels []string         `json:"supportedModels"`
}

type SkillResourceDetail struct {
	ResourceID        string         `json:"resourceId"`
	CapabilitySummary string         `json:"capabilitySummary"`
	InputRequirements []string       `json:"inputRequirements"`
	UsageSteps        []string       `json:"usageSteps"`
	SupportedModels   []string       `json:"supportedModels"`
	CopyPayload       string         `json:"copyPayload"`
	RawSchema         map[string]any `json:"rawSchema"`
	ProviderAdapters  map[string]any `json:"providerAdapters"`
	ExampleCode       string         `json:"exampleCode"`
	ExampleLanguage   string         `json:"exampleLanguage"`
}

type MCPResourceDetail struct {
	ResourceID          string   `json:"resourceId"`
	CapabilitiesSummary string   `json:"capabilitiesSummary"`
	SupportedClients    []string `json:"supportedClients"`
	RequiredEnvVars     []string `json:"requiredEnvVars"`
	SetupSteps          []string `json:"setupSteps"`
	ConfigTemplate      string   `json:"configTemplate"`
	SafetyNotes         string   `json:"safetyNotes"`
	Transport           string   `json:"transport"`
	BaseURL             string   `json:"baseUrl"`
}

type CatalogCollection struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Subtitle    string `json:"subtitle"`
	Description string `json:"description"`
	IconKey     string `json:"iconKey"`
	SortOrder   int    `json:"sortOrder"`
}

type CollectionItem struct {
	CollectionID string `json:"collectionId"`
	ResourceID   string `json:"resourceId"`
	SortOrder    int    `json:"sortOrder"`
}

type CatalogResourceEnvelope struct {
	Resource     CatalogResource       `json:"resource"`
	PromptDetail *PromptResourceDetail `json:"promptDetail,omitempty"`
	SkillDetail  *SkillResourceDetail  `json:"skillDetail,omitempty"`
	MCPDetail    *MCPResourceDetail    `json:"mcpDetail,omitempty"`
}
