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
  @Trace public barSize: number;
  @Trace public tabList: TabViewModel[] = [];
  @Trace public tabIndex: number = 0;
  @Trace public vertical: boolean;
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

    this.position = BarPosition.End;

    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? 0;
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    if (curWidthVp >= CommonConstants.SCREEN_WIDTH_LARGE && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.vertical = true;
      this.barSize = CommonConstants.TAB_BAR_HEIGHT_BASE + CommonConstants.TAB_BAR_EXTRA_PADDING;
    } else {
      this.vertical = false;
      let navHeight = this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0;
      this.barSize = CommonConstants.TAB_BAR_HEIGHT_BASE + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    }
  }
}