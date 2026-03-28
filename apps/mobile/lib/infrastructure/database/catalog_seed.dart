import 'catalog_seed_mcps.dart';
import 'catalog_seed_mcps_expanded.dart';
import 'catalog_seed_prompts_part1.dart';
import 'catalog_seed_prompts_part2.dart';
import 'catalog_seed_prompts_expanded.dart';
import 'catalog_seed_skills.dart';
import 'catalog_seed_skills_expanded.dart';
import 'catalog_seed_types.dart';

OfficialCatalogSeed buildOfficialCatalogSeed() {
  const stamp = '2026-03-28T15:30:00.000Z';
  const version = '2026.03.28.4';

  final prompts = [
    ...buildPromptSeedsPart1(stamp),
    ...buildPromptSeedsPart2(stamp),
    ...buildPromptSeedsExpanded(stamp),
  ];
  final skills = [...buildSkillSeeds(stamp), ...buildSkillSeedsExpanded(stamp)];
  final mcps = [...buildMcpSeeds(stamp), ...buildMcpSeedsExpanded(stamp)];

  final collections = <SeedCollection>[
    const SeedCollection(
      id: 'starter-pack',
      title: '新手入门',
      subtitle: '10 分钟快速看懂这个 App 能做什么',
      description: '先从最容易上手的提示词、技能和 MCP 资源开始，建立清晰的使用思路。',
      iconKey: 'rocket',
      sortOrder: 0,
    ),
    const SeedCollection(
      id: 'developer-efficiency',
      title: '开发提效',
      subtitle: '给开发者准备的一组高频资源',
      description: '覆盖代码审查、排障、SQL、API 文档、GitHub 和数据库连接等高频任务。',
      iconKey: 'terminal',
      sortOrder: 1,
    ),
    const SeedCollection(
      id: 'content-growth',
      title: '内容增长',
      subtitle: '面向内容创作、运营和品牌表达',
      description: '适合做短视频脚本、小红书文案、标题优化、用户回复和内容排期。',
      iconKey: 'sparkles',
      sortOrder: 2,
    ),
    const SeedCollection(
      id: 'office-boost',
      title: '办公协作',
      subtitle: '会议、周报、需求、文档和沟通一次收好',
      description: '适合把零散信息整理成结论、待办、方案和正式表达。',
      iconKey: 'briefcase',
      sortOrder: 3,
    ),
    const SeedCollection(
      id: 'job-hunt',
      title: '求职成长',
      subtitle: '简历、面试、作品集和学习规划',
      description: '适合准备求职材料、项目表达、面试追问和能力提升计划。',
      iconKey: 'target',
      sortOrder: 4,
    ),
    const SeedCollection(
      id: 'mcp-starter',
      title: 'MCP 入门连接',
      subtitle: '先接最常用的平台和基础能力',
      description: 'GitHub、Notion、Postgres、Filesystem 和浏览器自动化是最常见起点。',
      iconKey: 'hub',
      sortOrder: 5,
    ),
    const SeedCollection(
      id: 'observability',
      title: '排障与观测',
      subtitle: '日志、异常、监控和性能问题排查',
      description: '适合定位线上问题、整理日志和对接异常监控平台。',
      iconKey: 'shield',
      sortOrder: 6,
    ),
    const SeedCollection(
      id: 'agent-workflows',
      title: 'Agent 工作流',
      subtitle: '把提示词、技能和 MCP 串起来用',
      description: '适合已经在使用 Claude Code、Cursor、Copilot 或自建 Agent 的用户。',
      iconKey: 'graph',
      sortOrder: 7,
    ),
  ];

  final collectionItems = <SeedCollectionItem>[
    ...buildCollectionItems('starter-pack', const [
      'prompt-code-review',
      'prompt-meeting-summary',
      'prompt-resume-rewrite',
      'skill-structured-minutes',
      'skill-prompt-scorer',
      'mcp-github',
      'mcp-notion',
      'mcp-filesystem',
    ]),
    ...buildCollectionItems('developer-efficiency', const [
      'prompt-code-review',
      'prompt-bug-triage',
      'prompt-api-doc',
      'prompt-sql-optimize',
      'prompt-unit-test',
      'prompt-refactor-plan',
      'skill-api-doc-generator',
      'skill-bug-report-normalizer',
      'skill-github-cli-workflow',
      'skill-sql-explainer',
      'mcp-github',
      'mcp-postgres',
      'mcp-filesystem',
      'mcp-git',
      'mcp-sqlite',
    ]),
    ...buildCollectionItems('content-growth', const [
      'prompt-short-video-script',
      'prompt-xiaohongshu-post',
      'prompt-title-polish',
      'prompt-product-copy',
      'prompt-customer-reply',
      'prompt-content-calendar',
      'prompt-landing-page-hero',
      'skill-content-labeler',
      'skill-customer-intent',
      'mcp-notion',
      'mcp-google-drive',
    ]),
    ...buildCollectionItems('office-boost', const [
      'prompt-meeting-summary',
      'prompt-weekly-report',
      'prompt-requirement-breakdown',
      'prompt-proposal-outline',
      'prompt-email-reply',
      'prompt-data-insight',
      'prompt-sop-draft',
      'skill-structured-minutes',
      'skill-requirement-todo',
      'mcp-notion',
      'mcp-atlassian',
      'mcp-google-drive',
    ]),
    ...buildCollectionItems('job-hunt', const [
      'prompt-self-intro',
      'prompt-resume-rewrite',
      'prompt-job-analysis',
      'prompt-interview-followup',
      'prompt-portfolio-case',
      'prompt-learning-plan',
      'skill-resume-highlights',
      'skill-interview-followup',
    ]),
    ...buildCollectionItems('mcp-starter', const [
      'mcp-github',
      'mcp-filesystem',
      'mcp-fetch',
      'mcp-notion',
      'mcp-postgres',
      'mcp-browserbase',
    ]),
    ...buildCollectionItems('observability', const [
      'prompt-bug-triage',
      'prompt-log-analysis',
      'prompt-performance-diagnosis',
      'prompt-security-audit',
      'skill-bug-report-normalizer',
      'mcp-sentry',
      'mcp-cloudflare',
      'mcp-aws',
    ]),
    ...buildCollectionItems('agent-workflows', const [
      'prompt-code-review',
      'prompt-requirement-breakdown',
      'skill-skill-creator',
      'skill-webapp-testing',
      'skill-github-cli-workflow',
      'mcp-github',
      'mcp-filesystem',
      'mcp-browserbase',
      'mcp-memory',
    ]),
  ];

  return OfficialCatalogSeed(
    version: version,
    generatedAt: stamp,
    resources: [
      ...prompts.map((value) => value.resource),
      ...skills.map((value) => value.resource),
      ...mcps.map((value) => value.resource),
    ],
    promptDetails: prompts.map((value) => value.detail).toList(),
    skillDetails: skills.map((value) => value.detail).toList(),
    mcpDetails: mcps.map((value) => value.detail).toList(),
    collections: collections,
    collectionItems: collectionItems,
  );
}
