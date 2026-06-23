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
