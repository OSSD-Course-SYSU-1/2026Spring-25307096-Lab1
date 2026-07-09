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
