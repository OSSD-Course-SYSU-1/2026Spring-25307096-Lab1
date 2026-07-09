# 工程文件描述文档 - 多设备图片美化应用

## 项目概述

本项目是一个基于 HarmonyOS 的多设备图片美化应用，采用"三层工程架构"（commons/features/products）实现一次开发、多端部署。支持直板机(phone)、折叠屏(foldable)、平板(tablet)三种设备形态，通过自适应布局和响应式布局实现不同屏幕尺寸的 UI 适配。

**技术栈**: HarmonyOS 5.0.5+, DevEco Studio 6.0.2+, ArkTS, ArkUI

---

## 一、工程目录总览

```
MultiPictureBeautification/
├── AppScope/                          # 应用全局配置
│   ├── app.json5                      # 应用包名、版本号等配置
│   └── resources/                     # 全局资源（图标、字符串）
├── build-profile.json5                # 构建配置（模块、产品、签名）
├── oh-package.json5                   # 项目依赖包配置
├── hvigorfile.ts                      # Hvigor 构建入口
├── hvigor/                            # Hvigor 构建工具配置
│   └── hvigor-config.json5
├── commons/                           # 【公共能力层】
│   └── base/                          # 基础能力模块（HAR）
├── features/                          # 【基础特性层】
│   ├── pictureView/                   # 大图预览模块（HAR）
│   ├── pictureEdit/                   # 图片编辑模块（HAR）
│   └── albumView/                     # 相册模块（HAR）
├── product/                           # 【产品定制层】
│   └── phone/                         # 手机/平板入口模块（HAP）
├── screenshots/                       # 应用效果截图
└── README.md                          # 项目说明文档
```

---

## 二、各文件详细说明

### 2.1 根目录配置文件

#### `build-profile.json5` (第1-86行)
项目级构建配置文件，定义了：
- **signingConfigs**: 签名配置（空数组，使用默认签名）
- **products**: 产品配置，支持 HarmonyOS 运行时，兼容 SDK 5.0.5，目标 SDK 6.0.2
- **modules**: 声明5个子模块：phone(入口)、base(公共库)、pictureview、albumview、pictureedit
- 各模块通过 `srcPath` 指定源码路径，通过 `applyToProducts` 关联目标产品

#### `oh-package.json5` (第1-12行)
包管理配置文件，modelVersion 6.0.0，包名为 `multipicturebeautification`，版本 1.0.0。

#### `hvigorfile.ts` (第1-6行)
Hvigor 构建系统入口文件，引用 `@ohos/hvigor-ohos-plugin` 的 `appTasks` 作为系统插件。

---

### 2.2 AppScope/ - 应用全局配置

#### `AppScope/app.json5` (第1-10行)
应用级别的清单配置：
- **bundleName**: `com.example.multipicturebeautification` — 应用唯一标识
- **vendor**: example
- **versionCode**: 1000000, **versionName**: 1.0.0
- **icon**: 应用图标引用 `$media:app_icon`
- **label**: 应用名称引用 `$string:app_name`

#### `AppScope/resources/base/element/string.json`
全局字符串资源，包含应用名称等文本。

---

### 2.3 commons/base/ - 公共能力层

这是三层架构的底层，提供可被所有特性层复用的基础能力。

#### `commons/base/Index.ets` (第1-3行)
模块对外导出接口，导出三个核心类：
- `BaseConstants` — 基础常量
- `BreakpointConstants` — 断点常量
- `BreakpointType` — 断点泛型工具类

#### `commons/base/src/main/ets/constants/BaseConstants.ets` (第1-139行)
**基础常量类**，包含：
- **尺寸常量**: FULL_PERCENT, FULL_HEIGHT, FULL_WIDTH 等百分比/字符串尺寸
- **字体属性**: 字体家族(FONT_FAMILY_*)、字号(FONT_SIZE_*)、字重(FONT_WEIGHT_*)
- **布局常量**: 各设备形态下的 Tab 高度/宽度、联系人面板宽高、文档标题高度等
- **设备网格列**: DEVICE_GRID_COLUMNS 数组
- **设备类型枚举**: CurrentFeature(首页/小程序/文档)、CurrentPage(首页/会话/朋友圈/我的)、DeviceTypes(手机/平板/2in1)

#### `commons/base/src/main/ets/constants/BreakpointConstants.ets` (第1-57行)
**响应式断点常量**，定义三种断点：
- **BREAKPOINT_SM** ('sm'): 小屏设备，宽度 < 600vp
- **BREAKPOINT_MD** ('md'): 中屏设备，600vp ≤ 宽度 < 840vp
- **BREAKPOINT_LG** ('lg'): 大屏设备，宽度 ≥ 840vp
- **BREAKPOINT_SCOPE**: 断点范围数组 [0, 320, 600, 840]
- **GRID_ROW_COLUMNS**: 不同断点下的栅格列数
- **GRID_COLUMN_SPANS**: 不同断点下的列跨度

