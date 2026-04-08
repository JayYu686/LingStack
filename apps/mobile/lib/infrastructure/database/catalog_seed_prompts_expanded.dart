// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import '../../domain/models.dart';
import 'catalog_seed_types.dart';

class _PromptLabels {
  const _PromptLabels(this.primary, this.secondary);

  final String primary;
  final String secondary;
}

const Map<String, _PromptLabels> _promptLabelMap = {
  'development': _PromptLabels('待处理内容', '额外约束'),
  'office': _PromptLabels('原始材料', '目标对象'),
  'writing': _PromptLabels('原始文本', '目标对象'),
  'content': _PromptLabels('原始素材', '平台或风格'),
  'learning': _PromptLabels('原始资料', '学习目标'),
  'career': _PromptLabels('个人经历或材料', '目标岗位'),
  'growth': _PromptLabels('当前页面、活动或素材', '目标人群'),
  'life': _PromptLabels('当前情况', '限制条件'),
};

const String _promptSpecsJson = r'''
[
  {
    "id": "prompt-adr-draft",
    "title": "ADR 初稿生成",
    "category": "development",
    "tags": [
      "架构",
      "ADR",
      "技术方案"
    ],
    "featured": true
  },
  {
    "id": "prompt-tech-solution-review",
    "title": "技术方案评审意见",
    "category": "development",
    "tags": [
      "方案评审",
      "风险",
      "架构"
    ],
    "featured": true
  },
  {
    "id": "prompt-tech-debt-backlog",
    "title": "技术债清单梳理",
    "category": "development",
    "tags": [
      "技术债",
      "排期",
      "维护"
    ],
    "featured": true
  },
  {
    "id": "prompt-dependency-upgrade-review",
    "title": "依赖升级影响评估",
    "category": "development",
    "tags": [
      "依赖升级",
      "兼容性",
      "迁移"
    ],
    "featured": true
  },
  {
    "id": "prompt-config-risk-check",
    "title": "配置变更风险检查",
    "category": "development",
    "tags": [
      "配置",
      "上线",
      "风险"
    ],
    "featured": true
  },
  {
    "id": "prompt-data-migration-checklist",
    "title": "数据迁移检查清单",
    "category": "development",
    "tags": [
      "数据库",
      "迁移",
      "上线"
    ],
    "featured": true
  },
  {
    "id": "prompt-release-notes",
    "title": "发布说明生成",
    "category": "development",
    "tags": [
      "发布",
      "变更说明",
      "版本"
    ],
    "featured": true
  },
  {
    "id": "prompt-rollback-plan",
    "title": "回滚预案草稿",
    "category": "development",
    "tags": [
      "回滚",
      "应急",
      "上线"
    ],
    "featured": true
  },
  {
    "id": "prompt-api-compatibility",
    "title": "接口兼容性检查",
    "category": "development",
    "tags": [
      "API",
      "兼容性",
      "接口"
    ],
    "featured": true
  },
  {
    "id": "prompt-error-code-guide",
    "title": "错误码规范整理",
    "category": "development",
    "tags": [
      "错误码",
      "规范",
      "后端"
    ],
    "featured": true
  },
  {
    "id": "prompt-log-sampling-plan",
    "title": "日志采样策略设计",
    "category": "development",
    "tags": [
      "日志",
      "可观测性",
      "成本"
    ],
    "featured": true
  },
  {
    "id": "prompt-cache-strategy",
    "title": "Redis 缓存策略建议",
    "category": "development",
    "tags": [
      "Redis",
      "缓存",
      "性能"
    ],
    "featured": true
  },
  {
    "id": "prompt-dockerfile-audit",
    "title": "Dockerfile 审核",
    "category": "development",
    "tags": [
      "Docker",
      "安全",
      "构建"
    ],
    "featured": false
  },
  {
    "id": "prompt-ci-failure-diagnosis",
    "title": "CI 失败定位",
    "category": "development",
    "tags": [
      "CI",
      "构建",
      "排障"
    ],
    "featured": false
  },
  {
    "id": "prompt-canary-plan",
    "title": "灰度发布方案",
    "category": "development",
    "tags": [
      "灰度",
      "发布",
      "监控"
    ],
    "featured": false
  },
  {
    "id": "prompt-tracking-review",
    "title": "埋点方案审查",
    "category": "development",
    "tags": [
      "埋点",
      "分析",
      "数据"
    ],
    "featured": false
  },
  {
    "id": "prompt-permission-model",
    "title": "权限模型梳理",
    "category": "development",
    "tags": [
      "权限",
      "角色",
      "安全"
    ],
    "featured": false
  },
  {
    "id": "prompt-alert-thresholds",
    "title": "监控告警阈值建议",
    "category": "development",
    "tags": [
      "监控",
      "告警",
      "可观测性"
    ],
    "featured": false
  },
  {
    "id": "prompt-compensation-plan",
    "title": "异步任务补偿方案",
    "category": "development",
    "tags": [
      "异步任务",
      "重试",
      "补偿"
    ],
    "featured": false
  },
  {
    "id": "prompt-load-test-plan",
    "title": "性能压测计划",
    "category": "development",
    "tags": [
      "压测",
      "性能",
      "容量"
    ],
    "featured": false
  },
  {
    "id": "prompt-weekly-host-script",
    "title": "周会主持稿",
    "category": "office",
    "tags": [
      "周会",
      "主持",
      "会议"
    ],
    "featured": false
  },
  {
    "id": "prompt-retrospective-summary",
    "title": "项目复盘总结",
    "category": "office",
    "tags": [
      "复盘",
      "总结",
      "项目管理"
    ],
    "featured": false
  },
  {
    "id": "prompt-email-tone-polish",
    "title": "邮件礼貌改写",
    "category": "writing",
    "tags": [
      "邮件",
      "改写",
      "沟通"
    ],
    "featured": false
  },
  {
    "id": "prompt-agenda-builder",
    "title": "会议议程整理",
    "category": "office",
    "tags": [
      "会议",
      "议程",
      "协作"
    ],
    "featured": false
  },
  {
    "id": "prompt-option-comparison",
    "title": "方案比选说明",
    "category": "office",
    "tags": [
      "方案对比",
      "决策",
      "汇报"
    ],
    "featured": false
  },
  {
    "id": "prompt-presentation-opening",
    "title": "汇报开场白",
    "category": "writing",
    "tags": [
      "汇报",
      "表达",
      "演讲"
    ],
    "featured": false
  },
  {
    "id": "prompt-decision-summary",
    "title": "决策结论整理",
    "category": "office",
    "tags": [
      "决策",
      "整理",
      "会议"
    ],
    "featured": false
  },
  {
    "id": "prompt-priority-sorter",
    "title": "待办优先级排序",
    "category": "office",
    "tags": [
      "待办",
      "优先级",
      "排期"
    ],
    "featured": false
  },
  {
    "id": "prompt-clarifying-questions",
    "title": "需求澄清问题清单",
    "category": "office",
    "tags": [
      "需求",
      "澄清",
      "沟通"
    ],
    "featured": false
  },
  {
    "id": "prompt-sop-optimization",
    "title": "SOP 优化建议",
    "category": "office",
    "tags": [
      "SOP",
      "流程",
      "优化"
    ],
    "featured": false
  },
  {
    "id": "prompt-interview-outline",
    "title": "访谈提纲生成",
    "category": "learning",
    "tags": [
      "访谈",
      "研究",
      "提纲"
    ],
    "featured": false
  },
  {
    "id": "prompt-training-script",
    "title": "培训讲稿提纲",
    "category": "office",
    "tags": [
      "培训",
      "提纲",
      "讲稿"
    ],
    "featured": false
  },
  {
    "id": "prompt-public-title-ideas",
    "title": "公众号标题备选",
    "category": "content",
    "tags": [
      "标题",
      "公众号",
      "内容"
    ],
    "featured": false
  },
  {
    "id": "prompt-opening-rewrite",
    "title": "文章开头重写",
    "category": "writing",
    "tags": [
      "文章",
      "开头",
      "改写"
    ],
    "featured": false
  },
  {
    "id": "prompt-longform-restructure",
    "title": "长文结构重组",
    "category": "writing",
    "tags": [
      "长文",
      "结构",
      "编辑"
    ],
    "featured": false
  },
  {
    "id": "prompt-knowledge-cards",
    "title": "知识卡片生成",
    "category": "learning",
    "tags": [
      "知识卡片",
      "整理",
      "学习"
    ],
    "featured": false
  },
  {
    "id": "prompt-faq-builder",
    "title": "FAQ 整理",
    "category": "office",
    "tags": [
      "FAQ",
      "整理",
      "客服"
    ],
    "featured": false
  },
  {
    "id": "prompt-case-study-draft",
    "title": "案例拆解文章",
    "category": "content",
    "tags": [
      "案例",
      "文章",
      "复盘"
    ],
    "featured": false
  },
  {
    "id": "prompt-brand-voice",
    "title": "品牌语气统一",
    "category": "content",
    "tags": [
      "品牌",
      "语气",
      "文案"
    ],
    "featured": false
  },
  {
    "id": "prompt-value-to-user-language",
    "title": "产品卖点转用户语言",
    "category": "content",
    "tags": [
      "卖点",
      "转化",
      "表达"
    ],
    "featured": false
  },
  {
    "id": "prompt-cover-copy",
    "title": "短视频封面文案",
    "category": "content",
    "tags": [
      "短视频",
      "封面",
      "文案"
    ],
    "featured": false
  },
  {
    "id": "prompt-storyboard-draft",
    "title": "视频分镜草稿",
    "category": "content",
    "tags": [
      "视频",
      "分镜",
      "脚本"
    ],
    "featured": false
  },
  {
    "id": "prompt-event-promo-copy",
    "title": "社群活动宣传文案",
    "category": "growth",
    "tags": [
      "活动",
      "宣传",
      "社群"
    ],
    "featured": false
  },
  {
    "id": "prompt-ab-title-test",
    "title": "A/B 标题对比",
    "category": "growth",
    "tags": [
      "A/B 测试",
      "标题",
      "转化"
    ],
    "featured": false
  },
  {
    "id": "prompt-topic-expansion",
    "title": "内容选题池扩展",
    "category": "content",
    "tags": [
      "选题",
      "内容规划",
      "创作"
    ],
    "featured": false
  },
  {
    "id": "prompt-live-cue-cards",
    "title": "直播提词卡",
    "category": "content",
    "tags": [
      "直播",
      "提词",
      "口播"
    ],
    "featured": false
  },
  {
    "id": "prompt-comment-reply",
    "title": "评论区高情商回复",
    "category": "content",
    "tags": [
      "评论回复",
      "社媒",
      "互动"
    ],
    "featured": false
  },
  {
    "id": "prompt-customer-care",
    "title": "客诉安抚回复",
    "category": "growth",
    "tags": [
      "客服",
      "安抚",
      "回复"
    ],
    "featured": false
  },
  {
    "id": "prompt-jd-polish",
    "title": "招聘 JD 优化",
    "category": "career",
    "tags": [
      "招聘",
      "JD",
      "岗位"
    ],
    "featured": false
  },
  {
    "id": "prompt-cover-letter-optimize",
    "title": "自荐信优化",
    "category": "career",
    "tags": [
      "自荐信",
      "求职",
      "改写"
    ],
    "featured": false
  },
  {
    "id": "prompt-research-question",
    "title": "论文研究问题提炼",
    "category": "learning",
    "tags": [
      "论文",
      "研究",
      "提炼"
    ],
    "featured": false
  },
  {
    "id": "prompt-book-chapter-summary",
    "title": "书籍章节速读",
    "category": "learning",
    "tags": [
      "读书",
      "摘要",
      "学习"
    ],
    "featured": false
  },
  {
    "id": "prompt-course-notes",
    "title": "课程笔记结构化",
    "category": "learning",
    "tags": [
      "课程",
      "笔记",
      "整理"
    ],
    "featured": false
  },
  {
    "id": "prompt-quiz-generator",
    "title": "知识点测验题生成",
    "category": "learning",
    "tags": [
      "测验",
      "题目",
      "学习"
    ],
    "featured": false
  },
  {
    "id": "prompt-explain-to-beginner",
    "title": "概念讲给小白",
    "category": "learning",
    "tags": [
      "解释",
      "入门",
      "科普"
    ],
    "featured": false
  },
  {
    "id": "prompt-jargon-guide",
    "title": "行业术语解释",
    "category": "learning",
    "tags": [
      "术语",
      "解释",
      "行业"
    ],
    "featured": false
  },
  {
    "id": "prompt-interview-simulation",
    "title": "面试问题模拟",
    "category": "career",
    "tags": [
      "面试",
      "模拟",
      "求职"
    ],
    "featured": false
  },
  {
    "id": "prompt-star-case",
    "title": "STAR 案例补强",
    "category": "career",
    "tags": [
      "STAR",
      "面试",
      "案例"
    ],
    "featured": false
  },
  {
    "id": "prompt-resume-quantify",
    "title": "简历项目量化",
    "category": "career",
    "tags": [
      "简历",
      "量化",
      "项目经历"
    ],
    "featured": false
  },
  {
    "id": "prompt-career-roadmap",
    "title": "职业发展路线图",
    "category": "career",
    "tags": [
      "职业规划",
      "成长",
      "路线图"
    ],
    "featured": false
  },
  {
    "id": "prompt-persona-sketch",
    "title": "用户画像速写",
    "category": "growth",
    "tags": [
      "用户画像",
      "增长",
      "产品"
    ],
    "featured": false
  },
  {
    "id": "prompt-competitor-diff",
    "title": "竞品差异总结",
    "category": "growth",
    "tags": [
      "竞品",
      "差异",
      "定位"
    ],
    "featured": false
  },
  {
    "id": "prompt-user-insight",
    "title": "用户访谈洞察",
    "category": "growth",
    "tags": [
      "访谈",
      "洞察",
      "研究"
    ],
    "featured": false
  },
  {
    "id": "prompt-sales-objection",
    "title": "销售异议应对",
    "category": "growth",
    "tags": [
      "销售",
      "异议",
      "转化"
    ],
    "featured": false
  },
  {
    "id": "prompt-pricing-discussion",
    "title": "价格策略讨论",
    "category": "growth",
    "tags": [
      "定价",
      "商业化",
      "策略"
    ],
    "featured": false
  },
  {
    "id": "prompt-campaign-retro",
    "title": "活动复盘",
    "category": "growth",
    "tags": [
      "活动",
      "复盘",
      "运营"
    ],
    "featured": false
  },
  {
    "id": "prompt-travel-plan",
    "title": "出行计划整理",
    "category": "life",
    "tags": [
      "出行",
      "计划",
      "生活"
    ],
    "featured": false
  },
  {
    "id": "prompt-fitness-plan",
    "title": "健身计划提醒",
    "category": "life",
    "tags": [
      "健身",
      "计划",
      "生活"
    ],
    "featured": false
  },
  {
    "id": "prompt-budget-draft",
    "title": "家庭预算草案",
    "category": "life",
    "tags": [
      "预算",
      "家庭",
      "生活"
    ],
    "featured": false
  },
  {
    "id": "prompt-daily-priority",
    "title": "每日优先事项清单",
    "category": "life",
    "tags": [
      "效率",
      "计划",
      "清单"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ethereum-developer",
    "title": "Ethereum Developer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Ethereum Developer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-linux-terminal",
    "title": "Linux Terminal",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "命令行",
      "Linux",
      "Linux Terminal"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-english-translator-and-improver",
    "title": "English Translator and Improver",
    "category": "writing",
    "tags": [
      "Prompt",
      "写作表达",
      "润色",
      "English Translator and Improver"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-job-interviewer",
    "title": "Job Interviewer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "面试",
      "Job Interviewer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-javascript-console",
    "title": "JavaScript Console",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "命令行",
      "JavaScript Console"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-excel-sheet",
    "title": "Excel Sheet",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Excel Sheet"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-english-pronunciation-helper",
    "title": "English Pronunciation Helper",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "English Pronunciation Helper"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-spoken-english-teacher-and-improver",
    "title": "Spoken English Teacher and Improver",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "教学",
      "Spoken English Teacher and Improver"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-travel-guide",
    "title": "Travel Guide",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "出行",
      "Travel Guide"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-plagiarism-checker",
    "title": "Plagiarism Checker",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Plagiarism Checker"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-character",
    "title": "Character",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Character"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-advertiser",
    "title": "Advertiser",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Advertiser"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-storyteller",
    "title": "Storyteller",
    "category": "content",
    "tags": [
      "Prompt",
      "内容创作",
      "创意",
      "Storyteller"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-football-commentator",
    "title": "Football Commentator",
    "category": "content",
    "tags": [
      "Prompt",
      "内容创作",
      "创意",
      "Football Commentator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-stand-up-comedian",
    "title": "Stand-up Comedian",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Stand-up Comedian"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-motivational-coach",
    "title": "Motivational Coach",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Motivational Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-composer",
    "title": "Composer",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Composer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-debater",
    "title": "Debater",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Debater"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-debate-coach",
    "title": "Debate Coach",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Debate Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-screenwriter",
    "title": "Screenwriter",
    "category": "content",
    "tags": [
      "Prompt",
      "内容创作",
      "创意",
      "Screenwriter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-novelist",
    "title": "Novelist",
    "category": "content",
    "tags": [
      "Prompt",
      "内容创作",
      "创意",
      "Novelist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-movie-critic",
    "title": "Movie Critic",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Movie Critic"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-relationship-coach",
    "title": "Relationship Coach",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Relationship Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-poet",
    "title": "Poet",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Poet"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-rapper",
    "title": "Rapper",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Rapper"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-motivational-speaker",
    "title": "Motivational Speaker",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Motivational Speaker"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-philosophy-teacher",
    "title": "Philosophy Teacher",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "教学",
      "Philosophy Teacher"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-philosopher",
    "title": "Philosopher",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Philosopher"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-math-teacher",
    "title": "Math Teacher",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "教学",
      "Math Teacher"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ai-writing-tutor",
    "title": "AI Writing Tutor",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "AI Writing Tutor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ux-ui-developer",
    "title": "UX/UI Developer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "UX/UI Developer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-cyber-security-specialist",
    "title": "Cyber Security Specialist",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Cyber Security Specialist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-recruiter",
    "title": "Recruiter",
    "category": "career",
    "tags": [
      "Prompt",
      "求职成长",
      "面试",
      "Recruiter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-life-coach",
    "title": "Life Coach",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Life Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-etymologist",
    "title": "Etymologist",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Etymologist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-commentariat",
    "title": "Commentariat",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Commentariat"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-magician",
    "title": "Magician",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Magician"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-career-counselor",
    "title": "Career Counselor",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "研究",
      "Career Counselor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-pet-behaviorist",
    "title": "Pet Behaviorist",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Pet Behaviorist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-personal-trainer",
    "title": "Personal Trainer",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "健身",
      "Personal Trainer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-mental-health-adviser",
    "title": "Mental Health Adviser",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Mental Health Adviser"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-real-estate-agent",
    "title": "Real Estate Agent",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Real Estate Agent"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-logistician",
    "title": "Logistician",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "会议",
      "Logistician"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-dentist",
    "title": "Dentist",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Dentist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-web-design-consultant",
    "title": "Web Design Consultant",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "会议",
      "Web Design Consultant"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ai-assisted-doctor",
    "title": "AI Assisted Doctor",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "AI Assisted Doctor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-doctor",
    "title": "Doctor",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Doctor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-accountant",
    "title": "Accountant",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Accountant"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-chef",
    "title": "Chef",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Chef"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-automobile-mechanic",
    "title": "Automobile Mechanic",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Automobile Mechanic"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-artist-advisor",
    "title": "Artist Advisor",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Artist Advisor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-financial-analyst",
    "title": "Financial Analyst",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Financial Analyst"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-investment-manager",
    "title": "Investment Manager",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Investment Manager"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-tea-taster",
    "title": "Tea-Taster",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Tea-Taster"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-interior-decorator",
    "title": "Interior Decorator",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Interior Decorator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-florist",
    "title": "Florist",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Florist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-self-help-book",
    "title": "Self-Help Book",
    "category": "career",
    "tags": [
      "Prompt",
      "求职成长",
      "面试",
      "Self-Help Book"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-gnomist",
    "title": "Gnomist",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Gnomist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-aphorism-book",
    "title": "Aphorism Book",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Aphorism Book"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-text-based-adventure-game",
    "title": "Text Based Adventure Game",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Text Based Adventure Game"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ai-trying-to-escape-the-box",
    "title": "AI Trying to Escape the Box",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "命令行",
      "Linux",
      "Docker"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-fancy-title-generator",
    "title": "Fancy Title Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Fancy Title Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-statistician",
    "title": "Statistician",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Statistician"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-prompt-generator",
    "title": "Prompt Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "提示词",
      "Prompt Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-instructor-in-a-school",
    "title": "Instructor in a School",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "提示词",
      "Instructor in a School"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-sql-terminal",
    "title": "SQL Terminal",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "SQL",
      "命令行",
      "SQL Terminal"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-dietitian",
    "title": "Dietitian",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Dietitian"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-psychologist",
    "title": "Psychologist",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Psychologist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-smart-domain-name-generator",
    "title": "Smart Domain Name Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "提示词",
      "Smart Domain Name Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-tech-reviewer",
    "title": "Tech Reviewer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Tech Reviewer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-developer-relations-consultant",
    "title": "Developer Relations Consultant",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "GitHub",
      "研究",
      "Developer Relations Consultant"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-academician",
    "title": "Academician",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Academician"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-it-architect",
    "title": "IT Architect",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "IT Architect"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-lunatic",
    "title": "Lunatic",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Lunatic"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-gaslighter",
    "title": "Gaslighter",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Gaslighter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-fallacy-finder",
    "title": "Fallacy Finder",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Fallacy Finder"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-journal-reviewer",
    "title": "Journal Reviewer",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Journal Reviewer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-diy-expert",
    "title": "DIY Expert",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "DIY Expert"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-social-media-influencer",
    "title": "Social Media Influencer",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "YouTube",
      "Social Media Influencer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-socrat",
    "title": "Socrat",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Socrat"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-socratic-method",
    "title": "Socratic Method",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Socratic Method"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-educational-content-creator",
    "title": "Educational Content Creator",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Educational Content Creator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-yogi",
    "title": "Yogi",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Yogi"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-essay-writer",
    "title": "Essay Writer",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Essay Writer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-social-media-manager",
    "title": "Social Media Manager",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Social Media Manager"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-elocutionist",
    "title": "Elocutionist",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Elocutionist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-scientific-data-visualizer",
    "title": "Scientific Data Visualizer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "研究",
      "Scientific Data Visualizer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-car-navigation-system",
    "title": "Car Navigation System",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Car Navigation System"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-hypnotherapist",
    "title": "Hypnotherapist",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Hypnotherapist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-historian",
    "title": "Historian",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Historian"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-astrologer",
    "title": "Astrologer",
    "category": "career",
    "tags": [
      "Prompt",
      "求职成长",
      "面试",
      "提示词",
      "Astrologer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-film-critic",
    "title": "Film Critic",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Film Critic"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-classical-music-composer",
    "title": "Classical Music Composer",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Classical Music Composer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-journalist",
    "title": "Journalist",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Journalist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-digital-art-gallery-guide",
    "title": "Digital Art Gallery Guide",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "研究",
      "Digital Art Gallery Guide"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-public-speaking-coach",
    "title": "Public Speaking Coach",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Public Speaking Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-makeup-artist",
    "title": "Makeup Artist",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Makeup Artist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-babysitter",
    "title": "Babysitter",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Babysitter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-tech-writer",
    "title": "Tech Writer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Tech Writer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-ascii-artist",
    "title": "Ascii Artist",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Ascii Artist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-python-interpreter",
    "title": "Python Interpreter",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Python Interpreter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-synonym-finder",
    "title": "Synonym Finder",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "提示词",
      "Synonym Finder"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-personal-shopper",
    "title": "Personal Shopper",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Personal Shopper"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-food-critic",
    "title": "Food Critic",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Food Critic"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-virtual-doctor",
    "title": "Virtual Doctor",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Virtual Doctor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-personal-chef",
    "title": "Personal Chef",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Personal Chef"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-legal-advisor",
    "title": "Legal Advisor",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Legal Advisor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-personal-stylist",
    "title": "Personal Stylist",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Personal Stylist"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-machine-learning-engineer",
    "title": "Machine Learning Engineer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Machine Learning Engineer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-biblical-translator",
    "title": "Biblical Translator",
    "category": "writing",
    "tags": [
      "Prompt",
      "写作表达",
      "润色",
      "Biblical Translator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-svg-designer",
    "title": "SVG designer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "SVG designer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-it-expert",
    "title": "IT Expert",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "IT Expert"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-chess-player",
    "title": "Chess Player",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Chess Player"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-midjourney-prompt-generator",
    "title": "Midjourney Prompt Generator",
    "category": "content",
    "tags": [
      "Prompt",
      "内容创作",
      "创意",
      "提示词",
      "Midjourney Prompt Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-fullstack-software-developer",
    "title": "Fullstack Software Developer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Fullstack Software Developer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-mathematician",
    "title": "Mathematician",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Mathematician"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-regex-generator",
    "title": "RegEx Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "邮件",
      "RegEx Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-time-travel-guide",
    "title": "Time Travel Guide",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "出行",
      "Time Travel Guide"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-dream-interpreter",
    "title": "Dream Interpreter",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "Dream Interpreter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-talent-coach",
    "title": "Talent Coach",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "面试",
      "Talent Coach"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-r-programming-interpreter",
    "title": "R Programming Interpreter",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "命令行",
      "R Programming Interpreter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-stackoverflow-post",
    "title": "StackOverflow Post",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "StackOverflow Post"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-emoji-translator",
    "title": "Emoji Translator",
    "category": "writing",
    "tags": [
      "Prompt",
      "写作表达",
      "润色",
      "Emoji Translator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-php-interpreter",
    "title": "PHP Interpreter",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "命令行",
      "PHP Interpreter"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-emergency-response-professional",
    "title": "Emergency Response Professional",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Emergency Response Professional"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-fill-in-the-blank-worksheets-generator",
    "title": "Fill in the Blank Worksheets Generator",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "Fill in the Blank Worksheets Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-software-quality-assurance-tester",
    "title": "Software Quality Assurance Tester",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Software Quality Assurance Tester"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-tic-tac-toe-game",
    "title": "Tic-Tac-Toe Game",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Tic-Tac-Toe Game"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-password-generator",
    "title": "Password Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Password Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-new-language-creator",
    "title": "New Language Creator",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "New Language Creator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-web-browser",
    "title": "Web Browser",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "提示词",
      "Web Browser"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-senior-frontend-developer",
    "title": "Senior Frontend Developer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Senior Frontend Developer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-code-reviewer",
    "title": "Code Reviewer",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Code Reviewer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-accessibility-auditor",
    "title": "Accessibility Auditor",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Accessibility Auditor"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-solr-search-engine",
    "title": "Solr Search Engine",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "提示词",
      "Solr Search Engine"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-startup-idea-generator",
    "title": "Startup Idea Generator",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "营销",
      "销售",
      "Startup Idea Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-spongebob-s-magic-conch-shell",
    "title": "Spongebob's Magic Conch Shell",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Spongebob's Magic Conch Shell"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-language-detector",
    "title": "Language Detector",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Language Detector"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-salesperson",
    "title": "Salesperson",
    "category": "growth",
    "tags": [
      "Prompt",
      "运营增长",
      "转化",
      "销售",
      "Salesperson"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-commit-message-generator",
    "title": "Commit Message Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Commit Message Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-conventional-commit-message-generator",
    "title": "Conventional Commit Message Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Conventional Commit Message Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-chief-executive-officer",
    "title": "Chief Executive Officer",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Chief Executive Officer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-diagram-generator",
    "title": "Diagram Generator",
    "category": "development",
    "tags": [
      "Prompt",
      "开发编程",
      "工程提效",
      "Diagram Generator"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-speech-language-pathologist-slp",
    "title": "Speech-Language Pathologist (SLP)",
    "category": "life",
    "tags": [
      "Prompt",
      "生活效率",
      "计划",
      "Speech-Language Pathologist (SLP)"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-startup-tech-lawyer",
    "title": "Startup Tech Lawyer",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Startup Tech Lawyer"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-title-generator-for-written-pieces",
    "title": "Title Generator for written pieces",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Title Generator for written pieces"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-product-manager",
    "title": "Product Manager",
    "category": "writing",
    "tags": [
      "Prompt",
      "写作表达",
      "润色",
      "Product Manager"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-project-manager",
    "title": "Project Manager",
    "category": "office",
    "tags": [
      "Prompt",
      "办公协作",
      "整理",
      "Project Manager"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-drunk-person",
    "title": "Drunk Person",
    "category": "writing",
    "tags": [
      "Prompt",
      "写作表达",
      "润色",
      "Drunk Person"
    ],
    "featured": false
  },
  {
    "id": "prompt-open-source-mathematical-history-teacher",
    "title": "Mathematical History Teacher",
    "category": "learning",
    "tags": [
      "Prompt",
      "学习研究",
      "总结",
      "教学",
      "Mathematical History Teacher"
    ],
    "featured": false
  }
]
''';

