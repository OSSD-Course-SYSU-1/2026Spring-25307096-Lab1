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
import { AlbumListViewModel, SideAlbum } from 'multipicturebrowsing';
import { TimeFilterViewModel } from 'multipicturebrowsing';
import { PictureEditingPcView } from '../view/PictureEditingPcView';
import { PictureBrowsingPcView } from '../view/PictureBrowsingPcView';

@Builder
export function PictureBrowsingBuilder() {
  PictureBrowsingPcView()
}

@Builder
export function PictureEditingBuilder() {
  PictureEditingPcView()
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

  aboutToAppear(): void {
    this.pathStack.pushPathByName('PictureBrowsing', null);
  }

  aboutToDisappear(): void {
    this.windowUtil.release();
    AppStorageV2.remove(CommonConstants.WINDOW_UTIL_KEY);
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.star_circle_fill'))
            .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
            .fontColor([Color.Orange])
            .margin({ right: CommonConstants.MARGIN_LEFT_BUTTON })
          Text($r('app.string.title'))
            .fontSize(CommonConstants.FONT_SIZE_APP_NAME)
            .lineHeight(CommonConstants.LINE_HEIGHT_APP_NAME)
        }
        .height(CommonConstants.TITLE_BAR_HEIGHT)
        .width('100%')
        .padding({
          left: CommonConstants.PADDING_MD,
          right: CommonConstants.PADDING_MD
        })

        SideAlbum()
      }
      .height('100%')
      .width('100%')
    }
    .mode(this.albumListViewModel.showSidebar && this.albumListViewModel.showSidebarIcon ? NavigationMode.Split :
      NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .navBarWidth(240)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}