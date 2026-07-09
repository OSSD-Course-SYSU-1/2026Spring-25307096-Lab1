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

import { AlbumCategoryViewModel } from '../viewmodel/AlbumCategoryViewModel';
import { AlbumListViewModel } from '../viewmodel/AlbumListViewModel';
import { AlbumViewModel } from '../viewmodel/AlbumViewModel';
import { BrowsingConstants } from '../constants/BrowsingConstants';

@ComponentV2
export struct AlbumListView {
  @Param @Require albumCategory: AlbumCategoryViewModel;
  @Param @Require albumCategoryId: number;
  @Local albumListViewModel: AlbumListViewModel = AlbumListViewModel.getInstance();

  build() {
    Column() {
      Row() {
        Text(this.albumCategory.name)
          .fontSize(BrowsingConstants.ALBUM_LIST_FONT_SIZE_SECONDARY)
          .lineHeight(BrowsingConstants.ALBUM_LIST_LINE_HEIGHT_SECONDARY)
        Blank()
        SymbolGlyph($r('sys.symbol.chevron_up'))
          .fontSize(BrowsingConstants.ALBUM_LIST_ICON_SIZE)
          .fontColor([$r('app.color.album_category_icon')])
      }
      .visibility(this.albumCategory.name != 'default' ? Visibility.Visible : Visibility.None)
      .width('100%')
      .height(BrowsingConstants.ALBUM_LIST_ICON_SIZE)
      .padding({
        left: BrowsingConstants.ALBUM_LIST_ITEM_PADDING_HORIZONTAL,
        right: BrowsingConstants.ALBUM_LIST_ITEM_PADDING_HORIZONTAL
      })
      .margin({ bottom: BrowsingConstants.ALBUM_LIST_ITEM_MARGIN_BOTTOM })

      Column() {
        ForEach(this.albumCategory.albums, (item: AlbumViewModel, index: number) => {
          Row() {
            SymbolGlyph(item.icon)
              .fontSize(BrowsingConstants.ALBUM_LIST_ICON_SIZE)
              .fontColor(this.albumListViewModel.curAlbumId == item.id ? [$r('app.color.album_selected_text')] : [$r('app.color.album_category_icon')])
              .margin({ right: BrowsingConstants.ALBUM_LIST_ITEM_MARGIN_LEFT })

            Text(item.albumName)
              .fontSize(BrowsingConstants.ALBUM_LIST_FONT_SIZE_SECONDARY)
              .lineHeight(BrowsingConstants.ALBUM_LIST_LINE_HEIGHT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor(this.albumListViewModel.curAlbumId === item.id ? $r('app.color.album_selected_text') : $r('app.color.album_unselected_text'))
              .layoutWeight(1)

            Text('' + item.albumNum)
              .fontSize(BrowsingConstants.ALBUM_LIST_FONT_SIZE_SECONDARY)
              .lineHeight(BrowsingConstants.ALBUM_LIST_LINE_HEIGHT_SECONDARY)
              .fontColor(this.albumListViewModel.curAlbumId === item.id ? $r('app.color.album_selected_text') : $r('app.color.album_unselected_text'))
              .margin({ left: BrowsingConstants.ALBUM_LIST_ITEM_MARGIN_LEFT })
              .visibility(item.albumNum != 0 ? Visibility.Visible : Visibility.None)

            SymbolGlyph($r('sys.symbol.lock_fill'))
              .fontSize(BrowsingConstants.ALBUM_LIST_FONT_SIZE_DATE)
              .fontColor(this.albumListViewModel.curAlbumId === item.id ? [$r('app.color.album_selected_text')] : [$r('app.color.album_category_icon')])
              .margin({ left: BrowsingConstants.ALBUM_LIST_DATE_MARGIN_LEFT })
              .visibility(item.isLocked ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .height(BrowsingConstants.ALBUM_LIST_ITEM_HEIGHT)
          .padding({
            left: BrowsingConstants.ALBUM_LIST_ITEM_INNER_PADDING,
            right: BrowsingConstants.ALBUM_LIST_ITEM_INNER_PADDING
          })
          .borderRadius(BrowsingConstants.ALBUM_LIST_ITEM_BORDER_RADIUS)
          .onClick(() => {
            this.albumListViewModel.curAlbumId = item.id;
          })
          .backgroundColor(this.albumListViewModel.curAlbumId === item.id ? $r('app.color.album_selected_bg') : Color.Transparent)

          Row() {
            Blank()
              .width(BrowsingConstants.ALBUM_LIST_CHECK_ICON_SIZE)

            Divider()
              .strokeWidth(BrowsingConstants.ALBUM_LIST_CHECK_ICON_STROKE_WIDTH)
              .color($r('app.color.album_divider_color'))
              .layoutWeight(1)
          }
          .visibility(!this.albumCategory.canBeCreated && index === this.albumCategory.albums.length - 1 ?
            Visibility.None : Visibility.Visible)
          .width('100%')
          .padding({
            left: BrowsingConstants.ALBUM_LIST_ITEM_INNER_PADDING,
            right: BrowsingConstants.ALBUM_LIST_ITEM_INNER_PADDING
          })
        }, (item: AlbumViewModel, index: number) => JSON.stringify(item) + index)

        Text($r('app.string.create_album'))
          .fontSize(BrowsingConstants.ALBUM_LIST_FONT_SIZE_SECONDARY)
          .lineHeight(BrowsingConstants.ALBUM_LIST_LINE_HEIGHT_SECONDARY)
          .fontColor($r('sys.color.font_emphasize'))
          .height(BrowsingConstants.ALBUM_LIST_ITEM_HEIGHT)
          .margin({ left: BrowsingConstants.ALBUM_LIST_ITEM_MARGIN_LEFT_LARGE })
          .visibility(this.albumCategory.canBeCreated ? Visibility.Visible : Visibility.None)
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.album_list_background'))
      .borderRadius(BrowsingConstants.ALBUM_LIST_SELECTED_ITEM_BORDER_RADIUS)
      .padding(BrowsingConstants.ALBUM_LIST_SELECTED_ITEM_PADDING)
    }
    .width('100%')
    .margin({ bottom: BrowsingConstants.ALBUM_LIST_BOTTOM_MARGIN })
  }
}