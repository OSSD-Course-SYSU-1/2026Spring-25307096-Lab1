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

import { MosaicRegion, Point } from '../../viewmodel/AdaptiveViewModel';

/**
 * Transparent Canvas overlay for drawing mosaic / blur regions.
 * Handles both brush (touch-drag) and box (touch-drag-release) modes.
 */
@Component
export struct MosaicCanvas {
  @Link regions: MosaicRegion[];
  @Prop brushMode: number;    // 0 = brush, 1 = box
  @Prop effectType: number;   // 0 = mosaic, 1 = blur
  @Prop brushSize: number;    // 10-80
  @Prop mosaicSize: number;   // 4-20
  @Prop canvasWidth: number;  // actual image display width in vp
  @Prop canvasHeight: number; // actual image display height in vp
  @Prop enabled: boolean;     // only active when mosaic tool selected

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private isDrawing: boolean = false;
  private boxStartX: number = 0;
  private boxStartY: number = 0;
  private boxEndX: number = 0;
  private boxEndY: number = 0;
  private currentPoints: Point[] = [];

  /**
   * Generate a deterministic pseudo-random color for mosaic blocks
   * based on (x, y) grid position.
   */
  private mosaicBlockColor(gx: number, gy: number): string {
    const r: number = ((gx * 131 + gy * 257) % 256);
    const g: number = ((gx * 311 + gy * 173) % 256);
    const b: number = ((gx * 199 + gy * 331) % 256);
    return `rgba(${r}, ${g}, ${b}, 0.85)`;
  }

  /**
   * Redraw all regions onto the canvas.
   */
  redrawAll(): void {
    this.ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    for (const region of this.regions) {
      this.drawRegion(region);
    }
  }

  private drawRegion(region: MosaicRegion): void {
    if (region.rect) {
      // Box mode region
      if (region.type === 'mosaic') {
        const gs: number = region.mosaicSize ?? 8;
        for (let px: number = region.rect.left; px < region.rect.left + region.rect.width; px += gs) {
          for (let py: number = region.rect.top; py < region.rect.top + region.rect.height; py += gs) {
            const gx: number = Math.floor(px / gs);
            const gy: number = Math.floor(py / gs);
            this.ctx.fillStyle = this.mosaicBlockColor(gx, gy);
            this.ctx.fillRect(px, py, gs, gs);
          }
        }
      } else {
        // Blur: draw semi-transparent white overlay
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.35)';
        this.ctx.fillRect(region.rect.left, region.rect.top, region.rect.width, region.rect.height);
      }
    } else if (region.points) {
      // Brush mode region
      for (const pt of region.points) {
        if (region.type === 'mosaic') {
          const gs: number = region.mosaicSize ?? 8;
          for (let dx: number = -region.brushSize / 2; dx < region.brushSize / 2; dx += gs) {
            for (let dy: number = -region.brushSize / 2; dy < region.brushSize / 2; dy += gs) {
              const px: number = pt.x + dx;
              const py: number = pt.y + dy;
              const gx: number = Math.floor(px / gs);
              const gy: number = Math.floor(py / gs);
              this.ctx.fillStyle = this.mosaicBlockColor(gx, gy);
              this.ctx.fillRect(px, py, gs, gs);
            }
          }
        } else {
          // Blur brush: semi-transparent frosted circle
          this.ctx.fillStyle = 'rgba(255, 255, 255, 0.25)';
          this.ctx.beginPath();
          this.ctx.arc(pt.x, pt.y, region.brushSize / 2, 0, 2 * Math.PI);
          this.ctx.fill();
        }
      }
    }
  }

  build() {
    Canvas(this.ctx)
      .width(this.canvasWidth)
      .height(this.canvasHeight)
      .position({ x: 0, y: 0 })
      .hitTestBehavior(this.enabled ? HitTestMode.Default : HitTestMode.None)
      .onReady(() => {
        this.redrawAll();
      })
      .onTouch((event: TouchEvent) => {
        if (!this.enabled) return;

        const touch: TouchObject = event.touches[0];
        const x: number = touch.x;
        const y: number = touch.y;

        if (event.type === TouchType.Down) {
          this.isDrawing = true;
          if (this.brushMode === 0) {
            // Brush mode: start a new region
            this.currentPoints = [{ x, y } as Point];
          } else {
            // Box mode: record start
            this.boxStartX = x;
            this.boxStartY = y;
            this.boxEndX = x;
            this.boxEndY = y;
          }
        } else if (event.type === TouchType.Move && this.isDrawing) {
          if (this.brushMode === 0) {
            // Brush mode: add point and draw stroke
            this.currentPoints.push({ x, y } as Point);
            const region: MosaicRegion = {
              id: '',
              points: [{ x, y } as Point],
              brushSize: this.brushSize,
              type: this.effectType === 0 ? 'mosaic' : 'blur',
              mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
            };
            this.drawRegion(region);
          } else {
            // Box mode: update end point
            this.boxEndX = x;
            this.boxEndY = y;
          }
        } else if (event.type === TouchType.Up && this.isDrawing) {
          this.isDrawing = false;
          if (this.brushMode === 0) {
            // Finalize brush region
            if (this.currentPoints.length > 0) {
              const region: MosaicRegion = {
                id: Date.now().toString(),
                points: [...this.currentPoints],
                brushSize: this.brushSize,
                type: this.effectType === 0 ? 'mosaic' : 'blur',
                mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
              };
              this.regions.push(region);
              this.regions = [...this.regions];
              this.currentPoints = [];
            }
          } else {
            // Finalize box region
            const left: number = Math.min(this.boxStartX, this.boxEndX);
            const top: number = Math.min(this.boxStartY, this.boxEndY);
            const width: number = Math.abs(this.boxEndX - this.boxStartX);
            const height: number = Math.abs(this.boxEndY - this.boxStartY);
            if (width > 10 && height > 10) {
              const region: MosaicRegion = {
                id: Date.now().toString(),
                brushSize: this.brushSize,
                rect: { left, top, width, height },
                type: this.effectType === 0 ? 'mosaic' : 'blur',
                mosaicSize: this.effectType === 0 ? this.mosaicSize : undefined
              };
              this.regions.push(region);
              this.regions = [...this.regions];
            }
          }
          // Redraw everything (final render)
          this.redrawAll();
        }
      })
  }
}
