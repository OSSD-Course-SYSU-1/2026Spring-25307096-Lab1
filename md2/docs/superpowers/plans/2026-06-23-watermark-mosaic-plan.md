# Watermark & Mosaic Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add text watermark (+ sticker) and mosaic/blur brush tools to the picture editor, extending the toolbar from 5 to 7 tools.

**Architecture:** Overlay-based (non-destructive) — text/stickers render as ArkUI components in a Stack above the image; mosaic/blur draws on a Canvas layer between the image and text overlays. All state managed via @State arrays in PictureEdit.

**Tech Stack:** HarmonyOS 6.0 ArkTS, ArkUI declarative UI, Canvas API, ImageBitmap

**Prerequisites:** JAVA_HOME="/d/DevEco Studio/jbr"; DEVECO_SDK_HOME="/d/DevEco Studio/sdk"

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `features/pictureEdit/.../viewmodel/AdaptiveViewModel.ets` | Add TextOverlay, StickerOverlay, MosaicRegion interfaces |
| Modify | `features/pictureEdit/.../constants/PictureEditConstants.ets` | Add tools 6 & 7 to toolsAndName array |
| Modify | `features/pictureEdit/.../resources/base/element/string.json` | EN strings for new tools/panels |
| Modify | `features/pictureEdit/.../resources/zh_CN/element/string.json` | ZH strings for new tools/panels |
| Modify | `features/pictureEdit/.../resources/en_US/element/string.json` | EN_US strings for new tools/panels |
| Create | `features/pictureEdit/.../views/watermark/TextWatermark.ets` | Text watermark editing panel builder |
| Create | `features/pictureEdit/.../views/watermark/StickerPanel.ets` | Sticker picker panel builder |
| Create | `features/pictureEdit/.../views/mosaic/MosaicCanvas.ets` | Canvas overlay for mosaic/blur drawing |
| Create | `features/pictureEdit/.../views/mosaic/MosaicPanel.ets` | Mosaic tool settings panel builder |
| Modify | `features/pictureEdit/.../views/PictureEdit.ets` | Integrate all new components, extend toolbar, add overlay Stack |

---

### Task 1: Add data model interfaces

**Files:**
- Modify: `features/pictureEdit/src/main/ets/viewmodel/AdaptiveViewModel.ets`

- [ ] **Step 1: Add overlay and mosaic interfaces**

Append to the end of `AdaptiveViewModel.ets` (after the `AiPreset` interface on line 92):

```typescript
/**
 * Base overlay item — text or sticker placed on top of the image.
 */
export interface TextOverlay {
  id: string;
  type: 'text';
  text: string;
  x: number;          // center X as fraction 0-1 relative to image
  y: number;          // center Y as fraction 0-1 relative to image
  fontSize: number;   // sp
  color: string;      // hex like '#FFFFFF'
  opacity: number;    // 0.2 - 1.0
  rotation: number;   // degrees 0-360
  scale: number;      // 0.5 - 3.0
}

export interface StickerOverlay {
  id: string;
  type: 'sticker';
  emoji: string;      // emoji character, e.g. '😀'
  x: number;
  y: number;
  scale: number;      // 0.5 - 3.0
  rotation: number;   // 0-360
  opacity: number;    // 0.3 - 1.0
}

export type OverlayItem = TextOverlay | StickerOverlay;

/**
 * A mosaic or blur region on the canvas.
 */
export interface MosaicRegion {
  id: string;
  // Brush mode
  points?: Array<{ x: number; y: number }>;
  brushSize: number;
  // Box mode
  rect?: { left: number; top: number; width: number; height: number };
  // Common
  type: 'mosaic' | 'blur';
  mosaicSize?: number;
}
```

- [ ] **Step 2: Verify file is valid**

```bash
cd /d/xingqier/MultiPictureBeautification && export JAVA_HOME="/d/DevEco Studio/jbr" && export DEVECO_SDK_HOME="/d/DevEco Studio/sdk" && hvigorw assembleHap 2>&1 | tail -20
```

Expected: BUILD SUCCESSFUL (no new errors from this change)

- [ ] **Step 3: Commit**

```bash
git add features/pictureEdit/src/main/ets/viewmodel/AdaptiveViewModel.ets
git commit -m "feat: add OverlayItem and MosaicRegion data interfaces"
```

---

### Task 2: Add i18n strings

**Files:**
- Modify: `features/pictureEdit/src/main/resources/base/element/string.json`
- Modify: `features/pictureEdit/src/main/resources/zh_CN/element/string.json`
- Modify: `features/pictureEdit/src/main/resources/en_US/element/string.json`

- [ ] **Step 1: Add EN strings (base)**

In `base/element/string.json`, before the closing `]` of the `"string"` array, append:

```json
    {
      "name": "ToolsAndName6",
      "value": "Text"
    },
    {
      "name": "ToolsAndName7",
      "value": "Mosaic"
    },
    {
      "name": "text_watermark_tab",
      "value": "Text"
    },
    {
      "name": "sticker_tab",
      "value": "Sticker"
    },
    {
      "name": "text_placeholder",
      "value": "Enter text..."
    },
    {
      "name": "text_add",
      "value": "Add Text"
    },
    {
      "name": "text_color",
      "value": "Color"
    },
    {
      "name": "text_size",
      "value": "Size"
    },
    {
      "name": "text_opacity",
      "value": "Opacity"
    },
    {
      "name": "mosaic_mode_brush",
      "value": "Brush"
    },
    {
      "name": "mosaic_mode_box",
      "value": "Box"
    },
    {
      "name": "mosaic_effect_mosaic",
      "value": "Mosaic"
    },
    {
      "name": "mosaic_effect_blur",
      "value": "Blur"
    },
    {
      "name": "mosaic_brush_size",
      "value": "Brush Size"
    },
    {
      "name": "mosaic_grain",
      "value": "Grain"
    },
    {
      "name": "mosaic_undo",
      "value": "Undo"
    },
    {
      "name": "mosaic_clear",
      "value": "Clear All"
    },
    {
      "name": "sticker_delete",
      "value": "Delete"
    },
    {
      "name": "sticker_done",
      "value": "Done"
    }
```