#### `commons/base/src/main/ets/utils/BreakpointType.ets` (第1-37行)
**断点泛型工具类**，支持为不同设备类型存储不同类型 T 的值。核心方法：
- `GetValue(currentBreakpoint)`: 根据当前断点返回对应的 sm/md/lg 值
- 通过泛型 `<T>` 可适配字符串、数字、资源等任意类型

#### `commons/base/src/main/module.json5` (第1-10行)
模块清单配置，type 为 `har`（Harmony Archive），支持 phone/tablet/2in1 设备。

#### `commons/base/BuildProfile.ets`
构建时生成的配置文件，由 Hvigor 自动管理。

#### `commons/base/hvigorfile.ts`
公共模块的 Hvigor 构建配置，引用 HAR 插件任务。

---

### 2.4 features/pictureView/ - 大图预览模块

主界面功能模块，负责展示大图及关联操作。

#### `features/pictureView/Index.ets` (第1-16行)
模块对外导出，暴露 `PictureViewIndex` 组件。

#### `features/pictureView/src/main/ets/pages/PictureViewIndex.ets` (第1-67行)
**大图预览主页面**，程序核心入口页面：
- 使用 `@Preview` 装饰器标记为预览组件
- 使用 `Navigation` + `NavPathStack` 实现页面导航栈管理
- 通过 `@Provide('pageInfos')` 向子组件传递导航栈
- 页面结构：TopBar → CenterPart(大图) → PreviewLists(缩略图) → BottomBar(工具栏，仅 sm/md 显示)
- `PageMap` 方法注册了两个子页面路由：albumView 和 pictureEdit
- 根据设备类型设置不同的 padding（2in1 设备特殊处理）

#### `features/pictureView/src/main/ets/view/TopBar.ets` (第1-103行)
**顶部栏组件**，显示：
- 返回按钮 + 日期标题(2020.12.24) + 副标题(图片数量信息)
- 右侧操作按钮：相册入口(跳转 albumView)、详情按钮
- 大屏(lg)模式下显示额外操作按钮（分享、收藏、编辑、删除、更多）
- 点击编辑按钮跳转到 pictureEdit 页面

#### `features/pictureView/src/main/ets/view/CenterPart.ets` (第1-59行)
**中心大图展示区**，核心功能：
- 展示当前选中的大图（固定资源 `$r('app.media.photo')`）
- 支持**双指缩放**(PinchGesture)：通过 `scaleValue` 和 `pinchValue` 状态变量控制缩放
- 图片尺寸根据当前断点通过 `Adaptive.PICTURE_HEIGHT/ WIDTH` 动态计算
- 手势结束将当前缩放值保存为基准值，支持连续缩放

#### `features/pictureView/src/main/ets/view/BottomBar.ets` (第1-59行)
**底部工具栏**（仅 sm/md 断点显示）：
- 水平排列5个操作按钮：分享、收藏、编辑、删除、更多
- 点击编辑按钮同样跳转到 pictureEdit 页面
- 使用 `ForEach` 渲染 `PictureViewConstants.ACTIONS` 数组
- 图标宽度固定为 "18%"

#### `features/pictureView/src/main/ets/view/PreviewLists.ets` (第1-46行)
**底部缩略图预览列表**：
- 水平滚动 List，初始索引居中
- 显示 PictureViewConstants.PICTURES 定义的所有图片缩略图
- 图片宽高比固定为 0.5，高度由资源 `list_image_height` 控制
- 启用 `scrollSnapAlign(CENTER)` 实现滑动对齐

#### `features/pictureView/src/main/ets/viewmodel/AdaptiveViewModel.ets` (第1-90行)
**自适应视图模型**，封装多断点下的尺寸适配逻辑：
- `PICTURE_HEIGHT/ WIDTH`: 大图尺寸（sm: 88%/100%, md/lg: 100%/不同百分比）
- `CircleImageOneWidth`: 圆形图片宽度
- `HomeTabHeight/ Width`: 首页 Tab 尺寸
- `ContactPhoneWidth`: 联系人面板宽度
- `ContactDetailHeight/ItemHeight`: 联系人详情/条目高度
- `DocumentTitleColumnHeight/Space`: 文档标题高度/间距
- 所有方法返回 `BreakpointType<T>` 根据当前断点的对应值

#### `features/pictureView/src/main/ets/constants/PictureViewConstants.ets` (第1-115行)
**大图预览模块常量**：
- **ActionInterface**: 操作按钮接口（icon: Resource, icon_name: ResourceStr）
- **ACTIONS**: 5个操作按钮定义（分享/收藏/编辑/删除/更多）
- **PICTURES**: 54张示例图片资源列表
- **布局尺寸**: 不同断点下的图片高度/宽度百分比
- **EDIT_ICON_NAME**: 编辑图标名称

