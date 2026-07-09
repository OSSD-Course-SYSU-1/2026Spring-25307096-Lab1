# 文字水印 & 马赛克/模糊笔 功能设计

**日期**: 2026-06-23  
**项目**: MultiPictureBeautification  
**状态**: 已批准

---

## 1. 概述

在现有图片编辑功能基础上，新增两个工具：
- **文字水印**（主）+ 贴纸（辅）：在图片上叠加自定义文字或贴纸
- **马赛克/模糊笔**：涂抹或框选区域进行马赛克或模糊处理

技术方案采用**叠加层方案（方案 A）**：所有效果通过 ArkUI 原生组件（Stack + Canvas）叠加实现，非破坏性编辑，与现有 colorFilter 架构一致。

---

## 2. 文件变更清单

### 新增文件

```
features/pictureEdit/src/main/ets/
├── views/
│   └── watermark/
│       ├── TextWatermark.ets     ← 文字水印编辑面板
│       └── StickerPanel.ets      ← 贴纸选择面板
│   └── mosaic/
│       ├── MosaicCanvas.ets      ← 马赛克/模糊 Canvas 画布
│       └── MosaicPanel.ets       ← 马赛克工具面板
```

### 修改文件

| 文件 | 改动 |
|------|------|
| `views/PictureEdit.ets` | 工具条 5→7 按钮可滚动；Stack 加叠加层容器；面板路由加 text/mosaic |
| `constants/PictureEditConstants.ets` | `toolsAndName` 新增文字和马赛克工具定义 |
| `viewmodel/AdaptiveViewModel.ets` | 新增 `TextOverlay`、`StickerOverlay`、`MosaicRegion` 接口 |
| `resources/base/element/string.json` | 新增 ~15 个字符串 key |
| `resources/zh_CN/element/string.json` | 中文翻译 |
| `resources/en_US/element/string.json` | 英文翻译 |

### 新增资源

```
features/pictureEdit/src/main/resources/base/media/
├── icon_tool_text.png          ← 文字工具图标
├── icon_tool_mosaic.png        ← 马赛克工具图标
├── sticker_heart.png           ← 贴纸：爱心
├── sticker_star.png            ← 贴纸：星星
├── sticker_crown.png           ← 贴纸：皇冠
├── sticker_arrow.png           ← 贴纸：箭头
├── sticker_frame.png           ← 贴纸：边框
├── sticker_glow.png            ← 贴纸：光效
├── sticker_bubble.png          ← 贴纸：气泡
├── sticker_tag.png             ← 贴纸：标签
├── sticker_sparkle.png         ← 贴纸：闪光
├── sticker_ribbon.png          ← 贴纸：缎带
├── sticker_smile.png           ← 贴纸：笑脸
└── sticker_fire.png            ← 贴纸：火焰
```

---

## 3. 工具条改造

### 当前（5个）

```
[截取] [裁剪] [调节] [滤镜] [AI修图]
```

### 改为（7个，可滚动）

```
Scroll(.Horizontal) {
  Row {
    [截取] [裁剪] [调节] [滤镜] [AI修图] [文字] [马赛克]
  }
}
```

- `selectedTool` 枚举扩展：`'capture' | 'crop' | 'adjust' | 'filter' | 'ai' | 'text' | 'mosaic'`
- 点击行为不变：选中高亮 → 显示面板；再次点击取消；切换工具收起前一面板

### 底部面板路由

```typescript
if (selectedTool === 'filter')     → filterWindows()
else if (selectedTool === 'ai')    → aiPanel()
else if (selectedTool === 'text')  → textWatermarkPanel()
else if (selectedTool === 'mosaic') → mosaicPanel()
else                               → sliderBar()  // 截取/裁剪/调节 占位
```

---

## 4. 图片编辑区域 Z 序

