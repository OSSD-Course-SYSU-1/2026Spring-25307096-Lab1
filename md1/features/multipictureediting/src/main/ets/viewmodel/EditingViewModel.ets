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

import { AppStorageV2, UIContext, window } from '@kit.ArkUI';
import { WindowInfo, WindowUtil, CommonConstants } from 'multipicturecommon';
import { EditingModel } from '../model/EditingModel';
import { FilterViewModel } from './FilterViewModel';
import { EditingConstants } from '../constants/EditingConstants';

@ObservedV2
export class EditingViewModel {
  @Trace public windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Trace public mainWindowInfo: WindowInfo = this.windowUtil.mainWindowInfo;
  @Trace public title: string | Resource;
  @Trace public filterList: FilterViewModel[] = [];
  @Trace public selectedIndex: number = 0;
  // Layout direction: true for vertical (mobile), false for horizontal (PC)
  @Trace public verticalFlex: boolean = true;
  @Trace public sliderValue: number = EditingConstants.DEFAULT_SLIDER_VALUE;
  public static instance: EditingViewModel;

  public static getInstance(): EditingViewModel {
    if (!EditingViewModel.instance) {
      EditingViewModel.instance = new EditingViewModel();
    }
    return EditingViewModel.instance;
  }

  constructor() {
    const model = EditingModel.getInstance();
    this.title = model.title;
    this.filterList = model.filterList.map(filterModel => new FilterViewModel(filterModel));

    let windowSize: window.Size = this.mainWindowInfo.windowSize;
    let curWidthVp: number = this.windowUtil.uiContext?.px2vp(windowSize.width) ?? EditingConstants.DEFAULT_WIDTH_VP;
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    this.updateLayoutDirection(curWidthVp, ratio);
  }

  // Update layout direction based on screen width and aspect ratio
  // Business logic moved from View to ViewModel
  updateLayoutDirection(curWidthVp: number, ratio: number): void {
    // Wide screen with low aspect ratio: horizontal layout (picture left, controls right)
    if (curWidthVp >= CommonConstants.SCREEN_WIDTH_LARGE && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.verticalFlex = false;
    } else {
      // Narrow screen: vertical layout (picture top, controls bottom)
      this.verticalFlex = true;
    }
  }

  // Handle window size change: update layout direction
  // Called by View when window size changes
  handleWindowSizeChange(windowSize: window.Size, uiContext: UIContext): void {
    let curWidthVp = uiContext.px2vp(windowSize.width);
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;
    this.updateLayoutDirection(curWidthVp, ratio);
  }

  // Check if current screen is small (XS width + SM height)
  isSmallScreen(widthBp: WidthBreakpoint, heightBp: HeightBreakpoint): boolean {
    return widthBp <= WidthBreakpoint.WIDTH_SM && heightBp <= HeightBreakpoint.HEIGHT_MD;
  }
}