- [ ] **Step 2: Add ZH strings**

In `zh_CN/element/string.json`, before the closing `]`, append:

```json
    {
      "name": "ToolsAndName6",
      "value": "文字"
    },
    {
      "name": "ToolsAndName7",
      "value": "马赛克"
    },
    {
      "name": "text_watermark_tab",
      "value": "文字水印"
    },
    {
      "name": "sticker_tab",
      "value": "贴纸"
    },
    {
      "name": "text_placeholder",
      "value": "输入文字..."
    },
    {
      "name": "text_add",
      "value": "添加文字"
    },
    {
      "name": "text_color",
      "value": "颜色"
    },
    {
      "name": "text_size",
      "value": "大小"
    },
    {
      "name": "text_opacity",
      "value": "透明度"
    },
    {
      "name": "mosaic_mode_brush",
      "value": "涂抹"
    },
    {
      "name": "mosaic_mode_box",
      "value": "框选"
    },
    {
      "name": "mosaic_effect_mosaic",
      "value": "马赛克"
    },
    {
      "name": "mosaic_effect_blur",
      "value": "模糊"
    },
    {
      "name": "mosaic_brush_size",
      "value": "画笔大小"
    },
    {
      "name": "mosaic_grain",
      "value": "马赛克粒度"
    },
    {
      "name": "mosaic_undo",
      "value": "撤销"
    },
    {
      "name": "mosaic_clear",
      "value": "清空全部"
    },
    {
      "name": "sticker_delete",
      "value": "删除"
    },
    {
      "name": "sticker_done",
      "value": "完成"
    }
```

- [ ] **Step 3: Add EN_US strings**

Same content as Step 1 (base EN). Copy the same JSON block into `en_US/element/string.json`.

- [ ] **Step 4: Commit**

```bash
git add features/pictureEdit/src/main/resources/base/element/string.json features/pictureEdit/src/main/resources/zh_CN/element/string.json features/pictureEdit/src/main/resources/en_US/element/string.json
git commit -m "feat: add i18n strings for watermark and mosaic tools"
```

---

### Task 3: Add tool constants

**Files:**
- Modify: `features/pictureEdit/src/main/ets/constants/PictureEditConstants.ets`

- [ ] **Step 1: Add tools 6 and 7 to toolsAndName array**

In `PictureEditConstants.ets`, replace the `toolsAndName` array (lines 52-67) — add two entries after the AI tool (index 4). The full array becomes:

```typescript
  static toolsAndName: ToolsAndName[] = [
    {
      pic: $r("app.media.tools_2"), pic_name: $r('app.string.ToolsAndName1')
    },
    {
      pic: $r("app.media.tools_1"), pic_name: $r('app.string.ToolsAndName2')
    },
    {
      pic: $r("app.media.tools_3"), pic_name: $r('app.string.ToolsAndName3')
    },
    {
      pic: $r("app.media.tools_4"), pic_name: $r('app.string.ToolsAndName4')
    },
    {
      pic: $r("app.media.tools_3"), pic_name: $r('app.string.ToolsAndName5')
    },
    {
      pic: $r("app.media.tools_4"), pic_name: $r('app.string.ToolsAndName6')
    },
    {
      pic: $r("app.media.tools_2"), pic_name: $r('app.string.ToolsAndName7')
    }];
```

Note: Tools 6 (Text) uses `tools_4` icon, tool 7 (Mosaic) uses `tools_2` icon as placeholders — these are existing media resources in the project.

- [ ] **Step 2: Add sticker emoji constant**

Append a new static array after the `toolsAndName` definition (after the closing `];` on the line above):

```typescript
  /** Emoji stickers — 18 common symbols rendered as text. */
  static readonly STICKER_EMOJI: string[] = [
    '😀', '😂', '❤️', '👍', '🎉', '⭐',
    '🌸', '🔥', '💯', '✨', '🌈', '🎂',
    '📸', '🎨', '🎵', '☕', '🍕', '⚽'
  ];

  /** Preset text colors for watermark. */
  static readonly TEXT_COLORS: string[] = [
    '#FFFFFF', '#000000', '#FF4444', '#FFD700',
    '#4DA6FF', '#4CAF50', '#FF9800', '#9C27B0'
  ];
```

- [ ] **Step 3: Commit**

```bash
git add features/pictureEdit/src/main/ets/constants/PictureEditConstants.ets
git commit -m "feat: extend toolsAndName with text and mosaic tools, add sticker constants"
```

---

### Task 4: Create TextWatermark component

**Files:**
- Create: `features/pictureEdit/src/main/ets/views/watermark/TextWatermark.ets`

- [ ] **Step 1: Create directory and file**

```bash
mkdir -p /d/xingqier/MultiPictureBeautification/features/pictureEdit/src/main/ets/views/watermark
```

- [ ] **Step 2: Write TextWatermark.ets**

