from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
DB_DIR = ROOT / 'apps/mobile/lib/infrastructure/database'
SPEC_SOURCE = ROOT / 'contracts/catalog/manual_seed_specs.json'

EXISTING_MCP_IDS = {
    'mcp-github',
    'mcp-filesystem',
    'mcp-fetch',
    'mcp-git',
    'mcp-sqlite',
    'mcp-postgres',
    'mcp-memory',
    'mcp-slack',
    'mcp-sentry',
    'mcp-notion',
    'mcp-google-drive',
    'mcp-atlassian',
    'mcp-aws',
    'mcp-oracle',
    'mcp-cloudflare',
    'mcp-browserbase',
}

SKIP_MCP_NAMES = {
    'GitHub',
    'FileSystem',
    'Fetch',
    'Git',
    'SQLite',
    'PostgreSQL',
    'Memory',
    'Slack',
    'Sentry',
    'Atlassian',
    'Google Drive',
}

SKIP_MCP_PROJECTS = {
    'mcp-get',
    'mxcp',
    'Remote MCP',
    'yamcp',
    'ToolHive',
    'MCPJungle',
    'Pipedream',
    'Zapier',
}


def write_json_const(name: str, value: object) -> str:
    payload = json.dumps(value, ensure_ascii=False, indent=2)
    return f"const String {name} = r'''\n{payload}\n''';\n"


def load_specs() -> tuple[list[tuple[str, str, str, list[str]]], list[tuple[str, str, str, list[str]]]]:
    payload = json.loads(SPEC_SOURCE.read_text(encoding='utf-8'))
    prompt_specs = [
        (
            item['id'],
            item['title'],
            item['category'],
            list(item['tags']),
        )
        for item in payload.get('prompts', [])
    ]
    skill_specs = [
        (
            item['id'],
            item['title'],
            item['category'],
            list(item['tags']),
        )
        for item in payload.get('skills', [])
    ]
    return prompt_specs, skill_specs


def derive_mcps(limit: int = 100) -> list[tuple[str, str, str, str]]:
    url = 'https://raw.githubusercontent.com/appcypher/awesome-mcp-servers/main/README.md'
    text = urllib.request.urlopen(url, timeout=30).read().decode('utf-8', 'ignore')
    items = re.findall(r'\[([^\]]+)\]\((https?://[^)]+)\)\s*-\s*([^\n]+)', text)
    results: list[tuple[str, str, str, str]] = []
    seen: set[str] = set()

    for name, link, desc in items:
        clean = name.strip('* ').strip()
        slug = re.sub(r'[^a-z0-9]+', '-', clean.lower()).strip('-')
        resource_id = f'mcp-{slug}'
        if (
            clean in SKIP_MCP_NAMES
            or clean in SKIP_MCP_PROJECTS
            or clean in seen
            or resource_id in EXISTING_MCP_IDS
        ):
            continue
        seen.add(clean)
        results.append((clean, link, desc.strip(), resource_id))
        if len(results) >= limit:
            break

    return results


def mcp_category(text: str) -> str:
    lowered = text.lower()
    if any(
        keyword in lowered
        for keyword in [
            'github',
            'gitlab',
            'git',
            'postgres',
            'sqlite',
            'mysql',
            'mongodb',
            'redis',
            'docker',
            'figma',
            'openapi',
            'postman',
            'browser',
            'playwright',
            'puppeteer',
            'keycloak',
            'semgrep',
            'database',
            'cloud',
        ]
    ):
        return 'development'
    if any(
        keyword in lowered
        for keyword in ['slack', 'linear', 'jira', 'todoist', 'notes', 'microsoft 365', 'line official']
    ):
        return 'office'
    if any(
        keyword in lowered
        for keyword in ['arxiv', 'papers', 'research', 'open library', 'nutrition', 'congress']
    ):
        return 'learning'
    if any(
        keyword in lowered
        for keyword in ['analytics', 'ads', 'spotify', 'tiktok', 'social', 'marketing']
    ):
        return 'growth'
    if any(
        keyword in lowered
        for keyword in ['voice', 'music', 'video', 'news', 'ebook']
    ):
        return 'content'
    return 'development'


