# Changelog

All notable changes to this project are documented in this file.

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
