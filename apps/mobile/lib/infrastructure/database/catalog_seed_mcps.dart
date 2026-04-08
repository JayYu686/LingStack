import '../../domain/models.dart';
import 'catalog_seed_types.dart';

List<McpSeedBundle> buildMcpSeeds(String stamp) {
  McpSeedBundle mcp({
    required String id,
    required String title,
    required String summary,
    required String scenario,
    required ResourceDifficulty difficulty,
    required List<String> tags,
    required String capabilitiesSummary,
    required List<String> supportedClients,
    required List<String> requiredEnvVars,
    required List<String> setupSteps,
    required String configTemplate,
    required String safetyNotes,
    required String transport,
    required String baseUrl,
    bool featured = false,
  }) {
    return buildMcpSeed(
      id: id,
      title: title,
      summary: summary,
      scenario: scenario,
      difficulty: difficulty,
      tags: tags,
      capabilitiesSummary: capabilitiesSummary,
      supportedClients: supportedClients,
      requiredEnvVars: requiredEnvVars,
      setupSteps: setupSteps,
      configTemplate: configTemplate,
      safetyNotes: safetyNotes,
      transport: transport,
      baseUrl: baseUrl,
      featured: featured,
      stamp: stamp,
    );
  }

  return [
    mcp(
      id: 'mcp-github',
      title: 'GitHub MCP 服务',
      summary: '让 AI 读取仓库、Issue、PR、提交记录和代码上下文，适合开发协作。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['GitHub', '代码', '协作'],
      capabilitiesSummary: '适合代码审查、Issue 追踪、仓库导航和 PR 处理。',
      supportedClients: const [
        'Claude Desktop',
        'Cherry Studio',
        'Cline',
        'Continue',
        'Cursor',
      ],
      requiredEnvVars: const ['GITHUB_TOKEN'],
      setupSteps: const [
        '准备最小权限的 GitHub Token',
        '把配置模板加入支持 MCP 的客户端',
        '重启客户端并验证仓库读取能力',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "github": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/github",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '优先使用最小权限 Token，只开放真正需要访问的仓库范围。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/github/github-mcp-server',
      featured: true,
    ),
    mcp(
      id: 'mcp-filesystem',
      title: '本地文件 MCP',
      summary: '让 AI 读取本地目录、文件和文档，适合知识整理与项目上下文读取。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['文件系统', '本地文档', '项目上下文'],
      capabilitiesSummary: '适合读取项目文档、规范、笔记和代码仓根目录附近文件。',
      supportedClients: const ['Claude Desktop', 'Cline', 'Continue', 'Cursor'],
      requiredEnvVars: const [],
      setupSteps: const [
        '确认要暴露给 AI 的目录范围',
        '按客户端要求配置一个本地 stdio MCP 服务',
        '用最小目录范围先做验证',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "D:/PROJECTS"
      ]
    }
  }
}
''',
      safetyNotes: '只暴露必要目录，不要把整个磁盘或敏感个人目录直接开放给 AI。',
      transport: 'stdio',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
      featured: true,
    ),
    mcp(
      id: 'mcp-fetch',
      title: '网页抓取 MCP',
      summary: '让 AI 抓取网页内容、文档页面和在线资料，适合研究和信息整理。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['网页抓取', '研究', '文档'],
      capabilitiesSummary: '适合读取网页正文、帮助文档和公开资料页面。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const [],
      setupSteps: const ['启用 fetch server', '限制允许访问的站点范围', '先在测试目标站点上验证抓取格式'],
      configTemplate: r'''
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-fetch"
      ]
    }
  }
}
''',
      safetyNotes: '注意抓取频率、网站规则和隐私边界，不要抓取需要授权的私人页面。',
      transport: 'stdio',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-git',
      title: 'Git 仓库 MCP',
      summary: '让 AI 读取提交历史、分支差异和仓库状态，适合提交分析和变更解释。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Git', '提交历史', '差异分析'],
      capabilitiesSummary: '适合解释提交差异、追踪文件演变和辅助 code review。',
      supportedClients: const ['Claude Desktop', 'Cline', 'Continue', 'Cursor'],
      requiredEnvVars: const [],
      setupSteps: const [
        '在本地安装 Git 并确认仓库路径',
        '为目标仓库配置 git MCP',
        '验证提交历史和 diff 读取是否正常',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "git": {
      "command": "uvx",
      "args": [
        "mcp-server-git",
        "--repository",
        "D:/PROJECTS/AIdeveloper"
      ]
    }
  }
}
''',
      safetyNotes: '如果允许写操作，要区分只读与可写模式，避免误改分支。',
      transport: 'stdio',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-sqlite',
      title: 'SQLite 数据库 MCP',
      summary: '让 AI 查询本地 SQLite 数据，适合原型应用、日志和轻量数据库分析。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['SQLite', '数据库', '查询'],
      capabilitiesSummary: '适合轻量库结构理解、查询验证和问题排查。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const [],
      setupSteps: const ['确定数据库文件路径', '为测试库先配置只读访问', '验证表结构和简单查询'],
      configTemplate: r'''
{
  "mcpServers": {
    "sqlite": {
      "command": "uvx",
      "args": [
        "mcp-server-sqlite",
        "--db-path",
        "D:/PROJECTS/AIdeveloper/services/sync-api/data/sync.db"
      ]
    }
  }
}
''',
      safetyNotes: '优先使用测试库或只读模式，避免模型直接修改正式数据。',
      transport: 'stdio',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-postgres',
      title: 'Postgres 数据库 MCP',
      summary: '让 AI 读取 Postgres 表结构、执行查询并辅助分析数据问题。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Postgres', '数据库', '查询'],
      capabilitiesSummary: '适合调试查询、理解表关系和做数据验证。',
      supportedClients: const [
        'Claude Desktop',
        'Cherry Studio',
        'Continue',
        'Cursor',
      ],
      requiredEnvVars: const ['POSTGRES_DSN'],
      setupSteps: const ['准备只读数据库账号', '配置连接串并限制访问库', '先验证 schema 读取和简单查询'],
      configTemplate: r'''
{
  "mcpServers": {
    "postgres": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/postgres",
      "headers": {
        "Authorization": "Bearer ${POSTGRES_DSN}"
      }
    }
  }
}
''',
      safetyNotes: '强烈建议使用只读账号，不要把生产写权限直接交给模型。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
      featured: true,
    ),
    mcp(
      id: 'mcp-memory',
      title: '长期记忆 MCP',
      summary: '让 AI 保留一部分长期记忆或偏好，适合个人工作流和持续对话。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['记忆', '偏好', '长期上下文'],
      capabilitiesSummary: '适合沉淀用户偏好、长期项目背景和重复约定。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const [],
      setupSteps: const ['启用 memory server', '先定义允许写入的记忆类型', '周期性清理过期或错误记忆'],
      configTemplate: r'''
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ]
    }
  }
}
''',
      safetyNotes: '长期记忆最容易积累噪音和过时信息，要定期清理。',
      transport: 'stdio',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-slack',
      title: 'Slack 协作 MCP',
      summary: '让 AI 读取频道消息、整理讨论和辅助生成回复。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Slack', '沟通', '团队协作'],
      capabilitiesSummary: '适合频道总结、问题追踪和团队信息回顾。',
      supportedClients: const ['Claude Desktop', 'Cline', 'Cherry Studio'],
      requiredEnvVars: const ['SLACK_BOT_TOKEN'],
      setupSteps: const [
        '创建 Slack Bot 并申请频道读取权限',
        '把配置模板加入客户端',
        '先验证只读检索和消息总结',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "slack": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/slack",
      "headers": {
        "Authorization": "Bearer ${SLACK_BOT_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '避免把含敏感讨论的频道全部暴露给模型，权限应按需开通。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-sentry',
      title: 'Sentry 监控 MCP',
      summary: '让 AI 读取错误事件、回溯和异常聚合，适合线上排障。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Sentry', '异常', '监控'],
      capabilitiesSummary: '适合线上错误汇总、异常定位和影响范围判断。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Cursor'],
      requiredEnvVars: const ['SENTRY_AUTH_TOKEN'],
      setupSteps: const [
        '准备 Sentry 访问令牌',
        '配置目标组织和项目范围',
        '验证 issue 列表、事件详情和堆栈读取',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "sentry": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/sentry",
      "headers": {
        "Authorization": "Bearer ${SENTRY_AUTH_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '异常事件里可能带用户数据和请求信息，注意脱敏和权限边界。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-notion',
      title: 'Notion 知识库 MCP',
      summary: '让 AI 读取页面、数据库和知识库内容，适合文档检索与整理。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Notion', '知识库', '文档'],
      capabilitiesSummary: '适合知识问答、文档归档和笔记整理。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const ['NOTION_TOKEN'],
      setupSteps: const [
        '创建 Notion integration',
        '把目标页面或数据库共享给集成',
        '验证页面读取和数据库查询',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "notion": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/notion",
      "headers": {
        "Authorization": "Bearer ${NOTION_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '不要默认授权整个工作区，先从一个知识库或单个数据库开始。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
      featured: true,
    ),
    mcp(
      id: 'mcp-google-drive',
      title: 'Google Drive 云盘 MCP',
      summary: '让 AI 读取云端文档和表格，适合资料归档与检索。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Google Drive', '文档', '检索'],
      capabilitiesSummary: '适合项目文档检索、共享文件汇总和知识沉淀。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const ['GOOGLE_OAUTH_TOKEN'],
      setupSteps: const ['准备 Google OAuth 凭据', '只共享必要文件夹或文档', '验证文档读取和权限范围'],
      configTemplate: r'''
{
  "mcpServers": {
    "google-drive": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/google-drive",
      "headers": {
        "Authorization": "Bearer ${GOOGLE_OAUTH_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '云盘目录里经常包含无关隐私文件，务必限制共享范围。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/modelcontextprotocol/servers',
    ),
    mcp(
      id: 'mcp-atlassian',
      title: 'Atlassian 协作 MCP',
      summary: '让 AI 读取 Jira、Confluence 等 Atlassian 数据，适合项目追踪和知识问答。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Atlassian', 'Jira', 'Confluence'],
      capabilitiesSummary: '适合 issue 检索、文档查询和项目状态梳理。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Cursor'],
      requiredEnvVars: const ['ATLASSIAN_API_TOKEN'],
      setupSteps: const [
        '准备 Atlassian 访问令牌',
        '限制到需要的站点和项目',
        '验证 issue 和页面读取结果',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "atlassian": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/atlassian",
      "headers": {
        "Authorization": "Bearer ${ATLASSIAN_API_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '先按项目或空间开放，不要一次性暴露整个组织内容。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/atlassian/atlassian-mcp-server',
      featured: true,
    ),
    mcp(
      id: 'mcp-aws',
      title: 'AWS 云平台 MCP',
      summary: '让 AI 读取或操作 AWS 资源，适合云上排障、查询和辅助运维。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.advanced,
      tags: const ['AWS', '云平台', '运维'],
      capabilitiesSummary: '适合查看云资源、总结配置和分析部署问题。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Cursor'],
      requiredEnvVars: const [
        'AWS_ACCESS_KEY_ID',
        'AWS_SECRET_ACCESS_KEY',
        'AWS_REGION',
      ],
      setupSteps: const ['准备最小权限 AWS 凭据', '按业务域选择具体 AWS MCP 服务', '优先做只读查询验证'],
      configTemplate: r'''
{
  "mcpServers": {
    "aws": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/aws",
      "headers": {
        "X-AWS-Region": "${AWS_REGION}"
      }
    }
  }
}
''',
      safetyNotes: '云平台权限风险很高，建议先只读，绝不要默认给管理员权限。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/awslabs/mcp',
    ),
    mcp(
      id: 'mcp-oracle',
      title: 'Oracle 数据库 MCP',
      summary: '让 AI 理解 Oracle 数据库结构、查询语句和问题排查上下文。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.advanced,
      tags: const ['Oracle', '数据库', '企业系统'],
      capabilitiesSummary: '适合企业存量系统数据库查询和文档整理。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Continue'],
      requiredEnvVars: const ['ORACLE_DSN'],
      setupSteps: const [
        '准备只读 Oracle 连接信息',
        '先验证 schema 与样例查询',
        '确认客户端不会执行高风险写操作',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "oracle": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/oracle",
      "headers": {
        "Authorization": "Bearer ${ORACLE_DSN}"
      }
    }
  }
}
''',
      safetyNotes: 'Oracle 常在关键业务系统里，务必采用只读账号和测试环境先验证。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/oracle/mcp',
    ),
    mcp(
      id: 'mcp-cloudflare',
      title: 'Cloudflare 边缘平台 MCP',
      summary: '让 AI 查询域名、Worker、KV、R2 等 Cloudflare 资源配置。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['Cloudflare', '边缘', '部署'],
      capabilitiesSummary: '适合调试边缘部署、站点设置和 Worker 配置。',
      supportedClients: const ['Claude Desktop', 'Cherry Studio', 'Cursor'],
      requiredEnvVars: const ['CLOUDFLARE_API_TOKEN'],
      setupSteps: const [
        '准备 Cloudflare 访问令牌',
        '限制 Zone 与服务权限',
        '验证 Worker、DNS 或存储资源查询',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "cloudflare": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/cloudflare",
      "headers": {
        "Authorization": "Bearer ${CLOUDFLARE_API_TOKEN}"
      }
    }
  }
}
''',
      safetyNotes: '边缘和 DNS 权限很敏感，最好拆出只读 Token 并限制到特定 Zone。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/cloudflare/mcp-server-cloudflare',
    ),
    mcp(
      id: 'mcp-browserbase',
      title: 'Browserbase 浏览器 MCP',
      summary: '让 AI 具备浏览器自动化能力，适合网页测试、抓取和流程验证。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['浏览器', '自动化', '测试'],
      capabilitiesSummary: '适合登录验证、页面操作、表单流程和网页采集场景。',
      supportedClients: const ['Claude Desktop', 'Cline', 'Cursor', 'Continue'],
      requiredEnvVars: const ['BROWSERBASE_API_KEY'],
      setupSteps: const [
        '准备 Browserbase API Key',
        '配置浏览器自动化 MCP',
        '先在测试环境验证关键流程',
      ],
      configTemplate: r'''
{
  "mcpServers": {
    "browserbase": {
      "type": "streamable_http",
      "url": "https://mcp.example.dev/browserbase",
      "headers": {
        "Authorization": "Bearer ${BROWSERBASE_API_KEY}"
      }
    }
  }
}
''',
      safetyNotes: '浏览器自动化容易接触账号和表单数据，必须先在测试环境验证。',
      transport: 'streamable_http',
      baseUrl: 'https://github.com/browserbase/mcp-server-browserbase',
      featured: true,
    ),
  ];
}