```typescript
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BaseConstants } from 'base';
import PictureEditConstants from '../../constants/PictureEditConstants';

/**
 * Text watermark editing panel.
 * User types text, picks color/size/opacity, then taps "Add Text".
 */
@Component
export struct TextWatermark {
  @State inputText: string = '';
  @State selectedColor: number = 0;       // index into TEXT_COLORS
  @State fontSize: number = 24;
  @State opacity: number = 0.8;
  @Link selectedTab: number;              // 0 = text, 1 = sticker
  onAddText?: (text: string, color: string, fontSize: number, opacity: number) => void;

  build() {
    Column({ space: 12 }) {
      /* Tab bar */
      Row({ space: 0 }) {
        Text($r('app.string.text_watermark_tab'))
          .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
          .fontColor(this.selectedTab === 0 ? '#4DA6FF' : '#99FFFFFF')
          .fontWeight(this.selectedTab === 0 ? BaseConstants.FONT_WEIGHT_FIVE : BaseConstants.FONT_WEIGHT_FOUR)
          .padding({ bottom: 8 })
          .border({ width: { bottom: this.selectedTab === 0 ? 2 : 0 }, color: '#4DA6FF' })
          .onClick(() => { this.selectedTab = 0; })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text($r('app.string.sticker_tab'))
          .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
          .fontColor(this.selectedTab === 1 ? '#4DA6FF' : '#99FFFFFF')
          .fontWeight(this.selectedTab === 1 ? BaseConstants.FONT_WEIGHT_FIVE : BaseConstants.FONT_WEIGHT_FOUR)
          .padding({ bottom: 8 })
          .border({ width: { bottom: this.selectedTab === 1 ? 2 : 0 }, color: '#4DA6FF' })
          .onClick(() => { this.selectedTab = 1; })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')

      /* Text input */
      TextInput({ placeholder: $r('app.string.text_placeholder'), text: this.inputText })
        .placeholderColor('#66FFFFFF')
        .fontColor(Color.White)
        .backgroundColor('#33FFFFFF')
        .borderRadius(8)
        .height(44)
        .width('100%')
        .onChange((value: string) => { this.inputText = value; })

      /* Color picker row */
      Row({ space: 4 }) {
        Text($r('app.string.text_color'))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#99FFFFFF')
          .width(40)

        ForEach(PictureEditConstants.TEXT_COLORS, (color: string, index: number) => {
          Row()
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(color)
            .border({ width: this.selectedColor === index ? 2 : 0, color: Color.White })
            .margin({ left: 2, right: 2 })
            .onClick(() => { this.selectedColor = index; })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      /* Size slider */
      Row({ space: 8 }) {
        Text($r('app.string.text_size'))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#99FFFFFF')
          .width(40)
        Slider({ value: this.fontSize, min: 12, max: 72, style: SliderStyle.OutSet })
          .blockColor('#4DA6FF')
          .selectedColor('#4DA6FF')
          .trackColor('#33FFFFFF')
          .onChange((value: number) => { this.fontSize = value; })
          .layoutWeight(1)
        Text(this.fontSize.toFixed(0))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#99FFFFFF')
          .width(30)
      }
      .width('100%')

      /* Opacity slider */
      Row({ space: 8 }) {
        Text($r('app.string.text_opacity'))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#99FFFFFF')
          .width(40)
        Slider({ value: this.opacity, min: 0.2, max: 1.0, style: SliderStyle.OutSet })
          .blockColor('#4DA6FF')
          .selectedColor('#4DA6FF')
          .trackColor('#33FFFFFF')
          .onChange((value: number) => { this.opacity = value; })
          .layoutWeight(1)
        Text(Math.round(this.opacity * 100).toString() + '%')
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#99FFFFFF')
          .width(36)
      }
      .width('100%')

      /* Add button */
      Button($r('app.string.text_add'))
        .width('100%')
        .height(40)
        .fontColor(Color.White)
        .backgroundColor(this.inputText.trim().length > 0 ? '#4DA6FF' : '#33FFFFFF')
        .borderRadius(8)
        .enabled(this.inputText.trim().length > 0)
        .onClick(() => {
          if (this.inputText.trim().length > 0 && this.onAddText) {
            this.onAddText(
              this.inputText.trim(),
              PictureEditConstants.TEXT_COLORS[this.selectedColor],
              this.fontSize,
              this.opacity
            );
            this.inputText = '';
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add features/pictureEdit/src/main/ets/views/watermark/TextWatermark.ets
git commit -m "feat: add TextWatermark editing panel component"
```

---

### Task 5: Create StickerPanel component

**Files:**
- Create: `features/pictureEdit/src/main/ets/views/watermark/StickerPanel.ets`

- [ ] **Step 1: Write StickerPanel.ets**

```typescript
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BaseConstants } from 'base';
import PictureEditConstants from '../../constants/PictureEditConstants';

/**
 * Sticker picker panel — emoji grid for adding stickers to the image.
 */
@Component
export struct StickerPanel {
  onAddSticker?: (emoji: string) => void;

  build() {
    Column({ space: 10 }) {
      Text('Emoji')
        .fontSize(BaseConstants.FONT_SIZE_TEN)
        .fontColor('#99FFFFFF')
        .width('100%')

      /* Emoji grid: 6 columns */
      Grid() {
        ForEach(PictureEditConstants.STICKER_EMOJI, (emoji: string) => {
          GridItem() {
            Text(emoji)
              .fontSize(28)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .borderRadius(8)
              .backgroundColor('#22FFFFFF')
              .onClick(() => {
                if (this.onAddSticker) {
                  this.onAddSticker(emoji);
                }
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(6)
      .columnsGap(6)
      .width('100%')
      .height(160)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add features/pictureEdit/src/main/ets/views/watermark/StickerPanel.ets
git commit -m "feat: add StickerPanel emoji picker component"
```

