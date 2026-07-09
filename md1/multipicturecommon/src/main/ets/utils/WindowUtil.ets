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

import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { LogConstants } from '../constants/LogConstants';
import { CommonConstants } from '../constants/CommonConstants';

// Window utility class for managing window state, size, avoid areas, and system bars
@ObservedV2
export class WindowUtil {
  // Main window info with @Trace for deep observation and auto-update tracking
  @Trace public mainWindowInfo: WindowInfo = new WindowInfo();
  public windowStage?: window.WindowStage;
  public uiContext?: UIContext;
  public mainWindow?: window.Window;
  // Callback: triggered when window status changes (fullscreen, split, floating, etc.)
  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    this.mainWindowInfo.windowStatusType = statusType;
  }
  // Callback: triggered when window size changes, updates size and responsive breakpoints
  public onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.mainWindowInfo.windowSize = windowSize;
    if (!this.uiContext) {
      return;
    }
    // Get responsive width/height breakpoints (XS, SM, MD, LG, XL) for adaptive layout
    this.mainWindowInfo.widthBp = this.uiContext.getWindowWidthBreakpoint();
    this.mainWindowInfo.heightBp = this.uiContext.getWindowHeightBreakpoint();
  };
  // Callback: triggered when avoid areas change (status bar, navigation bar, keyboard, cutout, gesture area)
  public onAvoidAreaChange: (avoidOptions: window.AvoidAreaOptions) => void =
    (avoidOptions: window.AvoidAreaOptions) => {
      if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        // System avoid area: status bar area at top of screen
        this.mainWindowInfo.avoidSystem = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_CUTOUT) {
        // Cutout avoid area: camera notch or punch-hole area
        this.mainWindowInfo.avoidCutout = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
        // System gesture area: edge areas reserved for system gestures
        this.mainWindowInfo.avoidSystemGesture = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_KEYBOARD) {
        // Keyboard avoid area: area occupied by virtual keyboard
        this.mainWindowInfo.avoidKeyboard = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // Navigation indicator: bottom navigation bar area
        this.mainWindowInfo.avoidNavigationIndicator = avoidOptions.area;
      }
    };
  // Callback: triggered when title button rect changes (for PC window decorations)
  public onTitleButtonRectChange: (titleButtonRect: window.TitleButtonRect) => void =
    (titleButtonRect: window.TitleButtonRect) => {
      this.mainWindowInfo.titleButtonRect = titleButtonRect;
    };
  // Callback: triggered when free window mode changes (floating window on PC/tablet)
  public onFreeWindowModeChange: (data: boolean) => void = (data: boolean) => {
    this.mainWindowInfo.isFreeWindow = data;
  };

  // Initialize window stage and get main window instance synchronously
  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    try {
      this.mainWindow = this.windowStage.getMainWindowSync();
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to get main window. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Get UIContext for accessing UI-related APIs (breakpoints, px2vp conversion, etc.)
  setUIContext(): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.uiContext = this.mainWindow.getUIContext();
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to get UI context. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Set fullscreen mode: content extends under system bars
  setFullScreen(isFullScreen: boolean): void {
    if (!this.mainWindow) {
      return;
    }
    this.mainWindow.setWindowLayoutFullScreen(isFullScreen)
      .then(() => {
        Logger.info(LogConstants.LOG_TAG_WINDOW_UTIL, 'Succeeded in setting full-screen mode.');
        this.mainWindowInfo.isFullScreen = isFullScreen;
      })
      .catch((err: BusinessError) => {
        Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL,
          'Failed to set full-screen mode. Code: %{public}d, message: %{public}s', err.code.toString(), err.message);
      });
  }

  // Set immersive window decorations for PC: hide default decorations and use custom ones
  setWindowDecorImmersive(): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.setWindowDecorVisible(false);
      this.mainWindow.setWindowDecorHeight(CommonConstants.WINDOW_DECOR_HEIGHT);
      this.mainWindow.setDecorButtonStyle({ buttonIconSize: CommonConstants.DECOR_BUTTON_ICON_SIZE });
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to set window decor immersive. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Set decoration button style (light/dark mode for title bar buttons on PC)
  setDecorButtonStyle(buttonStyle: window.DecorButtonStyle): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.setDecorButtonStyle(buttonStyle);
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to set decor button style. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Set system bar appearance: light/dark icons for status bar and navigation bar
  setSystemBarLightMode(isLight: boolean): void {
    if (!this.mainWindow) {
      return;
    }
    this.mainWindow.setWindowSystemBarProperties({
      statusBarColor: '#00000000',
      navigationBarColor: '#00000000',
      isStatusBarLightIcon: isLight,
      isNavigationBarLightIcon: isLight
    })
      .then(() => {
        Logger.info(LogConstants.LOG_TAG_WINDOW_UTIL, 'Succeeded in setting system bar light mode.');
      })
      .catch((err: BusinessError) => {
        Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL,
          'Failed to set system bar light mode. Code: %{public}d, message: %{public}s', err.code.toString(),
          err.message);
      });
  }

  // Register window size change listener
  addWindowSizeMonitor(addFunction: (windowSize: window.Size) => void): void {
    if (!this.mainWindow) {
      return;
    }
    this.mainWindow.on('windowSizeChange', addFunction);
  }

  // Unregister window size change listener
  removeWindowSizeMonitor(addFunction: (windowSize: window.Size) => void): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.off('windowSizeChange', addFunction);
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to remove window size monitor. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Register avoid area change listener (for keyboard, system bar changes)
  addWindowAvoidMonitor(addFunction: (avoidOptions: window.AvoidAreaOptions) => void): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.on('avoidAreaChange', addFunction);
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL,
        'Failed to monitor window avoid area. Code: %{public}d, message: %{public}s', err.code.toString(), err.message);
    }
  }

  // Set window orientation (portrait, landscape, auto)
  setWindowOrientation(orientation: window.Orientation): void {
    if (!this.mainWindow) {
      return;
    }
    this.mainWindow.setPreferredOrientation(orientation)
      .then(() => {
        Logger.info(LogConstants.LOG_TAG_WINDOW_UTIL, 'Succeeded in setting window orientation.');
        this.mainWindowInfo.orientation = orientation;
      })
      .catch((err: BusinessError) => {
        Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL,
          'Failed to set window orientation. Code: %{public}d, message: %{public}s', err.code.toString(), err.message);
      });
  }

  // Initialize all window info and register all change listeners
  updateWindowInfo(): void {
    if (!this.mainWindow || !this.uiContext) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'mainWindow or uiContext is not initialized.');
      return;
    }
    try {
      // Window status: fullscreen, split-screen, floating, etc.
      this.mainWindowInfo.windowStatusType = this.mainWindow.getWindowStatus();
      this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);

      // Window size and breakpoints
      let width: number = this.mainWindow.getWindowProperties().windowRect.width;
      let height: number = this.mainWindow.getWindowProperties().windowRect.height;
      let windowSize: window.Size = {
        width: width,
        height: height
      }
      this.mainWindowInfo.windowSize = windowSize;
      this.mainWindowInfo.widthBp = this.uiContext.getWindowWidthBreakpoint();
      this.mainWindowInfo.heightBp = this.uiContext.getWindowHeightBreakpoint();
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);

      // Avoid areas: regions that should not be covered by UI content
      this.mainWindowInfo.avoidSystem = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.mainWindowInfo.avoidNavigationIndicator =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.mainWindowInfo.avoidCutout = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
      this.mainWindowInfo.avoidSystemGesture =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
      this.mainWindowInfo.avoidKeyboard = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);

      // Title button rect for PC window title bar buttons
      this.mainWindowInfo.titleButtonRect = this.mainWindow.getTitleButtonRect();
      this.mainWindow.on('windowTitleButtonRectChange', this.onTitleButtonRectChange);

      // Free window mode: whether window is in floating mode
      this.mainWindowInfo.isFreeWindow = this.mainWindow.isInFreeWindowMode();
      this.mainWindow.on('freeWindowModeChange', this.onFreeWindowModeChange);
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to update window info. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  minimize(): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.minimize();
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to minimize the window. Cause: %{public}s',
        JSON.stringify(err));
    }
  }

  // Release all registered listeners when component is destroyed
  release(): void {
    if (!this.mainWindow) {
      return;
    }
    try {
      this.mainWindow.off('windowStatusChange');
      this.mainWindow.off('windowSizeChange');
      this.mainWindow.off('avoidAreaChange');
      this.mainWindow.off('windowTitleButtonRectChange');
      this.mainWindow.off('freeWindowModeChange');
    } catch (err) {
      Logger.error(LogConstants.LOG_TAG_WINDOW_UTIL, 'Failed to release window monitors. Cause: %{public}s',
        JSON.stringify(err));
    }
  }
}