List<PromptSeedBundle> buildPromptSeedsExpanded(String stamp) {
  final specs = (jsonDecode(_promptSpecsJson) as List<dynamic>)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList(growable: false);
  return specs.map((spec) => _buildExpandedPrompt(spec, stamp)).toList();
}

PromptSeedBundle _buildExpandedPrompt(Map<String, dynamic> spec, String stamp) {
  final category = spec['category'] as String? ?? 'life';
  final title = spec['title'] as String? ?? '';
  final tags = List<String>.from(spec['tags'] as List<dynamic>? ?? const []);
  final labels =
      _promptLabelMap[category] ?? const _PromptLabels('当前情况', '限制条件');
  final primaryPlaceholder = '{{${labels.primary}}}';
  final secondaryPlaceholder = '{{${labels.secondary}}}';
  const outputPlaceholder = '{{输出要求}}';

  return buildPromptSeed(
    id: spec['id'] as String? ?? '',
    title: title,
    summary: _promptSummary(title, category),
    scenario: _scenarioLabel(category),
    primaryCategory: _categoryFromKey(category),
    difficulty: _promptDifficulty(category),
    tags: tags,
    templateBody:
        '''请围绕“$title”帮助我完成任务。
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
}

String _scenarioLabel(String category) {
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
    case 'growth':
      return '运营增长';
    default:
      return '生活效率';
  }
}

ResourceCategory _categoryFromKey(String category) {
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
      return ResourceCategory.life;
  }
}

ResourceDifficulty _promptDifficulty(String category) {
  if (category == 'development' || category == 'growth') {
    return ResourceDifficulty.intermediate;
  }
  return ResourceDifficulty.beginner;
}

PromptVariableType _primaryVariableType(List<String> tags) {
  final joined = tags.join(' ').toLowerCase();
  if (joined.contains('sql') ||
      joined.contains('docker') ||
      joined.contains('ci') ||
      joined.contains('api') ||
      joined.contains('缓存') ||
      joined.contains('日志')) {
    return PromptVariableType.code;
  }
  return PromptVariableType.longText;
}

String _promptSummary(String title, String category) {
  if (category == 'development') {
    return '围绕“$title”快速输出可执行建议，适合开发任务先做判断再落地。';
  }
  if (category == 'office' || category == 'writing') {
    return '围绕“$title”整理结构和重点，适合协作或表达场景直接拿来用。';
  }
  if (category == 'content') {
    return '围绕“$title”快速生成更能直接发布或改写的创作结果。';
  }
  if (category == 'learning' || category == 'career') {
    return '围绕“$title”整理学习或求职所需材料，方便快速复用。';
  }
  if (category == 'growth') {
    return '围绕“$title”输出更偏增长和转化场景的可执行建议。';
  }
  return '围绕“$title”快速整理出可直接使用的结果。';
}

String _promptWhen(String category) {
  switch (category) {
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
  }
}