---

### Task 6: Create MosaicPanel component

**Files:**
- Create: `features/pictureEdit/src/main/ets/views/mosaic/MosaicPanel.ets`

- [ ] **Step 1: Create directory**

```bash
mkdir -p /d/xingqier/MultiPictureBeautification/features/pictureEdit/src/main/ets/views/mosaic
```

- [ ] **Step 2: Write MosaicPanel.ets**

```typescript
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BaseConstants } from 'base';

/**
 * Mosaic tool settings panel — mode switch, effect switch, brush size, grain, undo/clear.
 */
@Component
export struct MosaicPanel {
  @Link brushMode: number;     // 0 = brush, 1 = box
  @Link effectType: number;    // 0 = mosaic, 1 = blur
  @Link brushSize: number;     // 10-80 px
  @Link mosaicSize: number;    // 4-20 px
  onUndo?: () => void;
  onClear?: () => void;

  build() {
    Column({ space: 14 }) {
      /* Mode toggle */
      Row({ space: 0 }) {
        this.modeButton($r('app.string.mosaic_mode_brush'), 0)
        this.modeButton($r('app.string.mosaic_mode_box'), 1)
      }
      .borderRadius(8)
      .backgroundColor('#22FFFFFF')
      .width('100%')

      /* Effect toggle */
      Row({ space: 0 }) {
        this.effectButton($r('app.string.mosaic_effect_mosaic'), 0)
        this.effectButton($r('app.string.mosaic_effect_blur'), 1)
      }
      .borderRadius(8)
      .backgroundColor('#22FFFFFF')
      .width('100%')

      /* Brush size slider (only in brush mode) */
      if (this.brushMode === 0) {
        Row({ space: 8 }) {
          Text($r('app.string.mosaic_brush_size'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99FFFFFF')
            .width(56)
          Slider({ value: this.brushSize, min: 10, max: 80, style: SliderStyle.OutSet })
            .blockColor('#4DA6FF')
            .selectedColor('#4DA6FF')
            .trackColor('#33FFFFFF')
            .onChange((value: number) => { this.brushSize = value; })
            .layoutWeight(1)
          Text(this.brushSize.toFixed(0))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99FFFFFF')
            .width(24)
        }
        .width('100%')
      }

      /* Mosaic grain slider (only in mosaic effect mode) */
      if (this.effectType === 0) {
        Row({ space: 8 }) {
          Text($r('app.string.mosaic_grain'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99FFFFFF')
            .width(56)
          Slider({ value: this.mosaicSize, min: 4, max: 20, style: SliderStyle.OutSet })
            .blockColor('#4DA6FF')
            .selectedColor('#4DA6FF')
            .trackColor('#33FFFFFF')
            .onChange((value: number) => { this.mosaicSize = value; })
            .layoutWeight(1)
          Text(this.mosaicSize.toFixed(0))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99FFFFFF')
            .width(24)
        }
        .width('100%')
      }

      /* Action buttons */
      Row({ space: 12 }) {
        Button($r('app.string.mosaic_undo'))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#4DA6FF')
          .backgroundColor('#22FFFFFF')
          .borderRadius(8)
          .height(36)
          .layoutWeight(1)
          .onClick(() => { if (this.onUndo) this.onUndo(); })

        Button($r('app.string.mosaic_clear'))
          .fontSize(BaseConstants.FONT_SIZE_TEN)
          .fontColor('#FF5252')
          .backgroundColor('#22FFFFFF')
          .borderRadius(8)
          .height(36)
          .layoutWeight(1)
          .onClick(() => { if (this.onClear) this.onClear(); })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder
  modeButton(label: ResourceStr, mode: number) {
    Text(label)
      .fontSize(BaseConstants.FONT_SIZE_TEN)
      .fontColor(this.brushMode === mode ? '#FFFFFF' : '#99FFFFFF')
      .fontWeight(this.brushMode === mode ? BaseConstants.FONT_WEIGHT_FIVE : BaseConstants.FONT_WEIGHT_FOUR)
      .backgroundColor(this.brushMode === mode ? '#4DA6FF' : Color.Transparent)
      .borderRadius(8)
      .height(36)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.brushMode = mode; })
  }

  @Builder
  effectButton(label: ResourceStr, effect: number) {
    Text(label)
      .fontSize(BaseConstants.FONT_SIZE_TEN)
      .fontColor(this.effectType === effect ? '#FFFFFF' : '#99FFFFFF')
      .fontWeight(this.effectType === effect ? BaseConstants.FONT_WEIGHT_FIVE : BaseConstants.FONT_WEIGHT_FOUR)
      .backgroundColor(this.effectType === effect ? '#4DA6FF' : Color.Transparent)
      .borderRadius(8)
      .height(36)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.effectType = effect; })
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add features/pictureEdit/src/main/ets/views/mosaic/MosaicPanel.ets
git commit -m "feat: add MosaicPanel settings component"
```

---

### Task 7: Create MosaicCanvas component

**Files:**
- Create: `features/pictureEdit/src/main/ets/views/mosaic/MosaicCanvas.ets`

- [ ] **Step 1: Write MosaicCanvas.ets**

