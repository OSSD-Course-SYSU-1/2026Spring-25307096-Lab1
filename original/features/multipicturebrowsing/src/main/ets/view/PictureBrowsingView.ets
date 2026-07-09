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
import { PictureListView } from './PictureListView';
import { AlbumListViewModel } from '../viewmodel/AlbumListViewModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

@ComponentV2
export struct PictureBrowsingView {
  // Environment breakpoint for responsive layout
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  windowUtil: WindowUtil = AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;

  build() {
    Scroll() {
      PictureListView({ album: this.albumListViewModel.getCurAlbum() })
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor($r('app.color.browsing_page_background'))
    // Pinch gesture: delegates business logic to ViewModel
    .gesture(
      PinchGesture({ fingers: BrowsingConstants.GESTURE_FINGERS })
        .onActionUpdate((event: GestureEvent) => {
          // Call ViewModel method to get new grid columns
          let newColumns = this.albumListViewModel.handlePinchGesture(event.scale, this.breakpoint.widthBreakpoint);

          // Only animate if columns changed
          if (this.albumListViewModel.gridColumns !== newColumns) {
            this.getUIContext().animateTo({
              duration: BrowsingConstants.ANIMATION_DURATION
            }, () => {
              this.albumListViewModel.updateGridColumns(newColumns);
            })
          }
        }))
  }
}