# Changelog

All notable changes to this project are documented in this file.

## 0.1.5

* Add grouped pub.dev screenshots for full screen, bottom navigation, and status bar.
* Document that `auto` is the default and needs no extra parameters.

## 0.1.4

* Translucent top/bottom/left/right safe-area colors no longer consume padding, so lists can scroll behind them.
* Read live `FlutterView` insets when MediaQuery is stale after an Android 3-button / gesture overlay swap, and rebuild the tree so layout cannot stay stuck.
* Recommend `android:configChanges` include `assetsPaths` so the Activity is not destroyed when the system navigation overlay changes.

## 0.1.3

* Re-apply edge-to-edge and rebuild insets when the app resumes or window metrics change, so 3-button vs gesture updates after changing navigation in Settings.
* Add `showTopSafeArea` / `showBottomSafeArea` / `showLeftSafeArea` / `showRightSafeArea` to hide inset colors.
* Add `topSafeAreaOpacity` / `bottomSafeAreaOpacity` / `leftSafeAreaOpacity` / `rightSafeAreaOpacity` (`0`–`1`) so inset colors can be transparent.

## 0.1.2

* Add `topSafeAreaColor`, `bottomSafeAreaColor`, `leftSafeAreaColor`, and `rightSafeAreaColor` to paint the system inset regions.

## 0.1.1

* Add `applyOnAndroid` and `applyOnIOS` so you can turn the package off on one platform.
* At least one of those flags must stay `true`. When a platform is disabled, insets, MediaQuery adaptation, and edge-to-edge overlay are skipped there.

## 0.1.0

* Initial release of `flutter_smart_safe_area`.
* Auto-detect Android 3-button navigation vs gesture / iPhone home indicator.
* Inset content (buttons, text, images) only when a 3-button system nav bar is showing.
* Keep background color, image, and gradient edge-to-edge by default.
* `SmartSafeAreaHost` adapts Flutter's own `SafeArea` app-wide.
* `SmartSafeAreaScaffold`, `SmartSystemNavBar`, and `SmartSafeAreaSimulator`.
* Configurable bottom behavior (`auto`, `always`, `never`), letterboxing, extra padding, and keyboard awareness.
* `SmartSafeAreaHost.materialBuilder(then:)` wraps the route child inside the host.
* `SmartSafeAreaScaffold` lifts the floating action button above 3-button system navigation.
