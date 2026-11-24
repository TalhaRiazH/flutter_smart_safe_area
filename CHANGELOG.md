# Changelog

All notable changes to this project are documented in this file.

## 0.1.11

* Show the README screenshots from public image links.

## 0.1.10

* List Talha Riaz as the package author.

## 0.1.9

* Apply status-bar and bottom-inset colors from `SmartSafeAreaHost` to every screen.
* A `SmartSafeAreaScaffold` replaces those colors and that screen's bottom inset only while the screen is visible.
* Material `BottomNavigationBar` follows `auto` from the host, without wrapping each page.

## 0.1.8

* Stop replacing the navigator when the system inset changes, so routes and screen state stay put.
* Drop the bottom inset while the keyboard is open, so it is not stacked above the keyboard.
* Apply a bottom-bar inset once. Material `BottomNavigationBar` and `NavigationBar` no longer get a second copy.
* Trust a live inset of 0 when the status bar shows the view metrics are real, so a switch away from 3-button navigation can clear a stale inset.
* On a disabled platform, keep Flutter's normal padding instead of removing every side.
* Correct the README: a normal `Scaffold` updates `SafeArea` and `ListView`. Bottom bars belong in `SmartSafeAreaScaffold`.

## 0.1.7

* Document that a normal `Scaffold` is enough after `SmartSafeAreaHost`. `SmartSafeAreaScaffold` is only for extra options such as colors and opacity.
* Put a large “handles safe areas automatically” heading and the screenshots in the README body.

## 0.1.6

* Rewrite the README in plain language: 3-step setup, copy-paste recipes, and a parameter table with defaults.
* Simplify the example app to a commented list + tab bar on `auto`.

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