def mcp_transport(url: str) -> str:
    lowered = url.lower()
    if any(keyword in lowered for keyword in ['mercadolibre.com', 'mercadopago.com', 'probe.dev']):
        return 'streamable_http'
    return 'stdio'


def mcp_envs(text: str) -> list[str]:
    lowered = text.lower()
    table = [
        ('github', ['GITHUB_TOKEN']),
        ('gitlab', ['GITLAB_TOKEN']),
        ('linear', ['LINEAR_API_KEY']),
        ('mongodb', ['MONGODB_URI']),
        ('mysql', ['MYSQL_DSN']),
        ('postgres', ['POSTGRES_DSN']),
        ('redis', ['REDIS_URL']),
        ('airtable', ['AIRTABLE_TOKEN']),
        ('snowflake', ['SNOWFLAKE_DSN']),
        ('slack', ['SLACK_BOT_TOKEN']),
        ('todoist', ['TODOIST_API_TOKEN']),
        ('spotify', ['SPOTIFY_TOKEN']),
        ('openai', ['OPENAI_API_KEY']),
        ('perplexity', ['PERPLEXITY_API_KEY']),
        ('figma', ['FIGMA_ACCESS_TOKEN']),
        ('postman', ['POSTMAN_API_KEY']),
        ('keycloak', ['KEYCLOAK_BASE_URL', 'KEYCLOAK_TOKEN']),
        ('semgrep', ['SEMGREP_APP_TOKEN']),
        ('google maps', ['GOOGLE_MAPS_API_KEY']),
        ('tavily', ['TAVILY_API_KEY']),
        ('brave', ['BRAVE_API_KEY']),
        ('kagi', ['KAGI_API_KEY']),
        ('microsoft 365', ['MS_GRAPH_TOKEN']),
    ]
    for keyword, envs in table:
        if keyword in lowered:
            return envs
    if any(keyword in lowered for keyword in ['api', 'cloud', 'analytics', 'ads', 'search']):
        return ['SERVICE_TOKEN']
    return []


