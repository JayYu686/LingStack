// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import '../../domain/models.dart';
import 'catalog_seed_types.dart';

const List<String> _defaultClients = [
  'Claude Desktop',
  'Cursor',
  'VS Code',
  'Continue',
  'Cherry Studio',
];

const String _mcpSpecsJson = r'''
[
  {
    "id": "mcp-backup",
    "title": "Backup MCP",
    "category": "development",
    "tags": [
      "Backup",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hexitex/MCP-Backup-Server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": true
  },
  {
    "id": "mcp-filestash",
    "title": "FileStash MCP",
    "category": "development",
    "tags": [
      "FileStash",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/mickael-kerjean/filestash/tree/master/server/plugin/plg_handler_mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-everything-search",
    "title": "Everything Search MCP",
    "category": "development",
    "tags": [
      "Everything Search",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/mamertofabian/mcp-everything-search",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-fast-filesystem-mcp",
    "title": "fast-filesystem-mcp MCP",
    "category": "development",
    "tags": [
      "fast-filesystem-mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/efforthye/fast-filesystem-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-llm-context",
    "title": "llm-context MCP",
    "category": "development",
    "tags": [
      "llm-context",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/cyberchitta/llm-context.py",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": true
  },
  {
    "id": "mcp-docker",
    "title": "Docker MCP",
    "category": "development",
    "tags": [
      "Docker",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/QuantGeekDev/docker-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": true
  },
  {
    "id": "mcp-gitlab",
    "title": "GitLab MCP",
    "category": "development",
    "tags": [
      "GitLab",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/modelcontextprotocol/servers/tree/main/src/gitlab",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITLAB_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-phabricator",
    "title": "Phabricator MCP",
    "category": "development",
    "tags": [
      "Phabricator",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/baba786/phabricator-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-gitingest-mcp",
    "title": "Gitingest-MCP MCP",
    "category": "development",
    "tags": [
      "Gitingest-MCP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/puravparab/Gitingest-MCP",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-microsoft-365",
    "title": "Microsoft 365 MCP",
    "category": "development",
    "tags": [
      "Microsoft 365",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/softeria/ms-365-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "MS_GRAPH_TOKEN"
    ],
    "featured": true
  },
  {
    "id": "mcp-duckdb",
    "title": "DuckDB MCP",
    "category": "development",
    "tags": [
      "DuckDB",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ktanaka101/mcp-server-duckdb",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": true
  },
  {
    "id": "mcp-excel",
    "title": "Excel MCP",
    "category": "development",
    "tags": [
      "Excel",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/haris-musa/excel-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": true
  },
  {
    "id": "mcp-mongodb",
    "title": "MongoDB MCP",
    "category": "development",
    "tags": [
      "MongoDB",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/kiliczsh/mcp-mongo-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "MONGODB_URI"
    ],
    "featured": false
  },
  {
    "id": "mcp-mongodb-lens",
    "title": "MongoDB Lens MCP",
    "category": "development",
    "tags": [
      "MongoDB Lens",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/furey/mongodb-lens",
    "transport": "stdio",
    "requiredEnvVars": [
      "MONGODB_URI"
    ],
    "featured": false
  },
  {
    "id": "mcp-mysql",
    "title": "MySQL MCP",
    "category": "development",
    "tags": [
      "MySQL",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/designcomputer/mysql_mcp_server",
    "transport": "stdio",
    "requiredEnvVars": [
      "MYSQL_DSN"
    ],
    "featured": false
  },
  {
    "id": "mcp-airtable",
    "title": "Airtable MCP",
    "category": "development",
    "tags": [
      "Airtable",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/domdomegg/airtable-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "AIRTABLE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-snowflake",
    "title": "Snowflake MCP",
    "category": "development",
    "tags": [
      "Snowflake",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/isaacwasserman/mcp-snowflake-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SNOWFLAKE_DSN"
    ],
    "featured": false
  },
  {
    "id": "mcp-dbutils",
    "title": "DBUtils MCP",
    "category": "development",
    "tags": [
      "DBUtils",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/donghao1393/mcp-dbutils",
    "transport": "stdio",
    "requiredEnvVars": [
      "POSTGRES_DSN"
    ],
    "featured": false
  },
  {
    "id": "mcp-tidb",
    "title": "TiDB MCP",
    "category": "development",
    "tags": [
      "TiDB",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/c4pt0r/mcp-server-tidb",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-nocodb",
    "title": "NocoDB MCP",
    "category": "development",
    "tags": [
      "NocoDB",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/edwinbernadus/nocodb-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-linear",
    "title": "Linear MCP",
    "category": "development",
    "tags": [
      "Linear",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/jerhadf/linear-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "LINEAR_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-ntfy",
    "title": "ntfy MCP",
    "category": "development",
    "tags": [
      "ntfy",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/gitmotion/ntfy-me-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-metoro",
    "title": "Metoro MCP",
    "category": "development",
    "tags": [
      "Metoro",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/metoro-io/metoro-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-raygun",
    "title": "Raygun MCP",
    "category": "development",
    "tags": [
      "Raygun",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/MindscapeHQ/mcp-server-raygun",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-sslmon",
    "title": "sslmon MCP",
    "category": "development",
    "tags": [
      "sslmon",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/firesh/sslmon-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-signoz",
    "title": "Signoz MCP",
    "category": "development",
    "tags": [
      "Signoz",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/DrDroidLab/signoz-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-victoriametrics",
    "title": "VictoriaMetrics MCP",
    "category": "development",
    "tags": [
      "VictoriaMetrics",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/VictoriaMetrics-Community/mcp-victoriametrics",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-puppeteer",
    "title": "Puppeteer MCP",
    "category": "development",
    "tags": [
      "Puppeteer",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/modelcontextprotocol/servers/tree/main/src/puppeteer",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-brave-search",
    "title": "Brave Search MCP",
    "category": "development",
    "tags": [
      "Brave Search",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/modelcontextprotocol/servers/tree/main/src/brave-search",
    "transport": "stdio",
    "requiredEnvVars": [
      "BRAVE_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-bright-data",
    "title": "Bright Data MCP",
    "category": "development",
    "tags": [
      "Bright Data",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/luminati-io/brightdata-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-dumpling-ai",
    "title": "Dumpling AI MCP",
    "category": "development",
    "tags": [
      "Dumpling AI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Dumpling-AI/mcp-server-dumplingai",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-kagi-search",
    "title": "Kagi Search MCP",
    "category": "development",
    "tags": [
      "Kagi Search",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ac3xx/mcp-servers-kagi",
    "transport": "stdio",
    "requiredEnvVars": [
      "KAGI_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-nytimes",
    "title": "NYTimes MCP",
    "category": "development",
    "tags": [
      "NYTimes",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/angheljf/nyt",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-google-news",
    "title": "Google News MCP",
    "category": "development",
    "tags": [
      "Google News",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ChanMeng666/server-google-news",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-scrapeless",
    "title": "Scrapeless MCP",
    "category": "development",
    "tags": [
      "Scrapeless",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/scrapeless-ai/scrapeless-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-search1api",
    "title": "Search1API MCP",
    "category": "development",
    "tags": [
      "Search1API",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/fatwang2/search1api-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-rivalsearchmcp",
    "title": "RivalSearchMCP MCP",
    "category": "development",
    "tags": [
      "RivalSearchMCP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/damionrashford/RivalSearchMCP",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-tavily",
    "title": "Tavily MCP",
    "category": "development",
    "tags": [
      "Tavily",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Tomatio13/mcp-server-tavily",
    "transport": "stdio",
    "requiredEnvVars": [
      "TAVILY_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-arxiv",
    "title": "ArXiv MCP",
    "category": "development",
    "tags": [
      "ArXiv",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/blazickjp/arxiv-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-paperswithcode",
    "title": "PapersWithCode MCP",
    "category": "development",
    "tags": [
      "PapersWithCode",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hbg/mcp-paperswithcode",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-playwright",
    "title": "Playwright MCP",
    "category": "development",
    "tags": [
      "Playwright",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/executeautomation/mcp-playwright",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-websearch",
    "title": "Websearch MCP",
    "category": "development",
    "tags": [
      "Websearch",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/mnhlt/WebSearch-MCP",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-browser-control",
    "title": "Browser Control MCP",
    "category": "development",
    "tags": [
      "Browser Control",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/eyalzh/browser-control-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-apify-actors",
    "title": "Apify Actors MCP",
    "category": "development",
    "tags": [
      "Apify Actors",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/apify/actors-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-rag-web-browser",
    "title": "RAG Web Browser MCP",
    "category": "development",
    "tags": [
      "RAG Web Browser",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/apify/mcp-server-rag-web-browser",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-skyvern",
    "title": "Skyvern MCP",
    "category": "development",
    "tags": [
      "Skyvern",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Skyvern-AI/skyvern/tree/main/integrations/mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-ihor-sokoliuk-mcp-searxng",
    "title": "Ihor-Sokoliuk/MCP-SearXNG MCP",
    "category": "development",
    "tags": [
      "Ihor-Sokoliuk/MCP-SearXNG",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ihor-sokoliuk/mcp-searxng",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-mcp-server-webcrawl",
    "title": "mcp-server-webcrawl MCP",
    "category": "development",
    "tags": [
      "mcp-server-webcrawl",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/pragmar/mcp-server-webcrawl",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-campertunity",
    "title": "Campertunity MCP",
    "category": "development",
    "tags": [
      "Campertunity",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/campertunity/mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-google-maps",
    "title": "Google Maps MCP",
    "category": "development",
    "tags": [
      "Google Maps",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/modelcontextprotocol/servers/tree/main/src/google-maps",
    "transport": "stdio",
    "requiredEnvVars": [
      "GOOGLE_MAPS_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-iplocate",
    "title": "IPLocate MCP",
    "category": "development",
    "tags": [
      "IPLocate",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/iplocate/mcp-server-iplocate",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-ip2location-io",
    "title": "IP2Location.io MCP",
    "category": "development",
    "tags": [
      "IP2Location.io",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ip2location/mcp-ip2location-io",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-qgis",
    "title": "QGIS MCP",
    "category": "development",
    "tags": [
      "QGIS",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/jjsantos01/qgis_mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-agent-mindshare",
    "title": "Agent Mindshare MCP",
    "category": "development",
    "tags": [
      "Agent Mindshare",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://agentmindshare.com",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-fathom-analytics",
    "title": "Fathom Analytics MCP",
    "category": "development",
    "tags": [
      "Fathom Analytics",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/mackenly/mcp-fathom-analytics",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-facebook-ads",
    "title": "Facebook Ads MCP",
    "category": "development",
    "tags": [
      "Facebook Ads",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/gomarble-ai/facebook-ads-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-google-ads",
    "title": "Google Ads MCP",
    "category": "development",
    "tags": [
      "Google Ads",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/gomarble-ai/google-ads-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-apple-books",
    "title": "Apple Books MCP",
    "category": "development",
    "tags": [
      "Apple Books",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/vgnshiyer/apple-books-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-ebook-mcp",
    "title": "eBook-mcp MCP",
    "category": "development",
    "tags": [
      "eBook-mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/onebirdrocks/ebook-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-apple-notes",
    "title": "Apple Notes MCP",
    "category": "development",
    "tags": [
      "Apple Notes",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/sirmews/apple-notes-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-slite",
    "title": "Slite MCP",
    "category": "development",
    "tags": [
      "Slite",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/fajarmf/slite-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-todoist",
    "title": "Todoist MCP",
    "category": "development",
    "tags": [
      "Todoist",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/abhiz123/todoist-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "TODOIST_API_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-google-keep",
    "title": "Google Keep MCP",
    "category": "development",
    "tags": [
      "Google Keep",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/feuerdev/keep-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-shell",
    "title": "Shell MCP",
    "category": "development",
    "tags": [
      "Shell",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/rusiaaman/wcgw",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-windows-cli",
    "title": "Windows CLI MCP",
    "category": "development",
    "tags": [
      "Windows CLI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/SimonB97/win-cli-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-windows-control",
    "title": "Windows Control MCP",
    "category": "development",
    "tags": [
      "Windows Control",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Cheffromspace/nutjs-windows-control",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-command-line",
    "title": "Command Line MCP",
    "category": "development",
    "tags": [
      "Command Line",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/phialsbasement/cmd-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-apple-shortcuts",
    "title": "Apple Shortcuts MCP",
    "category": "development",
    "tags": [
      "Apple Shortcuts",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/recursechat/mcp-server-apple-shortcuts",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-bluesky",
    "title": "BlueSky MCP",
    "category": "development",
    "tags": [
      "BlueSky",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/keturiosakys/bluesky-context-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-spotify",
    "title": "Spotify MCP",
    "category": "development",
    "tags": [
      "Spotify",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/varunneal/spotify-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SPOTIFY_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-tiktok",
    "title": "TikTok MCP",
    "category": "development",
    "tags": [
      "TikTok",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Seym0n/tiktok-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-coinmarket",
    "title": "CoinMarket MCP",
    "category": "development",
    "tags": [
      "CoinMarket",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/anjor/coinmarket-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-mercado-pago",
    "title": "Mercado Pago MCP",
    "category": "development",
    "tags": [
      "Mercado Pago",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://mcp.mercadopago.com/",
    "transport": "streamable_http",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-ancestry",
    "title": "Ancestry MCP",
    "category": "development",
    "tags": [
      "Ancestry",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/reeeeemo/ancestry-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-probe-dev",
    "title": "Probe.dev MCP",
    "category": "development",
    "tags": [
      "Probe.dev",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://mcp.probe.dev",
    "transport": "streamable_http",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-opennutrition",
    "title": "OpenNutrition MCP",
    "category": "development",
    "tags": [
      "OpenNutrition",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/deadletterq/mcp-opennutrition",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-congress",
    "title": "Congress MCP",
    "category": "development",
    "tags": [
      "Congress",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/amurshak/congressMCP",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-agentset-ai",
    "title": "Agentset AI MCP",
    "category": "development",
    "tags": [
      "Agentset AI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/agentset-ai/mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-openai",
    "title": "OpenAI MCP",
    "category": "development",
    "tags": [
      "OpenAI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/pierrebrunelle/mcp-server-openai",
    "transport": "stdio",
    "requiredEnvVars": [
      "OPENAI_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-openai-compatible-chat",
    "title": "OpenAI Compatible Chat MCP",
    "category": "development",
    "tags": [
      "OpenAI Compatible Chat",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/pyroprompts/any-chat-completions-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "OPENAI_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-llamacloud",
    "title": "LlamaCloud MCP",
    "category": "development",
    "tags": [
      "LlamaCloud",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/run-llama/mcp-server-llamacloud",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-huggingface-spaces",
    "title": "HuggingFace Spaces MCP",
    "category": "development",
    "tags": [
      "HuggingFace Spaces",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/evalstate/mcp-hfspace",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-piapi",
    "title": "PiAPI MCP",
    "category": "development",
    "tags": [
      "PiAPI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/apinetwork/piapi-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-chronulus-ai",
    "title": "Chronulus AI MCP",
    "category": "development",
    "tags": [
      "Chronulus AI",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ChronulusAI/chronulus-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-creatify",
    "title": "Creatify MCP",
    "category": "development",
    "tags": [
      "Creatify",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/TSavo/creatify-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-centralmind-gateway",
    "title": "CentralMind/Gateway MCP",
    "category": "development",
    "tags": [
      "CentralMind/Gateway",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/centralmind/gateway",
    "transport": "stdio",
    "requiredEnvVars": [
      "MYSQL_DSN"
    ],
    "featured": false
  },
  {
    "id": "mcp-octocode",
    "title": "Octocode MCP",
    "category": "development",
    "tags": [
      "Octocode",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/bgauryy/octocode-mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-openapi-schema-explorer",
    "title": "OpenAPI Schema Explorer MCP",
    "category": "development",
    "tags": [
      "OpenAPI Schema Explorer",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/kadykov/mcp-openapi-schema-explorer",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-openrpc",
    "title": "OpenRPC MCP",
    "category": "development",
    "tags": [
      "OpenRPC",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/shanejonas/openrpc-mpc-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-postman",
    "title": "Postman MCP",
    "category": "development",
    "tags": [
      "Postman",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/delano/postman-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "POSTMAN_API_KEY"
    ],
    "featured": false
  },
  {
    "id": "mcp-figma",
    "title": "Figma MCP",
    "category": "development",
    "tags": [
      "Figma",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/GLips/Figma-Context-MCP",
    "transport": "stdio",
    "requiredEnvVars": [
      "FIGMA_ACCESS_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-vscode-devtools",
    "title": "VSCode Devtools MCP",
    "category": "development",
    "tags": [
      "VSCode Devtools",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/biegehydra/BifrostMCP",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-bucket",
    "title": "Bucket MCP",
    "category": "development",
    "tags": [
      "Bucket",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/bucketco/bucket-javascript-sdk/tree/main/packages/cli#model-context-protocol",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-edgeone-pages",
    "title": "EdgeOne Pages MCP",
    "category": "development",
    "tags": [
      "EdgeOne Pages",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/TencentEdgeOne/edgeone-pages-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-aymericzip-intlayer",
    "title": "aymericzip/intlayer MCP",
    "category": "development",
    "tags": [
      "aymericzip/intlayer",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/aymericzip/intlayer",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-tom28881-mcp-jira-server",
    "title": "tom28881/mcp-jira-server MCP",
    "category": "development",
    "tags": [
      "tom28881/mcp-jira-server",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/tom28881/mcp-jira-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-maven-tools-mcp",
    "title": "Maven Tools MCP MCP",
    "category": "development",
    "tags": [
      "Maven Tools MCP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/arvindand/maven-tools-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-defanglabs-defang",
    "title": "DefangLabs/defang MCP",
    "category": "development",
    "tags": [
      "DefangLabs/defang",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/DefangLabs/defang",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-vegalite",
    "title": "VegaLite MCP",
    "category": "development",
    "tags": [
      "VegaLite",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/isaacwasserman/mcp-vegalite-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-chart",
    "title": "Chart MCP",
    "category": "development",
    "tags": [
      "Chart",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/antvis/mcp-server-chart",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-echarts",
    "title": "ECharts MCP",
    "category": "development",
    "tags": [
      "ECharts",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hustcc/mcp-echarts",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-mermaid",
    "title": "Mermaid MCP",
    "category": "development",
    "tags": [
      "Mermaid",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hustcc/mcp-mermaid",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-unified-diff-mcp",
    "title": "unified-diff-mcp MCP",
    "category": "development",
    "tags": [
      "unified-diff-mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/gorosun/unified-diff-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-keycloak",
    "title": "Keycloak MCP",
    "category": "development",
    "tags": [
      "Keycloak",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/ChristophEnglisch/keycloak-model-context-protocol",
    "transport": "stdio",
    "requiredEnvVars": [
      "KEYCLOAK_BASE_URL",
      "KEYCLOAK_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-semgrep",
    "title": "Semgrep MCP",
    "category": "development",
    "tags": [
      "Semgrep",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/semgrep/mcp",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-microsoft-entra-id",
    "title": "Microsoft Entra ID MCP",
    "category": "development",
    "tags": [
      "Microsoft Entra ID",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hieuttmmo/entraid-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-osv",
    "title": "OSV MCP",
    "category": "development",
    "tags": [
      "OSV",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/StacklokLabs/osv-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-cdsp",
    "title": "CDSP MCP",
    "category": "development",
    "tags": [
      "CDSP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/sanyambassi/ciphertrust-manager-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-cakm",
    "title": "CAKM MCP",
    "category": "development",
    "tags": [
      "CAKM",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/sanyambassi/thales-cdsp-cakm-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-crdp",
    "title": "CRDP MCP",
    "category": "development",
    "tags": [
      "CRDP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/sanyambassi/thales-cdsp-crdp-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-csm",
    "title": "CSM MCP",
    "category": "development",
    "tags": [
      "CSM",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/sanyambassi/thales-cdsp-csm-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-coreflux-mqtt",
    "title": "Coreflux MQTT MCP",
    "category": "development",
    "tags": [
      "Coreflux MQTT",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/CorefluxCommunity/CorefluxMCPServer",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-mcp-open-library",
    "title": "MCP Open Library MCP",
    "category": "development",
    "tags": [
      "MCP Open Library",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/8enSmith/mcp-open-library",
    "transport": "stdio",
    "requiredEnvVars": [
      "SERVICE_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-mercado-libre",
    "title": "Mercado Libre MCP",
    "category": "development",
    "tags": [
      "Mercado Libre",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://mcp.mercadolibre.com/",
    "transport": "streamable_http",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-bagel",
    "title": "Bagel MCP",
    "category": "development",
    "tags": [
      "Bagel",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Extelligence-ai/bagel",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-https-mcp-1mcpserver-com-mcp",
    "title": "https://mcp.1mcpserver.com/mcp/ MCP",
    "category": "development",
    "tags": [
      "https://mcp.1mcpserver.com/mcp/",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://mcp.1mcpserver.com/mcp/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-e2b",
    "title": "E2B MCP",
    "category": "development",
    "tags": [
      "E2B",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://e2b.dev",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-element-fm",
    "title": "ELEMENT.FM MCP",
    "category": "development",
    "tags": [
      "ELEMENT.FM",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://element.fm",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-exa",
    "title": "Exa MCP",
    "category": "development",
    "tags": [
      "Exa",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://exa.ai",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-fewsats",
    "title": "Fewsats MCP",
    "category": "development",
    "tags": [
      "Fewsats",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://fewsats.com",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-firecrawl",
    "title": "Firecrawl MCP",
    "category": "development",
    "tags": [
      "Firecrawl",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://firecrawl.dev",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-inbox-zero",
    "title": "Inbox Zero MCP",
    "category": "development",
    "tags": [
      "Inbox Zero",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://www.getinboxzero.com",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-ref-tools",
    "title": "ref.tools MCP",
    "category": "development",
    "tags": [
      "ref.tools",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://ref.tools/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-riza",
    "title": "Riza MCP",
    "category": "development",
    "tags": [
      "Riza",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://riza.io",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-scrapezy",
    "title": "Scrapezy MCP",
    "category": "development",
    "tags": [
      "Scrapezy",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://scrapezy.com",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-screenshotone",
    "title": "ScreenshotOne MCP",
    "category": "development",
    "tags": [
      "ScreenshotOne",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://screenshotone.com/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-supadata",
    "title": "Supadata MCP",
    "category": "growth",
    "tags": [
      "Supadata",
      "MCP",
      "增长",
      "工具接入"
    ],
    "baseUrl": "https://supadata.ai",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-starrocks",
    "title": "StarRocks MCP",
    "category": "development",
    "tags": [
      "StarRocks",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://www.starrocks.io/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-thirdweb",
    "title": "Thirdweb MCP",
    "category": "development",
    "tags": [
      "Thirdweb",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://thirdweb.com/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-tl-dv",
    "title": "tl;dv MCP",
    "category": "development",
    "tags": [
      "tl;dv",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://tldv.io",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-trade-agent",
    "title": "Trade Agent MCP",
    "category": "development",
    "tags": [
      "Trade Agent",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://thetradeagent.ai/",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-unifai-network",
    "title": "UnifAI Network MCP",
    "category": "development",
    "tags": [
      "UnifAI Network",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://unifai.network",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-urldna",
    "title": "urlDNA MCP",
    "category": "development",
    "tags": [
      "urlDNA",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://urlDNA.io",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-allinonemcp",
    "title": "AllInOneMCP MCP",
    "category": "development",
    "tags": [
      "AllInOneMCP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/particlefuture/MCPDiscovery",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-schemaflow",
    "title": "SchemaFlow MCP",
    "category": "development",
    "tags": [
      "SchemaFlow",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://schemaflow.dev",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-searxng",
    "title": "SearXNG MCP",
    "category": "development",
    "tags": [
      "SearXNG",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://docs.searxng.org",
    "transport": "stdio",
    "requiredEnvVars": [
      "GITHUB_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-spotify-player",
    "title": "Spotify Player MCP",
    "category": "development",
    "tags": [
      "Spotify Player",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/vsaez/mcp-spotify-player",
    "transport": "stdio",
    "requiredEnvVars": [
      "SPOTIFY_TOKEN"
    ],
    "featured": false
  },
  {
    "id": "mcp-awesome-mcp-clients",
    "title": "awesome-mcp-clients MCP",
    "category": "development",
    "tags": [
      "awesome-mcp-clients",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/punkpeye/awesome-mcp-clients/",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-ai-gateway",
    "title": "AI gateway MCP",
    "category": "development",
    "tags": [
      "AI gateway",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://glama.ai/gateway",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-quickstart-to-mcp",
    "title": "Quickstart to MCP MCP",
    "category": "development",
    "tags": [
      "Quickstart to MCP",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://glama.ai/blog/2024-11-25-model-context-protocol-quickstart",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-reddit-r-mcp",
    "title": "Reddit: r/mcp MCP",
    "category": "development",
    "tags": [
      "Reddit: r/mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://www.reddit.com/r/mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-microsoft-playwright-mcp",
    "title": "microsoft/playwright-mcp MCP",
    "category": "development",
    "tags": [
      "microsoft/playwright-mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/microsoft/playwright-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-flux159-mcp-server-kubernetes",
    "title": "flux159/mcp-server-kubernetes MCP",
    "category": "development",
    "tags": [
      "flux159/mcp-server-kubernetes",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/Flux159/mcp-server-kubernetes",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-hardik-id-azure-resource-graph-mcp-server",
    "title": "hardik-id/azure-resource-graph-mcp-server MCP",
    "category": "development",
    "tags": [
      "hardik-id/azure-resource-graph-mcp-server",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/hardik-id/azure-resource-graph-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-jdubois-azure-cli-mcp",
    "title": "jdubois/azure-cli-mcp MCP",
    "category": "development",
    "tags": [
      "jdubois/azure-cli-mcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/jdubois/azure-cli-mcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-manusa-kubernetes-mcp-server",
    "title": "manusa/Kubernetes MCP Server MCP",
    "category": "development",
    "tags": [
      "manusa/Kubernetes MCP Server",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/manusa/kubernetes-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-nwiizo-tfmcp",
    "title": "nwiizo/tfmcp MCP",
    "category": "development",
    "tags": [
      "nwiizo/tfmcp",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/nwiizo/tfmcp",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-rohitg00-kubectl-mcp-server",
    "title": "rohitg00/kubectl-mcp-server MCP",
    "category": "development",
    "tags": [
      "rohitg00/kubectl-mcp-server",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/rohitg00/kubectl-mcp-server",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-strowk-mcp-k8s-go",
    "title": "strowk/mcp-k8s-go MCP",
    "category": "development",
    "tags": [
      "strowk/mcp-k8s-go",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/strowk/mcp-k8s-go",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  },
  {
    "id": "mcp-thunderboltsid-mcp-nutanix",
    "title": "thunderboltsid/mcp-nutanix MCP",
    "category": "development",
    "tags": [
      "thunderboltsid/mcp-nutanix",
      "MCP",
      "开发",
      "工具接入"
    ],
    "baseUrl": "https://github.com/thunderboltsid/mcp-nutanix",
    "transport": "stdio",
    "requiredEnvVars": [],
    "featured": false
  }
]
''';