#### `features/pictureView/src/main/module.json5`
模块配置，type 为 `har`。

---

### 2.5 features/pictureEdit/ - 图片编辑模块

图片编辑功能模块，提供滤镜、调节滑块、工具操作等编辑能力。

#### `features/pictureEdit/Index.ets` (第1-16行)
模块导出，暴露 `PictureEdit` 组件。

#### `features/pictureEdit/src/main/ets/views/PictureEdit.ets` (第1-237行)
**图片编辑页面**，完整功能：
- **topBar()**: 顶部工具栏 — 返回、编辑标题、窗口方向切换按钮(md断点)、添加操作按钮
- **centerPicture()**: 中心图片展示区 — 显示需编辑的图片，支持 `ImageInterpolation.High` 高质量插值
- **optionRegion()**: 编辑选项区域 — 包含 sliderBar、filterWindows、bottomBar
- **sliderBar()**: 滑动调节条 — 范围0-100，OutSet样式，方向根据布局轴向切换
- **filterWindows()**: 滤镜窗口 — List 展示8种滤镜效果缩略图，支持 colorFilter 矩阵
- **bottomBar()**: 底部工具条 — 裁剪、调节、滤镜、文字4个工具按钮
- **isColumnLayout()**: 布局方向判断 — sm 竖向、lg 横向、md 根据 windowDirection 切换

#### `features/pictureEdit/src/main/ets/constants/PictureEditConstants.ets` (第1-112行)
**编辑模块常量**：
- **toolsAndName**: 4个工具（裁剪/调节/滤镜/文字）的图标和名称
- **filterAndName**: 8个滤镜预设，每个含图片和 5x4 colorFilter 颜色矩阵
- **尺寸常量**: 不同布局下的图片高度/宽度
- **Flex basis**: 滑块区(80)/工具条(60)/选项区(250)

#### `features/pictureEdit/src/main/ets/viewmodel/AdaptiveViewModel.ets` (第1-44行)
编辑模块的自适应视图模型，提供 `PICTURE_HEIGHT` 和 `PICTURE_WIDTH` 方法。同时导出 `ToolsAndName` 和 `PicAndName` 接口定义。

#### `features/pictureEdit/src/main/module.json5`
模块配置，type 为 `har`。

---

### 2.6 features/albumView/ - 相册模块

相册浏览功能模块，以网格形式展示相册图片，支持双指缩放调整列数。

#### `features/albumView/Index.ets` (第1行)
模块导出，暴露 `AlbumView` 组件。

#### `features/albumView/src/main/ets/views/AlbumView.ets` (第1-203行)
**相册页面**，核心功能：
- **topRow()**: 顶部栏 — 返回按钮、相册标题、勾选/更多按钮（lg显示额外按钮）
- **Grid 网格布局**: 使用 `Grid` + `GridItem` 展示 IMAGE_LIST 中的图片
  - `columnsTemplate`: 动态列模板，由 `gridColumn` 状态变量控制
  - 通过 `onAreaChange` 监听组件区域大小，自动调用 `getGridColumn()` 计算列数
  - 每列宽度 = 1fr（等分），最小2列，最大16列
- **双指缩放**: 通过 `PinchGesture` 手势，缩小时增加列数(`up()`)，放大时减少列数(`down()`)
  - 使用 setTimeout 防抖机制，延迟70ms，限制100ms内最多触发一次
- **大屏侧边栏**: lg 断点显示 SideColumn 侧边栏
- **选图边框**: 选中的图片显示蓝色边框
- 使用 `NavDestination` 作为导航子页面，通过 `@Consume pageInfos` 接收导航栈

#### `features/albumView/src/main/ets/views/SideColumn.ets` (第1-287行)
**侧边栏组件**（仅大屏lg显示）：
- 切换按钮（switch 图标）
- 搜索框（TextInput + 搜索图标）
- 相册分类：所有照片、相册文件夹（可展开）
- 相册属性分类：收藏、视频、截图、GIF动画、全景、连拍
- 其他工具：回收站、隐藏相册、设置
- 每个选项行包含图标/文字/数量和右箭头

#### `features/albumView/src/main/ets/constants/AlbumViewConstants.ets` (第1-85行)
**相册模块常量**：
- **ImageData**: 图片数据接口（src: Resource, selected: boolean）
- **IMAGE_LIST**: 42张示例图片（7张图片 × 6次重复）
- **DES_TEXT**: 标题文字（'图片'）
- **SideConstants**: 14个侧边栏文本常量

#### `features/albumView/src/main/module.json5`
模块配置，type 为 `har`。

---

### 2.7 product/phone/ - 产品定制层（入口模块）

应用入口模块，整合所有特性模块，为具体设备形态提供最终产品。

