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
import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakPointType, WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumViewModel } from '../viewmodel/AlbumViewModel';
import { PictureViewModel } from '../viewmodel/PictureViewModel';
import { AlbumListViewModel } from '../viewmodel/AlbumListViewModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';
import { PictureListDataSource } from '../datasource/PictureListDataSource';

@ComponentV2
export struct PictureListView {
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  @Param @Require album: AlbumViewModel;
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  windowUtil: WindowUtil = AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  // LazyForEach data source for on-demand Grid rendering
  @Local dataSource: PictureListDataSource = new PictureListDataSource([]);
  onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.albumListViewModel.gridColumns =
      ('1fr ').repeat(new BreakPointType(BrowsingConstants.GRID_COLUMNS_SM, BrowsingConstants.GRID_COLUMNS_MD,
        BrowsingConstants.GRID_COLUMNS_LG,
        BrowsingConstants.GRID_COLUMNS_XL).getValue(this.windowUtil.mainWindowInfo.widthBp));
  };

  // Monitor album.pictureList changes: update dataSource when switching albums
  @Monitor('album.pictureList')
  onAlbumPictureListChange(): void {
    this.dataSource.updatePictureList(this.album.pictureList);
  }

  aboutToAppear(): void {
    this.windowUtil.addWindowSizeMonitor(this.onWindowSizeChange);
    // Initialize data source with album picture list
    this.dataSource.updatePictureList(this.album.pictureList);
  }

  build() {
    Grid() {
      // LazyForEach for on-demand loading, improves performance for large lists
      LazyForEach(this.dataSource,
        (picture: PictureViewModel) => {
          GridItem() {
            Image(picture.thumbnailUrl)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                this.pathStack.pushPathByName('PictureEditing', null);
              })
          }
          .aspectRatio(1)
        },
        // Use unique id as key, never use index in key for dynamic content
        (picture: PictureViewModel) => picture.id.toString()
      )
    }
    .width('100%')
    .rowsGap(BrowsingConstants.GRID_GAP)
    .columnsGap(BrowsingConstants.GRID_GAP)
    .columnsTemplate(this.albumListViewModel.gridColumns)
    // Pre-load 5 items ahead for smooth scrolling
    .cachedCount(5)
    .margin({
      bottom: deviceInfo.sdkApiVersion >= 23 || this.breakpoint.widthBreakpoint > WidthBreakpoint.WIDTH_SM ?
        this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height) +
          CommonConstants.MARGIN_HDS_TABS : 0
    })
  }
}