def build_prompt_file(prompt_specs: list[tuple[str, str, str, list[str]]]) -> str:
    prompt_specs_data = [
        {
            'id': resource_id,
            'title': title,
            'category': category,
            'tags': tags,
            'featured': index < 12,
        }
        for index, (resource_id, title, category, tags) in enumerate(prompt_specs)
    ]

    return f"""// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import '../../domain/models.dart';
import 'catalog_seed_types.dart';

class _PromptLabels {{
  const _PromptLabels(this.primary, this.secondary);

  final String primary;
  final String secondary;
}}

const Map<String, _PromptLabels> _promptLabelMap = {{
  'development': _PromptLabels('待处理内容', '额外约束'),
  'office': _PromptLabels('原始材料', '目标对象'),
  'writing': _PromptLabels('原始文本', '目标对象'),
  'content': _PromptLabels('原始素材', '平台或风格'),
  'learning': _PromptLabels('原始资料', '学习目标'),
  'career': _PromptLabels('个人经历或材料', '目标岗位'),
  'growth': _PromptLabels('当前页面、活动或素材', '目标人群'),
  'life': _PromptLabels('当前情况', '限制条件'),
}};

{write_json_const('_promptSpecsJson', prompt_specs_data)}
List<PromptSeedBundle> buildPromptSeedsExpanded(String stamp) {{
  final specs = (jsonDecode(_promptSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedPrompt(spec, stamp)).toList();
}}

PromptSeedBundle _buildExpandedPrompt(Map<String, dynamic> spec, String stamp) {{
  final category = spec['category'] as String? ?? 'life';
  final title = spec['title'] as String? ?? '';
  final tags = List<String>.from(spec['tags'] as List<dynamic>? ?? const []);
  final labels =
      _promptLabelMap[category] ?? const _PromptLabels('当前情况', '限制条件');
  final primaryPlaceholder = '{{{{${{labels.primary}}}}}}';
  final secondaryPlaceholder = '{{{{${{labels.secondary}}}}}}';
  const outputPlaceholder = '{{{{输出要求}}}}';

  return buildPromptSeed(
    id: spec['id'] as String? ?? '',
    title: title,
    summary: _promptSummary(title, category),
    scenario: _scenarioLabel(category),
    primaryCategory: _categoryFromKey(category),
    difficulty: _promptDifficulty(category),
    tags: tags,
    templateBody: '''请围绕“$title”帮助我完成任务。
任务目标：先给结论，再给可直接使用的内容。

核心材料：
$primaryPlaceholder

补充信息：
$secondaryPlaceholder

输出要求：
$outputPlaceholder

请按以下结构输出：
1. 先给结论或建议
2. 再给正文、清单或话术
3. 最后列出风险、缺口或需要确认的点
''',
    variables: [
      PromptVariable(
        name: labels.primary,
        type: _primaryVariableType(tags),
        description: '贴入这次任务的核心材料',
      ),
      PromptVariable(
        name: labels.secondary,
        type: PromptVariableType.longText,
        description: '补充背景、限制条件或风格要求',
      ),
      const PromptVariable(
        name: '输出要求',
        type: PromptVariableType.longText,
        defaultValue: '语言简洁、条理清楚、方便直接使用',
      ),
    ],
    whenToUse: _promptWhen(category),
    avoidWhen: '如果关键事实还没确认，或者必须由真人做最终判断与签批，不要直接照抄输出结果。',
    exampleInput: '把本次任务的核心材料、补充背景和输出要求填进去即可。',
    exampleOutput: '输出会先给结论，再给正文或清单，最后补充风险和注意事项。',
    featured: spec['featured'] as bool? ?? false,
    stamp: stamp,
  );
}}

String _scenarioLabel(String category) {{
  switch (category) {{
    case 'development':
      return '开发编程';
    case 'office':
      return '办公协作';
    case 'writing':
      return '写作表达';
    case 'content':
      return '内容创作';
    case 'learning':
      return '学习研究';
    case 'career':
      return '求职成长';
    case 'growth':
      return '运营增长';
    default:
      return '生活效率';
  }}
}}

ResourceCategory _categoryFromKey(String category) {{
  switch (category) {{
    case 'development':
      return ResourceCategory.development;
    case 'office':
      return ResourceCategory.office;
    case 'writing':
      return ResourceCategory.writing;
    case 'content':
      return ResourceCategory.content;
    case 'learning':
      return ResourceCategory.learning;
    case 'career':
      return ResourceCategory.career;
    case 'growth':
      return ResourceCategory.growth;
    default:
      return ResourceCategory.life;
  }}
}}

ResourceDifficulty _promptDifficulty(String category) {{
  if (category == 'development' || category == 'growth') {{
    return ResourceDifficulty.intermediate;
  }}
  return ResourceDifficulty.beginner;
}}

PromptVariableType _primaryVariableType(List<String> tags) {{
  final joined = tags.join(' ').toLowerCase();
  if (joined.contains('sql') ||
      joined.contains('docker') ||
      joined.contains('ci') ||
      joined.contains('api') ||
      joined.contains('缓存') ||
      joined.contains('日志')) {{
    return PromptVariableType.code;
  }}
  return PromptVariableType.longText;
}}

String _promptSummary(String title, String category) {{
  if (category == 'development') {{
    return '围绕“$title”快速输出可执行建议，适合开发任务先做判断再落地。';
  }}
  if (category == 'office' || category == 'writing') {{
    return '围绕“$title”整理结构和重点，适合协作或表达场景直接拿来用。';
  }}
  if (category == 'content') {{
    return '围绕“$title”快速生成更能直接发布或改写的创作结果。';
  }}
  if (category == 'learning' || category == 'career') {{
    return '围绕“$title”整理学习或求职所需材料，方便快速复用。';
  }}
  if (category == 'growth') {{
    return '围绕“$title”输出更偏增长和转化场景的可执行建议。';
  }}
  return '围绕“$title”快速整理出可直接使用的结果。';
}}

String _promptWhen(String category) {{
  switch (category) {{
    case 'development':
      return '适合手头已经有代码、日志、配置或方案材料，希望先快速判断方向时。';
    case 'office':
      return '适合先把会里、需求里或协作里的信息收束成清晰结论时。';
    case 'writing':
      return '适合先把表达整理顺，再去做最后人工润色时。';
    case 'content':
      return '适合先拉出可用初稿，再按平台风格二次修改时。';
    case 'learning':
      return '适合阅读、整理和复习资料时先做第一轮结构化输出。';
    case 'career':
      return '适合准备简历、面试和自荐材料时快速打底。';
    case 'growth':
      return '适合围绕增长、活动、转化和用户洞察先做第一轮整理。';
    default:
      return '适合先把事情排清楚，再决定今天或这周怎么安排。';
  }}
}}
"""