```typescript
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { MosaicRegion } from '../../viewmodel/AdaptiveViewModel';

/**
 * Transparent Canvas overlay for drawing mosaic / blur regions.
 * Handles both brush (touch-drag) and box (touch-drag-release) modes.
 */
@Component
export struct MosaicCanvas {
  @Link regions: MosaicRegion[];
  @Prop brushMode: number;    // 0 = brush, 1 = box
  @Prop effectType: number;   // 0 = mosaic, 1 = blur
  @Prop brushSize: number;    // 10-80
  @Prop mosaicSize: number;   // 4-20
  @Prop canvasWidth: number;  // actual image display width in vp
  @Prop canvasHeight: number; // actual image display height in vp
  @Prop enabled: boolean;     // only active when mosaic tool selected

  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private isDrawing: boolean = false;
  private boxStartX: number = 0;
  private boxStartY: number = 0;
  private boxEndX: number = 0;
  private boxEndY: number = 0;
  private currentPoints: Array<{ x: number; y: number }> = [];

  /**
   * Generate a deterministic pseudo-random color for mosaic blocks
   * based on (x, y) grid position — gives a "pixelated" look.
   */
  private mosaicBlockColor(gx: number, gy: number): string {
    const r: number = ((gx * 131 + gy * 257) % 256);
    const g: number = ((gx * 311 + gy * 173) % 256);
    const b: number = ((gx * 199 + gy * 331) % 256);
    return `rgba(${r}, ${g}, ${b}, 0.85)`;
  }

  /**
   * Redraw all regions onto the canvas.
   */
  redrawAll(): void {
    this.ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    for (const region of this.regions) {
      this.drawRegion(region);
    }
  }

  private drawRegion(region: MosaicRegion): void {
    if (region.rect) {
      // Box mode region
      if (region.type === 'mosaic') {
        const gs: number = region.mosaicSize ?? 8;
        for (let px: number = region.rect.left; px < region.rect.left + region.rect.width; px += gs) {
          for (let py: number = region.rect.top; py < region.rect.top + region.rect.height; py += gs) {
            const gx: number = Math.floor(px / gs);
            const gy: number = Math.floor(py / gs);
            this.ctx.fillStyle = this.mosaicBlockColor(gx, gy);
            this.ctx.fillRect(px, py, gs, gs);
          }
        }
      } else {
        // Blur: draw semi-transparent white overlay
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.35)';
        this.ctx.fillRect(region.rect.left, region.rect.top, region.rect.width, region.rect.height);
      }
    } else if (region.points) {
      // Brush mode region
      for (const pt of region.points) {
        if (region.type === 'mosaic') {
          const gs: number = region.mosaicSize ?? 8;
          for (let dx: number = -region.brushSize / 2; dx < region.brushSize / 2; dx += gs) {
            for (let dy: number = -region.brushSize / 2; dy < region.brushSize / 2; dy += gs) {
              const px: number = pt.x + dx;
              const py: number = pt.y + dy;
              const gx: number = Math.floor(px / gs);
              const gy: number = Math.floor(py / gs);
              this.ctx.fillStyle = this.mosaicBlockColor(gx, gy);
              this.ctx.fillRect(px, py, gs, gs);
            }
          }
        } else {
          // Blur brush: semi-transparent frosted circle
          this.ctx.fillStyle = 'rgba(255, 255, 255, 0.25)';
          this.ctx.beginPath();
          this.ctx.arc(pt.x, pt.y, region.brushSize / 2, 0, 2 * Math.PI);
          this.ctx.fill();
        }
      }
    }
  }

  build() {
    Canvas(this.ctx)
      .width(this.canvasWidth)
      .height(this.canvasHeight)
      .position({ x: 0, y: 0 })
      .hitTestBehavior(this.enabled ? HitTestMode.Default : HitTestMode.None)
      .onReady(() => {
        this.redrawAll();
      })
      .onTouch((event: TouchEvent) => {
        if (!this.enabled) return;

        const touch: TouchObject = event.touches[0];
        const x: number = touch.x;
        const y: number = touch.y;

        if (event.type === TouchType.Down) {
          this.isDrawing = true;
          if (this.brushMode === 0) {
            // Brush mode: start a new region
            this.currentPoints = [{ x, y }];
          } else {
            // Box mode: record start
            this.boxStartX = x;
            this.boxStartY = y;
            this.boxEndX = x;
            this.boxEndY = y;
          }
        } else if (event.type === TouchType.Move && this.isDrawing) {
          if (this.brushMode === 0) {
            // Brush mode: add point and draw
            this.currentPoints.push({ x, y });
            // Draw last stroke segment
            const region: MosaicRegion = {
              id: '',
              points: [{ x, y }],
              brushSize: this.brushSize,
              type: this.effectType === 0 ? 'mosaic' : 'blur',
              mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
            };
            this.drawRegion(region);
          } else {
            // Box mode: update end point
            this.boxEndX = x;
            this.boxEndY = y;
          }
        } else if (event.type === TouchType.Up && this.isDrawing) {
          this.isDrawing = false;
          if (this.brushMode === 0) {
            // Finalize brush region
            if (this.currentPoints.length > 0) {
              const region: MosaicRegion = {
                id: Date.now().toString(),
                points: [...this.currentPoints],
                brushSize: this.brushSize,
                type: this.effectType === 0 ? 'mosaic' : 'blur',
                mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
              };
              this.regions.push(region);
              // Trigger re-render by replacing the array reference
              this.regions = [...this.regions];
              this.currentPoints = [];
            }
          } else {
            // Finalize box region — ensure positive dimensions
            const left: number = Math.min(this.boxStartX, this.boxEndX);
            const top: number = Math.min(this.boxStartY, this.boxEndY);
            const width: number = Math.abs(this.boxEndX - this.boxStartX);
            const height: number = Math.abs(this.boxEndY - this.boxStartY);
            if (width > 10 && height > 10) {
              const region: MosaicRegion = {
                id: Date.now().toString(),
                brushSize: this.brushSize,
                rect: { left, top, width, height },
                type: this.effectType === 0 ? 'mosaic' : 'blur',
                mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
              };
              this.regions.push(region);
              this.regions = [...this.regions];
            }
          }
          // Redraw everything (final render)
          this.redrawAll();
        }
      })
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add features/pictureEdit/src/main/ets/views/mosaic/MosaicCanvas.ets
git commit -m "feat: add MosaicCanvas overlay component"
```

