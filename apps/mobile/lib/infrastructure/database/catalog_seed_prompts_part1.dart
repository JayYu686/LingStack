import '../../domain/models.dart';
import 'catalog_seed_types.dart';

List<PromptSeedBundle> buildPromptSeedsPart1(String stamp) {
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

  PromptVariable codeVar(
    String name, {
    String description = '',
    String defaultValue = '',
  }) => PromptVariable(
    name: name,
    type: PromptVariableType.code,
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
      id: 'prompt-code-review',
      title: '代码审查与风险提示',
      summary: '把代码变更贴进去，快速得到高风险问题、修复建议和测试缺口。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['开发', 'Code Review', 'Flutter'],
      templateBody: '''
你现在是一名资深工程师，请审查下面这段 {{代码语言}} 代码。

代码内容：
{{代码内容}}

本次重点关注：
{{重点关注}}

请按以下结构输出：
1. 高风险问题
2. 可执行修复建议
3. 需要补的测试
4. 如果必须合并，风险提示语
''',
      variables: [
        textVar('代码语言', defaultValue: 'Flutter'),
        codeVar('代码内容', description: '粘贴待审查代码'),
        longVar('重点关注', defaultValue: '性能、可维护性、潜在 bug'),
      ],
      whenToUse: '适合在提交 PR 前、收到复杂改动后、或者自测通过但仍不放心时使用。',
      avoidWhen: '它不能替代真实编译、测试和线上验证。',
      exampleInput: '代码语言：Go\n重点关注：并发安全、错误处理',
      exampleOutput: '高风险问题：共享 map 未加锁。修复建议：补 mutex 或改用 channel 归并写入。',
      featured: true,
    ),
    prompt(
      id: 'prompt-bug-triage',
      title: '报错定位助手',
      summary: '输入异常堆栈和上下文，先缩小排查范围，再决定具体调试动作。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['调试', '异常', '排障'],
      templateBody: '''
下面是一段错误信息，请帮我定位问题根因。

错误信息：
{{错误信息}}

运行上下文：
{{运行上下文}}

请输出：
1. 最可能的 3 个根因
2. 推荐排查顺序
3. 最小验证步骤
4. 如果是线上事故，建议先做什么止损
''',
      variables: [
        longVar('错误信息'),
        longVar('运行上下文', defaultValue: '本地开发环境，最近刚改过相关模块'),
      ],
      whenToUse: '适合遇到陌生异常、线索很多但方向不明确时快速定界。',
      avoidWhen: '涉及高危生产操作时，仍需先走应急流程和权限审批。',
      exampleInput: '错误信息：Null check operator used on a null value',
      exampleOutput: '优先怀疑空数据未判空、接口字段缺失、异步状态过期。',
    ),
    prompt(
      id: 'prompt-pr-description',
      title: 'PR 描述生成器',
      summary: '把改动摘要贴进去，生成清楚、易审阅的 PR 说明。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['PR', '协作', '文档'],
      templateBody: '''
请根据以下信息生成一份清晰的 PR 描述。

改动摘要：
{{改动摘要}}

测试结果：
{{测试结果}}

请输出：
- 背景
- 主要改动
- 风险点
- 测试说明
- 回滚提示
''',
      variables: [
        longVar('改动摘要'),
        longVar('测试结果', defaultValue: '本地构建通过，核心流程已回归'),
      ],
      whenToUse: '适合合并前整理背景和测试信息，减少 reviewer 来回追问。',
      avoidWhen: '如果改动边界还没想清楚，不要直接把生成结果当正式说明。',
      exampleInput: '改动摘要：新增资源目录接口并改造首页文案',
      exampleOutput: '背景：资源库首页对新人不够友好。主要改动：新增目录下发、首页重写、落库回退。',
    ),
    prompt(
      id: 'prompt-api-doc',
      title: '接口说明整理',
      summary: '把接口字段和行为描述整理成对外可读文档。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['API', '文档', '后端'],
      templateBody: '''
请把下面这段接口说明整理成开发文档。

接口信息：
{{接口信息}}

受众：
{{受众}}

请输出：
1. 接口用途
2. 请求参数表
3. 响应字段表
4. 错误码与常见问题
5. 一个最小调用示例
''',
      variables: [
        longVar('接口信息'),
        textVar('受众', defaultValue: '前端工程师'),
      ],
      whenToUse: '适合接口刚写完、历史说明过散、或者准备对外开放时使用。',
      avoidWhen: '如果接口契约本身不稳定，先确认字段再出正式文档。',
      exampleInput: '接口信息：GET /v1/catalog/resources 返回资源列表',
      exampleOutput: '接口用途：按类型或关键词获取资源。参数表：type、query。',
    ),
    prompt(
      id: 'prompt-sql-optimize',
      title: 'SQL 优化建议',
      summary: '分析慢 SQL 的瓶颈，给出更稳妥的重写思路。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['SQL', '性能', '数据库'],
      templateBody: '''
请帮我分析并优化这段 SQL。

SQL：
{{SQL}}

表结构与索引：
{{表结构与索引}}

当前问题：
{{当前问题}}

请输出：
1. 性能瓶颈判断
2. 可尝试的 SQL 重写
3. 索引建议
4. 上线前要验证的风险
''',
      variables: [
        codeVar('SQL'),
        longVar('表结构与索引'),
        longVar('当前问题', defaultValue: '响应时间长，偶发超时'),
      ],
      whenToUse: '适合慢查询分析、报表 SQL 迭代和复杂筛选逻辑优化。',
      avoidWhen: '不要在不了解数据分布和索引影响时直接照抄改写结果上线。',
      exampleInput: '当前问题：按时间范围查询时扫描行数很高',
      exampleOutput: '优先检查时间字段复合索引和回表次数，再决定是否拆子查询。',
    ),
    prompt(
      id: 'prompt-unit-test',
      title: '测试用例补全器',
      summary: '根据现有函数或模块行为，补出覆盖边界条件的测试建议。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['测试', '单测', '质量'],
      templateBody: '''
请为下面这段 {{代码语言}} 代码设计测试。

代码：
{{代码}}

当前已覆盖：
{{当前已覆盖}}

请输出：
1. 必补的核心用例
2. 边界与异常用例
3. 建议的测试命名
4. 如果要先补最值钱的 3 条，应选哪 3 条
''',
      variables: [
        textVar('代码语言', defaultValue: 'Dart'),
        codeVar('代码'),
        longVar('当前已覆盖', defaultValue: '正常路径已覆盖'),
      ],
      whenToUse: '适合补测试、评估测试缺口和 review 单测设计。',
      avoidWhen: '不要把模型给出的用例直接当最终断言，仍需结合真实业务语义。',
      exampleInput: '代码语言：Go\n当前已覆盖：成功路径、空结果路径',
      exampleOutput: '建议补并发场景、超时场景、字段缺失场景。',
    ),
    prompt(
      id: 'prompt-refactor-plan',
      title: '重构计划拆解',
      summary: '先把重构风险讲清楚，再给出可分阶段执行的改造步骤。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['重构', '架构', '技术债'],
      templateBody: '''
请为下面这段系统或模块设计重构计划。

现状描述：
{{现状描述}}

希望达到的目标：
{{目标}}

约束条件：
{{约束条件}}

请输出：
1. 当前主要问题
2. 分阶段重构方案
3. 每阶段风险与回滚点
4. 建议优先落地的最小改造
''',
      variables: [
        longVar('现状描述'),
        longVar('目标'),
        longVar('约束条件', defaultValue: '不能大面积中断现有功能'),
      ],
      whenToUse: '适合面对存量技术债、模块拆分、目录重组这类系统性改造。',
      avoidWhen: '不要在目标和约束都没对齐时直接开重构任务。',
      exampleInput: '目标：从脚本堆积改成可维护的单仓结构',
      exampleOutput: '第一阶段先做边界梳理与接口收口，第二阶段再拆基础设施层。',
    ),
    prompt(
      id: 'prompt-architecture-review',
      title: '架构方案评审',
      summary: '对比两个方案的复杂度、风险和后续维护成本。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['架构', '评审', '方案'],
      templateBody: '''
请从工程视角评审下面的架构方案。

方案描述：
{{方案描述}}

业务目标：
{{业务目标}}

评审重点：
{{评审重点}}

请输出：
1. 优点
2. 隐藏成本
3. 未来 6 个月可能暴露的问题
4. 是否建议采用，以及前提条件
''',
      variables: [
        longVar('方案描述'),
        longVar('业务目标'),
        longVar('评审重点', defaultValue: '可维护性、扩展性、交付速度'),
      ],
      whenToUse: '适合技术方案评审、选型比较和重要改造前的风险判断。',
      avoidWhen: '如果方案还停留在空泛口号，先补关键约束和落地边界。',
      exampleInput: '方案描述：Flutter 本地优先 + Go 轻量同步服务',
      exampleOutput: '优点：部署轻、链路短。风险：多端冲突处理和数据迁移需要提前设计。',
    ),
    prompt(
      id: 'prompt-security-audit',
      title: '安全风险初筛',
      summary: '从鉴权、权限、数据暴露和输入处理角度做第一轮安全检查。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.advanced,
      tags: const ['安全', '鉴权', '审计'],
      templateBody: '''
请对下面的系统设计或代码片段做安全初筛。

内容：
{{内容}}

部署环境：
{{部署环境}}

请输出：
1. 高优先级安全风险
2. 攻击面或误用方式
3. 优先修复建议
4. 上线前至少要补的验证项
''',
      variables: [
        longVar('内容'),
        textVar('部署环境', defaultValue: '公网可访问的正式环境'),
      ],
      whenToUse: '适合功能上线前、开放 API 前、或者接入第三方服务前做快速自检。',
      avoidWhen: '它不是正式安全审计，不能替代渗透测试和权限评估。',
      exampleInput: '部署环境：自托管 VPS，支持用户自定义 API Key',
      exampleOutput: '优先检查密钥存储、日志脱敏、错误回显和最小权限设计。',
    ),
    prompt(
      id: 'prompt-performance-diagnosis',
      title: '性能瓶颈诊断',
      summary: '把慢点、指标和调用链贴进去，先判断瓶颈方向。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['性能', '分析', '优化'],
      templateBody: '''
请根据以下信息诊断性能瓶颈。

现象描述：
{{现象描述}}

监控或日志线索：
{{监控线索}}

系统背景：
{{系统背景}}

请输出：
1. 最可能的瓶颈位置
2. 验证顺序
3. 优先级最高的优化动作
4. 不建议盲目做的优化
''',
      variables: [
        longVar('现象描述'),
        longVar('监控线索'),
        longVar('系统背景', defaultValue: '接口型应用，请求量波动较大'),
      ],
      whenToUse: '适合先定方向，再决定是查数据库、网络、缓存还是前端渲染。',
      avoidWhen: '不要用它替代真实压测和 profiling 数据。',
      exampleInput: '现象描述：高峰期首页首屏偶发超过 2 秒',
      exampleOutput: '先检查远端目录接口、缓存命中率、数据库初始化时机。',
    ),
    prompt(
      id: 'prompt-log-analysis',
      title: '日志线索整理',
      summary: '把一段混乱日志整理成时间线、关键异常和下一步排查方向。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['日志', '排障', '时间线'],
      templateBody: '''
请帮我分析这段日志。

日志内容：
{{日志内容}}

关注目标：
{{关注目标}}

请输出：
1. 时间线
2. 可疑异常
3. 最关键的上下文缺口
4. 下一步应该补抓什么日志
''',
      variables: [
        longVar('日志内容'),
        longVar('关注目标', defaultValue: '定位异常、确认触发顺序'),
      ],
      whenToUse: '适合日志很长、排查容易迷路时先做一次结构化整理。',
      avoidWhen: '如果日志已缺失关键字段，要先补观测再继续分析。',
      exampleInput: '关注目标：为什么支付回调后订单没有更新',
      exampleOutput: '时间线显示回调已到达，但订单状态写入前出现事务回滚。',
    ),
    prompt(
      id: 'prompt-regex-explain',
      title: '正则表达式解释器',
      summary: '快速解释复杂正则的意图、匹配边界和可能误伤。',
      scenario: '开发提效',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['正则', '解释', '文本处理'],
      templateBody: '''
请解释这段正则表达式，并指出风险。

正则：
{{正则}}

样例文本：
{{样例文本}}

请输出：
1. 正则每一段的含义
2. 会匹配到什么
3. 可能漏掉或误伤什么
4. 如果要更稳妥，怎么改
''',
      variables: [
        textVar('正则'),
        longVar('样例文本', defaultValue: '示例文本可选，但建议提供'),
      ],
      whenToUse: '适合维护历史正则、review 提交、或者排查文本提取问题。',
      avoidWhen: '如果你要处理复杂结构化文档，正则未必是最好方案。',
      exampleInput: r'正则：^\d{4}-\d{2}-\d{2}$',
      exampleOutput: '它只保证格式像日期，不保证 2026-19-99 这种非法日期被过滤。',
    ),
    prompt(
      id: 'prompt-meeting-summary',
      title: '会议纪要整理',
      summary: '把会议原文整理成结论、待办、负责人和时间点。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['会议', '纪要', '待办'],
      templateBody: '''
请把下面的会议记录整理成纪要。

会议记录：
{{会议记录}}

会议主题：
{{会议主题}}

请输出：
1. 会议结论
2. 待办事项
3. 负责人
4. 截止时间
5. 需要继续确认的问题
''',
      variables: [
        longVar('会议记录'),
        textVar('会议主题', defaultValue: '项目同步会'),
      ],
      whenToUse: '适合语音转写、群聊摘录和会后快速同步。',
      avoidWhen: '责任分配敏感时，仍建议人工确认表述。',
      exampleInput: '会议主题：资源库首页改版',
      exampleOutput: '结论：首页改为资源库定位；待办：补中文文案、扩资源目录。',
      featured: true,
    ),
    prompt(
      id: 'prompt-weekly-report',
      title: '周报整理助手',
      summary: '把本周零散工作整理成对上可汇报、对内可同步的周报。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['周报', '汇报', '总结'],
      templateBody: '''
请帮我整理一份周报。

本周工作碎片：
{{本周工作碎片}}

下周计划：
{{下周计划}}

请输出：
1. 本周完成
2. 关键结果
3. 风险与阻塞
4. 下周重点
''',
      variables: [
        longVar('本周工作碎片'),
        longVar('下周计划', defaultValue: '待补充'),
      ],
      whenToUse: '适合工作碎片很多、需要快速合并成正式汇报时使用。',
      avoidWhen: '不要让模型编造成果，事实材料要自己先提供。',
      exampleInput: '本周工作碎片：补了目录接口、修了 Windows 启动问题',
      exampleOutput: '本周完成：打通官方目录下发链路；风险：资源文案仍需统一。',
    ),
    prompt(
      id: 'prompt-requirement-breakdown',
      title: '需求拆解助手',
      summary: '把模糊需求拆成目标、范围、依赖和待确认问题。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['需求', '拆解', '产品'],
      templateBody: '''
请帮我拆解下面这条需求。

需求描述：
{{需求描述}}

上线目标或时间：
{{上线目标}}

请输出：
1. 目标与成功标准
2. 功能范围
3. 不做什么
4. 依赖与风险
5. 待确认问题
''',
      variables: [
        longVar('需求描述'),
        textVar('上线目标', defaultValue: '两周内给出可用版本'),
      ],
      whenToUse: '适合需求刚提出、边界模糊、需要先把讨论拉到同一平面。',
      avoidWhen: '如果已经进入细化设计阶段，应该结合真实方案继续拆分任务。',
      exampleInput: '需求描述：把提示词、技能和 MCP 做成小白可用的资源库',
      exampleOutput: '目标：首屏 5 秒看懂；不做：团队空间和复杂权限系统。',
      featured: true,
    ),
    prompt(
      id: 'prompt-proposal-outline',
      title: '方案文档大纲',
      summary: '先搭好文档骨架，再往里填细节，减少从零开写的阻力。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['方案', '文档', '大纲'],
      templateBody: '''
请根据下面的信息生成一份方案文档大纲。

主题：
{{主题}}

背景信息：
{{背景信息}}

目标读者：
{{目标读者}}

请输出一个清晰的大纲，至少包括背景、目标、方案、风险、排期与验收。
''',
      variables: [
        textVar('主题'),
        longVar('背景信息'),
        textVar('目标读者', defaultValue: '团队负责人和协作同学'),
      ],
      whenToUse: '适合先搭骨架，再分块补充详细内容。',
      avoidWhen: '如果你还没想清楚结论，只能把它当思考辅助，不能直接成稿。',
      exampleInput: '主题：官方资源动态下发方案',
      exampleOutput: '大纲：背景、目标、方案概览、客户端改造、后端接口、风险与验收。',
    ),
    prompt(
      id: 'prompt-email-reply',
      title: '正式邮件回复',
      summary: '把口语化信息整理成礼貌、清楚、带行动项的邮件。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['邮件', '沟通', '商务'],
      templateBody: '''
请帮我写一封邮件回复。

对方来信：
{{对方来信}}

我的核心诉求：
{{我的核心诉求}}

语气要求：
{{语气要求}}

请输出一封简洁、礼貌、可直接发送的回复邮件。
''',
      variables: [
        longVar('对方来信'),
        longVar('我的核心诉求'),
        textVar('语气要求', defaultValue: '专业、礼貌、不卑不亢'),
      ],
      whenToUse: '适合跨团队沟通、外部合作回复和正式说明。',
      avoidWhen: '敏感承诺和商务条款仍需人工确认后再发送。',
      exampleInput: '我的核心诉求：延期两天交付，并说明当前风险已收敛',
      exampleOutput: '建议表达延期原因、已完成事项、最新交付时间和补偿动作。',
    ),
    prompt(
      id: 'prompt-data-insight',
      title: '数据洞察提炼',
      summary: '把表格或指标变化整理成业务能理解的洞察和建议。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.intermediate,
      tags: const ['数据', '分析', '洞察'],
      templateBody: '''
请根据下面的数据变化提炼洞察。

数据说明：
{{数据说明}}

业务背景：
{{业务背景}}

请输出：
1. 关键变化
2. 最可能原因
3. 风险提示
4. 建议下一步验证动作
''',
      variables: [longVar('数据说明'), longVar('业务背景')],
      whenToUse: '适合周会汇报、复盘分析和经营数据快读。',
      avoidWhen: '不要把相关性直接说成因果，仍需结合业务验证。',
      exampleInput: '数据说明：注册上涨 20%，付费率下降 5%',
      exampleOutput: '可能是低质量流量进入，建议按渠道拆解注册后留存和转化。',
    ),
    prompt(
      id: 'prompt-sop-draft',
      title: 'SOP 草案生成',
      summary: '把经验做法整理成新同学也能照着执行的 SOP。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['SOP', '流程', '知识沉淀'],
      templateBody: '''
请把下面的经验或流程整理成 SOP 草案。

原始说明：
{{原始说明}}

适用对象：
{{适用对象}}

请输出：
1. 目标
2. 前置条件
3. 操作步骤
4. 常见问题
5. 交付标准
''',
      variables: [
        longVar('原始说明'),
        textVar('适用对象', defaultValue: '新同学'),
      ],
      whenToUse: '适合把个人经验整理成可交接、可复制的流程文档。',
      avoidWhen: '如果流程变化很快，记得后续持续维护版本。',
      exampleInput: '原始说明：每周五同步资源目录、跑导出脚本、检查 Windows 构建',
      exampleOutput: '前置条件：本地已安装 Flutter 与 Go；步骤：更新目录、导出、验证、发布。',
    ),
    prompt(
      id: 'prompt-training-outline',
      title: '培训分享提纲',
      summary: '快速生成一场内部分享或培训的结构化提纲。',
      scenario: '办公协作',
      difficulty: ResourceDifficulty.beginner,
      tags: const ['培训', '分享', '提纲'],
      templateBody: '''
请为下面的主题生成一份培训分享提纲。

主题：
{{主题}}

听众背景：
{{听众背景}}

时长：
{{时长}}

请输出：
1. 开场
2. 核心知识点
3. 案例演示
4. 常见问题
5. 行动建议
''',
      variables: [
        textVar('主题'),
        textVar('听众背景', defaultValue: '刚接触相关工具的新同学'),
        textVar('时长', defaultValue: '30 分钟'),
      ],
      whenToUse: '适合内部分享、培训和 onboarding 讲解准备。',
      avoidWhen: '如果内容很专业，仍需结合真实案例和组织语境打磨。',
      exampleInput: '主题：如何把提示词、技能和 MCP 用在日常工作里',
      exampleOutput: '开场：先讲三者差异；案例：代码审查、会议纪要、GitHub 连接。',
    ),
  ];
}
