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

import { TopBar } from '../view/TopBar';
import { CenterPart } from '../view/CenterPart';
import { BottomBar } from '../view/BottomBar';
import { PreviewLists } from '../view/PreviewLists';
import { BaseConstants, BreakpointConstants } from 'base';
import { deviceInfo } from '@kit.BasicServicesKit';
import { AlbumView } from 'albumview';
import { PictureEdit } from 'pictureedit';
import PictureViewConstants, { ActionInterface } from '../constants/PictureViewConstants';
import { FavoritesStore } from '../utils/FavoritesStore';
import { DeletedSnapshot } from '../utils/FavoritesStore';

@Preview
@Component
export struct PictureViewIndex {
  @StorageLink('currentBreakpoint') currentBp: string = BreakpointConstants.BREAKPOINT_MD;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Provide('curImageIndex') curImageIndex: number = 0;
  @Provide('imageTotal') imageTotal: number = PictureViewConstants.PICTURES.length;
  @Provide('favoritedIndices') favoritedIndices: number[] = [];
  @Provide('pictureList') pictureList: Resource[] = [...PictureViewConstants.PICTURES];

  @StorageLink('fav_toggle_idx') @Watch('onFavToggle') favToggleIdx: number = -1;
  @StorageLink('delete_idx') @Watch('onDeleteTrigger') deleteIdx: number = -1;
  @StorageLink('show_info_dialog') showInfoDialog: boolean = false;

  @State deletedSnapshot: DeletedSnapshot | null = null;
  @State showUndoSnackbar: boolean = false;
  private undoTimer: number = -1;

  aboutToAppear(): void {
    let ctx = this.getUIContext().getHostContext();
    if (ctx !== undefined) {
      FavoritesStore.load(ctx).then((data: number[]) => {
        this.favoritedIndices = data;
      });
    }
  }

  onFavToggle(): void {
    if (this.favToggleIdx >= 0) {
      let index: number = this.favToggleIdx;
      this.favToggleIdx = -1;
      this.handleToggleFav(index);
    }
  }

  onDeleteTrigger(): void {
    if (this.deleteIdx >= 0) {
      let index: number = this.deleteIdx;
      this.deleteIdx = -1;
      this.handleDelete(index);
    }
  }

  handleToggleFav(index: number): void {
    const idx = this.favoritedIndices.indexOf(index);
    if (idx !== -1) {
      this.favoritedIndices.splice(idx, 1);
    } else {
      this.favoritedIndices.push(index);
    }
    this.favoritedIndices = [...this.favoritedIndices];
    let ctx = this.getUIContext().getHostContext();
    if (ctx !== undefined) {
      FavoritesStore.save(ctx, this.favoritedIndices);
    }
  }

  handleDelete(index: number): void {
    if (this.pictureList.length <= 1) {
      return;
    }
    // Clear previous undo timer
    if (this.undoTimer !== -1) {
      clearTimeout(this.undoTimer);
      this.undoTimer = -1;
    }
    // Save snapshot before deleting
    this.deletedSnapshot = {
      picture: this.pictureList[index],
      index: index,
      favorites: [...this.favoritedIndices]
    };
    const result = FavoritesStore.deleteAndReindex(this.pictureList, this.favoritedIndices, index);
    this.pictureList = result.list;
    this.favoritedIndices = result.favorites;
    this.imageTotal = result.list.length;
    if (this.curImageIndex >= result.list.length) {
      this.curImageIndex = result.list.length - 1;
    }
    let ctx = this.getUIContext().getHostContext();
    if (ctx !== undefined) {
      FavoritesStore.save(ctx, this.favoritedIndices);
    }
    // Show undo snackbar
    this.showUndoSnackbar = true;
    // Auto-dismiss after 5 seconds
    this.undoTimer = setTimeout(() => {
      this.clearUndoSnapshot();
    }, 5000);
  }

  handleUndoDelete(): void {
    if (this.deletedSnapshot === null) {
      return;
    }
    if (this.undoTimer !== -1) {
      clearTimeout(this.undoTimer);
      this.undoTimer = -1;
    }
    const snap = this.deletedSnapshot;
    // Rebuild list with deleted picture inserted back at original position
    let newList: Resource[] = [];
    for (let i = 0; i < this.pictureList.length; i++) {
      if (i === snap.index) {
        newList.push(snap.picture);
      }
      newList.push(this.pictureList[i]);
    }
    if (snap.index >= this.pictureList.length) {
      newList.push(snap.picture);
    }
    this.pictureList = newList;
    this.favoritedIndices = snap.favorites;
    this.imageTotal = newList.length;
    if (this.curImageIndex >= snap.index) {
      this.curImageIndex = snap.index;
    }
    let ctx = this.getUIContext().getHostContext();
    if (ctx !== undefined) {
      FavoritesStore.save(ctx, this.favoritedIndices);
    }
    this.showUndoSnackbar = false;
    this.deletedSnapshot = null;
  }

  clearUndoSnapshot(): void {
    this.showUndoSnackbar = false;
    this.deletedSnapshot = null;
    this.undoTimer = -1;
  }

  isFavoritedLg(): boolean {
    return this.favoritedIndices.indexOf(this.curImageIndex) !== -1;
  }

