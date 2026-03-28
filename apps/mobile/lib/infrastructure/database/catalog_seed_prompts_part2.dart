import '../../domain/models.dart';
import 'catalog_seed_types.dart';

List<PromptSeedBundle> buildPromptSeedsPart2(String stamp) {
  PromptVariable textVar(
    String name, {
    String description = '',
    String defaultValue = '',
  }) => PromptVariable(
    name: name,
    type: PromptVariableType.text,
    description: description,
    defaultValue: defaultValue,
  );

  PromptVariable longVar(
    String name, {
    String description = '',
    String defaultValue = '',
  }) => PromptVariable(
    name: name,
    type: PromptVariableType.longText,
    description: description,
    defaultValue: defaultValue,
  );

  PromptSeedBundle prompt({
    required String id,
    required String title,
    required String summary,
    required String scenario,
    required ResourceDifficulty difficulty,
    required List<String> tags,
    required String templateBody,
    required List<PromptVariable> variables,
    required String whenToUse,
    required String avoidWhen,
    required String exampleInput,
    required String exampleOutput,
    bool featured = false,
  }) {
    return buildPromptSeed(
      id: id,
      title: title,
      summary: summary,
      scenario: scenario,
      difficulty: difficulty,
      tags: tags,
      templateBody: templateBody,
      variables: variables,
      whenToUse: whenToUse,
      avoidWhen: avoidWhen,
      exampleInput: exampleInput,
      exampleOutput: exampleOutput,
      featured: featured,
      stamp: stamp,
    );
  }

  return [
    prompt(
      id: 'prompt-self-intro',
      title: '面试自我介绍',
      summary: '根据你的经历和目标岗位，生成自然、不空泛的开场介绍。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['面试', '自我介绍', '求职'],
      templateBody: '''
请根据以下信息，帮我写一段 1 分钟左右的面试自我介绍。

个人背景：
{{个人背景}}

目标岗位：
{{目标岗位}}

希望强调：
{{希望强调}}

要求：真实、自然、不过度包装，重点突出岗位匹配度。
''',
      variables: [
        longVar('个人背景'),
        textVar('目标岗位', defaultValue: '产品运营'),
        longVar('希望强调', defaultValue: '核心项目经验、结果、协作能力'),
      ],
      whenToUse: '适合面试前快速打磨开场表述。',
      avoidWhen: '不要直接背诵，最好再用自己的口语习惯改一遍。',
      exampleInput: '目标岗位：全栈工程师',
      exampleOutput: '我过去主要做本地优先工具产品，熟悉 Flutter、Go 和从需求到落地的完整过程。',
    ),
    prompt(
      id: 'prompt-resume-rewrite',
      title: '简历改写与提炼',
      summary: '把经历从“做过什么”改成“解决了什么问题、拿到了什么结果”。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['简历', '求职', '经历提炼'],
      templateBody: '''
请帮我改写下面的简历经历。

原始经历：
{{原始经历}}

目标岗位：
{{目标岗位}}

要求：
1. 更突出结果和影响
2. 保留真实信息
3. 语言更职业，但不要空话
''',
      variables: [
        longVar('原始经历'),
        textVar('目标岗位', defaultValue: '产品经理'),
      ],
      whenToUse: '适合把流水账式经历改成更能被招聘方快速理解的版本。',
      avoidWhen: '不要让模型编造项目成果和数据。',
      exampleInput: '原始经历：负责公众号日常更新、活动执行、数据整理',
      exampleOutput: '重写后会突出活动转化、内容增长和跨团队协作结果。',
      featured: true,
    ),
    prompt(
      id: 'prompt-job-analysis',
      title: 'JD 解读助手',
      summary: '把岗位描述拆成能力要求、隐含重点和简历投递策略。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['JD', '岗位分析', '求职'],
      templateBody: '''
请分析下面这份职位描述。

职位描述：
{{职位描述}}

我的背景：
{{我的背景}}

请输出：
1. 这个岗位最看重什么
2. 隐含要求有哪些
3. 我的匹配点
4. 简历和面试该重点讲什么
''',
      variables: [
        longVar('职位描述'),
        longVar('我的背景', defaultValue: '待补充'),
      ],
      whenToUse: '适合投递前快速判断岗位是否匹配，以及面试准备重点。',
      avoidWhen: '不要只看模型总结，仍建议自己通读 JD 原文。',
      exampleInput: '我的背景：3 年内容增长 + 1 年产品协作经验',
      exampleOutput: '岗位核心关注业务理解、实验迭代、协作推进能力。',
    ),
    prompt(
      id: 'prompt-interview-followup',
      title: '面试追问准备',
      summary: '围绕你的项目经历，预判面试官可能追问的深水区问题。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['面试', '追问', '准备'],
      templateBody: '''
请根据下面的项目经历，帮我准备面试追问。

项目经历：
{{项目经历}}

目标岗位：
{{目标岗位}}

请输出：
1. 面试官最可能追问的问题
2. 每个问题背后的考察点
3. 回答结构建议
''',
      variables: [
        longVar('项目经历'),
        textVar('目标岗位', defaultValue: '运营经理'),
      ],
      whenToUse: '适合做项目复盘和面试前针对性准备。',
      avoidWhen: '不要把标准答案背死，真实案例比模板更重要。',
      exampleInput: '项目经历：主导资源库 App 从概念到原型落地',
      exampleOutput: '可能追问优先级判断、技术取舍、数据验证方式。',
    ),
    prompt(
      id: 'prompt-portfolio-case',
      title: '作品集案例包装',
      summary: '把项目经历整理成适合作品集展示的案例结构。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['作品集', '案例', '表达'],
      templateBody: '''
请帮我把下面的项目整理成作品集案例。

项目背景：
{{项目背景}}

我的职责：
{{我的职责}}

最终结果：
{{最终结果}}

请输出一个适合作品集展示的结构：背景、问题、方案、我的贡献、结果、复盘。
''',
      variables: [
        longVar('项目背景'),
        longVar('我的职责'),
        longVar('最终结果'),
      ],
      whenToUse: '适合准备作品集、面试材料和个人主页案例。',
      avoidWhen: '如果结果不明确，先补事实，不要空写“推动业务增长”。',
      exampleInput: '最终结果：完成 MVP、首批用户能顺利上手',
      exampleOutput: '案例会更强调决策过程，而不只是功能列表。',
    ),
    prompt(
      id: 'prompt-learning-plan',
      title: '学习计划制定',
      summary: '围绕一个目标，拆出循序渐进、可以真的执行的学习路线。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['学习', '成长', '计划'],
      templateBody: '''
请为我制定一个学习计划。

学习目标：
{{学习目标}}

当前基础：
{{当前基础}}

可投入时间：
{{可投入时间}}

请输出：
1. 四周或八周学习路径
2. 每周重点
3. 推荐练习方式
4. 用什么结果验证我真的学会了
''',
      variables: [
        textVar('学习目标'),
        longVar('当前基础'),
        textVar('可投入时间', defaultValue: '每天 1 小时'),
      ],
      whenToUse: '适合自学转岗、补技能短板或准备新项目。',
      avoidWhen: '计划不能太满，最好预留复盘和实际练手时间。',
      exampleInput: '学习目标：掌握 MCP 基础并能接入 GitHub',
      exampleOutput: '会给出协议理解、客户端配置、最小接入案例和验证方式。',
    ),
    prompt(
      id: 'prompt-research-paper-summary',
      title: '论文或长文速读',
      summary: '把长文先压缩成背景、核心方法、结论和可行动价值。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['论文', '阅读', '总结'],
      templateBody: '''
请帮我快速理解下面这篇论文或长文。

内容：
{{内容}}

我的目标：
{{我的目标}}

请输出：
1. 这篇内容主要解决什么问题
2. 核心方法或观点
3. 局限性
4. 对我当前目标最有价值的部分
''',
      variables: [
        longVar('内容'),
        textVar('我的目标', defaultValue: '快速判断值不值得深读'),
      ],
      whenToUse: '适合读论文、长报告、复杂技术博客的第一轮筛选。',
      avoidWhen: '不要让模型替代你做精读，关键论证仍需回原文核对。',
      exampleInput: '我的目标：判断能否用于个人 AI 工具产品设计',
      exampleOutput: '重点会放在方法是否可落地、适用边界和实现成本。',
    ),
    prompt(
      id: 'prompt-english-polish',
      title: '英文表达润色',
      summary: '把中式英文或过硬表达，改成自然、专业、不过度复杂的英文。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['英文', '润色', '表达'],
      templateBody: '''
请帮我润色下面这段英文。

原文：
{{原文}}

场景：
{{场景}}

语气要求：
{{语气要求}}

请给出：
1. 润色后的版本
2. 为什么这样改
3. 更口语一点的版本（如果适合）
''',
      variables: [
        longVar('原文'),
        textVar('场景', defaultValue: '工作沟通'),
        textVar('语气要求', defaultValue: '自然、专业、简洁'),
      ],
      whenToUse: '适合邮件、英文简历、英文汇报和海外协作沟通。',
      avoidWhen: '不要为了“高级感”把句子改得又长又拗口。',
      exampleInput: '场景：求职邮件',
      exampleOutput: '会优先保证清晰和礼貌，而不是堆复杂词。',
    ),
    prompt(
      id: 'prompt-negotiation-reply',
      title: '谈判或议价回复',
      summary: '在不硬碰硬的前提下，把边界、底线和理由表达清楚。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['谈判', '沟通', '边界'],
      templateBody: '''
请帮我写一段谈判或议价回复。

对方说法：
{{对方说法}}

我的目标：
{{我的目标}}

我的底线：
{{我的底线}}

要求：坚定但不生硬，说明理由，给出可接受的下一步。
''',
      variables: [
        longVar('对方说法'),
        longVar('我的目标'),
        longVar('我的底线'),
      ],
      whenToUse: '适合薪资沟通、项目合作、资源争取等场景。',
      avoidWhen: '涉及正式合同条款时，仍建议法务或负责人确认。',
      exampleInput: '我的目标：争取更合理的交付周期',
      exampleOutput: '回复会说明现实约束，并提出一个可执行的新时间表。',
    ),
    prompt(
      id: 'prompt-stakeholder-update',
      title: '干系人同步更新',
      summary: '把项目进度、风险和需要决策的点说得短而清楚。',
      scenario: '求职成长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['同步', '项目', '沟通'],
      templateBody: '''
请帮我写一段项目同步更新。

当前进展：
{{当前进展}}

风险或阻塞：
{{风险或阻塞}}

希望对方配合：
{{希望对方配合}}

要求：短、清楚、方便对方快速决策。
''',
      variables: [
        longVar('当前进展'),
        longVar('风险或阻塞'),
        longVar('希望对方配合', defaultValue: '暂时没有'),
      ],
      whenToUse: '适合给老板、合作方或跨团队同学同步项目状态。',
      avoidWhen: '不要把模糊猜测写成确定事实。',
      exampleInput: '当前进展：首页重构已完成，动态目录链路已打通',
      exampleOutput: '同步会突出完成项、剩余风险和需要确认的资源范围。',
    ),
    prompt(
      id: 'prompt-short-video-script',
      title: '短视频脚本助手',
      summary: '输入主题和受众，快速生成可拍摄的短视频脚本。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['短视频', '脚本', '内容'],
      templateBody: '''
请帮我写一段短视频脚本。

主题：
{{主题}}

目标受众：
{{目标受众}}

平台：
{{平台}}

请输出：
1. 开场钩子
2. 主体分镜
3. 结尾引导
''',
      variables: [
        textVar('主题'),
        textVar('目标受众', defaultValue: '刚入门的新手'),
        textVar('平台', defaultValue: '抖音'),
      ],
      whenToUse: '适合选题确定后快速推进到拍摄脚本。',
      avoidWhen: '不要直接照念，拍摄前最好再做口播化调整。',
      exampleInput: '主题：如何把 AI 资源库用在日常工作里',
      exampleOutput: '开场会先抛痛点，再给三步上手路径。',
      featured: true,
    ),
    prompt(
      id: 'prompt-xiaohongshu-post',
      title: '小红书笔记草稿',
      summary: '根据产品卖点和目标人群，生成更像真实分享的笔记草稿。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['小红书', '种草', '文案'],
      templateBody: '''
请根据以下信息生成一篇小红书笔记草稿。

主题：
{{主题}}

产品卖点：
{{产品卖点}}

目标人群：
{{目标人群}}

要求：口语化、真诚、不夸张，避免太像硬广。
''',
      variables: [
        textVar('主题'),
        longVar('产品卖点'),
        textVar('目标人群', defaultValue: '效率工具爱好者'),
      ],
      whenToUse: '适合先出第一版草稿，再按个人语气和真实体验改写。',
      avoidWhen: '不要批量发布完全相同的文案。',
      exampleInput: '主题：本地优先的 AI 资源库 App',
      exampleOutput: '草稿会偏真实体验分享，而不是直接罗列功能。',
    ),
    prompt(
      id: 'prompt-title-polish',
      title: '标题优化器',
      summary: '围绕一个主题生成多种风格标题，方便选最合适的版本。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['标题', '点击率', '文案'],
      templateBody: '''
请围绕下面这个主题生成 10 个标题。

主题：
{{主题}}

平台：
{{平台}}

风格要求：
{{风格要求}}

请输出不同风格版本，并标注适合的场景。
''',
      variables: [
        textVar('主题'),
        textVar('平台', defaultValue: '小红书'),
        textVar('风格要求', defaultValue: '有吸引力，但不过度夸张'),
      ],
      whenToUse: '适合内容发布前做标题 A/B 备选。',
      avoidWhen: '不要一味追求刺激标题，平台和受众都会影响效果。',
      exampleInput: '主题：提示词、技能与 MCP 的区别',
      exampleOutput: '会给出教程型、经验型、踩坑型等不同标题方向。',
    ),
    prompt(
      id: 'prompt-product-copy',
      title: '产品卖点文案',
      summary: '把功能点改写成用户更能理解的价值表达。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['卖点', '文案', '转化'],
      templateBody: '''
请根据以下信息写产品卖点文案。

产品功能：
{{产品功能}}

目标用户：
{{目标用户}}

希望突出：
{{希望突出}}

请输出：一句话价值主张、3 条卖点、1 段适合详情页的说明。
''',
      variables: [
        longVar('产品功能'),
        textVar('目标用户', defaultValue: '开发者与知识工作者'),
        longVar('希望突出', defaultValue: '上手快、可复用、本地优先'),
      ],
      whenToUse: '适合落地页、应用商店描述和渠道介绍。',
      avoidWhen: '不要把内部技术实现直接当卖点，要翻译成用户收益。',
      exampleInput: '产品功能：支持提示词、技能和 MCP 分类管理',
      exampleOutput: '价值主张会更强调“少找、少忘、拿来就用”。',
    ),
    prompt(
      id: 'prompt-customer-reply',
      title: '客服回复助手',
      summary: '把用户问题整理成温和、清楚、有行动建议的回复。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['客服', '回复', '用户沟通'],
      templateBody: '''
请帮我回复下面这条用户消息。

用户原话：
{{用户原话}}

我们的处理原则：
{{处理原则}}

请输出一条可以直接发给用户的回复，要求：礼貌、清楚、有下一步。
''',
      variables: [
        longVar('用户原话'),
        longVar('处理原则', defaultValue: '先共情，再解释，再给解决路径'),
      ],
      whenToUse: '适合售后回复、社群答疑和评论区互动。',
      avoidWhen: '涉及退款、合同或高风险承诺时，仍建议人工复核。',
      exampleInput: '用户原话：为什么我打开后一直加载？',
      exampleOutput: '回复会先解释原因，再给出可执行的排查步骤。',
    ),
    prompt(
      id: 'prompt-persona-summary',
      title: '用户画像提炼',
      summary: '把访谈、评论和反馈整理成更可用的人群画像。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['用户画像', '访谈', '研究'],
      templateBody: '''
请根据下面的材料提炼用户画像。

原始材料：
{{原始材料}}

产品场景：
{{产品场景}}

请输出：
1. 典型用户类型
2. 他们最在意什么
3. 常见阻碍
4. 可以怎么打动他们
''',
      variables: [
        longVar('原始材料'),
        textVar('产品场景', defaultValue: 'AI 工具与工作提效'),
      ],
      whenToUse: '适合做内容选题、文案方向和产品优先级判断。',
      avoidWhen: '如果样本很少，结论要保守，避免过度概括。',
      exampleInput: '原始材料：20 条用户访谈摘录',
      exampleOutput: '可能会提炼出“开发者型”“轻运营型”“新手探索型”等分群。',
    ),
    prompt(
      id: 'prompt-content-calendar',
      title: '内容排期生成',
      summary: '围绕一个主题方向，生成连续一周或一月的内容排期。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['排期', '内容运营', '选题'],
      templateBody: '''
请根据下面的信息给我做一份内容排期。

主题方向：
{{主题方向}}

平台：
{{平台}}

排期周期：
{{排期周期}}

请输出：每天/每周选题、形式建议、发布重点和 CTA。
''',
      variables: [
        textVar('主题方向'),
        textVar('平台', defaultValue: '小红书 + 公众号'),
        textVar('排期周期', defaultValue: '7 天'),
      ],
      whenToUse: '适合内容运营、个人 IP 和专题活动准备。',
      avoidWhen: '排期只能做框架，仍需结合热点和真实产能调整。',
      exampleInput: '主题方向：AI 开发者工具与工作流',
      exampleOutput: '排期会覆盖科普、案例、踩坑、教程和互动话题。',
    ),
    prompt(
      id: 'prompt-landing-page-hero',
      title: '落地页首屏文案',
      summary: '生成一句主标题、一句副标题和首屏卖点，帮助页面更快讲清价值。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['落地页', '首屏', '价值表达'],
      templateBody: '''
请为下面这个产品写落地页首屏文案。

产品描述：
{{产品描述}}

目标用户：
{{目标用户}}

差异化优势：
{{差异化优势}}

请输出：
1. 主标题
2. 副标题
3. 3 条首屏卖点
''',
      variables: [
        longVar('产品描述'),
        textVar('目标用户', defaultValue: '开发者与内容创作者'),
        longVar('差异化优势'),
      ],
      whenToUse: '适合官网、活动页和新产品介绍页。',
      avoidWhen: '主标题要克制，不要同时塞入太多功能点。',
      exampleInput: '差异化优势：本地优先、可收藏、支持提示词 / 技能 / MCP',
      exampleOutput: '主标题会优先突出“把 AI 资产收拢到一个地方”。',
    ),
    prompt(
      id: 'prompt-user-interview-summary',
      title: '用户访谈总结',
      summary: '把访谈纪要整理成问题、需求和产品机会。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['访谈', '洞察', '用户研究'],
      templateBody: '''
请根据下面的访谈记录做总结。

访谈记录：
{{访谈记录}}

研究目标：
{{研究目标}}

请输出：
1. 用户主要痛点
2. 高频需求
3. 典型原话摘要
4. 对产品的启发
''',
      variables: [
        longVar('访谈记录'),
        textVar('研究目标', defaultValue: '确认功能是否值得做'),
      ],
      whenToUse: '适合需求验证、产品迭代和市场研究。',
      avoidWhen: '仍要回看原始访谈，避免被二次总结带偏。',
      exampleInput: '研究目标：验证新手是否能理解提示词 / 技能 / MCP 的差异',
      exampleOutput: '总结会重点提取“术语障碍”和“首屏引导需求”。',
    ),
    prompt(
      id: 'prompt-community-reply',
      title: '社区互动回复',
      summary: '把回复写得更像真人，既有价值又不过度营销。',
      scenario: '内容增长',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['社区', '互动', '回复'],
      templateBody: '''
请帮我写一条社区回复。

帖子或评论内容：
{{帖子或评论内容}}

我的目标：
{{我的目标}}

请输出一条简洁、有帮助、不过度推销的回复。
''',
      variables: [
        longVar('帖子或评论内容'),
        longVar('我的目标', defaultValue: '建立信任、顺带介绍产品'),
      ],
      whenToUse: '适合社区评论区、开发者论坛、产品群讨论。',
      avoidWhen: '不要写成硬广，先提供真实帮助再提产品。',
      exampleInput: '我的目标：回答“技能和提示词有什么区别”',
      exampleOutput: '回复会先解释差异，再给一个简单上手建议。',
    ),
  ];
}
