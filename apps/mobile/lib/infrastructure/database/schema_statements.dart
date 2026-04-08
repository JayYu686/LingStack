const List<String> schemaStatements = [
  '''
  CREATE TABLE IF NOT EXISTS catalog_resources (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    source TEXT NOT NULL,
    title TEXT NOT NULL,
    summary TEXT NOT NULL,
    scenario TEXT NOT NULL,
    primary_category TEXT NOT NULL DEFAULT 'other',
    origin_resource_id TEXT,
    difficulty TEXT NOT NULL,
    tags_json TEXT NOT NULL,
    primary_action_label TEXT NOT NULL,
    is_featured INTEGER NOT NULL,
    quality_tier TEXT NOT NULL DEFAULT 'community',
    quality_score INTEGER NOT NULL DEFAULT 60,
    quality_reasons_json TEXT NOT NULL DEFAULT '[]',
    use_cases_json TEXT NOT NULL DEFAULT '[]',
    avoid_cases_json TEXT NOT NULL DEFAULT '[]',
    verified_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS prompt_resource_details (
    resource_id TEXT PRIMARY KEY,
    template_body TEXT NOT NULL,
    variables_json TEXT NOT NULL,
    when_to_use TEXT NOT NULL,
    avoid_when TEXT NOT NULL,
    example_input TEXT NOT NULL,
    example_output TEXT NOT NULL,
    supported_models_json TEXT NOT NULL,
    helper_notes_json TEXT NOT NULL DEFAULT '[]',
    required_variable_names_json TEXT NOT NULL DEFAULT '[]'
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS skill_resource_details (
    resource_id TEXT PRIMARY KEY,
    capability_summary TEXT NOT NULL,
    input_requirements_json TEXT NOT NULL,
    usage_steps_json TEXT NOT NULL,
    supported_models_json TEXT NOT NULL,
    copy_payload TEXT NOT NULL,
    raw_schema_json TEXT NOT NULL,
    provider_adapters_json TEXT NOT NULL,
    example_code TEXT NOT NULL,
    example_language TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS mcp_resource_details (
    resource_id TEXT PRIMARY KEY,
    capabilities_summary TEXT NOT NULL,
    supported_clients_json TEXT NOT NULL,
    required_env_vars_json TEXT NOT NULL,
    setup_steps_json TEXT NOT NULL,
    config_template TEXT NOT NULL,
    safety_notes TEXT NOT NULL,
    transport TEXT NOT NULL,
    base_url TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS resource_collections (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_key TEXT NOT NULL,
    sort_order INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS resource_collection_items (
    collection_id TEXT NOT NULL,
    resource_id TEXT NOT NULL,
    sort_order INTEGER NOT NULL,
    PRIMARY KEY (collection_id, resource_id)
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS favorite_resources (
    resource_id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS imported_resources (
    resource_id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS catalog_sync_state (
    singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
    version TEXT NOT NULL,
    source TEXT NOT NULL,
    last_synced_at TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS prompt_usage_records (
    resource_id TEXT PRIMARY KEY,
    last_values_json TEXT NOT NULL,
    copied_at TEXT,
    last_used_at TEXT,
    use_count INTEGER NOT NULL DEFAULT 0
  )
  ''',
];
