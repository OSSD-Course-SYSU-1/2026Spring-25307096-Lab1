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
 * Shares a tab bar with StickerPanel (controlled by selectedTab @Link).
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
