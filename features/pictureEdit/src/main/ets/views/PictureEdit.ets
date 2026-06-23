/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BaseConstants, BreakpointConstants } from 'base';
import PictureEditConstants from '../constants/PictureEditConstants';
import { AiPreset, ColorMatrix } from '../viewmodel/AdaptiveViewModel';
import { deviceInfo } from '@kit.BasicServicesKit';

interface ToolsAndName {
  pic: Resource
  pic_name: ResourceStr
}

interface PicAndName {
  pic: Resource
  pic_name: string
  color_filter: number[]
}

@Component
export struct PictureEdit {
  @StorageLink('currentBreakpoint') currentBp: string = BreakpointConstants.BREAKPOINT_MD;
  @State outSetValueOne: number = 40;
  @State windowDirection: boolean = true;
  @State pictureWidth: string = BaseConstants.FULL_WIDTH;
  @State selectedTool: number = -1;
  @State activeColorFilter: number[] = [...PictureEditConstants.IDENTITY];
  @Consume('pageInfos') pageInfos: NavPathStack;

  /* ---------- AI 修图专属状态 ---------- */
  @State activePresetIndex: number = -1;
  @State aiIntensity: number = 50;
  @State showOriginal: boolean = false;

  isColumnLayout(bp: string, direction: Boolean): Boolean {
    if (bp === BreakpointConstants.BREAKPOINT_SM) {
      this.pictureWidth = PictureEditConstants.PICTURE_WIDTH_SM;
      return true;
    }
    if (bp === BreakpointConstants.BREAKPOINT_LG) {
      this.pictureWidth = PictureEditConstants.PICTURE_WIDTH_LG;
      return false;
    }
    if (direction) {
      this.pictureWidth = PictureEditConstants.PICTURE_WIDTH_MD_ROW;
    } else {
      this.pictureWidth = PictureEditConstants.PICTURE_WIDTH_MD_COLUMN;
    }
    return !direction;
  }

  /* =================================================================
   *  Top Bar
   * ================================================================= */
  @Builder
  topBar() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(BaseConstants.DEFAULT_ICON_SIZE)
        .height(BaseConstants.DEFAULT_ICON_SIZE)
        .fillColor(Color.White)
        .onClick(() => {
          this.pageInfos.pop();
        })
        .margin({
          left: $r('app.float.back_image_left'),
          right: $r('app.float.back_image_right1')
        })

      Text(PictureEditConstants.Edit_Text)
        .fontSize(BaseConstants.FONT_SIZE_TWENTY)
        .fontColor(Color.White)
      Blank()
      if (this.currentBp === BreakpointConstants.BREAKPOINT_MD) {
        Image(this.windowDirection ? $r('app.media.change2') : $r('app.media.change'))
          .width(BaseConstants.DEFAULT_ICON_SIZE)
          .height(BaseConstants.DEFAULT_ICON_SIZE)
          .fillColor(Color.White)
          .margin({ right: $r('app.float.image_right') })
          .onClick(() => {
            this.windowDirection = !this.windowDirection;
          })
      }
      Image($r('app.media.ic_add_2'))
        .width(BaseConstants.DEFAULT_ICON_SIZE)
        .height(BaseConstants.DEFAULT_ICON_SIZE)
        .fillColor(Color.White)
        .margin({ right: $r('app.float.image_right') })
      Image($r('app.media.ic_add_3'))
        .width(BaseConstants.DEFAULT_ICON_SIZE)
        .height(BaseConstants.DEFAULT_ICON_SIZE)
        .fillColor(Color.White)
        .margin({ right: $r('app.float.image_right') })

