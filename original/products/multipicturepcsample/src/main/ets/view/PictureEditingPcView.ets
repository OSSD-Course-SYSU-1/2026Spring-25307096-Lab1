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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BreakPointType, WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumListViewModel } from 'multipicturebrowsing';
import { EditingViewModel, PictureEditingView, TitleView } from 'multipictureediting';
import { TabViewModel } from '../viewmodel/TabViewModel';
import { EditingTabListViewModel } from '../viewmodel/EditingTabListViewModel';
import { PcConstants } from '../constants/PcConstants';

@ComponentV2
export struct PictureEditingPcView {
  @Local editingViewModel: EditingViewModel = EditingViewModel.getInstance();
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  @Local tabListViewModel: EditingTabListViewModel = EditingTabListViewModel.getInstance();
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Provider() pathStack: NavPathStack = new NavPathStack();
  controller: TabsController = new TabsController();
  public onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let curWidthVp = this.getUIContext().px2vp(windowSize.width);
    let ratio: number =
      windowSize.width > 0 ? windowSize.height / windowSize.width : CommonConstants.SCREEN_RATIO_DEFAULT;

    if (curWidthVp >= CommonConstants.SCREEN_WIDTH_LARGE && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.tabListViewModel.vertical = true;
      this.tabListViewModel.barSize = CommonConstants.TAB_BAR_HEIGHT_BASE + CommonConstants.TAB_BAR_EXTRA_PADDING;
    } else {
      this.tabListViewModel.vertical = false;
      let navHeight =
        this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? PcConstants.DEFAULT_NAV_HEIGHT;
      this.tabListViewModel.barSize =
        CommonConstants.TAB_BAR_HEIGHT_BASE + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    }
  };

  aboutToAppear(): void {
    this.windowUtil.addWindowSizeMonitor(this.onWindowSizeChange);
  }

  build() {
    NavDestination() {
      Column() {
        TitleView()
          .padding({
            left: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
              CommonConstants.PADDING_XL).getValue(this.windowUtil.mainWindowInfo.widthBp),
            right: this.windowUtil.mainWindowInfo.titleButtonRect?.width ?? PcConstants.DEFAULT_TITLE_BUTTON_WIDTH
          })

        Tabs({ controller: this.controller }) {
          ForEach(this.tabListViewModel.tabList, (tab: TabViewModel, index: number) => {
            TabContent() {
              PictureEditingView()
            }
            .tabBar(this.buildTabBar(tab, index))
          }, (tab: TabViewModel, index: number) => JSON.stringify(tab) + index)
        }
        .layoutWeight(1)
        .width('100%')
        .vertical(this.tabListViewModel.vertical)
        .barPosition(this.tabListViewModel.position)
        .barHeight(this.tabListViewModel.vertical ? '50%' : this.tabListViewModel.barSize)
        .barWidth(this.tabListViewModel.vertical ? this.tabListViewModel.barSize : '100%')
        .scrollable(false)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.editing_page_background'))
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onShown(() => {
      this.albumListViewModel.showSidebarIcon = false;
      let style: window.DecorButtonStyle = {
        colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      }
      this.windowUtil.setDecorButtonStyle(style);
      this.windowUtil.setSystemBarLightMode(true);
    })
    .onHidden(() => {
      this.albumListViewModel.initSidebar();
      let style: window.DecorButtonStyle = {
        colorMode: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      }
      this.windowUtil.setDecorButtonStyle(style);
      this.windowUtil.setSystemBarLightMode(false);
    })
  }

  @Builder
  buildTabBar(tab: TabViewModel, index: number) {
    Column() {
      SymbolGlyph(tab.icon)
        .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
        .fontColor(this.tabListViewModel.tabIndex === index ? [$r('sys.color.icon_emphasize')] :
          [$r('app.color.tab_unselected_color')])
      Text(tab.name)
        .fontSize(CommonConstants.FONT_SIZE_TAB_TEXT)
        .lineHeight(CommonConstants.LINE_HEIGHT_TAB_TEXT)
        .fontColor(this.tabListViewModel.tabIndex === index ? $r('sys.color.icon_emphasize') :
          $r('app.color.tab_unselected_color'))
        .margin({ top: CommonConstants.MARGIN_TOP_TAB_TEXT })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .borderRadius(CommonConstants.BORDER_RADIUS_TAB_ITEM)
    .onClick(() => {
      this.tabListViewModel.tabIndex = index;
      this.controller.changeIndex(index);
    })
    .padding({
      right: this.tabListViewModel.vertical ? CommonConstants.TAB_BAR_EXTRA_PADDING : 0,
      bottom: this.tabListViewModel.vertical ? 0 :
        this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0)
    })
  }
}