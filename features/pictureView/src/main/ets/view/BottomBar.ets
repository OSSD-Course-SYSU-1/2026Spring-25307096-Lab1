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

import PictureViewConstants, { ActionInterface } from '../constants/PictureViewConstants';
import { BaseConstants } from 'base';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Preview
@Component
export struct BottomBar {
  @Consume('pageInfos') pageInfos: NavPathStack
  @Consume('favoritedIndices') favoritedIndices: number[];
  @Consume('curImageIndex') curImageIndex: number;

  isFavorited(): boolean {
    return this.favoritedIndices.indexOf(this.curImageIndex) !== -1;
  }

  getActionColor(index: number): string {
    if (index === 1) {
      return this.isFavorited() ? '#FF4444' : '#999999';
    }
    const colors: string[] = ['#4DA6FF', '', '#4CAF50', '#FF5252', '#999999'];
    return colors[index];
  }

  build() {
    Flex({
      justifyContent: FlexAlign.Center,
      direction: FlexDirection.Row
    }) {
      ForEach(PictureViewConstants.ACTIONS, (item: ActionInterface, index: number) => {
        if (index === 2) {
          Column() {
            Image(item.icon)
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .fillColor(this.getActionColor(index))
            Text(item.icon_name)
              .fontFamily(BaseConstants.FONT_FAMILY_NORMAL)
              .fontSize(BaseConstants.FONT_SIZE_TEN)
              .fontWeight(BaseConstants.FONT_WEIGHT_FOUR)
              .padding({ top: $r('app.float.icon_padding_top') })
          }
          .width(PictureViewConstants.ICON_LIST_WIDTH)
          .onClick(() => {
            this.pageInfos.pushPath(new NavPathInfo('pictureEdit', []));
          })
        } else if (index === 3) {
          Column() {
            Image(item.icon)
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .fillColor(this.getActionColor(index))
            Text(item.icon_name)
              .fontFamily(BaseConstants.FONT_FAMILY_NORMAL)
              .fontSize(BaseConstants.FONT_SIZE_TEN)
              .fontWeight(BaseConstants.FONT_WEIGHT_FOUR)
              .padding({ top: $r('app.float.icon_padding_top') })
          }
          .width(PictureViewConstants.ICON_LIST_WIDTH)
          .onClick(() => {
            AppStorage.setOrCreate<number>('delete_idx', this.curImageIndex);
          })
        } else {
          Column() {
            Image(item.icon)
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .fillColor(this.getActionColor(index))
            Text(this.isFavorited() && index === 1 ? $r('app.string.favorited') : item.icon_name)
              .fontFamily(BaseConstants.FONT_FAMILY_NORMAL)
              .fontSize(BaseConstants.FONT_SIZE_TEN)
              .fontWeight(BaseConstants.FONT_WEIGHT_FOUR)
              .padding({ top: $r('app.float.icon_padding_top') })
          }
          .width(PictureViewConstants.ICON_LIST_WIDTH)
          .onClick(() => {
            try {
              if (index === 1) {
                AppStorage.setOrCreate<number>('fav_toggle_idx', this.curImageIndex);
                return;
              }
            } catch (error) {
              let err = error as BusinessError;
              hilog.error(0x0000, 'BottomBar', 'error code is ' + err.code);
            }
          })
        }
      }, (_item: ActionInterface, idx: number) => idx.toString())
    }
    .height($r('app.float.icon_list_height'))
  }
}