def build_skill_file(skill_specs: list[tuple[str, str, str, list[str]]]) -> str:
    skill_specs_data = [
        {
            'id': f'skill-{resource_id}',
            'title': title,
            'category': category,
            'tags': tags,
            'featured': index < 12,
        }
        for index, (resource_id, title, category, tags) in enumerate(skill_specs)
    ]

    return f"""// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import '../../domain/models.dart';
import 'catalog_seed_types.dart';

const Map<String, bool> _allAdapters = {{
  'openai': true,
  'anthropic': true,
  'gemini': true,
}};

{write_json_const('_skillSpecsJson', skill_specs_data)}
List<SkillSeedBundle> buildSkillSeedsExpanded(String stamp) {{
  final specs = (jsonDecode(_skillSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedSkill(spec, stamp)).toList();
}}

SkillSeedBundle _buildExpandedSkill(Map<String, dynamic> spec, String stamp) {{
  final category = spec['category'] as String? ?? 'office';
  final title = spec['title'] as String? ?? '';
  final tags = List<String>.from(spec['tags'] as List<dynamic>? ?? const []);

  return buildSkillSeed(
    id: spec['id'] as String? ?? '',
    title: title,
    summary: _skillSummary(title, category),
    scenario: _skillScenario(category),
    primaryCategory: _skillCategory(category),
    difficulty: _skillDifficulty(category, title),
    tags: tags,
    capabilitySummary: _skillSummary(title, category),
    inputRequirements: _skillInputs(category),
    usageSteps: const [
      '先确认任务目标和边界',
      '贴入原始材料并补充限制条件',
      '先复核结果，再沉淀成自己的版本',
    ],
    supportedModels: const ['ChatGPT', 'Claude', 'Gemini', 'DeepSeek'],
    copyPayload: '''技能名：$title
适用场景：${{_skillScenario(category)}}
用途：${{_skillSummary(title, category)}}
推荐输入：context, materials, goal
输出重点：先给结论，再给步骤，最后补充风险或建议''',
    rawSchema: const {{
      'type': 'object',
      'properties': {{
        'context': {{'type': 'string'}},
        'materials': {{'type': 'string'}},
        'goal': {{'type': 'string'}},
      }},
      'required': ['context', 'materials'],
    }},
    providerAdapters: _allAdapters,
    exampleCode: '''{{
  "context": "这次要处理的任务背景",
  "materials": "原始材料或链接",
  "goal": "希望最终得到什么"
}}''',
    exampleLanguage: 'json',
    featured: spec['featured'] as bool? ?? false,
    stamp: stamp,
  );
}}

ResourceCategory _skillCategory(String category) {{
  switch (category) {{
    case 'development':
      return ResourceCategory.development;
    case 'office':
      return ResourceCategory.office;
    case 'writing':
      return ResourceCategory.writing;
    case 'content':
      return ResourceCategory.content;
    case 'learning':
      return ResourceCategory.learning;
    case 'career':
      return ResourceCategory.career;
    case 'growth':
      return ResourceCategory.growth;
    default:
      return ResourceCategory.other;
  }}
}}

String _skillScenario(String category) {{
  switch (category) {{
    case 'development':
      return '开发编程';
    case 'office':
      return '办公协作';
    case 'writing':
      return '写作表达';
    case 'content':
      return '内容创作';
    case 'learning':
      return '学习研究';
    case 'career':
      return '求职成长';
    default:
      return '运营增长';
  }}
}}

ResourceDifficulty _skillDifficulty(String category, String title) {{
  final advanced =
      title.contains('Azure') || title.contains('MCP') || title.contains('Agent');
  if (advanced || category == 'development' || category == 'growth') {{
    return ResourceDifficulty.intermediate;
  }}
  return ResourceDifficulty.beginner;
}}

List<String> _skillInputs(String category) {{
  switch (category) {{
    case 'development':
      return const ['任务背景', '现有代码、日志或配置', '你最关心的风险或目标'];
    case 'content':
      return const ['原始素材或链接', '目标平台或风格', '你希望达成的结果'];
    case 'growth':
      return const ['当前页面、活动或素材', '目标人群', '目标动作或转化指标'];
    case 'writing':
      return const ['原始文本', '目标对象', '希望保留或强调的点'];
    case 'learning':
      return const ['原始资料', '学习目标', '你希望输出的形式'];
    default:
      return const ['任务背景', '原始材料', '输出偏好'];
  }}
}}

String _skillSummary(String title, String category) {{
  if (category == 'development') {{
    return '把“$title”沉淀成固定做法，适合同类工程任务反复复用。';
  }}
  if (category == 'content') {{
    return '把“$title”整理成可重复执行的创作方法，减少每次从零开始。';
  }}
  if (category == 'growth') {{
    return '围绕“$title”形成稳定的增长工作法，方便持续复用。';
  }}
  if (category == 'writing') {{
    return '把“$title”拆成清晰步骤，适合反复处理类似写作任务。';
  }}
  if (category == 'learning') {{
    return '把“$title”变成固定学习流程，帮助你更稳定地产出结论。';
  }}
  return '把“$title”整理成固定步骤，方便反复复用。';
}}
"""


