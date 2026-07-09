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

import { PicAndName, ToolsAndName, AiPreset, ColorMatrix } from '../viewmodel/AdaptiveViewModel';

export default class PictureEditConstants {
  /** Identity matrix shortcut — bundled with model for convenience. */
  static readonly IDENTITY: number[] = ColorMatrix.IDENTITY;

  /**
   * Picture size.
   */
  static PICTURE_HEIGHT_SM = '90%';
  static PICTURE_HEIGHT_MD = '90%';
  static PICTURE_HEIGHT_LG = '90%';
  static PICTURE_WIDTH_SM = '72%';
  static PICTURE_WIDTH_MD = '72%';
  static PICTURE_WIDTH_LG = '40%';
  static PICTURE_WIDTH_MD_ROW = '82%';
  static PICTURE_WIDTH_MD_COLUMN = '36.6%';
  static PICTURE_HEIGHT = '95%';
  static PICTURE_HALF_HEIGHT = '50%';
  /**
   * Flex basis.
   */
  static SLIDER_FLEX_BASIS = 80;
  static BAR_FLEX_BASIS = 60;
  static OPTION_FLEX_BASIS = 250;
  static IMAGE_BORDER_RADIUS = 8;
  /** AI grid columns per breakpoint. */
  static AI_GRID_MD = 4;
  static AI_GRID_SM = 3;
  /**
   * Edit text.
   */
  static Edit_Text = $r('app.string.edit');
  /**
   * Tools name.
   */
  static toolsAndName: ToolsAndName[] = [
    {
      pic: $r("app.media.tools_2"), pic_name: $r('app.string.ToolsAndName1')
    },
    {
      pic: $r("app.media.tools_1"), pic_name: $r('app.string.ToolsAndName2')
    },
    {
      pic: $r("app.media.tools_3"), pic_name: $r('app.string.ToolsAndName3')
    },
    {
      pic: $r("app.media.tools_4"), pic_name: $r('app.string.ToolsAndName4')
    },
    {
      pic: $r("app.media.tools_3"), pic_name: $r('app.string.ToolsAndName5')
    },
    {
      pic: $r("app.media.tools_4"), pic_name: $r('app.string.ToolsAndName6')
    },
    {
      pic: $r("app.media.tools_2"), pic_name: $r('app.string.ToolsAndName7')
    }];
  /** Emoji stickers — 18 common symbols rendered as text. */
  static readonly STICKER_EMOJI: string[] = [
    '😀', '😂', '❤️', '👍', '🎉', '⭐',
    '🌸', '🔥', '💯', '✨', '🌈', '🎂',
    '📸', '🎨', '🎵', '☕', '🍕', '⚽'
  ];

