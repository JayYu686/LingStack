// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import '../../domain/models.dart';
import 'catalog_seed_types.dart';

const Map<String, bool> _allAdapters = {
  'openai': true,
  'anthropic': true,
  'gemini': true,
};

const String _skillSpecsJson = r'''
[
  {
    "id": "skill-find-skills",
    "title": "技能搜索与匹配",
    "category": "development",
    "tags": [
      "目录",
      "技能",
      "检索"
    ],
    "featured": true
  },
  {
    "id": "skill-vercel-react-best-practices",
    "title": "Vercel React 最佳实践",
    "category": "development",
    "tags": [
      "React",
      "Vercel",
      "前端"
    ],
    "featured": true
  },
  {
    "id": "skill-frontend-design",
    "title": "前端设计审校",
    "category": "content",
    "tags": [
      "设计",
      "前端",
      "界面"
    ],
    "featured": true
  },
  {
    "id": "skill-web-design-guidelines",
    "title": "Web 设计规范",
    "category": "content",
    "tags": [
      "网页",
      "设计",
      "规范"
    ],
    "featured": true
  },
  {
    "id": "skill-remotion-best-practices",
    "title": "Remotion 最佳实践",
    "category": "content",
    "tags": [
      "Remotion",
      "视频",
      "前端"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-ai",
    "title": "Azure AI 接入",
    "category": "development",
    "tags": [
      "Azure",
      "AI",
      "云平台"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-deploy",
    "title": "Azure 部署流程",
    "category": "development",
    "tags": [
      "Azure",
      "部署",
      "云平台"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-storage",
    "title": "Azure 存储实践",
    "category": "development",
    "tags": [
      "Azure",
      "存储",
      "云平台"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-cost-optimization",
    "title": "Azure 成本优化",
    "category": "growth",
    "tags": [
      "Azure",
      "成本",
      "优化"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-diagnostics",
    "title": "Azure 故障诊断",
    "category": "development",
    "tags": [
      "Azure",
      "排障",
      "监控"
    ],
    "featured": true
  },
  {
    "id": "skill-entra-app-registration",
    "title": "Entra 应用注册",
    "category": "development",
    "tags": [
      "身份认证",
      "Entra",
      "Azure"
    ],
    "featured": true
  },
  {
    "id": "skill-azure-compliance",
    "title": "Azure 合规检查",
    "category": "development",
    "tags": [
      "Azure",
      "合规",
      "安全"
    ],
    "featured": true
  },
  {
    "id": "skill-appinsights-instrumentation",
    "title": "App Insights 埋点实践",
    "category": "development",
    "tags": [
      "监控",
      "埋点",
      "Azure"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-prepare",
    "title": "Azure 上云准备",
    "category": "development",
    "tags": [
      "Azure",
      "准备",
      "上线"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-rbac",
    "title": "Azure RBAC 权限配置",
    "category": "development",
    "tags": [
      "Azure",
      "权限",
      "RBAC"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-resource-visualizer",
    "title": "Azure 资源可视化",
    "category": "development",
    "tags": [
      "Azure",
      "资源",
      "架构"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-aigateway",
    "title": "Azure AI Gateway 规划",
    "category": "development",
    "tags": [
      "Azure",
      "AI Gateway",
      "架构"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-validate",
    "title": "Azure 配置校验",
    "category": "development",
    "tags": [
      "Azure",
      "校验",
      "部署"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-kusto",
    "title": "Azure Kusto 查询",
    "category": "development",
    "tags": [
      "Azure",
      "Kusto",
      "日志"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-resource-lookup",
    "title": "Azure 资源检索",
    "category": "development",
    "tags": [
      "Azure",
      "资源查询",
      "云平台"
    ],
    "featured": false
  },
  {
    "id": "skill-microsoft-foundry",
    "title": "Microsoft Foundry 工作流",
    "category": "development",
    "tags": [
      "Foundry",
      "AI",
      "平台"
    ],
    "featured": false
  },
  {
    "id": "skill-agent-browser",
    "title": "Agent 浏览器操作",
    "category": "development",
    "tags": [
      "Agent",
      "浏览器",
      "自动化"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-messaging",
    "title": "Azure 消息链路",
    "category": "development",
    "tags": [
      "Azure",
      "消息队列",
      "架构"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-observability",
    "title": "Azure 可观测性",
    "category": "development",
    "tags": [
      "Azure",
      "可观测性",
      "监控"
    ],
    "featured": false
  },
  {
    "id": "skill-ai-image-generation",
    "title": "AI 图片生成",
    "category": "content",
    "tags": [
      "图片",
      "生成",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "skill-ai-video-generation",
    "title": "AI 视频生成",
    "category": "content",
    "tags": [
      "视频",
      "生成",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "skill-nano-banana",
    "title": "Nano Banana 图片玩法",
    "category": "content",
    "tags": [
      "图片",
      "创意",
      "生成"
    ],
    "featured": false
  },
  {
    "id": "skill-nano-banana-2",
    "title": "Nano Banana 进阶玩法",
    "category": "content",
    "tags": [
      "图片",
      "进阶",
      "生成"
    ],
    "featured": false
  },
  {
    "id": "skill-twitter-automation",
    "title": "X 平台自动化",
    "category": "growth",
    "tags": [
      "社媒",
      "自动化",
      "运营"
    ],
    "featured": false
  },
  {
    "id": "skill-agent-tools",
    "title": "Agent 工具组合",
    "category": "development",
    "tags": [
      "Agent",
      "工具",
      "工作流"
    ],
    "featured": false
  },
  {
    "id": "skill-remotion-render",
    "title": "Remotion 渲染流程",
    "category": "content",
    "tags": [
      "视频",
      "渲染",
      "Remotion"
    ],
    "featured": false
  },
  {
    "id": "skill-qwen-image-2",
    "title": "Qwen Image 2 出图",
    "category": "content",
    "tags": [
      "图片",
      "Qwen",
      "生成"
    ],
    "featured": false
  },
  {
    "id": "skill-qwen-image-2-pro",
    "title": "Qwen Image 2 Pro 出图",
    "category": "content",
    "tags": [
      "图片",
      "Qwen",
      "进阶"
    ],
    "featured": false
  },
  {
    "id": "skill-p-video",
    "title": "P 视频生成工作流",
    "category": "content",
    "tags": [
      "视频",
      "生成",
      "工作流"
    ],
    "featured": false
  },
  {
    "id": "skill-p-image",
    "title": "P 图片生成工作流",
    "category": "content",
    "tags": [
      "图片",
      "生成",
      "工作流"
    ],
    "featured": false
  },
  {
    "id": "skill-infsh-cli",
    "title": "Infsh 命令行工作流",
    "category": "development",
    "tags": [
      "CLI",
      "Agent",
      "工具"
    ],
    "featured": false
  },
  {
    "id": "skill-vercel-composition-patterns",
    "title": "Vercel 组合模式",
    "category": "development",
    "tags": [
      "Vercel",
      "架构",
      "前端"
    ],
    "featured": false
  },
  {
    "id": "skill-ui-ux-pro-max",
    "title": "UI / UX Pro Max",
    "category": "content",
    "tags": [
      "UI",
      "UX",
      "设计"
    ],
    "featured": false
  },
  {
    "id": "skill-brainstorming",
    "title": "系统化头脑风暴",
    "category": "office",
    "tags": [
      "创意",
      "讨论",
      "方案"
    ],
    "featured": false
  },
  {
    "id": "skill-seo-audit",
    "title": "SEO 审计",
    "category": "growth",
    "tags": [
      "SEO",
      "审计",
      "增长"
    ],
    "featured": false
  },
  {
    "id": "skill-browser-use",
    "title": "Browser Use 实操",
    "category": "development",
    "tags": [
      "浏览器",
      "自动化",
      "Agent"
    ],
    "featured": false
  },
  {
    "id": "skill-pdf",
    "title": "PDF 结构化处理",
    "category": "office",
    "tags": [
      "PDF",
      "文档",
      "整理"
    ],
    "featured": false
  },
  {
    "id": "skill-elevenlabs-tts",
    "title": "ElevenLabs 语音生成",
    "category": "content",
    "tags": [
      "语音",
      "TTS",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "skill-elevenlabs-music",
    "title": "ElevenLabs 音乐生成",
    "category": "content",
    "tags": [
      "音乐",
      "生成",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "skill-copywriting",
    "title": "高转化文案写作",
    "category": "growth",
    "tags": [
      "文案",
      "转化",
      "营销"
    ],
    "featured": false
  },
  {
    "id": "skill-pptx",
    "title": "PPT 文档处理",
    "category": "office",
    "tags": [
      "PPT",
      "演示",
      "办公"
    ],
    "featured": false
  },
  {
    "id": "skill-shadcn",
    "title": "shadcn/ui 组件落地",
    "category": "development",
    "tags": [
      "shadcn/ui",
      "前端",
      "组件"
    ],
    "featured": false
  },
  {
    "id": "skill-next-best-practices",
    "title": "Next.js 最佳实践",
    "category": "development",
    "tags": [
      "Next.js",
      "前端",
      "实践"
    ],
    "featured": false
  },
  {
    "id": "skill-systematic-debugging",
    "title": "系统化调试",
    "category": "development",
    "tags": [
      "调试",
      "排障",
      "工程"
    ],
    "featured": false
  },
  {
    "id": "skill-docx",
    "title": "Word 文档处理",
    "category": "office",
    "tags": [
      "Word",
      "文档",
      "办公"
    ],
    "featured": false
  },
  {
    "id": "skill-writing-plans",
    "title": "写作计划编排",
    "category": "writing",
    "tags": [
      "写作",
      "计划",
      "表达"
    ],
    "featured": false
  },
  {
    "id": "skill-using-superpowers",
    "title": "高阶工作法使用指南",
    "category": "office",
    "tags": [
      "工作法",
      "效率",
      "方法"
    ],
    "featured": false
  },
  {
    "id": "skill-audit-website",
    "title": "网站审查",
    "category": "growth",
    "tags": [
      "网站",
      "审查",
      "优化"
    ],
    "featured": false
  },
  {
    "id": "skill-xlsx",
    "title": "Excel 文档处理",
    "category": "office",
    "tags": [
      "Excel",
      "表格",
      "办公"
    ],
    "featured": false
  },
  {
    "id": "skill-simple",
    "title": "先做简单版本",
    "category": "office",
    "tags": [
      "简化",
      "执行",
      "方法"
    ],
    "featured": false
  },
  {
    "id": "skill-marketing-psychology",
    "title": "营销心理学应用",
    "category": "growth",
    "tags": [
      "营销",
      "心理学",
      "转化"
    ],
    "featured": false
  },
  {
    "id": "skill-test-driven-development",
    "title": "测试驱动开发",
    "category": "development",
    "tags": [
      "测试",
      "TDD",
      "工程"
    ],
    "featured": false
  },
  {
    "id": "skill-azure-postgres",
    "title": "Azure PostgreSQL 实践",
    "category": "development",
    "tags": [
      "Azure",
      "Postgres",
      "数据库"
    ],
    "featured": false
  },
  {
    "id": "skill-requesting-code-review",
    "title": "请求代码评审",
    "category": "development",
    "tags": [
      "Code Review",
      "协作",
      "工程"
    ],
    "featured": false
  },
  {
    "id": "skill-executing-plans",
    "title": "计划执行推进",
    "category": "office",
    "tags": [
      "计划",
      "执行",
      "项目管理"
    ],
    "featured": false
  },
  {
    "id": "skill-content-strategy",
    "title": "内容策略设计",
    "category": "content",
    "tags": [
      "内容策略",
      "选题",
      "规划"
    ],
    "featured": false
  },
  {
    "id": "skill-programmatic-seo",
    "title": "程序化 SEO",
    "category": "growth",
    "tags": [
      "SEO",
      "程序化",
      "增长"
    ],
    "featured": false
  },
  {
    "id": "skill-polish",
    "title": "界面与表达润色",
    "category": "content",
    "tags": [
      "润色",
      "设计",
      "表达"
    ],
    "featured": false
  },
  {
    "id": "skill-social-content",
    "title": "社媒内容生产",
    "category": "content",
    "tags": [
      "社媒",
      "内容",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "skill-critique",
    "title": "结构化批评反馈",
    "category": "office",
    "tags": [
      "反馈",
      "评审",
      "改进"
    ],
    "featured": false
  },
  {
    "id": "skill-adapt",
    "title": "跨平台内容改编",
    "category": "content",
    "tags": [
      "改编",
      "平台",
      "内容"
    ],
    "featured": false
  },
  {
    "id": "skill-audit",
    "title": "方案审计",
    "category": "office",
    "tags": [
      "审计",
      "检查",
      "评估"
    ],
    "featured": false
  },
  {
    "id": "skill-animate",
    "title": "动效设计协作",
    "category": "content",
    "tags": [
      "动效",
      "设计",
      "前端"
    ],
    "featured": false
  },
  {
    "id": "skill-teach-impeccable",
    "title": "高标准设计讲解",
    "category": "learning",
    "tags": [
      "设计",
      "讲解",
      "学习"
    ],
    "featured": false
  },
  {
    "id": "skill-clarify",
    "title": "需求澄清",
    "category": "office",
    "tags": [
      "需求",
      "澄清",
      "沟通"
    ],
    "featured": false
  },
  {
    "id": "skill-normalize",
    "title": "内容规范化",
    "category": "office",
    "tags": [
      "规范化",
      "统一",
      "整理"
    ],
    "featured": false
  },
  {
    "id": "skill-colorize",
    "title": "配色优化",
    "category": "content",
    "tags": [
      "配色",
      "视觉",
      "设计"
    ],
    "featured": false
  },
  {
    "id": "skill-optimize",
    "title": "方案优化",
    "category": "office",
    "tags": [
      "优化",
      "方案",
      "执行"
    ],
    "featured": false
  },
  {
    "id": "skill-sleek-design-mobile-apps",
    "title": "简洁移动端设计",
    "category": "content",
    "tags": [
      "移动端",
      "设计",
      "界面"
    ],
    "featured": false
  },
  {
    "id": "skill-bolder",
    "title": "更有力量的表达",
    "category": "writing",
    "tags": [
      "表达",
      "风格",
      "写作"
    ],
    "featured": false
  },
  {
    "id": "skill-product-marketing-context",
    "title": "产品营销上下文",
    "category": "growth",
    "tags": [
      "产品营销",
      "定位",
      "增长"
    ],
    "featured": false
  },
  {
    "id": "skill-delight",
    "title": "细节体验打磨",
    "category": "content",
    "tags": [
      "体验",
      "细节",
      "设计"
    ],
    "featured": false
  },
  {
    "id": "skill-extract",
    "title": "信息抽取",
    "category": "office",
    "tags": [
      "抽取",
      "整理",
      "结构化"
    ],
    "featured": false
  },
  {
    "id": "skill-marketing-ideas",
    "title": "营销灵感生成",
    "category": "growth",
    "tags": [
      "营销",
      "创意",
      "增长"
    ],
    "featured": false
  },
  {
    "id": "skill-distill",
    "title": "长内容提炼",
    "category": "writing",
    "tags": [
      "提炼",
      "摘要",
      "写作"
    ],
    "featured": false
  },
  {
    "id": "skill-harden",
    "title": "方案加固",
    "category": "development",
    "tags": [
      "加固",
      "风险",
      "工程"
    ],
    "featured": false
  },
  {
    "id": "skill-onboard",
    "title": "新成员上手",
    "category": "office",
    "tags": [
      "入门",
      "上手",
      "协作"
    ],
    "featured": false
  },
  {
    "id": "skill-quieter",
    "title": "更克制的表达",
    "category": "writing",
    "tags": [
      "表达",
      "风格",
      "写作"
    ],
    "featured": false
  },
  {
    "id": "skill-pricing-strategy",
    "title": "定价策略",
    "category": "growth",
    "tags": [
      "定价",
      "商业化",
      "增长"
    ],
    "featured": false
  },
  {
    "id": "skill-subagent-driven-development",
    "title": "子代理驱动开发",
    "category": "development",
    "tags": [
      "Agent",
      "协作",
      "开发"
    ],
    "featured": false
  },
  {
    "id": "skill-better-auth-best-practices",
    "title": "Better Auth 最佳实践",
    "category": "development",
    "tags": [
      "鉴权",
      "Best Practice",
      "开发"
    ],
    "featured": false
  },
  {
    "id": "skill-copy-editing",
    "title": "文案精修",
    "category": "writing",
    "tags": [
      "改稿",
      "文案",
      "表达"
    ],
    "featured": false
  },
  {
    "id": "skill-mcp-builder",
    "title": "MCP Builder",
    "category": "development",
    "tags": [
      "MCP",
      "构建",
      "工具"
    ],
    "featured": false
  },
  {
    "id": "skill-verification-before-completion",
    "title": "完成前验证",
    "category": "development",
    "tags": [
      "验证",
      "交付",
      "质量"
    ],
    "featured": false
  },
  {
    "id": "skill-page-cro",
    "title": "页面转化优化",
    "category": "growth",
    "tags": [
      "转化",
      "页面",
      "增长"
    ],
    "featured": false
  }
]
''';

