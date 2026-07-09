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

/**
 * Constants.
 */
export interface ImageData {
  src: Resource,
  selected: boolean
}

export class AlbumViewConstants {
  /**
   * Image list.
   */
  static readonly IMAGE_LIST: ImageData[] = [
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false },
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false },
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false },
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false },
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false },
    { src: $r("app.media.album_photo1"), selected: false },
    { src: $r("app.media.album_photo2"), selected: false },
    { src: $r("app.media.album_photo3"), selected: false },
    { src: $r("app.media.album_photo4"), selected: false },
    { src: $r("app.media.album_photo5"), selected: false },
    { src: $r("app.media.album_photo6"), selected: false },
    { src: $r("app.media.album_photo7"), selected: false }
  ];
  /**
   * Default text.
   */
  static DES_TEXT = $r('app.string.picture');
  /**
   * Side constants.
   */
  static SideConstants: ResourceStr[] =
    [$r('app.string.sideConstants1'), $r('app.string.sideConstants2'), $r('app.string.sideConstants3'),
      $r('app.string.sideConstants4'),
      $r('app.string.sideConstants5'), $r('app.string.sideConstants6'), $r('app.string.sideConstants7'),
      $r('app.string.sideConstants8'), $r('app.string.sideConstants9'), $r('app.string.sideConstants10'),
      $r('app.string.sideConstants11'), $r('app.string.sideConstants12'), $r('app.string.sideConstants13'),
      $r('app.string.sideConstants14')];
}