def build_mcp_file(mcp_entries: list[tuple[str, str, str, str]]) -> str:
    mcp_specs_data = []
    category_tags = {
        'development': ['开发', '工具接入'],
        'office': ['协作', '工具接入'],
        'content': ['内容', '工具接入'],
        'growth': ['增长', '工具接入'],
        'learning': ['研究', '工具接入'],
    }

    for index, (name, url, desc, resource_id) in enumerate(mcp_entries):
        category = mcp_category(f'{name} {desc} {url}')
        envs = mcp_envs(f'{name} {desc}')
        tags = [name, 'MCP', *category_tags[category]]
        mcp_specs_data.append(
            {
                'id': resource_id,
                'title': f'{name} MCP',
                'category': category,
                'tags': tags,
                'baseUrl': url,
                'transport': mcp_transport(url),
                'requiredEnvVars': envs,
                'featured': index < 12,
            }
        )

    return f"""// ignore_for_file: prefer_interpolation_to_compose_strings

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

{write_json_const('_mcpSpecsJson', mcp_specs_data)}
List<McpSeedBundle> buildMcpSeedsExpanded(String stamp) {{
  final specs = (jsonDecode(_mcpSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedMcp(spec, stamp)).toList();
}}

McpSeedBundle _buildExpandedMcp(Map<String, dynamic> spec, String stamp) {{
  final category = spec['category'] as String? ?? 'development';
  final envs =
      List<String>.from(spec['requiredEnvVars'] as List<dynamic>? ?? const []);

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
}}

ResourceCategory _mcpCategory(String category) {{
  switch (category) {{
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
  }}
}}

String _mcpScenario(String category) {{
  switch (category) {{
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
  }}
}}

ResourceDifficulty _mcpDifficulty(Map<String, dynamic> spec) {{
  final transport = spec['transport'] as String? ?? 'stdio';
  final title = spec['title'] as String? ?? '';
  final category = spec['category'] as String? ?? 'development';
  if (transport == 'streamable_http') {{
    return ResourceDifficulty.intermediate;
  }}
  if (title.contains('Semgrep') ||
      title.contains('Keycloak') ||
      title.contains('Docker')) {{
    return ResourceDifficulty.advanced;
  }}
  return category == 'development'
      ? ResourceDifficulty.intermediate
      : ResourceDifficulty.beginner;
}}

String _mcpSummary(Map<String, dynamic> spec) {{
  final category = spec['category'] as String? ?? 'development';
  final title = spec['title'] as String? ?? '';
  if (category == 'office') {{
    return '把$title接到 AI 客户端里，适合处理文档、任务、协作和消息相关上下文。';
  }}
  if (category == 'content') {{
    return '把$title接到 AI 客户端里，适合内容生产、素材处理和媒体相关工作流。';
  }}
  if (category == 'growth') {{
    return '把$title接到 AI 客户端里，适合分析增长数据、广告与运营动作。';
  }}
  if (category == 'learning') {{
    return '把$title接到 AI 客户端里，适合查资料、做研究和整理知识。';
  }}
  return '把$title接到 AI 客户端里，适合让模型直接访问开发、数据或自动化工具。';
}}

String _mcpSafety(List<String> envs) {{
  if (envs.isEmpty) {{
    return '先确认它会访问哪些数据，再决定是否放进常用客户端里；不要把不需要的目录、仓库或生产环境直接开放给模型。';
  }}
  return '优先使用最小权限的 Token 或测试账号；只有在确认权限边界、审计方式和回滚手段后，再接入正式环境。';
}}

String _mcpConfig(Map<String, dynamic> spec, List<String> envs) {{
  final id = spec['id'] as String? ?? 'mcp-server';
  final transport = spec['transport'] as String? ?? 'stdio';
  final serverKey = id.replaceFirst('mcp-', '');
  final placeholder = envs.isEmpty ? '' : r'${{' + envs.first + '}}';

  if (transport == 'streamable_http') {{
    final headerBlock = envs.isEmpty
        ? ''
        : ',\\n      "headers": {{\\n        "Authorization": "Bearer ' +
            placeholder +
            '"\\n      }}';
    return '''{{
  "mcpServers": {{
    "$serverKey": {{
      "type": "streamable_http",
      "url": "https://your-mcp-gateway.example/$serverKey"$headerBlock
    }}
  }}
}}''';
  }}

  final envBlock = envs.isEmpty
      ? ''
      : ',\\n      "env": {{\\n' +
          envs
              .map(
                (env) => '        "' + env + '": "' + r'${{' + env + '}}"',
              )
              .join(',\\n') +
          '\\n      }}';

  return '''{{
  "mcpServers": {{
    "$serverKey": {{
      "command": "npx",
      "args": [
        "-y",
        "REPLACE_WITH_OFFICIAL_PACKAGE"
      ]$envBlock
    }}
  }}
}}''';
}}
"""


def main() -> None:
    prompt_specs, skill_specs = load_specs()
    mcp_entries = derive_mcps(100)

    (DB_DIR / 'catalog_seed_prompts_expanded.dart').write_text(
        build_prompt_file(prompt_specs),
        encoding='utf-8',
    )
    (DB_DIR / 'catalog_seed_skills_expanded.dart').write_text(
        build_skill_file(skill_specs),
        encoding='utf-8',
    )
    (DB_DIR / 'catalog_seed_mcps_expanded.dart').write_text(
        build_mcp_file(mcp_entries),
        encoding='utf-8',
    )

    summary = {
        'prompts_added': len(prompt_specs),
        'skills_added': len(skill_specs),
        'mcps_added': len(mcp_entries),
    }
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == '__main__':
    main()