List<SkillSeedBundle> buildSkillSeedsExpanded(String stamp) {
  final specs = (jsonDecode(_skillSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedSkill(spec, stamp)).toList();
}

SkillSeedBundle _buildExpandedSkill(Map<String, dynamic> spec, String stamp) {
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
适用场景：${_skillScenario(category)}
用途：${_skillSummary(title, category)}
推荐输入：context, materials, goal
输出重点：先给结论，再给步骤，最后补充风险或建议''',
    rawSchema: const {
      'type': 'object',
      'properties': {
        'context': {'type': 'string'},
        'materials': {'type': 'string'},
        'goal': {'type': 'string'},
      },
      'required': ['context', 'materials'],
    },
    providerAdapters: _allAdapters,
    exampleCode: '''{
  "context": "这次要处理的任务背景",
  "materials": "原始材料或链接",
  "goal": "希望最终得到什么"
}''',
    exampleLanguage: 'json',
    featured: spec['featured'] as bool? ?? false,
    stamp: stamp,
  );
}

ResourceCategory _skillCategory(String category) {
  switch (category) {
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
  }
}

String _skillScenario(String category) {
  switch (category) {
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
  }
}

ResourceDifficulty _skillDifficulty(String category, String title) {
  final advanced =
      title.contains('Azure') || title.contains('MCP') || title.contains('Agent');
  if (advanced || category == 'development' || category == 'growth') {
    return ResourceDifficulty.intermediate;
  }
  return ResourceDifficulty.beginner;
}

List<String> _skillInputs(String category) {
  switch (category) {
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
  }
}

String _skillSummary(String title, String category) {
  if (category == 'development') {
    return '把“$title”沉淀成固定做法，适合同类工程任务反复复用。';
  }
  if (category == 'content') {
    return '把“$title”整理成可重复执行的创作方法，减少每次从零开始。';
  }
  if (category == 'growth') {
    return '围绕“$title”形成稳定的增长工作法，方便持续复用。';
  }
  if (category == 'writing') {
    return '把“$title”拆成清晰步骤，适合反复处理类似写作任务。';
  }
  if (category == 'learning') {
    return '把“$title”变成固定学习流程，帮助你更稳定地产出结论。';
  }
  return '把“$title”整理成固定步骤，方便反复复用。';
}