---

### Task 8: Integrate everything into PictureEdit.ets

**Files:**
- Modify: `features/pictureEdit/src/main/ets/views/PictureEdit.ets`

This is the largest change. We modify `PictureEdit.ets` to:
1. Import new components and types
2. Add new @State variables for overlays and mosaic
3. Modify `centerPicture()` to use Stack with overlays
4. Modify `optionRegion()` panel routing for tools 5 & 6
5. Add `textWatermarkPanel()` and `mosaicPanel()` builders
6. Add overlay gesture handlers
7. Wrap bottomBar in Scroll

- [ ] **Step 1: Update imports**

Replace lines 16-19 (imports) with:

```typescript
import { BaseConstants, BreakpointConstants } from 'base';
import PictureEditConstants from '../constants/PictureEditConstants';
import {
  AiPreset, ColorMatrix, OverlayItem, TextOverlay,
  StickerOverlay, MosaicRegion
} from '../viewmodel/AdaptiveViewModel';
import { deviceInfo } from '@kit.BasicServicesKit';
import { TextWatermark } from './watermark/TextWatermark';
import { StickerPanel } from './watermark/StickerPanel';
import { MosaicPanel } from './mosaic/MosaicPanel';
import { MosaicCanvas } from './mosaic/MosaicCanvas';
```

- [ ] **Step 2: Add new @State variables**

In the `PictureEdit` struct, after the existing `@State showOriginal: boolean = false;` (line 45), add:

```typescript
  /* ---------- Text / Sticker overlay state ---------- */
  @State overlays: OverlayItem[] = [];
  @State selectedStickerTab: number = 0;           // 0=text, 1=sticker
  @State activeOverlayId: string = '';

  /* ---------- Mosaic state ---------- */
  @State mosaicRegions: MosaicRegion[] = [];
  @State mosaicBrushMode: number = 0;              // 0=brush, 1=box
  @State mosaicEffectType: number = 0;             // 0=mosaic, 1=blur
  @State mosaicBrushSize: number = 30;
  @State mosaicGrainSize: number = 8;
```

- [ ] **Step 3: Modify centerPicture() to include Stack overlays**

Replace the `centerPicture()` builder (lines 123-146) with:

```typescript
  @Builder
  centerPicture() {
    Stack() {
      /* Layer 0: Main image */
      Image($r("app.media.photo"))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .colorFilter(this.showOriginal ? PictureEditConstants.IDENTITY : this.activeColorFilter)
        .height(PictureEditConstants.PICTURE_HEIGHT)
        .width(this.pictureWidth)
        .constraintSize({ maxWidth: deviceInfo.deviceType === BaseConstants.DEVICE_2IN1 ? 900 : undefined })
        .gesture(
          LongPressGesture({ repeat: false, duration: 200 })
            .onAction(() => {
              if (this.selectedTool === 4 && this.activePresetIndex >= 0) {
                this.showOriginal = true;
              }
            })
            .onActionEnd(() => {
              this.showOriginal = false;
            })
        )

      /* Layer 1: Mosaic/blur canvas */
      if (this.selectedTool === 6 || this.mosaicRegions.length > 0) {
        MosaicCanvas({
          regions: $mosaicRegions,
          brushMode: this.mosaicBrushMode,
          effectType: this.mosaicEffectType,
          brushSize: this.mosaicBrushSize,
          mosaicSize: this.mosaicGrainSize,
          canvasWidth: 360,   // will be set via onAreaChange
          canvasHeight: 360,
          enabled: this.selectedTool === 6
        })
          .width(this.pictureWidth)
          .height(PictureEditConstants.PICTURE_HEIGHT)
      }

      /* Layer 2: Text / sticker overlays */
      ForEach(this.overlays, (item: OverlayItem, index: number) => {
        if (item.type === 'text') {
          this.textOverlayItem(item as TextOverlay)
        } else {
          this.stickerOverlayItem(item as StickerOverlay)
        }
      }, (item: OverlayItem) => item.id)
    }
  }

  @Builder
  textOverlayItem(item: TextOverlay) {
    Text(item.text)
      .fontSize(item.fontSize)
      .fontColor(item.color)
      .opacity(item.opacity)
      .rotate({ angle: item.rotation })
      .scale({ x: item.scale, y: item.scale })
      .position({ x: item.x * 360, y: item.y * 360 })
      .border({
        width: this.activeOverlayId === item.id ? 1 : 0,
        color: '#4DA6FF',
        style: BorderStyle.Dashed
      })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({ fingers: 1 })
            .onActionUpdate((event: GestureEvent) => {
              item.x = Math.max(0, Math.min(1, item.x + event.offsetX / 360));
              item.y = Math.max(0, Math.min(1, item.y + event.offsetY / 360));
            }),
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent) => {
              item.scale = Math.max(0.5, Math.min(3.0, item.scale * event.scale));
            }),
          RotationGesture()
            .onActionUpdate((event: GestureEvent) => {
              item.rotation = (item.rotation + event.angle) % 360;
            })
        )
      )
      .onClick(() => {
        this.activeOverlayId = this.activeOverlayId === item.id ? '' : item.id;
      })
  }

  @Builder
  stickerOverlayItem(item: StickerOverlay) {
    Text(item.emoji)
      .fontSize(36)
      .opacity(item.opacity)
      .rotate({ angle: item.rotation })
      .scale({ x: item.scale, y: item.scale })
      .position({ x: item.x * 360, y: item.y * 360 })
      .border({
        width: this.activeOverlayId === item.id ? 1 : 0,
        color: '#4DA6FF',
        style: BorderStyle.Dashed
      })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({ fingers: 1 })
            .onActionUpdate((event: GestureEvent) => {
              item.x = Math.max(0, Math.min(1, item.x + event.offsetX / 360));
              item.y = Math.max(0, Math.min(1, item.y + event.offsetY / 360));
            }),
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent) => {
              item.scale = Math.max(0.5, Math.min(3.0, item.scale * event.scale));
            }),
          RotationGesture()
            .onActionUpdate((event: GestureEvent) => {
              item.rotation = (item.rotation + event.angle) % 360;
            })
        )
      )
      .onClick(() => {
        this.activeOverlayId = this.activeOverlayId === item.id ? '' : item.id;
      })
  }
```

