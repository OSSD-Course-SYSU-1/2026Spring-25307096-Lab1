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

import { TabModel } from './TabModel';

export class TabListModel {
  public static instance: TabListModel;
  public browsingTabList: TabModel[] = [];
  public editingTabList: TabModel[] = [];

  public static getInstance(): TabListModel {
    if (!TabListModel.instance) {
      TabListModel.instance = new TabListModel();
    }
    return TabListModel.instance;
  }

  constructor() {
    this.loadTabs();
  }

  loadTabs(): void {
    this.browsingTabList = [
      new TabModel($r('sys.symbol.picture_fill'), $r('app.string.tab_photos')),
      new TabModel($r('sys.symbol.rectangle_on_rectangle_fill'), $r('app.string.tab_albums')),
      new TabModel($r('sys.symbol.heart_square_stack_fill'), $r('app.string.tab_moments'))
    ];
    this.editingTabList = [
      new TabModel($r('sys.symbol.cut'), $r('app.string.tab_cut')),
      new TabModel($r('sys.symbol.crop_rotate'), $r('app.string.tab_crop')),
      new TabModel($r('sys.symbol.slider_horizontal_2'), $r('app.string.tab_adjust')),
      new TabModel($r('sys.symbol.camera_filters'), $r('app.string.tab_filters'))
    ];
  }
}