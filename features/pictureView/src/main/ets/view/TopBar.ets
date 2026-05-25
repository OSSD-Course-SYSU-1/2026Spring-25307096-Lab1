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
import PictureViewConstants, { ActionInterface } from '../constants/PictureViewConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TITLE: string = '2020.12.24';

@Preview
@Component
export struct TopBar {
  @StorageLink('currentBreakpoint') currentBp: string = BreakpointConstants.BREAKPOINT_MD;
  @Consume('pageInfos') pageInfos: NavPathStack
  @Consume('isFavorited') isFavorited: boolean;
  @State showInfoDialog: boolean = false;

  build() {
    Stack() {
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
                  this.showInfoDialog = true;
                })
              if (this.currentBp === BreakpointConstants.BREAKPOINT_LG) {
                ForEach(PictureViewConstants.ACTIONS, (item: ActionInterface) => {
                  Image(item.icon)
                    .height(BaseConstants.DEFAULT_ICON_SIZE)
                    .width(BaseConstants.DEFAULT_ICON_SIZE)
                    .fillColor(this.isFavorited && item.icon === $r('app.media.ic_public_favor') ?
                      '#FF4444' : '')
                    .margin({ left: $r('app.float.detail_image_left') })
                    .onClick(() => {
                      try {
                        let pushPath = this.getUIContext()
                          .getHostContext()?.resourceManager.getStringSync((item.icon_name as Resource).id) as string;
                        if (pushPath === '编辑' || pushPath === 'edit') {
                          this.pageInfos.pushPath(new NavPathInfo('pictureEdit', []));
                        }
                        if (item.icon === $r('app.media.ic_public_favor')) {
                          this.isFavorited = !this.isFavorited;
                        }
                      } catch (error) {
                        let err = error as BusinessError;
                        hilog.error(0x0000, 'TopBar', 'error code is ' + err.code);
                      }
                    })
                }, (item: ActionInterface, index: number) => index + JSON.stringify(item))
              }
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
      // Image info dialog overlay
      if (this.showInfoDialog) {
        Column() {
          Column() {
            Text($r('app.string.image_info_title'))
              .fontSize(BaseConstants.FONT_SIZE_EIGHTEEN)
              .fontWeight(BaseConstants.FONT_WEIGHT_FIVE)
              .margin({ bottom: $r('app.float.image_margin') })
            Divider()
            Row() {
              Text($r('app.string.image_name_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  IMG_20201224_001.jpg')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.image_margin') })
            Row() {
              Text($r('app.string.image_size_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  4032 × 3024')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.icon_padding_top') })
            Row() {
              Text($r('app.string.image_date_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  2020-12-24 10:30:00')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.icon_padding_top') })
            Button($r('app.string.image_info_close'))
              .margin({ top: $r('app.float.image_margin') })
              .onClick(() => {
                this.showInfoDialog = false;
              })
          }
          .padding($r('app.float.row_padding'))
          .backgroundColor(Color.White)
          .borderRadius(16)
          .width('80%')
        }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#66000000')
        .onClick(() => {
          this.showInfoDialog = false;
        })
      }
    }
    .width(BaseConstants.FULL_WIDTH)
  }
}