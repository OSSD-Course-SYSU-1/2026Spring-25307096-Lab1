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

import PictureViewConstants, { ActionInterface } from '../constants/PictureViewConstants';
import { BaseConstants } from 'base';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Preview
@Component
export struct BottomBar {
  @Consume('pageInfos') pageInfos: NavPathStack
  @Consume('isFavorited') isFavorited: boolean;

  build() {
    Flex({
      justifyContent: FlexAlign.Center,
      direction: FlexDirection.Row
    }) {
      ForEach(PictureViewConstants.ACTIONS, (item: ActionInterface) => {
        Column() {
          Image(item.icon)
            .height(BaseConstants.DEFAULT_ICON_SIZE)
            .width(BaseConstants.DEFAULT_ICON_SIZE)
            .fillColor(this.isFavorited && item.icon === $r('app.media.ic_public_favor') ?
              '#FF4444' : '')
          Text(this.isFavorited && item.icon === $r('app.media.ic_public_favor') ?
            $r('app.string.favorited') : item.icon_name)
            .fontFamily(BaseConstants.FONT_FAMILY_NORMAL)
            .fontSize(BaseConstants.FONT_SIZE_TEN)
            .fontWeight(BaseConstants.FONT_WEIGHT_FOUR)
            .padding({ top: $r('app.float.icon_padding_top') })
        }
        .onClick(() => {
          try {
            let pushPath = this.getUIContext()
              .getHostContext()?.resourceManager.getStringSync((item.icon_name as Resource).id) as string;
            if (pushPath === '编辑' || pushPath === 'edit') {
              this.pageInfos.pushPath(new NavPathInfo('pictureEdit', []));
            }
            if (item.icon === $r('app.media.ic_public_favor')) {
              this.isFavorited = !this.isFavorited;
            }
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'BottomBar', 'error code is ' + err.code);
          }
        })
        .width(PictureViewConstants.ICON_LIST_WIDTH)
      }, (item: ActionInterface, index: number) => index + JSON.stringify(item))
    }
    .height($r('app.float.icon_list_height'))
  }
}