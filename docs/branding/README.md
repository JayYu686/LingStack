# 灵感栈品牌资产

这套品牌资产围绕 `lingstack-mark.svg` 生成，当前已经覆盖项目内实际存在的客户端目标：`Android`、`iOS`、`Windows`。

## 源文件

- 品牌主标识：`apps/mobile/assets/branding/lingstack-mark.svg`
- 首页主视觉：`apps/mobile/assets/illustrations/hero-orbit.svg`
- Prompt 主题插画：`apps/mobile/assets/illustrations/prompt-card.svg`
- Skill 主题插画：`apps/mobile/assets/illustrations/skill-card.svg`
- MCP 主题插画：`apps/mobile/assets/illustrations/mcp-card.svg`

## 已替换的应用图标

- Android Launcher Icons：`apps/mobile/android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS App Icons：`apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/*`
- Windows App Icon：`apps/mobile/windows/runner/resources/app_icon.ico`

## 已接入的启动页资源

- Android 启动图：`apps/mobile/android/app/src/main/res/mipmap-*/launch_image.png`
- Android 启动背景：`apps/mobile/android/app/src/main/res/drawable/launch_background.xml`
- iOS Launch Image：`apps/mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/*`
- iOS Launch Screen：`apps/mobile/ios/Runner/Base.lproj/LaunchScreen.storyboard`

## 商店展示图

- 资源库主题：`docs/branding/store-poster-01-library.svg`
- 工作流主题：`docs/branding/store-poster-02-workflows.svg`
- MCP 连接主题：`docs/branding/store-poster-03-connect.svg`

PNG 导出结果位于：

- `docs/branding/exports/lingstack-icon-1024.png`
- `docs/branding/exports/launch-preview.png`
- `docs/branding/exports/store-poster-01-library.png`
- `docs/branding/exports/store-poster-02-workflows.png`
- `docs/branding/exports/store-poster-03-connect.png`

## 生成脚本

重新生成图标和展示图时，执行：

```powershell
cd apps/mobile
python -X utf8 tool/generate_brand_assets.py
```

脚本会重新写入 Android、iOS、Windows 图标资源，并导出当前的 PNG 预览图。