  @Builder
  PageMap(name: string) {
    if (name === 'albumView') {
      AlbumView()
    }
    if (name === 'pictureEdit') {
      PictureEdit()
    }
  }

  build() {
    Stack() {
      Navigation(this.pageInfos) {
        Flex({ direction: FlexDirection.Column }) {
          TopBar()
          if (this.currentBp === BreakpointConstants.BREAKPOINT_LG) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
              CenterPart()
                .layoutWeight(3)
              Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
                PreviewLists({ isVertical: true })
                  .layoutWeight(1)
                Row() {
                  ForEach(PictureViewConstants.ACTIONS, (item: ActionInterface, index: number) => {
                    if (index === 1) {
                      Column() {
                        Image(item.icon).height(24).width(24)
                          .fillColor(this.isFavoritedLg() ? '#FF4444' : '#999999')
                        Text(this.isFavoritedLg() ? $r('app.string.favorited') : item.icon_name)
                          .fontSize(10).margin({ top: 4 })
                      }.width('18%').onClick(() => {
                        AppStorage.setOrCreate<number>('fav_toggle_idx', this.curImageIndex);
                      })
                    } else if (index === 2) {
                      Column() {
                        Image(item.icon).height(24).width(24).fillColor('#4CAF50')
                        Text(item.icon_name).fontSize(10).margin({ top: 4 })
                      }.width('18%').onClick(() => {
                        this.pageInfos.pushPath(new NavPathInfo('pictureEdit', []));
                      })
                    } else if (index === 3) {
                      Column() {
                        Image(item.icon).height(24).width(24).fillColor('#FF5252')
                        Text(item.icon_name).fontSize(10).margin({ top: 4 })
                      }.width('18%').onClick(() => {
                        AppStorage.setOrCreate<number>('delete_idx', this.curImageIndex);
                      })
                    } else {
                      Column() {
                        Image(item.icon).height(24).width(24).fillColor(index === 0 ? '#4DA6FF' : '#999999')
                        Text(item.icon_name).fontSize(10).margin({ top: 4 })
                      }.width('18%')
                    }
                  })
                }
                .width('90%')
                .justifyContent(FlexAlign.SpaceEvenly)
                .padding({ top: 12, bottom: 12 })
              }
              .layoutWeight(2)
              .padding({ left: 12 })
            }
            .flexGrow(1)
          } else {
            Flex({
              direction: FlexDirection.Column,
              alignItems: ItemAlign.Center
            }) {
              CenterPart()
                .flexGrow(1)
              PreviewLists({ isVertical: false })
              BottomBar()
            }
            .flexGrow(1)
          }
        }
        .padding({
          top: deviceInfo.deviceType === BaseConstants.DEVICE_2IN1 ? '0vp' : $r('app.float.device_padding_top'),
          bottom: deviceInfo.deviceType !== BaseConstants.DEVICE_2IN1 ? $r('app.float.tab_content_pb') : '0vp'
        })
      }
      .mode(NavigationMode.Auto)
      .height(BaseConstants.FULL_HEIGHT)
      .width(BaseConstants.FULL_WIDTH)
      .navDestination(this.PageMap)
      .hideTitleBar(true)
      .hideToolBar(true)
      .hideBackButton(true)
      .titleMode(NavigationTitleMode.Mini)

      if (this.showUndoSnackbar) {
        Row() {
          Text($r('app.string.undo_delete_msg'))
            .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
            .fontColor(Color.White)
            .layoutWeight(1)
          Button($r('app.string.undo_action'))
            .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
            .fontColor('#4DA6FF')
            .backgroundColor(Color.Transparent)
            .height(32)
            .onClick(() => {
              this.handleUndoDelete();
            })
        }
        .width('90%')
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12
        })
        .backgroundColor('#CC333333')
        .borderRadius(8)
        .position({ x: '5%', y: '88%' })
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
      }

      if (this.showInfoDialog) {
        Column() {
          Column() {
            Text($r('app.string.image_info_title'))
              .fontSize(BaseConstants.FONT_SIZE_EIGHTEEN)
              .fontWeight(BaseConstants.FONT_WEIGHT_FIVE)
              .margin({ bottom: $r('app.float.image_margin') })
            Divider()
            Row() {
              Text($r('app.string.image_name_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  IMG_20201224_001.jpg')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.image_margin') })
            Row() {
              Text($r('app.string.image_size_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  4032 × 3024')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.icon_padding_top') })
            Row() {
              Text($r('app.string.image_date_label'))
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
              Text('  2020-12-24 10:30:00')
                .fontSize(BaseConstants.FONT_SIZE_FOURTEEN)
                .fontColor('#666666')
            }
            .width(BaseConstants.FULL_WIDTH)
            .margin({ top: $r('app.float.icon_padding_top') })
            Button($r('app.string.image_info_close'))
              .margin({ top: $r('app.float.image_margin') })
              .onClick(() => {
                this.showInfoDialog = false;
              })
          }
          .padding($r('app.float.row_padding'))
          .backgroundColor(Color.White)
          .borderRadius(16)
          .width('80%')
          .hitTestBehavior(HitTestMode.Block)
        }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#66000000')
        .onClick(() => {
          this.showInfoDialog = false;
        })
      }
    }
  }
}
