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
import { WindowInfo, WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumCategoryViewModel } from '../viewmodel/AlbumCategoryViewModel';
import { AlbumListViewModel } from '../viewmodel/AlbumListViewModel';
import { AlbumListView } from './AlbumListView';

@ComponentV2
export struct SideAlbum {
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Local mainWindowInfo: WindowInfo = this.windowUtil.mainWindowInfo;
  curIndex: number = 0;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();

  build() {
    Scroll() {
      Column() {
        ForEach(this.albumListViewModel.albumList, (item: AlbumCategoryViewModel, index: number) => {
          AlbumListView({
            albumCategory: item,
            albumCategoryId: index
          })
        }, (item: AlbumCategoryViewModel, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: CommonConstants.PADDING_SM,
        right: CommonConstants.PADDING_SM
      })
      .margin({
        bottom: this.getUIContext().px2vp(this.mainWindowInfo.avoidNavigationIndicator?.topRect.height)
      })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .width('100%')
    .scrollBar(BarState.Off)
  }
}