// Window info model: stores all window state with @Trace for reactive updates
@ObservedV2
export class WindowInfo {
  // Current window status type (fullscreen, split, floating, undefined)
  @Trace public windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;
  // Whether window is in fullscreen mode
  @Trace public isFullScreen: boolean = false;
  // Current window orientation
  @Trace public orientation: window.Orientation = window.Orientation.UNSPECIFIED;
  // Window size in pixels
  @Trace public windowSize: window.Size = { width: 0, height: 0 };
  // Responsive width breakpoint (XS/SM/MD/LG/XL) for adaptive layout
  @Trace public widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  // Responsive height breakpoint (SM/MD/LG) for adaptive layout
  @Trace public heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  // System avoid area: status bar region at top
  @Trace public avoidSystem?: window.AvoidArea;
  // Navigation indicator avoid area: bottom navigation bar
  @Trace public avoidNavigationIndicator?: window.AvoidArea;
  // Cutout avoid area: camera notch/punch-hole
  @Trace public avoidCutout?: window.AvoidArea;
  // System gesture avoid area: edge regions for system gestures
  @Trace public avoidSystemGesture?: window.AvoidArea;
  // Keyboard avoid area: virtual keyboard region
  @Trace public avoidKeyboard?: window.AvoidArea;
  // Title button rect: PC window title bar button positions (minimize, maximize, close)
  @Trace public titleButtonRect?: window.TitleButtonRect;
  // Whether in free/floating window mode (PC/tablet)
  @Trace public isFreeWindow?: boolean;
}