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

import { AppStorageV2, uiObserver } from '@kit.ArkUI';
import { WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumListViewModel, PictureBrowsingView } from 'multipicturebrowsing';
import { PcConstants } from '../constants/PcConstants';

@ComponentV2
export struct PictureBrowsingPcView {
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Provider('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      PictureBrowsingView()
    }
    .width('100%')
    .height('100%')
    .hideBackButton(true)
    .title({
      builder: this.titleBar(),
      height: CommonConstants.TITLE_BAR_HEIGHT +
        this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height ?? 0)
    })
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onBackPressed(() => {
      this.getUIContext().getRouter().back();
      return true;
    })
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  @Builder
  titleBar() {
    Row() {
      Row() {
        SymbolGlyph(this.albumListViewModel.showSidebar ? $r('sys.symbol.close_sidebar') :
          $r('sys.symbol.open_sidebar'))
          .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
          .fontColor([$r('sys.color.font_primary')])
      }
      .height(CommonConstants.BUTTON_SIZE)
      .width(CommonConstants.BUTTON_SIZE)
      .borderRadius(CommonConstants.BORDER_RADIUS_BUTTON)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.albumListViewModel.showSidebar = !this.albumListViewModel.showSidebar;
      })

      Text($r('app.string.title_today'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .fontSize(CommonConstants.FONT_SIZE_TITLE)
        .lineHeight(CommonConstants.LINE_HEIGHT_TITLE)
        .margin({ left: CommonConstants.MARGIN_LEFT_BUTTON })

      Blank()

      this.titleIcon($r('sys.symbol.checkmark_square'))
      this.titleIcon($r('sys.symbol.magnifyingglass'))
      this.titleIcon($r('sys.symbol.dot_grid_2x2'))
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height ?? 0),
      left: CommonConstants.PADDING_SM,
      right: this.windowUtil.mainWindowInfo.titleButtonRect?.width ?? PcConstants.DEFAULT_TITLE_BUTTON_WIDTH
    })
  }

  @Builder
  titleIcon(icon: Resource) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
        .fontColor([$r('sys.color.font_primary')])
    }
    .width(CommonConstants.BUTTON_SIZE)
    .height(CommonConstants.BUTTON_SIZE)
    .borderRadius(CommonConstants.BORDER_RADIUS_BUTTON)
    .justifyContent(FlexAlign.Center)
    .margin({ left: CommonConstants.MARGIN_LEFT_BUTTON })
  }
}