  /** Preset text colors for watermark. */
  static readonly TEXT_COLORS: string[] = [
    '#FFFFFF', '#000000', '#FF4444', '#FFD700',
    '#4DA6FF', '#4CAF50', '#FF9800', '#9C27B0'
  ];
  /**
   * ================================================================
   * AI Presets — 8 color directions. Slider controls intensity.
   * Each matrix is designed so that lerp(IDENTITY, matrix, t) at
   * t=0 yields no change and t=1 yields the full effect.
   * ================================================================
   */
  static aiPresets: AiPreset[] = [
    {
      name: $r('app.string.AiPresetName1'),
      desc: $r('app.string.AiPresetDesc1'),
      sliderValue: 50,
      colorFilter: [
        1.10, 0,    0,    0, -5,
        0,    1.10, 0,    0, -5,
        0,    0,    1.10, 0, -5,
        0,    0,    0,    1,  0
      ]
    },
    {
      name: $r('app.string.AiPresetName2'),
      desc: $r('app.string.AiPresetDesc2'),
      sliderValue: 50,
      colorFilter: [
        1.10, 0,    0,    0, 10,
        0,    1.02, 0,    0,  5,
        0,    0,    0.88, 0, -5,
        0,    0,    0,    1,  0
      ]
    },
    {
      name: $r('app.string.AiPresetName3'),
      desc: $r('app.string.AiPresetDesc3'),
      sliderValue: 50,
      colorFilter: [
        0.88, 0,    0,    0, -5,
        0,    1.00, 0,    0,  0,
        0,    0,    1.12, 0, 10,
        0,    0,    0,    1,  0
      ]
    },
    {
      name: $r('app.string.AiPresetName4'),
      desc: $r('app.string.AiPresetDesc4'),
      sliderValue: 50,
      colorFilter: [
        1.30, 0,    0,    0, -30,
        0,    1.30, 0,    0, -30,
        0,    0,    1.30, 0, -30,
        0,    0,    0,    1,   0
      ]
    },
    {
      name: $r('app.string.AiPresetName5'),
      desc: $r('app.string.AiPresetDesc5'),
      sliderValue: 50,
      colorFilter: [
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0,     0,     0,     1, 0
      ]
    },
    {
      name: $r('app.string.AiPresetName6'),
      desc: $r('app.string.AiPresetDesc6'),
      sliderValue: 50,
      colorFilter: [
        0.299, 0.587, 0.114, 0, 0,
        0.299, 0.587, 0.114, 0, 0,
        0.299, 0.587, 0.114, 0, 0,
        0,     0,     0,     1, 0
      ]
    },
    {
      name: $r('app.string.AiPresetName7'),
      desc: $r('app.string.AiPresetDesc7'),
      sliderValue: 50,
      colorFilter: [
        1.05,  0.02,  0,      0, 8,
        0,     1.02, -0.02,   0, 4,
        0,    -0.02,  0.98,   0, 2,
        0,     0,     0,      1, 0
      ]
    },
    {
      name: $r('app.string.AiPresetName8'),
      desc: $r('app.string.AiPresetDesc8'),
      sliderValue: 50,
      colorFilter: [
        1.15, 0.05,  0,   0, 5,
        0,    1.08,  0,   0, 2,
        0,    0,    0.90, 0, -3,
        0,    0,     0,   1,  0
      ]
    }
  ];
  /**
   * ================================================================
   * Filter thumbnails — 8 visually distinct color filters.
   * ================================================================
   */
  static filterAndName: PicAndName[] = [
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName1'),
      color_filter: [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName2'),
      color_filter: [
        1.05, 0,    0,    0, 3,
        0,    1.02, 0,    0, 3,
        0,    0,    1.00, 0, 3,
        0,    0,    0,    1, 0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName3'),
      color_filter: [
        1.08, 0.05, 0,    0, 5,
        0,    1.02, 0,    0, 2,
        0,    0,    0.92, 0, 0,
        0,    0,    0,    1, 0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName4'),
      color_filter: [
        1.12, 0.08, 0,    0, 8,
        0,    0.95, 0,    0, 0,
        0,    0,    0.85, 0, -5,
        0,    0,    0,    1,  0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName5'),
      color_filter: [
        0.98, 0.02, 0.02, 0, 2,
        0.02, 0.98, 0.02, 0, 2,
        0.02, 0.02, 0.98, 0, 2,
        0,    0,    0,    1, 0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName6'),
      color_filter: [
        0.95, 0.10, 0,    0, 10,
        0.05, 0.98, 0,    0,  5,
        0,    0,    1.00, 0,  3,
        0,    0,    0,    1,  0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName7'),
      color_filter: [
        0.80, 0.20, 0.10, 0, 10,
        0.15, 0.75, 0.10, 0,  5,
        0.10, 0.15, 0.70, 0,  2,
        0,    0,    0,    1,  0
      ]
    },
    {
      pic: $r("app.media.photo"), pic_name: $r('app.string.PicAndName8'),
      color_filter: [
        0.60, 0.35, 0.15, 0, 15,
        0.30, 0.55, 0.15, 0,  5,
        0.20, 0.30, 0.45, 0,  2,
        0,    0,    0,    1,  0
      ]
    }
  ];
}