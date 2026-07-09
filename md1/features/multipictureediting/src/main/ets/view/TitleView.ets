/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import { AppStorageV2 } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { WindowUtil, CommonConstants } from 'multipicturecommon'
import { EditingViewModel } from '../viewmodel/EditingViewModel';
import { EditingConstants } from '../constants/EditingConstants';

@ComponentV2
export struct TitleView {
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Local editingViewModel: EditingViewModel = EditingViewModel.getInstance();
  @Consumer() pathStack: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
          .fontColor([$r('app.color.title_icon_color_primary')])
      }
      .width(CommonConstants.BUTTON_SIZE)
      .height(CommonConstants.BUTTON_SIZE)
      .backgroundColor(deviceInfo.deviceType === '2in1' ? Color.Transparent : $r('app.color.title_button_background'))
      .borderRadius(CommonConstants.BORDER_RADIUS_BUTTON)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.pathStack.pop();
      })

      Text(this.editingViewModel.title)
        .fontSize(CommonConstants.FONT_SIZE_TITLE)
        .fontWeight(EditingConstants.TITLE_FONT_WEIGHT)
        .lineHeight(CommonConstants.LINE_HEIGHT_TITLE)
        .fontColor($r('app.color.title_icon_color_primary'))
        .margin({ left: CommonConstants.MARGIN_LEFT_BUTTON })

      Blank()

      Row() {
        SymbolGlyph($r('sys.symbol.save'))
          .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
          .fontColor([$r('app.color.title_icon_color_secondary')])
      }
      .width(CommonConstants.BUTTON_SIZE)
      .height(CommonConstants.BUTTON_SIZE)
      .backgroundColor(deviceInfo.deviceType === '2in1' ? Color.Transparent : $r('app.color.title_button_background'))
      .borderRadius(CommonConstants.BORDER_RADIUS_BUTTON)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(CommonConstants.TITLE_BAR_HEIGHT)
  }
}