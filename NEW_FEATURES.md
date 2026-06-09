# 新增功能说明文档 (v2 - 虚拟机修复版)

## 概述

在基础工程（多设备图片美化应用）之上，新增了以下4项功能，提升用户交互体验。

## 修复说明 (2026/06/09)

原版本在虚拟机/模拟器上存在问题，已全面修复：

### 修复的根因

| 问题 | 根因 | 修复方式 |
|------|------|---------|
| 信息弹窗无法显示 | 弹窗在 TopBar 的 Stack 内，TopBar 高度仅~48vp，弹窗被限制在极小区域内 | 弹窗移至 PictureViewIndex 最外层 Stack，覆盖全屏 |
| 收藏/删除点击无反应 | `PageCallbacks` 类通过 `@Provide/@Consume` 传递时，子组件可能获取到空回调对象 | 改用 `AppStorage.setOrCreate` + `@Watch` 触发器模式 |
| 资源字符串缺失 | `favorited` 等6个字符串仅在 zh_CN/en_US 中定义，base/ 缺失 | 补全 base/ 中的所有字符串 |
| ForEach key 不稳定 | `JSON.stringify(item)` 中 item 含 Resource 类型，序列化不可靠 | 改用 `index.toString()` |

### 架构变更

**旧方案 (有bug)**:
```
子组件 → @Consume('pageCallbacks') → PageCallbacks.onToggleFav() 
       → @Provide 父组件
问题: @Provide/@Consume 对类实例的函数属性传递不可靠
```

**新方案 (可靠)**:
```
子组件 → AppStorage.setOrCreate('fav_toggle_idx', index)
       → @StorageLink + @Watch → 父组件 onFavToggle()
       → handleToggleFav()
优势: AppStorage 是全局可靠的单例通道，@Watch 保证同步触发
```

---

## 新增功能列表

### 1. 图片旋转功能

**功能描述**: 用户可通过双击图片将其旋转90度，连续双击可循环旋转（0°→90°→180°→270°→0°）。

**实现方式**:
- 在 `CenterPart.ets` 中添加 `TapGesture({ count: 2 })` 双击手势
- 新增 `@State rotationAngle: number = 0` 状态变量
- 每次双击 `rotationAngle += 90`，超过360度自动归零
- 通过 `.rotate({ angle: this.rotationAngle })` 实现旋转动画
- 切换图片时自动重置旋转和缩放状态

**涉及文件**: `features/pictureView/src/main/ets/view/CenterPart.ets`

---

### 2. 左右滑动切换图片

**功能描述**: 用户可通过左右滑动手势在大图预览中切换上一张/下一张图片，切换时自动重置缩放和旋转状态。

**实现方式**:
- 在 `PictureViewIndex.ets` 中添加 `@Provide('curImageIndex')` 和 `@Provide('imageTotal')` 状态
- 在 `CenterPart.ets` 中添加 `PanGesture({ direction: PanDirection.Horizontal })` 手势
- 左滑（offsetX < -50）切换到下一张
- 右滑（offsetX > 50）切换到上一张
- 使用 `GestureGroup(GestureMode.Exclusive)` 将缩放、滑动、双击三个手势组合，互斥触发
- 底部显示图片计数器（如 "3 / 54"），半透明背景

**涉及文件**:
- `features/pictureView/src/main/ets/pages/PictureViewIndex.ets`
- `features/pictureView/src/main/ets/view/CenterPart.ets`

---

### 3. 图片收藏功能

**功能描述**: 用户可点击收藏按钮（红心图标）来标记/取消收藏当前图片，收藏状态通过图标颜色变化提供视觉反馈。

**实现方式** (v2 修复):
- `PictureViewIndex.ets` 中通过 `@StorageLink('fav_toggle_idx')` + `@Watch('onFavToggle')` 监听收藏切换请求
- `TopBar.ets` 和 `BottomBar.ets` 通过 `AppStorage.setOrCreate('fav_toggle_idx', index)` 发起请求
- 收藏时：图标变为红色（`fillColor: '#FF4444'`），文字变为"已收藏"
- 取消收藏：图标恢复原色，文字恢复"收藏"
- 状态通过 `@Provide('favoritedIndices')` + `@Consume` 在组件间共享

