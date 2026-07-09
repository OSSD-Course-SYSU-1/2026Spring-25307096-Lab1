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

import { AppStorageV2, LengthMetrics, uiObserver, window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { hdsMaterial, HdsNavDestination, HdsTabs, HdsTabsController, ScrollEffectType } from '@kit.UIDesignKit';
import { BreakPointType, WindowUtil, CommonConstants } from 'multipicturecommon';
import { AlbumListViewModel, PictureBrowsingView, TimeFilterView } from 'multipicturebrowsing';
import { BrowsingTabListViewModel } from '../viewmodel/BrowsingTabListViewModel';
import { TabViewModel } from '../viewmodel/TabViewModel';
import { DefaultConstants } from '../constants/DefaultConstants';

@ComponentV2
export struct PictureBrowsingMobileView {
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local tabListViewModel: BrowsingTabListViewModel = BrowsingTabListViewModel.getInstance();
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Provider('pathStack') pathStack: NavPathStack = new NavPathStack();
  hdsTabsController: HdsTabsController = new HdsTabsController();
  tabsController: TabsController = new TabsController();
  onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    if (this.breakpoint.widthBreakpoint <= WidthBreakpoint.WIDTH_SM &&
      this.breakpoint.heightBreakpoint === HeightBreakpoint.HEIGHT_MD) {
      this.tabListViewModel.isSmallScreen = true;
    } else {
      this.tabListViewModel.isSmallScreen = false;
    }
  };
  onWindowAvoidChange: (avoidOptions: window.AvoidAreaOptions) => void = (avoidOptions: window.AvoidAreaOptions) => {
    let curWidthVp = this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.windowSize.width);
    let ratio: number =
      this.windowUtil.mainWindowInfo.windowSize.height / this.windowUtil.mainWindowInfo.windowSize.width;
    if (curWidthVp >= CommonConstants.BREAKPOINT_WIDTH_MEDIUM && ratio <= CommonConstants.SCREEN_RATIO_THRESHOLD) {
      this.tabListViewModel.barHeight = 0;
    } else {
      let navHeight = this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ??
        DefaultConstants.DEFAULT_NAV_HEIGHT;
      this.tabListViewModel.barHeight =
        CommonConstants.TAB_BAR_HEIGHT_BASE + (this.windowUtil.uiContext?.px2vp(navHeight) ?? 0);
    }
  };

  aboutToAppear(): void {
    this.windowUtil.addWindowAvoidMonitor(this.onWindowAvoidChange);
  }

  build() {
    if (deviceInfo.sdkApiVersion >= 23) {
      HdsNavDestination() {
        HdsTabs({ controller: this.hdsTabsController }) {
          ForEach(this.tabListViewModel.tabList, (tab: TabViewModel, index: number) => {
            TabContent() {
              PictureBrowsingView()
            }
            .tabBar(this.buildHdsTabBar(tab, index))
          }, (tab: TabViewModel, index: number) => JSON.stringify(tab) + index)
        }
        .width('100%')
        .height('100%')
        .vertical(false)
        .barPosition(BarPosition.End)
        .barHeight(CommonConstants.TITLE_BAR_HEIGHT)
        .barWidth(DefaultConstants.BAR_WIDTH_HDS)
        .barOverlap(true)
        .scrollable(false)
        .barFloatingStyle({
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
          },
          barSideMargin: DefaultConstants.BAR_SIDE_MARGIN_HDS,
          barBottomMargin: this.tabListViewModel.hdsTabsBottomMargin,
          lightColor: $r('sys.color.icon_emphasize')
        })
        .onChange((index: number) => {
          this.tabListViewModel.tabCurIndex = index;
          this.tabListViewModel.tabSelIndex = index;
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return;
          }
          this.tabListViewModel.tabSelIndex = targetIndex;
        })
      }
      .width('100%')
      .height('100%')
      .hideBackButton(true)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onBackPressed(() => {
        this.getUIContext().getRouter().back();
        return true;
      })
      .titleBar({
        padding: {
          start: new LengthMetrics(!this.albumListViewModel.showSidebar && this.albumListViewModel.showSidebarIcon ?
            new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
              CommonConstants.PADDING_XL).getValue(this.windowUtil.mainWindowInfo.widthBp) +
              CommonConstants.SIDEBAR_ICON_EXTRA_WIDTH :
            new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
              CommonConstants.PADDING_XL).getValue(this.windowUtil.mainWindowInfo.widthBp)),
          end: new LengthMetrics(new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD,
            CommonConstants.PADDING_LG, CommonConstants.PADDING_XL).getValue(this.windowUtil.mainWindowInfo.widthBp))
        },
        content: {
          title: {
            mainTitle: $r('app.string.title_today')
          },
          menu: {
            value: [
              {
                content: {
                  icon: $r('sys.symbol.checkmark_square'),
                  label: 'checkmark'
                }
              },
              {
                content: {
                  icon: $r('sys.symbol.magnifyingglass'),
                  label: 'search'
                }
              },
              {
                content: {
                  icon: $r('sys.symbol.dot_grid_2x2'),
                  label: 'more',
                }
              }
            ]
          }
        },
        style: {
          originalStyle: {
            backgroundStyle: {
              backgroundColor: $r('app.color.title_bar_background')
            },
            contentStyle: {
              titleStyle: {
                mainTitleColor: $r('sys.color.font_primary')
              },
              menuStyle: {
                iconColor: $r('sys.color.font_primary')
              }
            }
          },
          scrollEffectOpts: {
            scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
            enableScrollEffect: true
          },
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.IMMERSIVE,
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
          }
        },
        avoidLayoutSafeArea: true,
        enableComponentSafeArea: true
      })
      .onReady((context: NavDestinationContext) => {
        this.pathStack = context.pathStack;
      })
    } else {
      NavDestination() {
        Tabs({ controller: this.tabsController }) {
          ForEach(this.tabListViewModel.tabList, (tab: TabViewModel, index: number) => {
            TabContent() {
              Stack({ alignContent: Alignment.Bottom }) {
                PictureBrowsingView()
                TimeFilterView()
              }
              .width('100%')
              .height('100%')
            }
            .tabBar(this.buildTabBar(tab, index))
          }, (tab: TabViewModel, index: number) => JSON.stringify(tab) + index)
        }
        .width('100%')
        .height('100%')
        .vertical(false)
        .barPosition(BarPosition.End)
        .barWidth('100%')
        .barHeight(this.tabListViewModel.barHeight)
        .scrollable(false)
        .onChange((index: number) => {
          this.tabListViewModel.tabCurIndex = index;
          this.tabListViewModel.tabSelIndex = index;
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return;
          }
          this.tabListViewModel.tabSelIndex = targetIndex;
        })
      }
      .width('100%')
      .height('100%')
      .hideBackButton(true)
      .title({
        builder: this.titleBar(),
        height: CommonConstants.TITLE_BAR_HEIGHT +
          this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height ?? 0)
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onBackPressed(() => {
        this.getUIContext().getRouter().back();
        return true;
      })
      .onReady((context: NavDestinationContext) => {
        this.pathStack = context.pathStack;
      })
    }
  }

  @Builder
  buildTabBar(tab: TabViewModel, index: number) {
    Column() {
      SymbolGlyph(tab.icon)
        .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
        .fontColor(this.tabListViewModel.tabSelIndex === index ? [$r('sys.color.icon_emphasize')] :
          [$r('app.color.tab_bar_unselected_color')])
      Text(tab.name)
        .fontSize(CommonConstants.FONT_SIZE_TAB_TEXT)
        .lineHeight(CommonConstants.LINE_HEIGHT_TAB_TEXT)
        .fontColor(this.tabListViewModel.tabSelIndex === index ? $r('sys.color.icon_emphasize') :
          $r('app.color.tab_bar_unselected_color'))
        .margin({ top: CommonConstants.MARGIN_TOP_TAB_TEXT })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      bottom: this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height ?? 0)
    })
  }

  @Builder
  buildHdsTabBar(tab: TabViewModel, index: number) {
    Column() {
      SymbolGlyph(tab.icon)
        .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
        .fontColor(this.tabListViewModel.tabSelIndex === index ? [$r('sys.color.icon_emphasize')] :
          [$r('sys.color.font_primary')])
      Text(tab.name)
        .fontSize(CommonConstants.FONT_SIZE_TAB_TEXT)
        .lineHeight(CommonConstants.LINE_HEIGHT_TAB_TEXT)
        .fontColor(this.tabListViewModel.tabSelIndex === index ? $r('sys.color.icon_emphasize') :
          $r('sys.color.font_primary'))
        .margin({ top: CommonConstants.MARGIN_TOP_TAB_TEXT })
    }
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  titleBar() {
    Row() {
      Text($r('app.string.title_today'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .fontSize(CommonConstants.FONT_SIZE_MAIN_TITLE)
        .lineHeight(CommonConstants.LINE_HEIGHT_MAIN_TITLE)
      Blank()

      this.titleIcon($r('sys.symbol.checkmark_square'))
      this.titleIcon($r('sys.symbol.magnifyingglass'))
      this.titleIcon($r('sys.symbol.dot_grid_2x2'))
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidSystem?.topRect.height ?? 0),
      left: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
        CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint),
      right: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
        CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint)
    })
  }

  @Builder
  titleIcon(icon: Resource) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(CommonConstants.ICON_SIZE_DEFAULT)
        .fontColor([$r('sys.color.font_primary')])
    }
    .width(CommonConstants.BUTTON_SIZE)
    .height(CommonConstants.BUTTON_SIZE)
    .borderRadius(CommonConstants.BORDER_RADIUS_BUTTON)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ left: CommonConstants.MARGIN_LEFT_BUTTON })
  }
}