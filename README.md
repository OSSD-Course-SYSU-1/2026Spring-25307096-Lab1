# MultiPictureBeautification（多设备图片美化）

基于 HarmonyOS ArkUI 开发的多设备图片美化应用，实现**一次开发、多端部署**。支持直板机、折叠屏、平板等多种设备形态，提供图片浏览、编辑、美化等完整功能。

## 📱 效果预览

### 设备适配

| 直板机 | 折叠屏 | 平板 |
|---|---|---|
| <img src='screenshots/device/phone.png' width=240> | <img src='screenshots/device/foldable.png' width=360> | <img src='screenshots/device/pad.png' width=480> |

### 功能演示视频

| 日期 | 内容 | 链接 |
|---|---|---|
| 2026-05-12 | 基础功能演示 | [📹 观看](screenshots/demo/PixPin_2026-05-12_16-51-18.mp4) |
| 2026-05-26 | 新增功能展示 | [📹 观看](screenshots/demo/PixPin_2026-05-26_12-51-09.mp4) |
| 2026-06-23 | 水印 & 马赛克工具 | [📹 观看](screenshots/demo/PixPin_2026-06-23_17-15-49.mp4) |
| 2026-07-09 | 最新功能展示 | [📹 观看](screenshots/demo/PixPin_2026-07-09_21-12-59.mp4) |

## 🎯 功能特性

### 图片浏览
- ✅ **自适应相册** — 响应式网格布局，适配不同屏幕尺寸
- ✅ **大图预览** — 支持双指缩放（Pinch Gesture）
- ✅ **缩略图列表** — 底部滑动缩略图，快速定位
- ✅ **左右滑动切换** — 手势互斥组合（缩放 × 滑动 × 双击），互不冲突
- ✅ **图片旋转** — 双击 90° 循环旋转（0° → 90° → 180° → 270° → 0°）

### 图片编辑
- ✅ **AI 智能美化** — 8 种预设滤镜（自然、美食、风景、人像、夜景、复古、黑白、鲜艳），强度滑块调节，长按预览原始效果
- ✅ **文字水印** — 自定义文字、颜色、透明度、旋转角度、字体大小
- ✅ **马赛克工具** — 画笔涂抹式打码，可调节画笔大小和模糊强度
- ✅ **贴纸/表情** — 内置 emoji 贴纸面板，拖拽添加到图片

### 交互体验
- ✅ **收藏功能** — 红心图标标记，`preferences` API 持久化存储，应用重启不丢失
- ✅ **删除功能** — 从列表移除图片，自动重建收藏索引
- ✅ **图片信息弹窗** — 文件名、尺寸、日期等元数据，全屏模态弹窗
- ✅ **国际化** — 中英文双语支持，base 资源完整覆盖
- ✅ **深色模式** — 跟随系统主题自动切换

### 多设备适配
- ✅ **Breakpoint 断点系统** — sm (< 600vp) / md (< 840vp) / lg (≥ 840vp)
- ✅ **折叠屏适配** — 监听 `display.on('change')` 实时切换布局
- ✅ **三层工程架构** — commons（公共层）+ features（特性层）+ product（产品层）

## 🏗️ 工程目录

