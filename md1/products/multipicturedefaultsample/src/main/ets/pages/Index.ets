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

import { AppStorageV2, uiObserver, window } from '@kit.ArkUI';
import { HdsNavigation } from '@kit.UIDesignKit';
import { WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumListViewModel, SideAlbum } from 'multipicturebrowsing';
import { TimeFilterViewModel } from 'multipicturebrowsing';
import { PictureBrowsingMobileView } from '../view/PictureBrowsingMobileView';
import { PictureEditingMobileView } from '../view/PictureEditingMobileView';
import { DefaultConstants } from '../constants/DefaultConstants';

@Builder
export function PictureBrowsingBuilder() {
  PictureBrowsingMobileView()
}

@Builder
export function PictureEditingBuilder() {
  PictureEditingMobileView()
}

@Entry
@ComponentV2
struct Index {
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  @Local timeFilterViewModel: TimeFilterViewModel = TimeFilterViewModel.getInstance();
  pathStack: NavPathStack = new NavPathStack();
  public onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let curWidthVp = this.getUIContext().px2vp(windowSize.width);
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    let stackTop: string = this.pathStack.getAllPathName()[this.pathStack.size() - 1];

    if (stackTop === 'PictureBrowsing') {
      if (curWidthVp >= DefaultConstants.BREAKPOINT_THRESHOLD_WIDTH &&
        ratio <= DefaultConstants.SCREEN_RATIO_THRESHOLD_INDEX) {
        this.albumListViewModel.showSidebarIcon = true;
      } else {
        this.albumListViewModel.showSidebarIcon = false;
      }
    }
  };

  aboutToAppear(): void {
    this.pathStack.pushPathByName('PictureBrowsing', null);
    this.windowUtil.addWindowSizeMonitor(this.onWindowSizeChange);
  }

  aboutToDisappear(): void {
    this.windowUtil.release();
    AppStorageV2.remove(CommonConstants.WINDOW_UTIL_KEY);
  }

  build() {
    Stack() {
      HdsNavigation(this.pathStack) {
        SideAlbum()
          .margin({
            top: this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height) +
              DefaultConstants.SIDEBAR_MARGIN_TOP_EXTRA
          })
      }
      .mode(this.albumListViewModel.showSidebarIcon && this.albumListViewModel.showSidebar ? NavigationMode.Split :
        NavigationMode.Stack)
      .hideToolBar(true)
      .hideTitleBar(true)
      .width('100%')
      .height('100%')
      .navBarWidth(DefaultConstants.SIDEBAR_NAV_BAR_WIDTH)
      .backgroundColor($r('sys.color.comp_background_tertiary'))

      Row() {
        SymbolGlyph(this.albumListViewModel.showSidebar ? $r('sys.symbol.close_sidebar') :
          $r('sys.symbol.open_sidebar'))
          .fontSize(DefaultConstants.SIDEBAR_BUTTON_FONT_SIZE)
          .fontColor([$r('sys.color.font_primary')])
      }
      .height(DefaultConstants.SIDEBAR_BUTTON_SIZE)
      .width(DefaultConstants.SIDEBAR_BUTTON_SIZE)
      .borderRadius(DefaultConstants.SIDEBAR_BUTTON_BORDER_RADIUS)
      .backgroundColor($r('app.color.sidebar_button_background'))
      .justifyContent(FlexAlign.Center)
      .visibility(this.albumListViewModel.showSidebarIcon ? Visibility.Visible : Visibility.None)
      .position({
        left: DefaultConstants.SIDEBAR_BUTTON_POSITION_LEFT,
        top: DefaultConstants.SIDEBAR_BUTTON_POSITION_TOP +
          this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height)
      })
      .onClick(() => {
        this.albumListViewModel.showSidebar = !this.albumListViewModel.showSidebar;
      })
    }
    .height('100%')
    .width('100%')
  }
}