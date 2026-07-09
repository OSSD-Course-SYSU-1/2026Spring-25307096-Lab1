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

import { BaseConstants, BreakpointConstants } from 'base';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TITLE: string = '2020.12.24';

@Preview
@Component
export struct TopBar {
  @StorageLink('currentBreakpoint') currentBp: string = BreakpointConstants.BREAKPOINT_MD;
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
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
    }) {
      Column() {
        Flex({
          justifyContent: FlexAlign.SpaceBetween,
          direction: FlexDirection.Row,
          alignItems: ItemAlign.Stretch
        }) {
          Row() {
            Image($r('app.media.ic_public_back_black'))
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .margin({ right: $r('app.float.back_image_right') })
            Column() {
              Text(TITLE)
                .fontFamily(BaseConstants.FONT_FAMILY_MEDIUM)
                .fontSize(BaseConstants.FONT_SIZE_TWENTY)
                .fontWeight(BaseConstants.FONT_WEIGHT_FIVE)
              Text($r('app.string.subtitle_infomation'))
                .fontFamily(BaseConstants.FONT_FAMILY_NORMAL)
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontWeight(BaseConstants.FONT_WEIGHT_FOUR)
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('app.float.back_area_padding'))
          }

          Row() {
            Image($r('app.media.ic_public_picture'))
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .autoResize(true)
              .onClick(() => {
                this.pageInfos.pushPath(new NavPathInfo('albumView', []));
              })
            Image($r('app.media.ic_public_detail'))
              .height(BaseConstants.DEFAULT_ICON_SIZE)
              .width(BaseConstants.DEFAULT_ICON_SIZE)
              .margin({ left: $r('app.float.detail_image_left') })
              .onClick(() => {
                AppStorage.setOrCreate<boolean>('show_info_dialog', true);
              })
          }
        }
      }
    }
    .height($r('app.float.top_bar_height'))
    .margin({
      top: $r('app.float.top_bar_top'),
      bottom: $r('app.float.top_bar_bottom'),
      left: $r('app.float.top_bar_left'),
      right: $r('app.float.top_bar_right')
    })
    .width(BaseConstants.FULL_WIDTH)
  }
}
