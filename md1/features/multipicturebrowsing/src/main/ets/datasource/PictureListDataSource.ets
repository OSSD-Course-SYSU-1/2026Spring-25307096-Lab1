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

import { PictureViewModel } from '../viewmodel/PictureViewModel';

// LazyForEach data source implementation for Grid items
// Provides on-demand loading for large picture lists
export class PictureListDataSource implements IDataSource {
  private pictureList: PictureViewModel[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(pictureList: PictureViewModel[]) {
    this.pictureList = pictureList;
  }

  // Get total data count
  totalCount(): number {
    return this.pictureList.length;
  }

  // Get data item at specified index
  getData(index: number): PictureViewModel {
    return this.pictureList[index];
  }

  // Register data change listener
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // Unregister data change listener
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // Notify listeners when data is added at end
  notifyDataAdd(): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(this.pictureList.length - 1);
    });
  }

  // Notify listeners when data changes
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  // Notify listeners when data is deleted
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  // Update the entire picture list
  updatePictureList(newList: PictureViewModel[]): void {
    this.pictureList = newList;
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }
}