```
Stack（图片编辑区域）
├── Image                          ← 原图，带 .colorFilter() 滤镜（现有）
├── MosaicCanvas                   ← 马赛克/模糊层（新增）
└── ForEach(overlays)              ← 文字+贴纸叠加层（新增）
    ├── Text()  (type === 'text')
    └── Image() (type === 'sticker')
```

- 马赛克层在文字层下方（Z 序正确）
- 所有叠加层数据存储在 `@State overlays: OverlayItem[]`

---

## 5. 文字水印功能

### 5.1 交互流程

```
点击「文字」→ 底部弹出文字编辑面板
  → Tab: [文字水印] [贴纸]
  → 输入文字、调颜色/大小/透明度
  → 点击「添加文字」
  → 文字出现在图片中央
  → 手势调整（拖拽/缩放/旋转）
  → 点 ✓ 确认
```

### 5.2 编辑面板 (TextWatermark.ets)

布局：
- TextInput：输入文字内容，placeholder "输入文字..."
- 6 个预设颜色圆点（白/黑/红/黄/蓝/绿）
- 大小 Slider：12-72sp，默认 24sp
- 透明度 Slider：20%-100%，默认 80%
- 「添加文字」Button

### 5.3 叠加交互

| 手势 | 行为 |
|------|------|
| 单指拖拽 | 移动文字位置 |
| 双指缩放 | 调整大小 0.5x-3x |
| 双指旋转 | 旋转 0-360° |
| 长按 | 弹出删除确认 |
| 点击选中 | 蓝色虚线边框，可再次编辑 |

### 5.4 数据模型

```typescript
interface TextOverlay {
  id: string;
  type: 'text';
  text: string;
  x: number;        // 中心 X，相对于图片的百分比 0-1
  y: number;        // 中心 Y，相对于图片的百分比 0-1
  fontSize: number;  // sp
  color: string;     // hex
  opacity: number;   // 0.2-1.0
  rotation: number;  // 0-360
  scale: number;     // 0.5-3.0
}
```

---

## 6. 贴纸功能

### 6.1 交互流程

```
「文字」面板 → Tab 切换到「贴纸」
  → 横向滚动贴纸列表
  → 18 emoji + 12 图形贴纸
  → 点击选中 → 贴纸出现在图片中央
  → 手势调整 → 点 ✓ 确认
```

### 6.2 贴纸面板 (StickerPanel.ets)

- Tab 栏：[文字水印] [贴纸]
- Emoji 区：18 个常用 emoji（😀😂❤️👍🎉⭐🌸🔥💯✨🌈🎂📸🎨🎵☕🍕⚽），Grid 3 行 × 6 列
- 图形贴纸区：12 个内置贴纸缩略图，Grid 滚动

### 6.3 叠加交互

与文字水印完全相同：拖拽/缩放/旋转/长按删除/点击选中

### 6.4 数据模型

```typescript
interface StickerOverlay {
  id: string;
  type: 'sticker';
  src?: Resource;       // 图形贴纸资源
  emoji?: string;       // emoji 字符
  x: number;
  y: number;
  scale: number;        // 0.5-3.0
  rotation: number;     // 0-360
  opacity: number;      // 0.3-1.0
}
```

---

## 7. 马赛克/模糊笔功能

### 7.1 交互流程

```
点击「马赛克」→ 底部弹出工具面板
  → 选择模式：[涂抹] [框选]
  → 选择效果：[马赛克] [模糊]
  → 调画笔粗细/马赛克粒度
  → 手指在图片上操作
  → [撤销] / [清空全部]
  → 点 ✓ 确认
```

### 7.2 工具面板 (MosaicPanel.ets)

```
模式切换：  [●涂抹]  [框选]
效果切换：  [●马赛克]  [模糊]
画笔大小：  ──●────── 10-80px（涂抹模式）
马赛克粒度：──●────── 4-20px（仅马赛克时显示）
操作按钮：  [撤销]  [清空全部]
```

### 7.3 涂抹模式实现 (MosaicCanvas.ets)