List<McpSeedBundle> buildMcpSeedsExpanded(String stamp) {
  final specs = (jsonDecode(_mcpSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedMcp(spec, stamp)).toList();
}

McpSeedBundle _buildExpandedMcp(Map<String, dynamic> spec, String stamp) {
  final category = spec['category'] as String? ?? 'development';
  final envs = List<String>.from(
    spec['requiredEnvVars'] as List<dynamic>? ?? const [],
  );

  return buildMcpSeed(
    id: spec['id'] as String? ?? '',
    title: spec['title'] as String? ?? '',
    summary: _mcpSummary(spec),
    scenario: _mcpScenario(category),
    primaryCategory: _mcpCategory(category),
    difficulty: _mcpDifficulty(spec),
    tags: List<String>.from(spec['tags'] as List<dynamic>? ?? const []),
    capabilitiesSummary: _mcpSummary(spec),
    supportedClients: _defaultClients,
    requiredEnvVars: envs,
    setupSteps: const [
      '先打开参考链接，确认官方安装方式和权限要求',
      '把配置模板里的占位地址、包名和环境变量替换成你的真实值',
      '先用最小权限和测试环境验证，再接到正式工作流里',
    ],
    configTemplate: _mcpConfig(spec, envs),
    safetyNotes: _mcpSafety(envs),
    transport: spec['transport'] as String? ?? 'stdio',
    baseUrl: spec['baseUrl'] as String? ?? '',
    featured: spec['featured'] as bool? ?? false,
    stamp: stamp,
  );
}

ResourceCategory _mcpCategory(String category) {
  switch (category) {
    case 'office':
      return ResourceCategory.office;
    case 'content':
      return ResourceCategory.content;
    case 'learning':
      return ResourceCategory.learning;
    case 'growth':
      return ResourceCategory.growth;
    default:
      return ResourceCategory.development;
  }
}

String _mcpScenario(String category) {
  switch (category) {
    case 'office':
      return '办公协作';
    case 'content':
      return '内容创作';
    case 'learning':
      return '学习研究';
    case 'growth':
      return '运营增长';
    default:
      return '开发编程';
  }
}

ResourceDifficulty _mcpDifficulty(Map<String, dynamic> spec) {
  final transport = spec['transport'] as String? ?? 'stdio';
  final title = spec['title'] as String? ?? '';
  final category = spec['category'] as String? ?? 'development';
  if (transport == 'streamable_http') {
    return ResourceDifficulty.intermediate;
  }
  if (title.contains('Semgrep') ||
      title.contains('Keycloak') ||
      title.contains('Docker')) {
    return ResourceDifficulty.advanced;
  }
  return category == 'development'
      ? ResourceDifficulty.intermediate
      : ResourceDifficulty.beginner;
}

String _mcpSummary(Map<String, dynamic> spec) {
  final category = spec['category'] as String? ?? 'development';
  final title = spec['title'] as String? ?? '';
  if (category == 'office') {
    return '把$title接到 AI 客户端里，适合处理文档、任务、协作和消息相关上下文。';
  }
  if (category == 'content') {
    return '把$title接到 AI 客户端里，适合内容生产、素材处理和媒体相关工作流。';
  }
  if (category == 'growth') {
    return '把$title接到 AI 客户端里，适合分析增长数据、广告与运营动作。';
  }
  if (category == 'learning') {
    return '把$title接到 AI 客户端里，适合查资料、做研究和整理知识。';
  }
  return '把$title接到 AI 客户端里，适合让模型直接访问开发、数据或自动化工具。';
}

String _mcpSafety(List<String> envs) {
  if (envs.isEmpty) {
    return '先确认它会访问哪些数据，再决定是否放进常用客户端里；不要把不需要的目录、仓库或生产环境直接开放给模型。';
  }
  return '优先使用最小权限的 Token 或测试账号；只有在确认权限边界、审计方式和回滚手段后，再接入正式环境。';
}

String _mcpConfig(Map<String, dynamic> spec, List<String> envs) {
  final id = spec['id'] as String? ?? 'mcp-server';
  final transport = spec['transport'] as String? ?? 'stdio';
  final serverKey = id.replaceFirst('mcp-', '');
  final placeholder = envs.isEmpty ? '' : r'${' + envs.first + '}';

  if (transport == 'streamable_http') {
    final headerBlock = envs.isEmpty
        ? ''
        : ',\n      "headers": {\n        "Authorization": "Bearer ' +
              placeholder +
              '"\n      }';
    return '''{
  "mcpServers": {
    "$serverKey": {
      "type": "streamable_http",
      "url": "https://your-mcp-gateway.example/$serverKey"$headerBlock
    }
  }
}''';
  }

  final envBlock = envs.isEmpty
      ? ''
      : ',\n      "env": {\n' +
            envs
                .map((env) => '        "' + env + '": "' + r'${' + env + '}"')
                .join(',\n') +
            '\n      }';

  return '''{
  "mcpServers": {
    "$serverKey": {
      "command": "npx",
      "args": [
        "-y",
        "REPLACE_WITH_OFFICIAL_PACKAGE"
      ]$envBlock
    }
  }
}''';
}
