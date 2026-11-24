# flutter_smart_safe_area

[![pub package](https://img.shields.io/pub/v/flutter_smart_safe_area.svg)](https://pub.dev/packages/flutter_smart_safe_area)
[![likes](https://img.shields.io/pub/likes/flutter_smart_safe_area)](https://pub.dev/packages/flutter_smart_safe_area/score)
[![pub points](https://img.shields.io/pub/points/flutter_smart_safe_area)](https://pub.dev/packages/flutter_smart_safe_area/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A smarter, drop-in Flutter `SafeArea` for handling **Android 3-button navigation, gesture navigation, and iPhone home indicators** without unwanted bottom gaps.

`flutter_smart_safe_area` keeps your backgrounds edge-to-edge while automatically protecting buttons, text, lists, and other interactive content when a real system navigation bar is present.

## Why flutter_smart_safe_area?

Flutter's standard `SafeArea` treats every bottom system inset the same.

That can lead to:

* unwanted empty space on gesture-navigation devices
* backgrounds stopping above the bottom edge
* buttons sitting underneath Android 3-button navigation
* inconsistent layouts between Android and iOS
* extra platform-specific safe-area code

`flutter_smart_safe_area` detects the navigation mode and applies the correct behavior:

| Device | System navigation | Content | Background |
| --- | --- | --- | --- |
| Android | 3-button | Moves above the system bar | Edge-to-edge |
| Android | Gesture | Stays flush | Edge-to-edge |
| iPhone | Home indicator | Stays flush | Edge-to-edge |
| Desktop / Web | None | No extra inset | Full-bleed |

## Features

* Automatic 3-button vs gesture / home-indicator detection
* Edge-to-edge backgrounds by default; content insets only when needed
* Existing Flutter `SafeArea` widgets pick up the same rules
* App-wide configuration, including sides and keyboard inset
* Smart bottom navigation bar support
* Simulator for desktop and iOS Simulator testing
* Enable Android, iOS, or both (at least one platform is required)

## Installation

```bash
flutter pub add flutter_smart_safe_area
```

## Quick Start

### 1. Enable edge-to-edge

```dart
import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartSafeAreaHost.ensureEdgeToEdge();
  runApp(const MyApp());
}
```

### 2. Wrap your app

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: SmartSafeAreaHost.materialBuilder(),
      home: const HomeScreen(),
    );
  }
}
```

`adaptExistingSafeArea` is on by default, so existing Flutter `SafeArea` widgets follow the same 3-button vs gesture rules.

### 3. Build a screen

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartSafeAreaScaffold(
      backgroundColor: Colors.black,
      backgroundImage: const DecorationImage(
        image: AssetImage('assets/bg.png'),
        fit: BoxFit.cover,
      ),
      body: Column(
        children: [
          const Text('This content stays clear of system navigation.'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('This button lifts only when needed.'),
          ),
        ],
      ),
    );
  }
}
```

## Bottom Safe Area Behavior

| Behavior | 3-button | Gesture |
| --- | --- | --- |
| `auto` (default) | Inset | No inset |
| `always` | Inset | Inset |
| `never` | No inset | No inset |

```dart
SmartSafeAreaHost(
  config: const SmartSafeAreaConfig(
    bottomBehavior: BottomSafeAreaBehavior.auto,
  ),
  child: child,
)
```

## Android and iOS

Both platforms are on by default. Turn one off when you only want the package on the other. At least one must stay enabled.

```dart
SmartSafeAreaHost(
  config: const SmartSafeAreaConfig(
    applyOnAndroid: true,
    applyOnIOS: false, // no-op on iPhone / iPad
  ),
  child: child,
)
```

| Flags | Android | iOS |
| --- | --- | --- |
| `applyOnAndroid: true`, `applyOnIOS: true` (default) | Applied | Applied |
| `applyOnAndroid: true`, `applyOnIOS: false` | Applied | Unchanged |
| `applyOnAndroid: false`, `applyOnIOS: true` | Unchanged | Applied |
| both `false` | Not allowed | Not allowed |

## Inset the Background Too

```dart
SmartSafeAreaScaffold(
  extendBackground: false,
  letterboxColor: Colors.black,
  backgroundColor: Colors.indigo,
  body: YourContent(),
)
```

## Use with an Existing Scaffold

```dart
Scaffold(
  backgroundColor: Colors.black,
  body: SmartSafeArea(child: YourContent()),
)
```

The `Scaffold` background stays full-bleed. `YourContent()` gets the smart inset.

## Smart Bottom Navigation Bar

```dart
bottomNavigationBar: SmartSystemNavBar(
  color: Colors.white,
  child: YourTabRow(),
)
```

On 3-button Android, the bar color can extend behind the system nav while tabs stay above it. `SmartSafeAreaScaffold` does this automatically when you pass `bottomNavigationBar`.

## App-Wide Configuration

```dart
MaterialApp(
  builder: SmartSafeAreaHost.materialBuilder(
    config: const SmartSafeAreaConfig(
      extendBackground: true,
      bottomBehavior: BottomSafeAreaBehavior.auto,
      applyTop: true,
      applyBottom: true,
      applyLeft: true,
      applyRight: true,
      applyOnAndroid: true,
      applyOnIOS: true,
      keyboardAware: false,
      adaptExistingSafeArea: true,
      enableEdgeToEdge: true,
    ),
  ),
)
```

| Option | Purpose |
| --- | --- |
| `extendBackground` | Backgrounds draw into system areas |
| `bottomBehavior` | Bottom inset policy |
| `applyTop` / `applyBottom` / `applyLeft` / `applyRight` | Which sides to inset |
| `applyOnAndroid` / `applyOnIOS` | Which platforms the package applies on (at least one required) |
| `keyboardAware` | Bottom inset is at least the keyboard height |
| `adaptExistingSafeArea` | Flutter `SafeArea` uses the smart inset |
| `enableEdgeToEdge` | Transparent system bars |

## Read Safe Area Values Directly

```dart
final insets = context.smartSafeArea;
final mode = context.systemNavMode;

Padding(
  padding: EdgeInsets.only(bottom: insets.contentBottom),
  child: child,
)
```

## Preview Navigation Modes

```dart
SmartSafeAreaSimulator(
  nav: SimulatedSystemNav.threeButton, // or .gesture, .none, .custom
  child: MyApp(),
)
```

## Navigation Detection

Uses `MediaQuery.viewPadding.bottom`, with a `FlutterView` fallback when Android edge-to-edge reports `padding` as `0`.

| Bottom inset | Detected as | Content |
| --- | --- | --- |
| `>= 40 dp` | 3-button | Inset |
| `> 0` and `< 40 dp` | Gesture / home indicator | Flush |
| `0 dp` | None | No inset |

Override the cutoff with `threeButtonNavThreshold`.

## API Overview

| API | Purpose |
| --- | --- |
| `SmartSafeAreaHost` | App-level config and edge-to-edge setup |
| `SmartSafeAreaScaffold` | Full-screen edge-to-edge scaffold |
| `SmartSafeArea` | Drop-in replacement for Flutter `SafeArea` |
| `SmartSystemNavBar` | Bottom bar aware of system navigation |
| `SmartSafeAreaConfig` | Global defaults |
| `SmartSafeAreaInsets.of` | Calculated inset values |
| `SystemNav` | Detection helpers |
| `SmartSafeAreaSimulator` | Preview 3-button vs gesture |

## Example

```bash
cd example
flutter run
```

## Issues

Report bugs at [TalhaRiazH/flutter_smart_safe_area](https://github.com/TalhaRiazH/flutter_smart_safe_area/issues).

## License

`flutter_smart_safe_area` is available under the [MIT License](LICENSE).

API reference (after publish): [flutter_smart_safe_area](https://pub.dev/documentation/flutter_smart_safe_area/latest/).
