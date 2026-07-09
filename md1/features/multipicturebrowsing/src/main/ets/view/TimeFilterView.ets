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
import { WindowUtil, CommonConstants } from 'multipicturecommon';
import { TimeFilterViewModel } from '../viewmodel/TimeFilterViewModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

@ComponentV2
export struct TimeFilterView {
  @Local timeFilterViewModel: TimeFilterViewModel = TimeFilterViewModel.getInstance();
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;

  build() {
    Row() {
      ForEach(this.timeFilterViewModel.filters, (item: string, index: number) => {
        Row() {
          Text(item)
            .fontSize(BrowsingConstants.TIME_FILTER_FONT_SIZE)
            .lineHeight(BrowsingConstants.TIME_FILTER_LINE_HEIGHT)
            .fontColor(this.timeFilterViewModel.filterIndex === index ? $r('app.color.time_filter_selected_text') :
              $r('app.color.time_filter_unselected_text'))
        }
        .layoutWeight(1)
        .height('100%')
        .borderRadius(BrowsingConstants.TIME_FILTER_ITEM_BORDER_RADIUS)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.timeFilterViewModel.filterIndex === index ? $r('app.color.time_filter_selected_bg') :
          Color.Transparent)
        .onClick(() => {
          this.timeFilterViewModel.filterIndex = index;
        })
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width(BrowsingConstants.TIME_FILTER_WIDTH)
    .height(BrowsingConstants.TIME_FILTER_HEIGHT)
    .backgroundColor($r('app.color.time_filter_background'))
    .borderRadius(BrowsingConstants.TIME_FILTER_BORDER_RADIUS)
    .padding(BrowsingConstants.TIME_FILTER_PADDING)
    .margin({
      bottom: this.windowUtil.mainWindowInfo.widthBp <= WidthBreakpoint.WIDTH_SM ? CommonConstants.MARGIN_LEFT_BUTTON :
        this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height) +
          CommonConstants.MARGIN_LEFT_BUTTON
    })
  }
}