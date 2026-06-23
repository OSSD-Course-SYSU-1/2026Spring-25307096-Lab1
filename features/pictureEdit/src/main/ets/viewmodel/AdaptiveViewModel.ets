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

/**
 * Base overlay item — text or sticker placed on top of the image.
 */
export interface TextOverlay {
  id: string;
  type: 'text';
  text: string;
  x: number;          // center X as fraction 0-1 relative to image
  y: number;          // center Y as fraction 0-1 relative to image
  fontSize: number;   // sp
  color: string;      // hex like '#FFFFFF'
  opacity: number;    // 0.2 - 1.0
  rotation: number;   // degrees 0-360
  scale: number;      // 0.5 - 3.0
}

export interface StickerOverlay {
  id: string;
  type: 'sticker';
  emoji: string;      // emoji character, e.g. '😀'
  x: number;
  y: number;
  scale: number;      // 0.5 - 3.0
  rotation: number;   // 0-360
  opacity: number;    // 0.3 - 1.0
}

export type OverlayItem = TextOverlay | StickerOverlay;

/**
 * A point on the canvas, used for brush strokes.
 */
export interface Point {
  x: number;
  y: number;
}

/**
 * A rectangular region on the canvas.
 */
export interface Rect {
  left: number;
  top: number;
  width: number;
  height: number;
}

/**
 * A mosaic or blur region on the canvas.
 */
export interface MosaicRegion {
  id: string;
  // Brush mode
  points?: Array<Point>;
  brushSize: number;
  // Box mode
  rect?: Rect;
  // Common
  type: 'mosaic' | 'blur';
  mosaicSize?: number;
}