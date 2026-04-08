import '../../domain/models.dart';
import 'catalog_seed_mcps.dart';
import 'catalog_seed_mcps_expanded.dart';
import 'catalog_seed_prompts_expanded.dart';
import 'catalog_seed_prompts_part1.dart';
import 'catalog_seed_prompts_part2.dart';
import 'catalog_seed_skills.dart';
import 'catalog_seed_skills_expanded.dart';
import 'catalog_seed_types.dart';

OfficialCatalogSeed buildOfficialCatalogSeed() {
  const stamp = '2026-03-29T10:30:00.000Z';
  const version = '2026.03.29.1';

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
      subtitle: '10 分钟先看懂这个 App 能做什么',
      description: '先从最容易上手的提示词、技能和 MCP 资源开始，建立清晰的使用心智。',
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
      description: 'GitHub、Notion、Postgres、Filesystem 和浏览器自动化是最常见的起点。',
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
    const SeedCollection(
      id: 'indie-shipping',
      title: '独立开发交付',
      subtitle: '从需求到发布，把交付链路先搭稳',
      description: '适合一个人推进产品时，把发布说明、回滚预案、定价和验收思路收在一起。',
      iconKey: 'rocket',
      sortOrder: 8,
    ),
    const SeedCollection(
      id: 'debug-review-lab',
      title: '代码审查与排障',
      subtitle: '先定位问题，再决定改哪里',
      description: '适合代码审查、CI 失败、日志分析和线上性能问题排查。',
      iconKey: 'shield',
      sortOrder: 9,
    ),
    const SeedCollection(
      id: 'agent-orchestration',
      title: 'Agent 搭建与编排',
      subtitle: '把工具、技能和上下文真正串起来',
      description: '适合做多工具协作、子代理拆分和 MCP 编排的场景。',
      iconKey: 'graph',
      sortOrder: 10,
    ),
    const SeedCollection(
      id: 'content-distribution',
      title: '内容选题与分发',
      subtitle: '先出题，再做脚本，再看分发',
      description: '适合短视频、图文和社媒内容的选题、脚本、标题和评论回复。',
      iconKey: 'sparkles',
      sortOrder: 11,
    ),
    const SeedCollection(
      id: 'research-knowledge',
      title: '研究阅读与知识整理',
      subtitle: '把资料读懂，再沉淀成结构化结论',
      description: '适合论文、书籍、课程和长资料的速读、提炼与卡片化整理。',
      iconKey: 'briefcase',
      sortOrder: 12,
    ),
    const SeedCollection(
      id: 'job-sprint',
      title: '求职冲刺',
      subtitle: '简历、面试和案例表达一起准备',
      description: '适合临近投递或面试时，集中补齐自我介绍、STAR 案例和跟进回复。',
      iconKey: 'target',
      sortOrder: 13,
    ),
    const SeedCollection(
      id: 'office-communication',
      title: '办公表达与方案汇报',
      subtitle: '把材料整理成能直接发出去的话',
      description: '适合会议纪要、周报、邮件、方案对比和正式汇报表达。',
      iconKey: 'briefcase',
      sortOrder: 14,
    ),
    const SeedCollection(
      id: 'platform-connections',
      title: '常用平台与数据连接',
      subtitle: '先接你已经在用的平台，再扩更多外部上下文',
      description: '适合 GitHub、数据库、云平台、文档与浏览器工具的连接起步。',
      iconKey: 'hub',
      sortOrder: 15,
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
    ...buildCollectionItems('indie-shipping', const [
      'prompt-release-notes',
      'prompt-rollback-plan',
      'prompt-canary-plan',
      'prompt-pricing-discussion',
      'prompt-clarifying-questions',
      'skill-executing-plans',
      'skill-product-marketing-context',
      'skill-requesting-code-review',
      'skill-verification-before-completion',
      'mcp-github',
      'mcp-cloudflare',
      'mcp-aws',
    ]),
    ...buildCollectionItems('debug-review-lab', const [
      'prompt-code-review',
      'prompt-bug-triage',
      'prompt-log-analysis',
      'prompt-ci-failure-diagnosis',
      'prompt-performance-diagnosis',
      'skill-systematic-debugging',
      'skill-harden',
      'skill-test-driven-development',
      'skill-verification-before-completion',
      'mcp-sentry',
      'mcp-github',
      'mcp-filesystem',
      'mcp-cloudflare',
    ]),
    ...buildCollectionItems('agent-orchestration', const [
      'prompt-requirement-breakdown',
      'prompt-api-doc',
      'prompt-clarifying-questions',
      'prompt-adr-draft',
      'skill-agent-tools',
      'skill-subagent-driven-development',
      'skill-mcp-builder',
      'skill-find-skills',
      'mcp-memory',
      'mcp-fetch',
      'mcp-browserbase',
      'mcp-filesystem',
      'mcp-github',
    ]),
    ...buildCollectionItems('content-distribution', const [
      'prompt-short-video-script',
      'prompt-xiaohongshu-post',
      'prompt-title-polish',
      'prompt-comment-reply',
      'prompt-event-promo-copy',
      'prompt-topic-expansion',
      'skill-content-strategy',
      'skill-social-content',
      'skill-copywriting',
      'skill-adapt',
      'mcp-notion',
      'mcp-google-drive',
      'mcp-slack',
    ]),
    ...buildCollectionItems('research-knowledge', const [
      'prompt-research-question',
      'prompt-book-chapter-summary',
      'prompt-course-notes',
      'prompt-knowledge-cards',
      'prompt-explain-to-beginner',
      'skill-pdf',
      'skill-docx',
      'skill-extract',
      'skill-distill',
      'skill-teach-impeccable',
      'mcp-fetch',
      'mcp-filesystem',
      'mcp-notion',
    ]),
    ...buildCollectionItems('job-sprint', const [
      'prompt-self-intro',
      'prompt-resume-rewrite',
      'prompt-job-analysis',
      'prompt-interview-followup',
      'prompt-star-case',
      'prompt-cover-letter-optimize',
      'skill-resume-highlights',
      'skill-interview-followup',
      'skill-writing-plans',
      'skill-clarify',
    ]),
    ...buildCollectionItems('office-communication', const [
      'prompt-meeting-summary',
      'prompt-weekly-report',
      'prompt-proposal-outline',
      'prompt-email-reply',
      'prompt-decision-summary',
      'prompt-presentation-opening',
      'skill-structured-minutes',
      'skill-brainstorming',
      'skill-copy-editing',
      'skill-normalize',
      'skill-pptx',
      'skill-xlsx',
      'mcp-notion',
      'mcp-atlassian',
      'mcp-google-drive',
      'mcp-slack',
    ]),
    ...buildCollectionItems('platform-connections', const [
      'prompt-api-compatibility',
      'prompt-tracking-review',
      'skill-browser-use',
      'skill-azure-resource-lookup',
      'mcp-github',
      'mcp-postgres',
      'mcp-browserbase',
      'mcp-notion',
      'mcp-cloudflare',
      'mcp-aws',
      'mcp-google-drive',
      'mcp-oracle',
    ]),
  ];

  return _enrichOfficialCatalogSeed(
    OfficialCatalogSeed(
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
    ),
  );
}

