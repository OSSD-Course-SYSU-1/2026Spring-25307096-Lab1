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
import { WindowInfo, WindowUtil, CommonConstants } from 'multipicturecommon';
import { TabListModel } from '../model/TabListModel';
import { TabViewModel } from './TabViewModel';

@ObservedV2
export class BrowsingTabListViewModel {
  @Trace public windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Trace public mainWindowInfo: WindowInfo = this.windowUtil.mainWindowInfo;
  // Tab bar height: dynamically calculated based on screen and navigation indicator
  @Trace public barHeight: number;
  @Trace public tabList: TabViewModel[] = [];
  // Selected index during animation (for visual highlight)
  @Trace public tabSelIndex: number = 0;
  // Current active tab index after animation completes
  @Trace public tabCurIndex: number = 0;
  // Flag for small screen mode (XS width + specific aspect ratio)
  @Trace public isSmallScreen: boolean;
  // Bottom margin for HdsTabs component
  @Trace public hdsTabsBottomMargin: number;
  public static instance: BrowsingTabListViewModel;
  public tabListModel: TabListModel = TabListModel.getInstance();

  public static getInstance(): BrowsingTabListViewModel {
    if (!BrowsingTabListViewModel.instance) {
      BrowsingTabListViewModel.instance = new BrowsingTabListViewModel();
    }
    return BrowsingTabListViewModel.instance;
  }

  constructor() {
    const tabModels = TabListModel.getInstance().browsingTabList;
    this.tabList = tabModels.map(model => new TabViewModel(model));

    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    // Convert pixel width to virtual pixels (vp) for breakpoint comparison
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? 0;
    // Aspect ratio: height/width, determines screen orientation
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    // Wide screen with low aspect ratio: hide bottom tab bar (use side bar instead)
    // barHeight = 0 means HdsTabs will use its own floating style
    if (curWidthVp >= CommonConstants.BREAKPOINT_WIDTH_MEDIUM && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.barHeight = 0;
    } else {
      // Normal screen: calculate bar height including navigation indicator
      let navHeight = this.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0;
      this.barHeight = CommonConstants.TAB_BAR_HEIGHT_BASE + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    }

    // Detect small screen: SM breakpoint with specific aspect ratio range
    // Used for special layout adjustments (e.g., extra bottom margin)
    if (curWidthVp >= CommonConstants.BREAKPOINT_WIDTH_SMALL && curWidthVp < CommonConstants.BREAKPOINT_WIDTH_MEDIUM &&
      ratio >= CommonConstants.SCREEN_RATIO_THRESHOLD_LOW && ratio < CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.isSmallScreen = true;
    } else {
      this.isSmallScreen = false;
    }

    // Calculate HdsTabs bottom margin based on screen type
    // Small screen or free window: add extra padding for better touch area
    if (this.isSmallScreen || this.windowUtil.mainWindowInfo.isFreeWindow) {
      let navHeight = this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0;
      this.hdsTabsBottomMargin = CommonConstants.PADDING_SM + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    } else {
      // Normal screen: only navigation indicator height
      let navHeight = this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0;
      this.hdsTabsBottomMargin = this.windowUtil.uiContext?.px2vp(navHeight) ?? 0;
    }
  }
}