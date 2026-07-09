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

import { PictureModel } from './PictureModel';

export class AlbumModel {
  public id: number;
  public albumName: string | Resource;
  public albumNum: number;
  public icon: Resource;
  public isLocked: boolean = false;
  public pictures: PictureModel[] = [];

  constructor(id: number, albumName: string | Resource, albumNum: number, icon: Resource, pictures: PictureModel[]) {
    this.id = id;
    this.albumName = albumName;
    this.albumNum = albumNum;
    this.icon = icon;
    this.pictures = pictures;
  }
}