**涉及文件**:
- `features/pictureView/src/main/ets/pages/PictureViewIndex.ets`
- `features/pictureView/src/main/ets/view/TopBar.ets`
- `features/pictureView/src/main/ets/view/BottomBar.ets`
- `features/pictureView/src/main/ets/utils/FavoritesStore.ets`

---

### 4. 图片信息弹窗

**功能描述**: 点击顶部栏的详情图标，弹出图片信息对话框，显示文件名、尺寸、日期等元数据信息。

**实现方式** (v2 修复):
- 弹窗 UI 移至 `PictureViewIndex.ets` 的最外层 `Stack` 中，确保全屏覆盖
- `TopBar.ets` 通过 `AppStorage.setOrCreate('show_info_dialog', true)` 触发弹窗
- `PictureViewIndex.ets` 通过 `@StorageLink('show_info_dialog')` 控制弹窗显示
- 弹窗采用模态遮罩层 + 白色卡片设计
- 显示信息：文件名（IMG_20201224_001.jpg）、尺寸（4032 × 3024）、日期（2020-12-24 10:30:00）
- 点击遮罩层或"关闭"按钮关闭弹窗
- 卡片使用 `.hitTestBehavior(HitTestMode.Block)` 防止点击穿透

**涉及文件**:
- `features/pictureView/src/main/ets/pages/PictureViewIndex.ets`
- `features/pictureView/src/main/ets/view/TopBar.ets`
- `features/pictureView/src/main/resources/base/element/string.json`（新增中英文字符串）

---

### 5. 图片删除功能

**功能描述**: 点击删除按钮从列表中移除当前图片，自动重建收藏索引。

**实现方式** (v2 修复):
- 通过 `AppStorage.setOrCreate('delete_idx', index)` + `@Watch('onDeleteTrigger')` 模式触发
- `FavoritesStore.deleteAndReindex()` 重建收藏索引
- 删除最后一张图片时自动将当前索引前移

---

### 6. 收藏数据持久化

**功能描述**: 收藏状态通过 `preferences` API 持久化存储，应用重启后保持。

**实现方式**:
- `FavoritesStore` 工具类封装 `preferences` 读写操作
- `load()`: 异步读取收藏索引数组
- `save()`: 异步写入收藏索引数组
- `deleteAndReindex()`: 删除图片时重建索引

**涉及文件**: `features/pictureView/src/main/ets/utils/FavoritesStore.ets`

---

## 代码变更统计

| 文件 | 变更类型 | 说明 |
|------|---------|------|
| `PictureViewIndex.ets` | 重写 | 改用 AppStorage 触发器 + @Watch，全屏信息弹窗 |
| `TopBar.ets` | 重写 | 移除弹窗 UI，改用 AppStorage 事件触发 |
| `BottomBar.ets` | 修改 | 移除 PageCallbacks，改用 AppStorage 事件触发 |
| `CenterPart.ets` | 不变 | 旋转、滑动切换、图片计数器（原样保留） |
| `PictureViewConstants.ets` | 修改 | 移除废弃的 PageCallbacks 类 |
| `PreviewLists.ets` | 修改 | 修复 ForEach key 生成器 |
| `FavoritesStore.ets` | 不变 | 收藏持久化（原样保留） |
| `base/element/string.json` | 修改 | 补全缺失的6个字符串 + subtitle_infomation |
| `zh_CN/element/string.json` | 修改 | 新增 subtitle_infomation |
| `en_US/element/string.json` | 修改 | 新增 subtitle_infomation |

## 技术亮点

1. **手势互斥组合**: 使用 `GestureGroup(GestureMode.Exclusive)` 将缩放、滑动、双击三种手势组合，避免手势冲突
2. **AppStorage 通信**: 使用 `AppStorage` + `@StorageLink` + `@Watch` 实现可靠的跨组件事件传递，避免 `@Provide`/`@Consume` 对类实例传递的不可靠性
3. **全屏弹窗**: 弹窗置于页面最外层 `Stack`，使用 `hitTestBehavior(HitTestMode.Block)` 防止点击穿透
4. **动画过渡**: 旋转和图片切换均使用 `.animation({ duration: 200 })` 实现平滑过渡
5. **自适应适配**: 新增功能沿用了原有的 Breakpoint 断点机制，在不同设备形态下均能正常工作
6. **国际化支持**: 所有新增文本同时提供中英文版本，base/ 提供完整默认值
7. **数据持久化**: 收藏状态使用 `preferences` API 持久化，应用重启不丢失