#### `product/phone/hvigorfile.ts` (第1-6行)
手机产品模块的 Hvigor 构建配置，引用 `hapTasks` 作为系统插件（HAP 类型）。

#### `product/phone/src/main/module.json5` (第1-38行)
**手机模块清单配置**：
- **type**: `entry` — 入口模块
- **mainElement**: `PhoneAbility` — 主 Ability
- **deviceTypes**: phone, tablet
- **abilities**: 定义 PhoneAbility，配置启动图标、窗口尺寸(minWidth:330/minHeight:600)
- **skills**: 注册系统桌面意图（entity.system.home）

#### `product/phone/src/main/ets/phoneability/PhoneAbility.ets` (第1-101行)
**应用主 Ability**，继承 UIAbility：
- **onCreate()**: Ability 创建时日志记录
- **onWindowStageCreate()**: 窗口创建，完成以下核心初始化：
  1. 获取主窗口对象
  2. 调用 `updateBreakpoint()` 设置初始断点
  3. 监听 `windowSizeChange` 事件，窗口变化时更新断点
  4. 非2in1设备且支持全屏能力时，设置全屏布局
  5. 加载 `pages/Index` 页面内容
- **updateBreakpoint()**: 根据窗口宽度计算断点(sm/md/lg)并存入 AppStorage
- 其他生命周期方法：onDestroy, onForeground, onBackground

#### `product/phone/src/main/ets/pages/Index.ets` (第1-47行)
**应用入口页面**：
- 使用 `@Entry` 装饰器标记为入口
- 从 AppStorage 获取 `currentBreakpoint` 断点状态
- 使用 `GridRow`/`GridCol` 栅格布局实现响应式
- 不同断点使用不同的列数和列跨度
- 内部渲染 `PictureViewIndex` 作为主界面

#### `product/phone/src/main/resources/base/profile/main_pages.json` (第1-5行)
页面路由配置，声明入口页面为 `pages/Index`。

---

## 三、架构设计分析

### 3.1 三层工程架构

```
┌─────────────────────────────────────┐
│    产品定制层 (product/phone)        │  ← HAP 入口，设备适配
├─────────────────────────────────────┤
│    基础特性层 (features/)            │  ← HAR 模块，功能实现
│  pictureView | pictureEdit | album  │
├─────────────────────────────────────┤
│    公共能力层 (commons/base)         │  ← HAR 模块，共享能力
└─────────────────────────────────────┘
```

### 3.2 响应式适配机制

1. **断点系统**: PhoneAbility 监听窗口宽度变化 → 计算断点值 → 存入 AppStorage
2. **状态同步**: 各组件通过 `@StorageLink('currentBreakpoint')` 双向绑定断点
3. **布局切换**: 通过 `if/else` 条件渲染、`BreakpointType.GetValue()` 方法、`FlexDirection` 切换实现不同布局

### 3.3 导航体系

- 使用 `Navigation` + `NavPathStack` 实现 Stack 模式导航
- 主页面通过 `@Provide` 向下传递导航栈
- 子页面通过 `@Consume` 获取导航栈
- 页面路由通过 `PageMap` 函数按名称分发

### 3.4 数据流

- 全局状态：AppStorage（断点值 currentBreakpoint）
- 父子传递：@Provide/@Consume（导航栈 pageInfos）
- 组件内状态：@State（缩放值、列数等）
- 常量数据：静态类 Constants（图片列表、操作按钮等）

---

## 四、资源文件说明

| 目录 | 说明 |
|------|------|
| `commons/base/src/main/resources/` | 公共资源：图标(SVG)、颜色、字符串、字体大小 |
| `features/pictureView/.../resources/` | 大图预览资源：操作图标、示例图片(JPG) |
| `features/pictureEdit/.../resources/` | 编辑资源：工具图标、滤镜预览图 |
| `features/albumView/.../resources/` | 相册资源：相册图片、侧边栏图标 |
| `product/phone/.../resources/` | 产品资源：应用图标、启动图标、字符串 |

国际化：各模块均包含 `en_US/element/string.json` 和 `zh_CN/element/string.json`。

---

## 五、关键代码片段索引

| 功能 | 文件 | 关键方法/变量 |
|------|------|--------------|
| 断点计算 | PhoneAbility.ets | `updateBreakpoint()` |
| 栅格响应式 | Index.ets(pages) | GridRow columns |
| 大图缩放 | CenterPart.ets | PinchGesture, scaleValue |
| 相册网格缩放 | AlbumView.ets | PinchGesture, getGridColumn() |
| 滤镜颜色矩阵 | PictureEditConstants.ets | color_filter 5×4 矩阵 |
| 自适应尺寸 | AdaptiveViewModel.ets | BreakpointType.GetValue() |
| 页面导航 | PictureViewIndex.ets | Navigation + NavPathStack |
