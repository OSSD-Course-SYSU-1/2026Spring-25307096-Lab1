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
import { BreakPointType, WindowUtil, CommonConstants } from 'multipicturecommon';
import { EditingViewModel } from '../viewmodel/EditingViewModel';
import { FilterViewModel } from '../viewmodel/FilterViewModel';
import { EditingConstants } from '../constants/EditingConstants';

@ComponentV2
export struct PictureEditingView {
  @Env(SystemProperties.BREAK_POINT) breakpoint: uiObserver.WindowSizeLayoutBreakpointInfo;
  @Local windowUtil: WindowUtil =
    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
  @Local editingViewModel: EditingViewModel = EditingViewModel.getInstance();
  @Consumer() pathStack: NavPathStack = new NavPathStack();
  listScroll: Scroller = new Scroller();
  // Window size change callback: delegates to ViewModel for business logic
  onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    // Call ViewModel method instead of handling logic in View
    this.editingViewModel.handleWindowSizeChange(windowSize, this.getUIContext());

    // Show alert for small screen (delegates check to ViewModel)
    if (this.editingViewModel.isSmallScreen(this.breakpoint.widthBreakpoint, this.breakpoint.heightBreakpoint)) {
      this.showAlert();
    }
  };

  aboutToAppear(): void {
    this.windowUtil.addWindowSizeMonitor(this.onWindowSizeChange);
    // Check screen size on initial appearance (delegates check to ViewModel)
    if (this.editingViewModel.isSmallScreen(this.breakpoint.widthBreakpoint, this.breakpoint.heightBreakpoint)) {
      this.showAlert();
    }
  }

  // Show warning dialog for small screen devices
  showAlert(): void {
    this.getUIContext().showAlertDialog({
      message: $r('app.string.small_screen_alert_message'),
      alignment: DialogAlignment.Center,
      width: '90%',
      confirm: {
        value: $r('app.string.small_screen_alert_confirm'),
        action: () => {}
      }
    })
  }

  build() {
    // Flex direction changes based on screen: Column for mobile, Row for wide screens
    Flex({
      direction: this.editingViewModel.verticalFlex ? FlexDirection.Column : FlexDirection.Row,
      alignItems: ItemAlign.Center
    }) {
      // Picture preview area with compare button overlay
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Image($r('app.media.original_picture'))
            .aspectRatio(EditingConstants.ASPECT_RATIO_PICTURE)
            .objectFit(ImageFit.Contain)
            .colorFilter(this.editingViewModel.filterList[this.editingViewModel.selectedIndex].colorFilter)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding({
          left: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
            CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint),
          right: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
            CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint)
        })

        // Compare button: position changes based on layout direction
        Row() {
          Text($r('app.string.compare_button'))
            .fontSize(EditingConstants.FONT_SIZE_COMPARE_BUTTON)
            .lineHeight(EditingConstants.LINE_HEIGHT_COMPARE_BUTTON)
            .fontColor($r('app.color.compare_button_text'))
        }
        .height(EditingConstants.HEIGHT_COMPARE_BUTTON)
        .backgroundColor($r('app.color.compare_button_background'))
        .borderRadius(EditingConstants.BORDER_RADIUS_COMPARE_BUTTON)
        .padding({
          left: CommonConstants.PADDING_SM,
          right: CommonConstants.PADDING_SM
        })
        .margin({
          top: EditingConstants.MARGIN_TOP_COMPARE_BUTTON,
          left: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
            CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint),
          right: new BreakPointType(CommonConstants.PADDING_SM, CommonConstants.PADDING_MD, CommonConstants.PADDING_LG,
            CommonConstants.PADDING_XL).getValue(this.breakpoint.widthBreakpoint)
        })
        // TOP_END for vertical layout (mobile), TOP_START for horizontal layout (PC)
        .layoutGravity(this.editingViewModel.verticalFlex ? LocalizedAlignment.TOP_END : LocalizedAlignment.TOP_START)
      }
      .layoutWeight(1)
      .width(this.editingViewModel.verticalFlex ? '100%' : 'auto')
      .height(this.editingViewModel.verticalFlex ? 'auto' : '100%')
      .padding({
        // Add bottom padding for navigation bar only in horizontal layout
        bottom: this.editingViewModel.verticalFlex ? 0 :
          this.getUIContext().px2vp(this.windowUtil.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height)
      })

      // Vertical layout controls: slider + horizontal filter list
      Column() {
        Row() {
          this.sliderView(false)
        }
        .width('100%')
        .height(EditingConstants.SLIDER_ROW_HEIGHT)
        .padding({
          left: new BreakPointType(EditingConstants.PADDING_SLIDER_SM, EditingConstants.PADDING_SLIDER_MD, 0,
            0).getValue(this.breakpoint.widthBreakpoint),
          right: new BreakPointType(EditingConstants.PADDING_SLIDER_SM, EditingConstants.PADDING_SLIDER_MD, 0,
            0).getValue(this.breakpoint.widthBreakpoint)
        })

        // Horizontal scrolling filter list
        List({
          scroller: this.listScroll,
          space: EditingConstants.LIST_SPACE
        }) {
          ForEach(this.editingViewModel.filterList, (item: FilterViewModel, index: number) => {
            ListItem() {
              this.colorFilterImage(item, index);
            }
            .width(EditingConstants.FILTER_ITEM_SIZE)
            .height(EditingConstants.FILTER_ITEM_SIZE)
          }, (item: FilterViewModel, index: number) => `filter_${index}`)
        }
        .height(EditingConstants.FILTER_LIST_HEIGHT_HORIZONTAL)
        .width('100%')
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .alignListItem(ListItemAlign.Center)
        .padding({ left: CommonConstants.PADDING_SM })
        // Fading edge for scroll hint
        .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(EditingConstants.FADING_EDGE_LENGTH) })
      }
      // Show only in vertical layout
      .visibility(this.editingViewModel.verticalFlex ? Visibility.Visible : Visibility.None)

      // Horizontal layout controls: vertical slider + vertical filter list
      Row() {
        Column() {
          this.sliderView(true)
        }
        .width(EditingConstants.SLIDER_ROW_HEIGHT)
        .height('100%')
        .padding({
          top: EditingConstants.PADDING_VERTICAL_TOP_BOTTOM,
          bottom: EditingConstants.PADDING_VERTICAL_TOP_BOTTOM
        })

        // Vertical scrolling filter list
        List({
          scroller: this.listScroll,
          space: EditingConstants.LIST_SPACE
        }) {
          ForEach(this.editingViewModel.filterList, (item: FilterViewModel, index: number) => {
            ListItem() {
              this.colorFilterImage(item, index);
            }
            .width(EditingConstants.FILTER_ITEM_SIZE)
            .height(EditingConstants.FILTER_ITEM_SIZE)
          }, (item: FilterViewModel, index: number) => `filter_${index}`)
        }
        .width(EditingConstants.FILTER_LIST_WIDTH_VERTICAL)
        .height('100%')
        .scrollBar(BarState.Off)
        .listDirection(Axis.Vertical)
        .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(EditingConstants.FADING_EDGE_LENGTH) })
      }
      // Show only in horizontal layout
      .visibility(this.editingViewModel.verticalFlex ? Visibility.None : Visibility.Visible)
      .height('50%')
      .width(EditingConstants.HORIZONTAL_LAYOUT_WIDTH)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  sliderView(vertical: boolean) {
    // Slider direction: horizontal for mobile, vertical for PC
    Slider({
      direction: vertical ? Axis.Vertical : Axis.Horizontal,
      reverse: vertical ? true : false,
      value: this.editingViewModel.sliderValue
    })
      .width('100%')
      .selectedColor($r('app.color.slider_selected_color'))
      .blockColor($r('app.color.slider_selected_color'))
      .trackColor($r('app.color.slider_track_color'))
      .onChange((value: number) => {
        this.editingViewModel.sliderValue = value;
      })
  }

  @Builder
  colorFilterImage(item: FilterViewModel, index: number) {
    // Filter thumbnail with name label at bottom
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.original_picture'))
        .colorFilter(item.colorFilter)
        .height('100%')
        .width('100%')
      Text(item.name)
        .fontSize(EditingConstants.FONT_SIZE_FILTER_NAME)
        .lineHeight(EditingConstants.LINE_HEIGHT_FILTER_NAME)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor($r('app.color.filter_name_color'))
        .margin({
          bottom: EditingConstants.MARGIN_FILTER_NAME,
          left: EditingConstants.MARGIN_FILTER_NAME
        })
    }
    .width('100%')
    .height('100%')
    .borderRadius(EditingConstants.BORDER_RADIUS_FILTER_ITEM)
    // Highlight border for selected filter
    .borderWidth(this.editingViewModel.selectedIndex == index ? EditingConstants.BORDER_WIDTH_SELECTED : 0)
    .borderColor($r('app.color.filter_border_color'))
    .clip(true)
    .onClick(() => {
      this.editingViewModel.selectedIndex = index;
      // Scroll to selected filter item smoothly
      this.listScroll.scrollToIndex(index, true, ScrollAlign.AUTO);
    })
  }
}