OfficialCatalogSeed _enrichOfficialCatalogSeed(OfficialCatalogSeed seed) {
  final promptDetailsById = {
    for (final detail in seed.promptDetails) detail.resourceId: detail,
  };
  final skillDetailsById = {
    for (final detail in seed.skillDetails) detail.resourceId: detail,
  };
  final mcpDetailsById = {
    for (final detail in seed.mcpDetails) detail.resourceId: detail,
  };

  final resources = seed.resources.map((resource) {
    final quality = _scoreResource(
      resource: resource,
      promptDetail: promptDetailsById[resource.id],
      skillDetail: skillDetailsById[resource.id],
      mcpDetail: mcpDetailsById[resource.id],
    );
    return resource.copyWith(
      qualityTier: quality.tier,
      qualityScore: quality.score,
      qualityReasons: quality.reasons,
      useCases: quality.useCases,
      avoidCases: quality.avoidCases,
      verifiedAt: quality.verifiedAt,
    );
  }).toList();

  final promptDetails = seed.promptDetails.map((detail) {
    if (detail.helperNotes.isNotEmpty &&
        detail.requiredVariableNames.isNotEmpty) {
      return detail;
    }
    final requiredNames = detail.variables
        .where((variable) => variable.defaultValue.trim().isEmpty)
        .map((variable) => variable.name)
        .toList();
    final helperNotes = detail.variables
        .map(_defaultPromptHelperNote)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return SeedPromptDetail(
      resourceId: detail.resourceId,
      templateBody: detail.templateBody,
      variables: detail.variables,
      whenToUse: detail.whenToUse,
      avoidWhen: detail.avoidWhen,
      exampleInput: detail.exampleInput,
      exampleOutput: detail.exampleOutput,
      supportedModels: detail.supportedModels,
      helperNotes: helperNotes,
      requiredVariableNames: requiredNames,
    );
  }).toList();

  return OfficialCatalogSeed(
    version: seed.version,
    generatedAt: seed.generatedAt,
    resources: resources,
    promptDetails: promptDetails,
    skillDetails: seed.skillDetails,
    mcpDetails: seed.mcpDetails,
    collections: seed.collections,
    collectionItems: seed.collectionItems,
  );
}

class _QualityMeta {
  const _QualityMeta({
    required this.tier,
    required this.score,
    required this.reasons,
    required this.useCases,
    required this.avoidCases,
    required this.verifiedAt,
  });

  final ResourceQualityTier tier;
  final int score;
  final List<String> reasons;
  final List<String> useCases;
  final List<String> avoidCases;
  final String? verifiedAt;
}

