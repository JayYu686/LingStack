# LingStack

LingStack 是一个本地优先的 AI 资源库，主要用来整理三类高频资产：

- Prompt：可以直接复制使用的提示词模板
- Skill：可复用的方法、流程和工具定义
- MCP：连接 GitHub、文档、数据库等外部系统的配置模板和接入说明

这个项目的出发点很简单：当 Prompt、Skill、MCP 越积越多时，真正麻烦的不是“没有资源”，而是“找不到、筛不准、用起来不顺手、沉淀不下来”。LingStack 想先把这几个基础问题做扎实。

## 为什么做这个项目

我希望有一个能长期自己用下去的工具，而不是另一个只适合演示的 AI 壳子应用。它应该满足几件事：

- 资源统一收口，避免散落在笔记、聊天记录、浏览器书签和仓库里
- 手机上也能快速检索、筛选、复制、收藏和补充自己的版本
- 本地优先，离线可用，敏感配置尽量留在设备侧
- 官方目录可以更新，但用户自己的内容不会被轻易覆盖
- 架构保持克制，先把个人使用场景做稳，再考虑更重的协作能力

## 当前做到的能力

### 资源库

- 支持 Prompt、Skill、MCP 三类资源统一浏览
- 内置官方资源目录，并支持本地收藏、导入和精选合集
- 支持按资源类型、大类、标签、质量级别筛选
- 支持搜索、最近使用、精选合集和我的资源
- 资源详情页会展示适用场景、不适用场景、质量级别、验证状态等信息

### Prompt 工作台

- Prompt 详情页已经做成“填写 -> 预览 -> 复制”的工作台
- 支持 `text / longText / enum / code / boolean` 五类变量
- 必填变量没填完时，不允许复制看起来已经完成的结果
- 本地会记录最近使用、上次填写值、复制时间和使用次数

### Skill / MCP

- 官方 Skill 保持只读，可以先复制成“我的版本”再编辑
- MCP 支持远程 HTTP 测试页，可以探测、列出 `tools/resources/prompts`，也可以做自定义 JSON-RPC 调用
- Token 和 Header 存在安全存储中，不写进 SQLite

### 客户端与服务端

- Flutter 客户端支持 Windows 调试和 Android 安装测试
- Go 服务负责官方目录下发和同步骨架
- Android 端已经补了正式签名、包名、版本号、图标和启动页资源

## 技术架构

### 前端

- Flutter 3.41.x
- Riverpod
- go_router
- Drift + sqlite3
- flutter_secure_storage
- flutter_svg

### 后端

- Go 1.26.x
- 原生 HTTP / JSON API
- SQLite

### 分层方式

代码按比较克制的 layered 结构组织：

- Presentation：页面和纯展示组件
- Application：Prompt 工作台、Skill 编辑、MCP 测试等状态控制器
- Domain：资源模型、渲染规则、Schema 编解码
- Infrastructure：数据库、网络、安全存储、仓储实现

原则上 Widget 只负责展示和交互转发，不在页面里继续堆业务逻辑。

## 仓库结构

```text
.
├─ apps/
│  └─ mobile/                  Flutter 客户端
├─ services/
│  └─ sync-api/                Go 目录与同步服务
├─ contracts/
│  ├─ catalog/                 官方资源目录导出
│  └─ openapi/                 OpenAPI 合同
├─ docs/
│  ├─ branding/                图标、启动页、商店展示素材
│  └─ app-summary.zh-CN.md     产品总结
└─ README.md
```

## 本地运行

### Flutter 客户端

```powershell
cd apps/mobile
flutter pub get
flutter run -d windows
```

Android 调试：

```powershell
cd apps/mobile
flutter run
```

### Go 服务

```powershell
cd services/sync-api
go run ./cmd/sync-api
```

默认情况下，客户端即使不连后端，也能依赖本地目录正常浏览和使用。

## 质量检查

我当前主要用下面这些命令做回归：

```powershell
cd apps/mobile
flutter analyze
flutter build apk --release
flutter build windows --release
```

```powershell
cd services/sync-api
go test ./...
```

说明：

- 这台 Windows 机器上的 `flutter test` 曾经遇到过 Dart worker 挂住的问题，所以当前我更依赖 `flutter analyze`、目标构建和针对性的 smoke test。
- Android 真机会做基本安装和页面流转验证，目前主要覆盖 Xiaomi 13。

## Android 发布信息

- 应用名：灵感栈
- 包名：`com.jayyu.lingstack`
- 当前版本：`1.1.0+3`

构建产物默认输出到：

- APK：`apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- AAB：`apps/mobile/build/app/outputs/bundle/release/app-release.aab`
- Windows EXE：`apps/mobile/build/windows/x64/runner/Release/mobile.exe`

## 设计取舍

这个项目里有几条我会比较坚持的取舍：

- 本地优先比多端同步更优先
- 目录质量比单纯堆数量更重要
- Prompt、Skill、MCP 的体验重点不是“展示”，而是“能不能马上用”
- 不急着做重型 Agent 平台，先把资源管理、筛选、使用闭环做稳

## 当前边界

目前还没有做这些能力：

- 团队协作和权限体系
- 完整的云同步冲突处理
- MCP 本地 `stdio` 拉起
- Skill 在线真实调试调用
- 复杂语义搜索和向量检索

这些能力不是不做，而是当前阶段没必要先引进复杂度。

## 下一步

接下来最值得继续做的是：

1. 把资源质量体系继续做细，提升精选、验证、去重和合集组织能力
2. 把 Prompt 工作台继续打磨成真正的高频使用入口
3. 把 Skill 可视化编辑和 MCP 测试补到“够日常使用”的程度
4. 把同步、历史版本和冲突处理做稳
5. 完善移动端发布、埋点和问题定位链路

## 命名

- 中文名：灵感栈
- 英文名：LingStack

