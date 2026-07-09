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

import { TimeFilterModel } from '../model/TimeFilterModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

@ObservedV2
export class TimeFilterViewModel {
  @Trace public filters: Resource[] = [];
  @Trace public filterIndex: number = BrowsingConstants.DEFAULT_TIME_FILTER_INDEX;
  public static instance: TimeFilterViewModel;
  public timeFilterModel: TimeFilterModel = new TimeFilterModel();

  public static getInstance(): TimeFilterViewModel {
    if (!TimeFilterViewModel.instance) {
      TimeFilterViewModel.instance = new TimeFilterViewModel();
    }
    return TimeFilterViewModel.instance;
  }

  constructor() {
    this.filters = this.timeFilterModel.filters;
  }
}