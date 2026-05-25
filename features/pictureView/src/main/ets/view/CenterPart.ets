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

import { BreakpointConstants } from 'base';
import { Adaptive } from '../viewmodel/AdaptiveViewModel'
import PictureViewConstants from '../constants/PictureViewConstants';

@Component
export struct CenterPart {
  @StorageLink('currentBreakpoint') currentBp: string = BreakpointConstants.BREAKPOINT_MD;
  @State scaleValue: number = 1;
  @State pinchValue: number = 1;
  @State rotationAngle: number = 0;
  @Consume('curImageIndex') curImageIndex: number;
  @Consume('imageTotal') imageTotal: number;

  // Switch to next image (swipe left)
  nextImage(): void {
    if (this.curImageIndex < this.imageTotal - 1) {
      this.curImageIndex += 1;
      this.scaleValue = 1;
      this.pinchValue = 1;
      this.rotationAngle = 0;
    }
  }

  // Switch to previous image (swipe right)
  prevImage(): void {
    if (this.curImageIndex > 0) {
      this.curImageIndex -= 1;
      this.scaleValue = 1;
      this.pinchValue = 1;
      this.rotationAngle = 0;
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Blank()
      // [Start center_part]
      Row() {
        Column() {
          Image(PictureViewConstants.PICTURES[this.curImageIndex])
            .autoResize(true)
        }
      }
      // [StartExclude center_part]
      .height(Adaptive.PICTURE_HEIGHT(this.currentBp))
      .width(Adaptive.PICTURE_WIDTH(this.currentBp))
      // [EndExclude center_part]
      .scale({ x: this.scaleValue, y: this.scaleValue, z: 1 })
      .rotate({ angle: this.rotationAngle })
      .animation({ duration: 200 })
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event: GestureEvent | undefined) => {
              if (event) {
                this.scaleValue = this.pinchValue * event.scale;
              }
            })
            .onActionEnd(() => {
              this.pinchValue = this.scaleValue;
            }),
          PanGesture({ direction: PanDirection.Horizontal })
            .onActionEnd((event: GestureEvent) => {
              if (event.offsetX < -50) {
                this.nextImage();
              } else if (event.offsetX > 50) {
                this.prevImage();
              }
            }),
          TapGesture({ count: 2 })
            .onAction(() => {
              this.rotationAngle += 90;
              if (this.rotationAngle >= 360) {
                this.rotationAngle = 0;
              }
            })
        )
      )
      // [End center_part]

      Blank()
        .height(this.currentBp === BreakpointConstants.BREAKPOINT_SM ? $r('app.float.center_blank_height_lg') : 0)
      // Image counter indicator
      Row() {
        Text(`${this.curImageIndex + 1} / ${this.imageTotal}`)
          .fontSize($r('app.float.font_size_twelve'))
          .fontColor(Color.White)
          .opacity(0.7)
          .padding({
            left: $r('app.float.row_padding_left'),
            right: $r('app.float.row_padding_right'),
            top: $r('app.float.icon_padding_top'),
            bottom: $r('app.float.icon_padding_top')
          })
      }
      .backgroundColor('#33000000')
      .borderRadius(12)
    }
    .margin({
      top: $r('app.float.center_margin_top'),
      bottom: $r('app.float.center_margin_bottom')
    })
  }
}