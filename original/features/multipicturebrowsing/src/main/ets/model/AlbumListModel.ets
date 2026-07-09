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

import { AlbumCategoryModel } from './AlbumCategoryModel';
import { AlbumModel } from './AlbumModel';
import { PictureModel } from './PictureModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

export class AlbumListModel {
  public static instance: AlbumListModel;
  public albumCategoryList: AlbumCategoryModel[] = [];

  public static getInstance(): AlbumListModel {
    if (!AlbumListModel.instance) {
      AlbumListModel.instance = new AlbumListModel();
    }
    return AlbumListModel.instance;
  }

  constructor() {
    this.loadAlbumList();
  }

  loadAlbumList(): void {
    let index: number = 0;
    let mockPicturesBase: PictureModel[] = [
      new PictureModel(index++, $r('app.media.album_photo1')), new PictureModel(index++, $r('app.media.album_photo2')),
      new PictureModel(index++, $r('app.media.album_photo3')), new PictureModel(index++, $r('app.media.album_photo4')),
      new PictureModel(index++, $r('app.media.album_photo5')), new PictureModel(index++, $r('app.media.album_photo6')),
      new PictureModel(index++, $r('app.media.album_photo7')), new PictureModel(index++, $r('app.media.album_photo8')),
      new PictureModel(index++, $r('app.media.album_photo9')), new PictureModel(index++, $r('app.media.album_photo10'))
    ];
    let mockPictures: PictureModel[] = [];
    while (mockPictures.length < BrowsingConstants.MOCK_PICTURE_COUNT) {
      mockPictures = mockPictures.concat(mockPicturesBase);
    }

    let hiddenAlbum: AlbumModel = new AlbumModel(5, $r('app.string.album_hidden'), 0, $r('sys.symbol.eye_slash'), mockPictures);
    hiddenAlbum.isLocked = true;
    let normalAlbumList: AlbumModel[] = [
      new AlbumModel(0, $r('app.string.album_photos_and_videos'), 1234, $r('sys.symbol.picture_on_square'), mockPictures),
      new AlbumModel(1, $r('app.string.album_photos'), 1200, $r(`sys.symbol.picture_fill`), mockPictures),
      new AlbumModel(2, $r('app.string.album_videos'), 34, $r('sys.symbol.video_fill'), mockPicturesBase),
      new AlbumModel(3, $r('app.string.album_favorites'), 34, $r('sys.symbol.heart_fill'), mockPicturesBase),
      new AlbumModel(4, $r('app.string.album_moments'), 0, $r('sys.symbol.heart_square_stack_fill'), []),
      hiddenAlbum,
      new AlbumModel(6, $r('app.string.album_recently_deleted'), 12, $r('sys.symbol.trash_fill'), mockPicturesBase)
    ];
    let normalAlbumCategory: AlbumCategoryModel = new AlbumCategoryModel('default', normalAlbumList);
    normalAlbumCategory.canBeCreated = false;

    let myAlbumList: AlbumModel[] = [
      new AlbumModel(7, $r('app.string.album_new_1'), 34, $r('sys.symbol.rectangle_on_rectangle_fill'), mockPicturesBase),
      new AlbumModel(8, $r('app.string.album_new_2'), 34, $r('sys.symbol.rectangle_on_rectangle_fill'), mockPicturesBase)
    ];
    let myAlbumCategory: AlbumCategoryModel = new AlbumCategoryModel($r('app.string.category_my_albums'), myAlbumList);

    let smartAlbumList: AlbumModel[] = [
      new AlbumModel(9, $r('app.string.album_portrait'), 34, $r('sys.symbol.person_fill'), mockPicturesBase)
    ];
    let smartAlbumCategory: AlbumCategoryModel = new AlbumCategoryModel($r('app.string.category_smart_albums'), smartAlbumList);

    this.albumCategoryList = [normalAlbumCategory, myAlbumCategory, smartAlbumCategory];
  }
}