```
MultiPictureBeautification/
├── AppScope/                                    # 全局应用配置
│   ├── app.json5                                # bundleName、版本号、图标
│   └── resources/                               # 全局资源
├── commons/                                     # 公共能力层
│   └── base/src/main/ets/
│       ├── constants/                           # 通用常量
│       └── utils/                               # 工具类
├── features/                                    # 基础特性层
│   ├── albumView/                               # 相册浏览模块
│   │   └── src/main/ets/
│   │       ├── constants/AlbumViewConstants.ets
│   │       └── view/
│   │           ├── AlbumView.ets                # 相册主视图
│   │           └── SideColumn.ets               # 侧边栏（平板/折叠屏）
│   ├── pictureView/                             # 大图预览模块
│   │   └── src/main/ets/
│   │       ├── pages/PictureViewIndex.ets       # 大图预览主页
│   │       ├── view/
│   │       │   ├── TopBar.ets                   # 顶部栏（返回/收藏/详情/删除）
│   │       │   ├── CenterPart.ets               # 中心大图（缩放/旋转/滑动）
│   │       │   ├── BottomBar.ets                # 底部栏（编辑/收藏/分享）
│   │       │   └── PreviewLists.ets             # 缩略图列表
│   │       ├── viewmodel/AdaptiveViewModel.ets  # 自适应视图模型
│   │       ├── utils/FavoritesStore.ets         # 收藏持久化
│   │       └── constants/PictureViewConstants.ets
│   └── pictureEdit/                             # 图片编辑模块
│       └── src/main/ets/
│           ├── views/PictureEdit.ets            # 编辑主视图
│           ├── viewmodel/AdaptiveViewModel.ets
│           └── constants/PictureEditConstants.ets
├── product/phone/                               # 产品定制层（手机）
│   └── src/main/ets/
│       ├── pages/Index.ets                      # 应用入口页
│       └── phoneability/PhoneAbility.ets        # UIAbility
├── screenshots/                                 # 截图 & 演示视频
│   ├── device/                                  # 设备截图
│   └── demo/                                    # 功能演示视频
├── docs/                                        # 文档 & 设计规格
├── build-profile.json5                          # 构建配置
├── hvigorfile.ts                                # Hvigor 构建入口
└── oh-package.json5                             # ohpm 依赖配置
```

## 🔧 技术栈

| 类别 | 技术 |
|---|---|
| 平台 | HarmonyOS 6.1 (API 23) |
| 语言 | ArkTS |
| UI 框架 | ArkUI（声明式） |
| 构建工具 | Hvigor 6.x |
| IDE | DevEco Studio 6.1+ |
| 架构模式 | Stage 模型 + 三层工程架构 |
| 状态管理 | `@State` / `@Link` / `@Provide` + `@Consume` / `AppStorage` + `@Watch` |
| 数据持久化 | `preferences` API |
| 手势系统 | `GestureGroup`（互斥模式）/ `PinchGesture` / `PanGesture` / `TapGesture` |

## 🚀 快速开始

### 环境要求

| 工具 | 版本 |
|---|---|
| HarmonyOS | 5.0.5 Release 及以上 |
| DevEco Studio | 6.0.2 Release 及以上 |
| HarmonyOS SDK | 6.0.2 Release SDK 及以上 |
| 支持设备 | 直板机、折叠屏（Mate X 系列）、平板 |

### 构建运行

```bash
# 1. 克隆仓库
git clone https://github.com/xieryongmiao/2026Spring-25307096-Lab1.git
cd 2026Spring-25307096-Lab1

# 2. 用 DevEco Studio 打开项目
# File → Open → 选择项目根目录

# 3. 连接设备/启动模拟器，点击运行
```

## 📋 技术亮点

1. **手势互斥组合** — 使用 `GestureGroup(GestureMode.Exclusive)` 将缩放、滑动、双击三种手势组合，避免冲突
2. **AppStorage 事件通信** — 用 `AppStorage.setOrCreate()` + `@StorageLink` + `@Watch` 替代不可靠的 `@Provide/@Consume` 类实例传递
3. **全屏模态弹窗** — 弹窗置于页面最外层 Stack，`hitTestBehavior(HitTestMode.Block)` 防穿透
4. **Breakpoint 响应式** — 监听 `display.on('change')` 实时切换单栏/双栏布局
5. **三层工程架构** — commons / features / product 分层复用，一套代码多端部署
6. **数据持久化** — `preferences` API 实现收藏状态跨会话保持
7. **国际化** — 中英文双语，base 资源完整覆盖，新增功能即含翻译
8. **AI 编辑** — 8 种预设滤镜 + 强度调节 + 长按预览原图

## 📄 相关文档

- [新增功能说明 (v2)](NEW_FEATURES.md)
- [项目文件描述](PROJECT_FILES_DESCRIPTION.md)
- [设计规格 & 实现计划](docs/)

## 📝 许可证

本项目基于 Apache 2.0 协议开源，详见 [LICENSE](LICENSE)。
