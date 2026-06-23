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

import { BreakpointType } from 'base';
import PictureEditConstants from '../constants/PictureEditConstants';

export class Adaptive {
  static PICTURE_HEIGHT = (currentBreakpoint: string): string => {
    return new BreakpointType(
      PictureEditConstants.PICTURE_HEIGHT_SM,
      PictureEditConstants.PICTURE_HEIGHT_MD,
      PictureEditConstants.PICTURE_HEIGHT_LG,
    ).GetValue(currentBreakpoint);
  }
  static PICTURE_WIDTH = (currentBreakpoint: string): string => {
    return new BreakpointType(
      PictureEditConstants.PICTURE_WIDTH_SM,
      PictureEditConstants.PICTURE_WIDTH_MD,
      PictureEditConstants.PICTURE_WIDTH_LG,
    ).GetValue(currentBreakpoint);
  }
}

/**
 * Color matrix utilities — 4x5 matrices for ArkUI .colorFilter().
 * Each matrix is a 20-element number[]:
 *   [Rr,Rg,Rb,Ra,Ro, Gr,Gg,Gb,Ga,Go, Br,Bg,Bb,Ba,Bo, Ar,Ag,Ab,Aa,Ao]
 * where Ro/Go/Bo/Ao are channel offsets.
 */
export class ColorMatrix {
  /** Identity matrix — passes through unchanged. */
  static readonly IDENTITY: number[] = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0
  ];

  /**
   * Linear interpolation between identity and a target matrix.
   * @param target   The preset color matrix to blend toward.
   * @param t        Intensity factor in [0, 1].  0 = identity, 1 = full target.
   */
  static lerp(target: number[], t: number): number[] {
    const result: number[] = [];
    for (let i = 0; i < 20; i++) {
      result[i] = ColorMatrix.IDENTITY[i] + (target[i] - ColorMatrix.IDENTITY[i]) * t;
    }
    return result;
  }

  /**
   * Linear interpolation between two arbitrary matrices.
   */
  static lerpBetween(a: number[], b: number[], t: number): number[] {
    const result: number[] = [];
    for (let i = 0; i < 20; i++) {
      result[i] = a[i] + (b[i] - a[i]) * t;
    }
    return result;
  }
}

export interface ToolsAndName {
  pic: Resource
  pic_name: ResourceStr
}

export interface PicAndName {
  pic: Resource
  pic_name: ResourceStr
  color_filter: number[]
}

export interface AiPreset {
  name: ResourceStr;
  desc: ResourceStr;
  sliderValue: number;
  colorFilter: number[];
}