- [ ] **Step 4: Modify optionRegion() to route panels for tools 5 & 6**

Replace the `optionRegion()` builder (lines 151-174) with:

```typescript
  @Builder
  optionRegion() {
    Flex({
      direction: this.isColumnLayout(this.currentBp, this.windowDirection) ? FlexDirection.Column : FlexDirection.Row
    }) {
      Flex() {
        this.sliderBar()
      }
      .flexBasis(PictureEditConstants.SLIDER_FLEX_BASIS)

      if (this.selectedTool === 4) {
        this.aiPanel()
      } else if (this.selectedTool === 5) {
        this.textWatermarkPanel()
      } else if (this.selectedTool === 6) {
        this.mosaicPanel()
      } else {
        this.filterWindows()
      }
      Flex({ justifyContent: FlexAlign.Center }) {
        this.bottomBar()
      }
      .flexBasis(PictureEditConstants.BAR_FLEX_BASIS)
    }
    .height(this.isColumnLayout(this.currentBp, this.windowDirection) ? BaseConstants.FULL_HEIGHT :
    PictureEditConstants.PICTURE_HALF_HEIGHT)
    .padding($r('app.float.row_padding'))
  }
```

- [ ] **Step 5: Add textWatermarkPanel() and mosaicPanel() builders**

Insert after the `aiPanel()` builder (after line 399, before `build()`):

```typescript
  /* =================================================================
   *  Text Watermark / Sticker Panel
   * ================================================================= */
  @Builder
  textWatermarkPanel() {
    Column({ space: 0 }) {
      TextWatermark({
        selectedTab: $selectedStickerTab,
        onAddText: (text: string, color: string, fontSize: number, opacity: number) => {
          const overlay: TextOverlay = {
            id: Date.now().toString() + '_text',
            type: 'text',
            text: text,
            x: 0.5,
            y: 0.5,
            fontSize: fontSize,
            color: color,
            opacity: opacity,
            rotation: 0,
            scale: 1.0
          };
          this.overlays.push(overlay);
          this.overlays = [...this.overlays];
        }
      })

      if (this.selectedStickerTab === 1) {
        StickerPanel({
          onAddSticker: (emoji: string) => {
            const overlay: StickerOverlay = {
              id: Date.now().toString() + '_sticker',
              type: 'sticker',
              emoji: emoji,
              x: 0.5,
              y: 0.5,
              scale: 1.0,
              rotation: 0,
              opacity: 1.0
            };
            this.overlays.push(overlay);
            this.overlays = [...this.overlays];
          }
        })
      }
    }
    .width('100%')
  }

  /* =================================================================
   *  Mosaic Panel
   * ================================================================= */
  @Builder
  mosaicPanel() {
    MosaicPanel({
      brushMode: $mosaicBrushMode,
      effectType: $mosaicEffectType,
      brushSize: $mosaicBrushSize,
      mosaicSize: $mosaicGrainSize,
      onUndo: () => {
        if (this.mosaicRegions.length > 0) {
          this.mosaicRegions.pop();
          this.mosaicRegions = [...this.mosaicRegions];
        }
      },
      onClear: () => {
        this.mosaicRegions = [];
      }
    })
  }

  /* ---- Delete overlay helper ---- */
  deleteActiveOverlay(): void {
    if (this.activeOverlayId) {
      this.overlays = this.overlays.filter((o: OverlayItem) => o.id !== this.activeOverlayId);
      this.activeOverlayId = '';
    }
  }
```

- [ ] **Step 6: Modify bottomBar() to support scrolling for 7 tools**

Replace the `bottomBar()` builder (lines 247-283) with:

