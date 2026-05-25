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

export interface ActionInterface {
  icon: Resource
  icon_name: ResourceStr
}

export default class PictureViewConstants {
  /**
   * Picture size.
   */
  static PICTURE_HEIGHT_SM = '88%';
  static PICTURE_HEIGHT_MD = '100%';
  static PICTURE_HEIGHT_LG = '100%';
  static PICTURE_WIDTH_SM = '100%';
  static PICTURE_WIDTH_MD = '84.5%';
  static PICTURE_WIDTH_LG = '46.9%';
  static readonly ICON_LIST_WIDTH = "18%";
  /**
   * Edit icon name.
   */
  static readonly EDIT_ICON_NAME: ResourceStr = $r('app.string.ActionInterface3');
  /**
   * Actions.
   */
  static ACTIONS: ActionInterface[] = [
    {
      icon: $r('app.media.ic_public_share'), icon_name: $r('app.string.ActionInterface1')
    },
    {
      icon: $r('app.media.ic_public_favor'), icon_name: $r('app.string.ActionInterface2')
    },
    {
      icon: $r("app.media.ic_gallery_public_details_4"), icon_name: $r('app.string.ActionInterface3')
    },
    {
      icon: $r("app.media.ic_gallery_public_details_5"), icon_name: $r('app.string.ActionInterface4')
    },
    {
      icon: $r('app.media.ic_public_more'), icon_name: $r('app.string.ActionInterface5')
    }
  ];
  /**
   * Pictures.
   */
  static readonly PICTURES: Resource[] = [
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9"),
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9"),
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9"),
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9"),
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9"),
    $r("app.media.album_photo1"),
    $r("app.media.album_photo2"),
    $r("app.media.album_photo3"),
    $r("app.media.album_photo4"),
    $r("app.media.album_photo5"),
    $r("app.media.album_photo6"),
    $r("app.media.album_photo7"),
    $r("app.media.album_photo8"),
    $r("app.media.album_photo9")
  ];
}