- 图片上方覆盖透明 Canvas（尺寸与图片一致）
- 监听 TouchEvent：手指滑动时获取触摸坐标
- 根据 `type` 决定渲染方式：

**马赛克：**
```
对每个触摸点：
1. 映射坐标到图片像素坐标系
2. 在 Canvas 上绘制 mosaicSize × mosaicSize 的纯色方块
3. 颜色 = 该区域图片像素平均值（从 ImageBitmap 采样）
4. 相邻方块形成马赛克效果
```

**模糊：**
```
对触摸轨迹区域：
1. 记录路径
2. 使用 clipPath + 半透明遮罩
3. 叠加 .blur() 处理的图片局部副本
```

### 7.4 框选模式

- 手指按下(down) → 拖拽(move) → 松开(up)，形成矩形选区
- 选区边界显示虚线 + 四角拖拽手柄
- 松开后自动对该区域应用马赛克/模糊
- 可按拖拽手柄调整选区大小
- 双击选区删除该区域

### 7.5 数据模型

```typescript
interface MosaicRegion {
  id: string;
  // 涂抹模式
  points?: Array<{x: number, y: number}>;
  brushSize: number;
  // 框选模式
  rect?: { left: number, top: number, width: number, height: number };
  // 通用
  type: 'mosaic' | 'blur';
  mosaicSize?: number;   // 仅 mosaic
}

// 所有叠加项统一类型
type OverlayItem = TextOverlay | StickerOverlay;
```

### 7.6 操作

- **撤销**：删除 `mosaicRegions` 最后一个元素，Canvas 重绘
- **清空**：清空 `mosaicRegions`，Canvas 清除
- **确认**：区域固化为最终状态

---

## 8. i18n 字符串

### 新增 key（3 locales）

| Key | EN (base) | ZH (zh_CN) |
|-----|-----------|------------|
| ToolsAndName6 | Text | 文字 |
| ToolsAndName7 | Mosaic | 马赛克 |
| text_watermark_tab | Text | 文字水印 |
| sticker_tab | Sticker | 贴纸 |
| text_placeholder | Enter text... | 输入文字... |
| text_add | Add Text | 添加文字 |
| text_color | Color | 颜色 |
| text_size | Size | 大小 |
| text_opacity | Opacity | 透明度 |
| mosaic_mode_brush | Brush | 涂抹 |
| mosaic_mode_box | Box | 框选 |
| mosaic_effect_mosaic | Mosaic | 马赛克 |
| mosaic_effect_blur | Blur | 模糊 |
| mosaic_brush_size | Brush Size | 画笔大小 |
| mosaic_grain | Grain | 马赛克粒度 |
| mosaic_undo | Undo | 撤销 |
| mosaic_clear | Clear All | 清空全部 |
| sticker_delete | Delete | 删除 |
| sticker_confirm | Done | 完成 |

---

## 9. 响应式布局适配

| 断点 | 工具条 | 编辑面板 | 贴纸/文字面板 |
|------|--------|----------|--------------|
| SM (<600vp) | 横向滚动 | 底部 Sheet 40% | 底部 Sheet 40% |
| MD (600-840vp) | 横向滚动 | 底部 Sheet 35% | 底部 Sheet 35% |
| LG (>=840vp) | 分散排列 | 右侧面板 320vp | 右侧面板 320vp |

沿用现有 `Adaptive` 类计算尺寸。

---

## 10. 约束和注意事项

1. **不破坏现有功能**：新增代码通过 `selectedTool` 路由隔离，不影响滤镜、AI修图等现有逻辑
2. **非破坏性编辑**：所有叠加层不修改原图数据，仅在显示层叠加
3. **贴纸资源**：使用项目内置 PNG 图标，不依赖网络
4. **Canvas 坐标映射**：需正确处理图片实际显示尺寸与 Canvas 坐标的转换
5. **编译验证**：每次改动后运行 `hvigorw assembleHap` 验证
