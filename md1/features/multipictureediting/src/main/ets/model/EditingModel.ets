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

import { FilterModel } from './FilterModel';

export class EditingModel {
  public static instance: EditingModel;
  public title: Resource = $r('app.string.editing_title');
  public filterList: FilterModel[] = [];

  public static getInstance(): EditingModel {
    if (!EditingModel.instance) {
      EditingModel.instance = new EditingModel();
    }
    return EditingModel.instance;
  }

  constructor() {
    this.loadData();
  }

  loadData(): void {
    this.filterList = [
      new FilterModel($r('app.string.filter_original'),
        [1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_cyan_orange'),
        [1, 0, 0, 0, 0,
          0, 1, 0.2, 0, 0,
          0, 0.2, 1.2, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_sunset'),
        [0.6, 0.2, 0.2, 0, 0,
          0.2, 0.6, 0.2, 0, 0,
          0.2, 0.2, 0.6, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_crystal'),
        [1.4, 0, 0, 0, 0,
          0, 1.4, 0, 0, 0,
          0, 0, 1.4, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_antique'),
        [0.39, 0.77, 0.19, 0, 0,
          0.35, 0.69, 0.17, 0, 0,
          0.27, 0.53, 0.13, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_lucky'),
        [0.9, 0, 0.1, 0, 0,
          0, 1, 0.1, 0, 0,
          0.1, 0, 1.1, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_sweet'),
        [1.2, 0.2, 0.0, 0, 0,
          0.0, 0.9, 0.3, 0, 0,
          0.1, 0.5, 1.3, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_medium'),
        [0.8, 0, 0.2, 0, 0,
          0, 0.9, 0.3, 0, 0,
          0.1, 0, 1.4, 0, 0,
          0, 0, 0, 1, 0]),
      new FilterModel($r('app.string.filter_milk_tea'),
        [0.8, 0.1, 0.1, 0, 0,
          0.1, 0.9, 0.1, 0, 0,
          0.1, 0.2, 0.8, 0, 0,
          0, 0, 0, 1, 0]),
    ];
  }
}