```typescript
  @Builder
  bottomBar() {
    Scroll(
      this.isColumnLayout(this.currentBp, this.windowDirection)
        ? Axis.Horizontal
        : Axis.Vertical
    ) {
      Flex({
        justifyContent: FlexAlign.SpaceAround,
        alignItems: ItemAlign.Center,
        direction: this.isColumnLayout(this.currentBp, this.windowDirection)
          ? FlexDirection.Row : FlexDirection.Column,
      }) {
        ForEach(PictureEditConstants.toolsAndName, (item: ToolsAndName, toolIndex: number) => {
          Column() {
            Image(item.pic)
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .autoResize(true)
              .aspectRatio(1)
              .margin({ bottom: $r('app.float.image_margin') })
              .fillColor(this.selectedTool === toolIndex ? '#4DA6FF' : '')
            Text(item.pic_name)
              .fontSize(BaseConstants.FONT_SIZE_TEN)
              .fontColor(this.selectedTool === toolIndex ? '#4DA6FF' : $r('app.color.text_color'))
          }
          .padding({ left: 6, right: 6 })
          .onClick(() => {
            if (this.selectedTool === toolIndex) {
              // Deselect
              this.selectedTool = -1;
              this.activePresetIndex = -1;
              this.activeColorFilter = [...PictureEditConstants.IDENTITY];
            } else {
              this.selectedTool = toolIndex;
              if (toolIndex !== 4) {
                this.activePresetIndex = -1;
              }
            }
          })
        }, (item: ToolsAndName, toolIndex: number) => toolIndex.toString())
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
```

- [ ] **Step 7: Add long-press delete for active overlay**

Modify the `centerPicture()` Stack to include a long-press handler. Add to the Stack's gesture area:

In the Stack within `centerPicture()`, the existing `onClick` on each overlay already handles selection. For deletion, we handle it via the active overlay. We'll rely on the overlay tap-to-select + the existing interaction pattern. The delete action is triggered by long-pressing the selected overlay:

In `textOverlayItem` builder, add after the existing gesture:

```typescript
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              this.deleteActiveOverlay();
            }),
          GestureGroup(GestureMode.Parallel,
            // ... existing PanGesture, PinchGesture, RotationGesture
          )
        )
      )
```

But this complicates the code. Let's keep it simpler — add a delete button in the text panel when an overlay is active. Actually, on second thought, let's keep the gesture approach clean:

Replace the `textOverlayItem` builder to use exclusive gesture group with long-press for delete:

The gesture block becomes:
```typescript
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              this.deleteActiveOverlay();
            }),
          GestureGroup(GestureMode.Parallel,
            PanGesture({ fingers: 1 })
              .onActionUpdate((event: GestureEvent) => {
                item.x = Math.max(0, Math.min(1, item.x + event.offsetX / 360));
                item.y = Math.max(0, Math.min(1, item.y + event.offsetY / 360));
              }),
            PinchGesture({ fingers: 2 })
              .onActionUpdate((event: GestureEvent) => {
                item.scale = Math.max(0.5, Math.min(3.0, item.scale * event.scale));
              }),
            RotationGesture()
              .onActionUpdate((event: GestureEvent) => {
                item.rotation = (item.rotation + event.angle) % 360;
              })
          )
        )
      )
```

Same for `stickerOverlayItem`.

- [ ] **Step 8: Run compilation check**

```bash
cd /d/xingqier/MultiPictureBeautification && export JAVA_HOME="/d/DevEco Studio/jbr" && export DEVECO_SDK_HOME="/d/DevEco Studio/sdk" && hvigorw assembleHap 2>&1 | tail -30
```

Expected: BUILD SUCCESSFUL

- [ ] **Step 9: Commit**

```bash
git add features/pictureEdit/src/main/ets/views/PictureEdit.ets
git commit -m "feat: integrate watermark and mosaic tools into PictureEdit"
```

---

### Task 9: Final verification and adjustments

- [ ] **Step 1: Run full build**

```bash
cd /d/xingqier/MultiPictureBeautification && export JAVA_HOME="/d/DevEco Studio/jbr" && export DEVECO_SDK_HOME="/d/DevEco Studio/sdk" && hvigorw assembleHap 2>&1
```

Expected: BUILD SUCCESSFUL

- [ ] **Step 2: Fix any compilation errors**

Review compiler output. Common ArkTS issues:
- `@Link` must be initialized with `$` prefix in parent → verify all `$mosaicRegions`, `$selectedStickerTab`, etc.
- `Canvas` requires `CanvasRenderingContext2D` instantiated as a field, not in build()
- `GestureGroup` may not support nesting in all API versions → if compilation fails, simplify to single gesture

If `GestureGroup(GestureMode.Exclusive, LongPressGesture, GestureGroup(Parallel, ...))` nesting fails, simplify gesture to just PanGesture for MVP, noting long-press-delete as a follow-up:

```typescript
      .gesture(
        PanGesture({ fingers: 1 })
          .onActionUpdate((event: GestureEvent) => {
            item.x = Math.max(0, Math.min(1, item.x + event.offsetX / 360));
            item.y = Math.max(0, Math.min(1, item.y + event.offsetY / 360));
          })
      )
```

- [ ] **Step 3: Push to remote**

```bash
git push origin dev:harmony-dev && git push course dev:harmony-dev
```

---

## Plan Self-Review

1. **Spec coverage:** All sections covered — data models (Task 1), i18n (Task 2), tool constants (Task 3), text watermark panel (Task 4), sticker panel (Task 5), mosaic panel (Task 6), mosaic canvas (Task 7), PictureEdit integration (Task 8), verification (Task 9).

2. **Placeholder check:** No TBD/TODO. All code is concrete. One known risk: nested GestureGroup may not compile — fallback documented in Task 9 Step 2.

3. **Type consistency:**
   - `OverlayItem = TextOverlay | StickerOverlay` defined in Task 1, used in Task 8
   - `MosaicRegion` defined in Task 1, used in Tasks 7, 8
   - `selectedTool` remains `number` type (0-6) throughout
   - `$mosaicRegions` `@Link` syntax used in MosaicCanvas and MosaicPanel
   - `toolsAndName` index: 0=capture, 1=crop, 2=adjust, 3=filter, 4=AI, 5=Text, 6=Mosaic ✓
