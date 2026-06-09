import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const STORE_NAME = 'picture_favorites';
const KEY_INDICES = 'favorited_indices';

interface DeleteResult {
  list: Resource[];
  favorites: number[];
}

export class FavoritesStore {
  static load(ctx: common.BaseContext): Promise<number[]> {
    return preferences.getPreferences(ctx, STORE_NAME).then((prefs) => {
      return prefs.get(KEY_INDICES, '[]').then((data) => {
        let result: number[] = [];
        try {
          let str = data as string;
          if (str.length > 0) {
            result = JSON.parse(str) as number[];
          }
        } catch (e) {
          // return empty array on parse failure
        }
        return result;
      });
    });
  }

  static save(ctx: common.BaseContext, favorites: number[]): void {
    preferences.getPreferences(ctx, STORE_NAME).then((prefs) => {
      prefs.put(KEY_INDICES, JSON.stringify(favorites)).then(() => {
        prefs.flush();
      });
    });
  }

  static deleteAndReindex(
    pictureList: Resource[],
    favorites: number[],
    index: number
  ): DeleteResult {
    let list: Resource[] = [];
    for (let i = 0; i < pictureList.length; i++) {
      if (i !== index) {
        list.push(pictureList[i]);
      }
    }
    let result: number[] = [];
    for (let i = 0; i < favorites.length; i++) {
      let n = favorites[i];
      if (n > index) {
        result.push(n - 1);
      } else if (n < index) {
        result.push(n);
      }
    }
    return { list: list, favorites: result };
  }
}
