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

import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { WindowUtil, CommonConstants, Logger } from 'multipicturecommon';
import { DefaultConstants } from '../constants/DefaultConstants';

export default class MultiPictureBeautificationDefaultAbility extends UIAbility {
  public windowUtil?: WindowUtil;

  onCreate(): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      Logger.error(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onCreate');
  }

  onDestroy(): void {
    if (this.windowUtil) {
      this.windowUtil.release();
    }
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onWindowStageCreate');

    AppStorageV2.connect<WindowUtil>(WindowUtil, CommonConstants.WINDOW_UTIL_KEY, () => new WindowUtil());
    this.windowUtil = AppStorageV2.connect(WindowUtil, CommonConstants.WINDOW_UTIL_KEY) as WindowUtil;
    this.windowUtil.setWindowStage(windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Succeeded in loading the content.');
      if (this.windowUtil) {
        this.windowUtil.setUIContext();
        this.windowUtil.setFullScreen(true);
        this.windowUtil.updateWindowInfo();
      }
    });
  }

  onWindowStageDestroy(): void {
    if (this.windowUtil) {
      this.windowUtil.release();
    }
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(DefaultConstants.LOG_TAG_DEFAULT_ABILITY, 'Ability onBackground');
  }
}