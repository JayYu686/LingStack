# LingStack / 灵感栈

灵感栈是一款面向个人开发者与知识工作者的本地优先 AI 资源库应用，用来统一管理三类高频资产：

- Prompt：可以直接复制使用的提示词模板
- Skill：可复用的方法、能力定义和工具说明
- MCP：连接 GitHub、文档、数据库等外部系统的配置模板与接入说明

当前仓库采用单仓结构，包含 Flutter 移动端、Go 目录/同步服务、共享合同与品牌资产。

## 项目目标

这个项目不是单纯的“提示词笔记本”，而是一个面向真实使用场景的 AI 资源管理工具：

- 用资源库而不是杂乱备忘录的方式组织 Prompt、Skill 和 MCP
- 本地优先，可离线浏览、搜索、收藏、导入
- 官方资源可通过轻量 Go 服务动态下发
- 用户自己的收藏和导入保留在本地，优先保护隐私与可控性
- 界面强调小白友好，先讲用途，再讲步骤，最后才讲技术细节

## 当前能力

### 资源库

- 官方资源目录已内置到本地数据库，并支持通过 Go 服务增量刷新
- 三类资源当前规模均已超过 100 条
- 支持精选合集、热门资源、收藏、本地导入
- 支持按大类与标签筛选
- 支持中文输入法友好的搜索防抖与提交查询

### 移动端

- Flutter 构建，支持 Windows 调试与 Android 安装测试
- 本地 SQLite 持久化
- 冷静简洁的 AI-Native 风格 UI
- Prompt / Skill / MCP 分别采用适合自身的详情页信息结构
- Android 已接入 launcher icon、adaptive icon、splash 资源链路

### 服务端

- Go 实现轻量目录与同步服务
- 支持官方目录下发
- 预留同步、MCP 探测、AI 摘要/分类等接口骨架
- 使用 SQLite，适合个人部署与轻量自托管

## 技术栈

### 前端

- Flutter 3.41.x
- Riverpod
- go_router
- Drift + sqlite3
- Dio
- flutter_secure_storage
- flutter_svg

### 后端

- Go 1.26.x
- 原生 HTTP/JSON API
- SQLite

### 资源与合同

- OpenAPI 合同位于 `contracts/openapi`
- 官方目录 JSON 位于 `contracts/catalog` 与 `services/sync-api/internal/catalog`
- 品牌与商店素材位于 `docs/branding`

## 仓库结构

```text
.
├─ apps/
│  └─ mobile/                 Flutter 移动端
├─ services/
│  └─ sync-api/               Go 目录与同步服务
├─ contracts/
│  ├─ catalog/                官方资源目录导出
│  └─ openapi/                OpenAPI 合同
├─ docs/
│  ├─ branding/               图标、启动页、商店展示素材
│  └─ app-summary.zh-CN.md    产品总结
└─ README.md
```

## 本地运行

### 1. 运行 Flutter 客户端

```powershell
cd apps/mobile
flutter pub get
flutter run -d windows
```

如果要跑 Android：

```powershell
cd apps/mobile
flutter run -d android
```

### 2. 运行 Go 服务

在当前网络环境下，建议显式指定 Go 代理：

```powershell
cd services/sync-api
$env:GOPROXY='https://goproxy.cn,direct'
$env:GOSUMDB='off'
$env:GOCACHE='D:\PROJECTS\AIdeveloper\.cache\go-build'
$env:GOMODCACHE='D:\PROJECTS\AIdeveloper\.cache\gopath\pkg\mod'
go run ./cmd/sync-api
```

默认监听：

```text
http://127.0.0.1:8080
```

Android 模拟器默认目录地址可通过 `SYNC_API_BASE_URL` 覆盖。

## 测试与质量检查

### Flutter

```powershell
cd apps/mobile
flutter analyze
flutter test
```

### Go

```powershell
cd services/sync-api
$env:GOPROXY='https://goproxy.cn,direct'
$env:GOSUMDB='off'
$env:GOCACHE='D:\PROJECTS\AIdeveloper\.cache\go-build'
$env:GOMODCACHE='D:\PROJECTS\AIdeveloper\.cache\gopath\pkg\mod'
go test ./...
```

## Android APK

### 打包

```powershell
cd apps/mobile
flutter build apk --release
```

### 输出路径

```text
apps/mobile/build/app/outputs/flutter-apk/app-release.apk
```

### 安装到真机

```powershell
adb install -r "D:\PROJECTS\AIdeveloper\apps\mobile\build\app\outputs\flutter-apk\app-release.apk"
```

## 图标与品牌资源

品牌主标识源文件：

```text
apps/mobile/assets/branding/lingstack-mark.svg
```

资源生成脚本：

```text
apps/mobile/tool/generate_brand_assets.py
```

脚本会生成：

- Android launcher icon / round icon / adaptive icon 前景资源
- iOS App Icon
- Windows icon
- 启动页预览图
- 商店展示图导出

## 设计原则

- 本地优先：优先保证离线可用、加载稳定、数据私密
- 小白友好：先说明“这是什么”，再说明“下一步怎么用”
- 内容优先：资源卡片和详情页优先服务于快速使用，而不是展示技术字段
- 平滑升级：v1 先解决个人资源库场景，不提前为团队协作和复杂编排付出过高复杂度

## 当前已知边界

- Android 目前输出的是测试签名包，不适合正式分发
- 服务端仍然是轻量目录/同步骨架，不是完整商业化后台
- MCP 以“目录、说明、配置模板”方式为主，尚未内置复杂运行时编排
- 官方资源质量已经达到原型可用标准，但仍需要持续人工筛选与迭代

## 适合谁

- 想系统管理提示词、工具配置和 MCP 说明的开发者
- 经常需要反复复用 AI 工作流的人
- 需要在手机上快速查、快速复制、快速收藏的人
- 想要一套可本地掌控、可自托管演进的 AI 资产库的人

## 后续方向

- 继续扩充高质量资源，并引入审核与版本机制
- 增加职业入口与任务入口，而不仅是资源类型入口
- 完善同步冲突处理与用户侧版本历史
- 增加更强的 Prompt 变量填写和渲染体验
- 增加 Skill 的 JSON Schema 可视化编辑与真实调试能力
- 完善 MCP 连接测试、客户端兼容说明和风险提示

## 仓库名称

- 中文名：灵感栈
- GitHub 仓库名：LingStack
