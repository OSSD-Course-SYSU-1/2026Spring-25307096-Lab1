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
export class EditingTabListViewModel {
  @Trace public windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Trace public mainWindowInfo: WindowInfo = this.windowUtil.mainWindowInfo;
  // Tab bar size: height for horizontal, width for vertical layout
  @Trace public barSize: number;
  @Trace public tabList: TabViewModel[] = [];
  @Trace public tabIndex: number = 0;
  // Tab bar orientation: true for vertical (side), false for horizontal (bottom)
  @Trace public vertical: boolean;
  // Tab bar position: End means bottom for horizontal, right for vertical
  @Trace public position: BarPosition;
  public static instance: EditingTabListViewModel;
  public tabListModel: TabListModel = TabListModel.getInstance();

  public static getInstance(): EditingTabListViewModel {
    if (!EditingTabListViewModel.instance) {
      EditingTabListViewModel.instance = new EditingTabListViewModel();
    }
    return EditingTabListViewModel.instance;
  }

  constructor() {
    const tabModels = TabListModel.getInstance().editingTabList;
    this.tabList = tabModels.map(model => new TabViewModel(model));

    // Position at bottom (horizontal) or right side (vertical)
    this.position = BarPosition.End;

    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    // Convert pixel width to virtual pixels (vp) for breakpoint comparison
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? 0;
    // Aspect ratio: height/width, determines screen orientation
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    // Wide screen with low aspect ratio: vertical tab bar on right side
    // Large width (>=840vp) + low aspect ratio (<=1.2) indicates tablet/PC landscape
    if (curWidthVp >= CommonConstants.SCREEN_WIDTH_LARGE && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.vertical = true;
      // Extra padding for vertical tab bar to align with content
      this.barSize = CommonConstants.TAB_BAR_HEIGHT_BASE + CommonConstants.TAB_BAR_EXTRA_PADDING;
    } else {
      // Normal screen: horizontal tab bar at bottom
      this.vertical = false;
      // Include navigation indicator height for proper positioning
      let navHeight = this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0;
      this.barSize = CommonConstants.TAB_BAR_HEIGHT_BASE + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    }
  }
}