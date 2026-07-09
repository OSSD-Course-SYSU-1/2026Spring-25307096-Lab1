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

import { AppStorageV2, window } from '@kit.ArkUI';
import { BreakPointType, WindowInfo, WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumListModel } from '../model/AlbumListModel';
import { AlbumViewModel } from './AlbumViewModel';
import { AlbumCategoryViewModel } from './AlbumCategoryViewModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

@ObservedV2
export class AlbumListViewModel {
  @Trace public windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Trace public mainWindowInfo: WindowInfo = this.windowUtil.mainWindowInfo;
  @Trace public showSidebar: boolean = true;
  @Trace public showSidebarIcon: boolean = false;
  @Trace public albumList: AlbumCategoryViewModel[] = [];
  @Trace public curAlbumId = 0;
  @Trace public gridColumns: string;
  public static instance: AlbumListViewModel;
  public albumListModel: AlbumListModel = AlbumListModel.getInstance();

  public static getInstance(): AlbumListViewModel {
    if (!AlbumListViewModel.instance) {
      AlbumListViewModel.instance = new AlbumListViewModel();
    }
    return AlbumListViewModel.instance;
  }

  constructor() {
    let categoryModels = AlbumListModel.getInstance().albumCategoryList;
    this.albumList = categoryModels.map(model => new AlbumCategoryViewModel(model));

    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? BrowsingConstants.DEFAULT_WIDTH_VP;
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    this.updateSidebarVisibility(curWidthVp, ratio);

    this.gridColumns =
      ('1fr ').repeat(new BreakPointType(BrowsingConstants.GRID_COLUMNS_SM, BrowsingConstants.GRID_COLUMNS_MD,
        BrowsingConstants.GRID_COLUMNS_LG, BrowsingConstants.GRID_COLUMNS_XL).getValue(this.mainWindowInfo.widthBp));
  }

  // Update sidebar visibility based on screen width and aspect ratio
  // Business logic moved from View to ViewModel
  updateSidebarVisibility(curWidthVp: number, ratio: number): void {
    if (curWidthVp >= CommonConstants.BREAKPOINT_WIDTH_MEDIUM && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.showSidebarIcon = true;
    } else {
      this.showSidebarIcon = false;
    }
  }

  initSidebar(): void {
    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? BrowsingConstants.DEFAULT_WIDTH_VP;
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    this.updateSidebarVisibility(curWidthVp, ratio);
  }

  // Handle pinch gesture: zoom in/out grid columns
  // Business logic moved from View to ViewModel
  handlePinchGesture(scale: number, widthBp: WidthBreakpoint): string {
    if (scale > 1) {
      // Zoom in: more columns for larger thumbnails
      return ('1fr ').repeat(new BreakPointType(BrowsingConstants.GRID_COLUMNS_SM, BrowsingConstants.GRID_COLUMNS_MD,
        BrowsingConstants.GRID_COLUMNS_LG, BrowsingConstants.GRID_COLUMNS_XL).getValue(widthBp));
    } else if (scale < 1) {
      // Zoom out: fewer columns for smaller thumbnails
      return ('1fr ').repeat(new BreakPointType(BrowsingConstants.GRID_COLUMNS_PINCH_SM,
        BrowsingConstants.GRID_COLUMNS_PINCH_MD, BrowsingConstants.GRID_COLUMNS_PINCH_LG,
        BrowsingConstants.GRID_COLUMNS_PINCH_XL).getValue(widthBp));
    }
    return this.gridColumns;
  }

  // Update grid columns if different from current value
  updateGridColumns(newColumns: string): boolean {
    if (this.gridColumns !== newColumns) {
      this.gridColumns = newColumns;
      return true;
    }
    return false;
  }

  getCurAlbum(): AlbumViewModel {
    let resAlbum: AlbumViewModel;
    for (let i = 0; i < this.albumList.length; ++i) {
      let albumList = this.albumList[i].albums;
      for (let j = 0; j < albumList.length; ++j) {
        if (this.curAlbumId === albumList[j].id) {
          resAlbum = albumList[j];
          return resAlbum;
        }
      }
    }
    return this.albumList[0].albums[0];
  }
}