      Image($r('app.media.ic_add_4'))
        .width(BaseConstants.DEFAULT_ICON_SIZE)
        .height(BaseConstants.DEFAULT_ICON_SIZE)
        .fillColor(Color.White)
        .margin({ right: $r('app.float.image_right') })

    }
    .alignItems(VerticalAlign.Center)
    .height($r('app.float.row_height1'))
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor(Color.Black)
  }

  /* =================================================================
   *  Center Picture — with long-press-to-peek-original gesture
   * ================================================================= */
  @Builder
  centerPicture() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r("app.media.photo"))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .colorFilter(this.showOriginal ? PictureEditConstants.IDENTITY : this.activeColorFilter)
        .height(PictureEditConstants.PICTURE_HEIGHT)
        .width(this.pictureWidth)
        .constraintSize({ maxWidth: deviceInfo.deviceType === BaseConstants.DEVICE_2IN1 ? 900 : undefined })
        .gesture(
          LongPressGesture({ repeat: false, duration: 200 })
            .onAction(() => {
              if (this.selectedTool === 4 && this.activePresetIndex >= 0) {
                this.showOriginal = true;
              }
            })
            .onActionEnd(() => {
              this.showOriginal = false;
            })
        )
    }
  }

  /* =================================================================
   *  Option Region
   * ================================================================= */
  @Builder
  optionRegion() {
    Flex({
      direction: this.isColumnLayout(this.currentBp, this.windowDirection) ? FlexDirection.Column : FlexDirection.Row
    }) {
      Flex() {
        this.sliderBar()
      }
      .flexBasis(PictureEditConstants.SLIDER_FLEX_BASIS)

      if (this.selectedTool === 4) {
        this.aiPanel()
      } else {
        this.filterWindows()
      }
      Flex({ justifyContent: FlexAlign.Center }) {
        this.bottomBar()
      }
      .flexBasis(PictureEditConstants.BAR_FLEX_BASIS)
    }
    .height(this.isColumnLayout(this.currentBp, this.windowDirection) ? BaseConstants.FULL_HEIGHT :
    PictureEditConstants.PICTURE_HALF_HEIGHT)
    .padding($r('app.float.row_padding'))
  }

  /* =================================================================
   *  Slider — AI mode drives intensity; else generic value
   * ================================================================= */
  @Builder
  sliderBar() {
    Column() {
      if (this.selectedTool === 4) {
        Row({ space: 8 }) {
          Text($r('app.string.ai_intensity'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99000000')
        }
        .width(BaseConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 4 })
      }
      Slider({
        value: this.selectedTool === 4 ? this.aiIntensity : this.outSetValueOne,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet,
        direction: this.isColumnLayout(this.currentBp, this.windowDirection) ? Axis.Horizontal : Axis.Vertical,
        reverse: this.isColumnLayout(this.currentBp, this.windowDirection) ? false : true
      })
        .blockColor(this.selectedTool === 4 ? '#4DA6FF' : Color.White)
        .selectedColor(this.selectedTool === 4 ? '#4DA6FF' : Color.White)
        .trackColor($r('app.color.track_color'))
        .showTips(this.selectedTool === 4)
        .onChange((value: number) => {
          if (this.selectedTool === 4) {
            this.aiIntensity = value;
            this.updateAiFilter();
          } else {
            this.outSetValueOne = value;
          }
        })
    }
  }

  /* =================================================================
   *  Filter Thumbnails (tools 0-3)
   * ================================================================= */
  @Builder
  filterWindows() {
    List() {
      ForEach(PictureEditConstants.filterAndName, (item: PicAndName) => {
        ListItem() {
          Stack() {
            Image(item.pic)
              .height($r('app.float.image_height'))
              .aspectRatio(1)
              .autoResize(true)
              .colorFilter(item.color_filter)
              .clip(true)
              .borderRadius(PictureEditConstants.IMAGE_BORDER_RADIUS)
            Text(item.pic_name)
              .fontSize(BaseConstants.FONT_SIZE_TEN)
              .fontColor($r('app.color.text_color'))
              .margin({ left: $r('app.float.text_margin'), bottom: $r('app.float.text_margin') })
          }
          .alignContent(Alignment.BottomStart)
        }
      },(item: PicAndName, index: number) => index + JSON.stringify(item))
    }
    .listDirection(this.isColumnLayout(this.currentBp, this.windowDirection) ? Axis.Horizontal : Axis.Vertical)
  }

  /* =================================================================
   *  Bottom Toolbar
   * ================================================================= */
  @Builder
  bottomBar() {
    Flex({
      justifyContent: this.isColumnLayout(this.currentBp, this.windowDirection) ? FlexAlign.SpaceAround :
      FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
      direction: this.isColumnLayout(this.currentBp, this.windowDirection) ? FlexDirection.Row : FlexDirection.Column,
    }) {

      ForEach(PictureEditConstants.toolsAndName, (item: ToolsAndName, toolIndex: number) => {
        Column() {
          Image(item.pic)
            .height(BaseConstants.DEFAULT_ICON_SIZE)
            .autoResize(true)
            .aspectRatio(1)
            .margin({ bottom: $r('app.float.image_margin') })
            .fillColor(this.selectedTool === toolIndex ? '#4DA6FF' : '')
          Text(item.pic_name)
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor(this.selectedTool === toolIndex ? '#4DA6FF' : $r('app.color.text_color'))
        }
        .onClick(() => {
          if (this.selectedTool === toolIndex) {
            // Deselect
            this.selectedTool = -1;
            this.activePresetIndex = -1;
            this.activeColorFilter = [...PictureEditConstants.IDENTITY];
          } else {
            this.selectedTool = toolIndex;
            if (toolIndex !== 4) {
              this.activePresetIndex = -1;
            }
          }
        })
      }, (item: ToolsAndName, toolIndex: number) => toolIndex.toString()
      )
    }
  }

  /* =================================================================
   *  AI core — lerp between identity and selected preset matrix
   * ================================================================= */
  updateAiFilter(): void {
    if (this.activePresetIndex < 0) {
      return;
    }
    const preset = PictureEditConstants.aiPresets[this.activePresetIndex];
    const t: number = this.aiIntensity / 100;
    this.activeColorFilter = ColorMatrix.lerp(preset.colorFilter, t);
  }

  selectAiPreset(index: number): void {
    if (this.activePresetIndex === index) {
      // Toggle off
      this.activePresetIndex = -1;
      this.activeColorFilter = [...PictureEditConstants.IDENTITY];
      return;
    }
    this.activePresetIndex = index;
    const preset = PictureEditConstants.aiPresets[index];
    this.aiIntensity = preset.sliderValue;
    this.updateAiFilter();
  }

  resetAi(): void {
    this.activePresetIndex = -1;
    this.aiIntensity = 50;
    this.activeColorFilter = [...PictureEditConstants.IDENTITY];
    this.showOriginal = false;
  }

  /* =================================================================
   *  AI Panel — 2×4 grid of preset cards, active highlight, controls
   * ================================================================= */
  @Builder
  aiPanel() {
    Column({ space: 12 }) {
      /* Title */
      Row() {
        Text($r('app.string.ToolsAndName5'))
          .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
          .fontColor(Color.White)
          .fontWeight(BaseConstants.FONT_WEIGHT_FIVE)
        Blank()
        if (this.activePresetIndex >= 0) {
          Text($r('app.string.ai_reset'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#4DA6FF')
            .onClick(() => {
              this.resetAi();
            })
        }
      }
      .width(BaseConstants.FULL_WIDTH)
      .padding({ left: 4, right: 4 })

      /* Preset grid */
      Grid() {
        ForEach(PictureEditConstants.aiPresets, (preset: AiPreset, index: number) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(preset.name)
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor(this.activePresetIndex === index ? '#FFFFFF' : '#CCFFFFFF')
                .fontWeight(this.activePresetIndex === index
                  ? BaseConstants.FONT_WEIGHT_FIVE : BaseConstants.FONT_WEIGHT_FOUR)
              Text(preset.desc)
                .fontSize(BaseConstants.FONT_SIZE_TEN)
                .fontColor(this.activePresetIndex === index ? '#99FFFFFF' : '#66FFFFFF')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .height(52)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(this.activePresetIndex === index ? '#4DA6FF' : '#33FFFFFF')
            .borderRadius(10)
            .border({
              width: this.activePresetIndex === index ? 1.5 : 0,
              color: '#4DA6FF',
              radius: 10
            })
            .onClick(() => {
              this.selectAiPreset(index);
            })
          }
        }, (preset: AiPreset, index: number) => index.toString())
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width(BaseConstants.FULL_WIDTH)
      .height(140)

      /* Apply hint — shown when a preset is active */
      if (this.activePresetIndex >= 0) {
        Row() {
          Text($r('app.string.ai_reset'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#99000000')
          Blank()
          Text($r('app.string.ai_apply'))
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontColor('#4DA6FF')
            .fontWeight(BaseConstants.FONT_WEIGHT_FIVE)
        }
        .width(BaseConstants.FULL_WIDTH)
        .padding({ left: 4, right: 4 })
      }
    }
    .width(BaseConstants.FULL_WIDTH)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  build() {
    NavDestination(){
      Flex({ direction: FlexDirection.Column }) {
        this.topBar()
        Flex({
          direction: this.isColumnLayout(this.currentBp, this.windowDirection) ? FlexDirection.Column : FlexDirection.Row
        }) {
          Flex() {
            this.centerPicture()
          }
          .flexShrink(1)

          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            this.optionRegion()
          }
          .flexBasis(PictureEditConstants.OPTION_FLEX_BASIS)
          .height(BaseConstants.FULL_HEIGHT)
        }
      }
      .backgroundColor(Color.Black)
      .padding({
        top: deviceInfo.deviceType === BaseConstants.DEVICE_2IN1 ? '0vp' :
         $r('app.float.device_padding_top'),
        bottom: deviceInfo.deviceType !== BaseConstants.DEVICE_2IN1 ?
         $r('app.float.tab_content_pb') : '0vp'
      })
    }
    .hideTitleBar(true)

  }
}