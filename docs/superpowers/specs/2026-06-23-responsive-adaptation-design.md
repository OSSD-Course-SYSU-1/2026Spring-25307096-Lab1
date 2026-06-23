# 大小屏适配设计方案

## 概述

为 MultiPictureBeautification 实现完善的响应式布局，使其在手机、平板、2in1/桌面设备上均能正常呈现。

## 核心原则

- **渐进增强**：SM 断点 (< 600vp) 保持现有布局完全不变，手机体验不受任何影响
- **断点驱动**：复用现有 BreakpointConstants (sm/md/lg) 和 AppStorage 机制
- **最小改动**：只改页面布局逻辑，不动公共层架构和三层工程结构

## 改造项

### 1. Navigation 模式切换
- 文件：`product/phone/src/main/ets/pages/Index.ets`
- 改动：`NavigationMode.Stack` → `NavigationMode.Auto`
- 效果：窗口 ≥ 600vp 自动双栏分屏，< 600vp 保持 Stack 单页

### 2. deviceTypes 补全
- 文件：`product/phone/src/main/module.json5`
- 改动：`"deviceTypes": ["phone", "tablet", "2in1"]`
- 效果：桌面/二合一设备获得正式支持

### 3. 图片浏览页布局优化
- 文件：`features/pictureView/src/main/ets/pages/PictureViewIndex.ets`
- SM/MD：保持现有上下布局不变
- LG：左右分栏，大图区 60% + 右侧面板（缩略图+操作按钮）40%
- 2in1：大图最大宽度限制防止过度拉伸

### 4. 相册页侧边栏自适应
- 文件：`features/albumView/src/main/ets/views/AlbumView.ets`, `SideColumn.ets`
- SideColumn 宽度按断点变化，LG/2in1 加最大宽度约束

### 5. 编辑页大屏比例优化
- 文件：`features/pictureEdit/src/main/ets/views/PictureEdit.ets`
- LG/2in1 时图片:编辑区 = 60:40，限制最大图片宽度

## 改动文件清单

| 文件 | 改动类型 |
|------|---------|
| `product/phone/src/main/module.json5` | deviceTypes 补全 |
| `product/phone/src/main/ets/pages/Index.ets` | Navigation 模式 |
| `features/pictureView/src/main/ets/pages/PictureViewIndex.ets` | LG 左右布局 |
| `features/pictureView/src/main/ets/view/PreviewLists.ets` | 支持竖向模式 |
| `features/albumView/src/main/ets/views/SideColumn.ets` | 宽度自适应 |
| `features/albumView/src/main/ets/views/AlbumView.ets` | LG 布局调整 |
| `features/pictureEdit/src/main/ets/views/PictureEdit.ets` | 大屏比例 |