_QualityMeta _scoreResource({
  required SeedCatalogResource resource,
  SeedPromptDetail? promptDetail,
  SeedSkillDetail? skillDetail,
  SeedMcpDetail? mcpDetail,
}) {
  var score = 40;
  final reasons = <String>[];

  if (resource.isFeatured) {
    score += 18;
    reasons.add('进入精选合集，适合优先浏览。');
  }
  if (resource.tags.length >= 4) {
    score += 8;
    reasons.add('标签较完整，适合按任务筛选。');
  }
  if (resource.summary.trim().length >= 24) {
    score += 8;
    reasons.add('摘要信息完整，判断成本更低。');
  }
  if (resource.difficulty == ResourceDifficulty.beginner) {
    score += 8;
    reasons.add('对新手更友好，上手更快。');
  }

  if (promptDetail != null) {
    if (promptDetail.variables.isNotEmpty) {
      score += 8;
      reasons.add('支持变量填写，适合直接复制使用。');
    }
    if (promptDetail.exampleInput.trim().isNotEmpty &&
        promptDetail.exampleOutput.trim().isNotEmpty) {
      score += 8;
      reasons.add('示例输入输出完整，结果预期更清楚。');
    }
    if (promptDetail.supportedModels.length >= 3) {
      score += 4;
      reasons.add('适配主流模型，迁移成本更低。');
    }
  }

  if (skillDetail != null) {
    if (skillDetail.inputRequirements.isNotEmpty) {
      score += 6;
      reasons.add('前置条件明确，不容易直接用错。');
    }
    if (skillDetail.usageSteps.length >= 3) {
      score += 8;
      reasons.add('步骤完整，便于照着接入。');
    }
    if (skillDetail.exampleCode.trim().isNotEmpty) {
      score += 6;
      reasons.add('带调用示例，接入成本更低。');
    }
  }

  if (mcpDetail != null) {
    if (mcpDetail.supportedClients.isNotEmpty) {
      score += 6;
      reasons.add('适配客户端明确，接入路径清楚。');
    }
    if (mcpDetail.setupSteps.length >= 3) {
      score += 8;
      reasons.add('接入步骤完整，适合按步骤排查。');
    }
    if (mcpDetail.configTemplate.trim().isNotEmpty &&
        mcpDetail.requiredEnvVars.isNotEmpty) {
      score += 8;
      reasons.add('模板和环境变量齐全，复制后更容易落地。');
    }
  }

  score = score.clamp(35, 98);
  final tier = switch (score) {
    >= 88 => ResourceQualityTier.featured,
    >= 74 => ResourceQualityTier.verified,
    >= 58 => ResourceQualityTier.community,
    _ => ResourceQualityTier.experimental,
  };
  return _QualityMeta(
    tier: resource.isFeatured ? ResourceQualityTier.featured : tier,
    score: resource.isFeatured && score < 90 ? 90 : score,
    reasons: reasons.take(5).toList(),
    useCases: _defaultUseCases(resource),
    avoidCases: _defaultAvoidCases(resource),
    verifiedAt:
        tier == ResourceQualityTier.featured ||
            tier == ResourceQualityTier.verified
        ? resource.updatedAt
        : null,
  );
}

List<String> _defaultUseCases(SeedCatalogResource resource) {
  return switch (resource.type) {
    ResourceType.prompt => const ['想先拿现成模板快速出第一版结果', '需要把任务交代给模型时更稳一些'],
    ResourceType.skill => const ['准备把重复任务沉淀成固定做法', '希望后续同类任务直接复用这套方法'],
    ResourceType.mcp => const [
      '想把 AI 接到 GitHub、文档、数据库或浏览器上',
      '需要在上下文里带入外部工具和实时数据',
    ],
  };
}

List<String> _defaultAvoidCases(SeedCatalogResource resource) {
  return switch (resource.type) {
    ResourceType.prompt => const ['需求还很模糊，连任务目标都没有想清楚', '想让一条模板直接覆盖所有场景'],
    ResourceType.skill => const ['你还没确认自己的工作流，步骤还经常变化', '需要复杂运行时调试，而不只是复制说明'],
    ResourceType.mcp => const ['还没有远程 HTTP 网关或对应平台权限', '不清楚接入后会暴露哪些数据和权限'],
  };
}

String _defaultPromptHelperNote(PromptVariable variable) {
  return switch (variable.type) {
    PromptVariableType.code => '代码变量建议直接粘贴原始代码，不要先手动简化。',
    PromptVariableType.enumeration => '枚举变量优先从给定选项里选，输出会更稳定。',
    PromptVariableType.booleanType => '布尔变量只决定开关，不需要补额外解释。',
    PromptVariableType.longText => '长文本变量建议只保留必要上下文，避免噪声太多。',
    PromptVariableType.text => '文本变量尽量具体，少用“随便”“差不多”这种模糊描述。',
  };
}
