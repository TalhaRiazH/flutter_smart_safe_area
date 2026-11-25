# Real-world example

A production app on Android with 3-button navigation.

**Without smart safe area** — the bottom bar and Play button sit under the system buttons.

![Without smart safe area. App bottom bar overlaps Android 3-button navigation.](https://raw.githubusercontent.com/TalhaRiazH/flutter_smart_safe_area_images/main/screenshots/real_example_before.jpg)

**With flutter_smart_safe_area** — the bottom bar lifts above Back, Home, and Recents.

![With flutter_smart_safe_area. App bottom bar clears Android 3-button navigation.](https://raw.githubusercontent.com/TalhaRiazH/flutter_smart_safe_area_images/main/screenshots/real_example_after.jpg)

# It handles safe areas automatically

You do not set it up screen by screen. It handles the safe area on its own.

**Full screen.** On 3-button phones the content and tab bar move up. On gesture phones and iPhone they stay flush.

![Full screen. 3-button lifts content. Gesture stays flush.](https://raw.githubusercontent.com/TalhaRiazH/flutter_smart_safe_area_images/main/screenshots/group_full.jpg)

**Bottom navigation.** The tab bar moves only when the phone has 3 buttons. A see-through color lets the list scroll behind it.

![Bottom navigation. 3-button, gesture, and scroll behind.](https://raw.githubusercontent.com/TalhaRiazH/flutter_smart_safe_area_images/main/screenshots/group_bottom_nav.jpg)

**Status bar.** Color the area behind the clock, or keep content below it.

![Status bar. List behind the clock, or content kept below it.](https://raw.githubusercontent.com/TalhaRiazH/flutter_smart_safe_area_images/main/screenshots/group_status_bar.jpg)

[![pub package](https://img.shields.io/pub/v/flutter_smart_safe_area.svg)](https://pub.dev/packages/flutter_smart_safe_area)
[![likes](https://img.shields.io/pub/likes/flutter_smart_safe_area)](https://pub.dev/packages/flutter_smart_safe_area/score)
[![pub points](https://img.shields.io/pub/points/flutter_smart_safe_area)](https://pub.dev/packages/flutter_smart_safe_area/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Your buttons never hide under the phone's navigation bar. Your background still fills the whole screen. You write almost no code.**

## What problem does this solve?

Phones have two kinds of bottom navigation:

* **3-button navigation** — Back, Home, and Recents buttons at the bottom of the screen.
* **Gesture navigation** — just a thin line at the bottom (Android gestures and iPhone).

Flutter's normal `SafeArea` treats both the same way. So you either get buttons hidden under the 3 buttons, or an ugly empty gap above the thin line.

This package **looks at the phone and decides for you**:

| The phone has… | Your buttons and text | Your background |
| --- | --- | --- |
| 3 buttons (Back / Home / Recents) | Move up, above the buttons | Fills the whole screen |
| A thin gesture line | Stay at the bottom, no gap | Fills the whole screen |
| iPhone home indicator | Stay at the bottom, no gap | Fills the whole screen |

## It is automatic

The default mode is **`auto`**. You do **not** need to set any parameters, and you do **not** need to replace your `Scaffold`. Add the package, do the two steps below, and it works.

---

## Setup in 2 steps

### Step 1 — Add the package

Run this in your project folder:

```bash
flutter pub add flutter_smart_safe_area
```

### Step 2 — Turn it on in `main.dart`

Copy this whole file. The two lines marked **NEW** are the only changes from a normal Flutter app.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartSafeAreaHost.ensureEdgeToEdge(); // NEW
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: SmartSafeAreaHost.materialBuilder(), // NEW
      home: const HomeScreen(),
    );
  }
}
```

### Set colors once for the whole app

Put the status-bar and bottom-inset colors on the host. Every screen uses them. You do not wrap each page.

```dart
MaterialApp(
  builder: SmartSafeAreaHost.materialBuilder(
    config: const SmartSafeAreaConfig(
      topSafeAreaColor: Colors.orange,
      topSafeAreaOpacity: 0.45,
      bottomSafeAreaColor: Color(0xFF12263A),
      bottomSafeAreaOpacity: 0.72,
    ),
  ),
  home: const HomeScreen(),
)
```

`bottomSafeAreaColor` paints the strip behind the 3 system buttons. Give your tab bar that same color and they look like one bar. On a gesture phone that strip stays hidden.

### One screen can be different

Use `SmartSafeAreaScaffold` only on the screen that should break the app-wide style. The other screens stay on the host config.

```dart
SmartSafeAreaScaffold(
  topSafeAreaColor: Colors.green, // this screen only
  body: const Text('This page has its own status-bar color.'),
)
```

When you leave that screen, the app-wide colors come back.

**That's it for content that already reads the safe area.** Keep your normal `Scaffold`. You do not wrap every screen with `SmartSafeAreaScaffold`.

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: ListView(
        children: const [
          Text('This list already follows auto.'),
        ],
      ),
    );
  }
}
```

After Step 2, these follow `auto` on every screen:

* Flutter's `SafeArea`
* a `ListView` that does not set its own `padding`
* Material 3 `NavigationBar`
* Material `BottomNavigationBar`

A custom tab bar does **not** follow `auto` by itself. `Scaffold` pins it to the bottom edge. Put that bar in `SmartSafeAreaScaffold`, or wrap the bar with `SmartSystemNavBar`.

### Optional — `SmartSafeAreaScaffold` for one screen

Set colors on the host when every screen should look the same. Use `SmartSafeAreaScaffold` when **one screen** should look different, or when you want the background to stay inside the safe area too (`extendBackground: false`).

```dart
SmartSafeAreaScaffold(
  backgroundColor: Colors.blue,
  topSafeAreaColor: Colors.orange,   // extra: color behind the clock
  bottomSafeAreaColor: Colors.black, // extra: color behind the 3 buttons
  body: const Center(
    child: Text('I never hide under the navigation bar!'),
  ),
)
```

You do not put this on every screen. This screen uses its own colors and bottom behavior. Every other screen keeps the host settings.

### Android only: one extra line (recommended)

When someone switches between 3-button and gesture in phone Settings, Android can restart your screen. To stop that, open `android/app/src/main/AndroidManifest.xml`, find `android:configChanges` on your `<activity>`, and add `|assetsPaths` to the end:

```xml
android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode|assetsPaths"
```

---

## Common recipes

Use these when you want a bottom bar, colors, or another extra option.

### Add a bottom tab bar

Pass the bar to `bottomNavigationBar`. This is the right place for a custom tab bar and for Material `BottomNavigationBar`. On 3-button phones the bar moves up once, and its color fills under the system buttons. On gesture phones it stays flush.

```dart
SmartSafeAreaScaffold(
  backgroundColor: Colors.blue,
  bottomNavigationBar: MyTabBar(),
  body: MyContent(),
)
```

### Color the top and bottom areas

```dart
SmartSafeAreaScaffold(
  backgroundColor: Colors.blue,
  topSafeAreaColor: Colors.orange,    // area behind the clock and battery
  bottomSafeAreaColor: Colors.black,  // area behind the 3 buttons
  body: MyContent(),
)
```

### Make those colors see-through

Opacity goes from `0` (invisible) to `1` (solid). Anything below `1` lets your list scroll **behind** the color.

```dart
SmartSafeAreaScaffold(
  backgroundColor: Colors.blue,
  topSafeAreaColor: Colors.orange,
  topSafeAreaOpacity: 0.5,      // half see-through
  bottomSafeAreaColor: Colors.black,
  bottomSafeAreaOpacity: 0.7,
  body: MyContent(),
)
```

### Hide a color without deleting it

```dart
SmartSafeAreaScaffold(
  topSafeAreaColor: Colors.orange,
  showTopSafeArea: false,       // orange is turned off
  body: MyContent(),
)
```

### Keep the background out of the system areas too

By default the background fills the whole screen. Set this to `false` if you want the background to stop at the safe area as well:

```dart
SmartSafeAreaScaffold(
  extendBackground: false,
  letterboxColor: Colors.black, // color of the empty strips
  backgroundColor: Colors.blue,
  body: MyContent(),
)
```

In this mode the whole screen, background included, always stays clear of the bottom bar.

### One widget that does not move by itself

A plain `Center` or `Text` does not read the safe area. Wrap that one widget, not the whole `Scaffold`:

```dart
Scaffold(
  body: SmartSafeArea(
    child: Center(child: Text('This one needs a wrap.')),
  ),
)
```

A `ListView`, a `bottomNavigationBar`, and Flutter's `SafeArea` already read it, so leave those as they are.

### Use it only on Android (or only on iPhone)

Both are on by default. At least one must stay `true`.

```dart
MaterialApp(
  builder: SmartSafeAreaHost.materialBuilder(
    config: const SmartSafeAreaConfig(
      applyOnAndroid: true,
      applyOnIOS: false, // iPhone is left untouched
    ),
  ),
  home: const HomeScreen(),
)
```

### Set colors once for the whole app

Put settings in `SmartSafeAreaConfig` and every screen uses them:

```dart
MaterialApp(
  builder: SmartSafeAreaHost.materialBuilder(
    config: const SmartSafeAreaConfig(
      topSafeAreaColor: Colors.orange,
      topSafeAreaOpacity: 0.5,
    ),
  ),
  home: const HomeScreen(),
)
```

Any screen can still override a value by passing it to `SmartSafeAreaScaffold`.

---

## Bottom behavior: `auto`, `always`, `never`

You almost never need to change this. `auto` is the default.

| Setting | 3-button phone | Gesture phone / iPhone |
| --- | --- | --- |
| `auto` (default) | Content moves up | Content stays at the bottom |
| `always` | Content moves up | Content moves up |
| `never` | Content stays at the bottom | Content stays at the bottom |

Only change it if you have a special reason:

```dart
SmartSafeAreaScaffold(
  bottomBehavior: BottomSafeAreaBehavior.always,
  body: MyContent(),
)
```

---

## All parameters

Every parameter is **optional**. The "Default" column shows what you get if you leave it out.

### Main parameters

| Parameter | Default | What it does |
| --- | --- | --- |
| `bottomBehavior` | `auto` | When content moves up from the bottom. See the table above. |
| `extendBackground` | `true` | `true`: background fills the whole screen. `false`: background stops at the safe area too. |
| `letterboxColor` | background color | Color of the empty strips when `extendBackground` is `false`. |
| `applyOnAndroid` | `true` | Turn the package on or off for Android. |
| `applyOnIOS` | `true` | Turn the package on or off for iPhone and iPad. |

### Colors for the system areas

Replace `top` with `bottom`, `left`, or `right` for the other sides.

| Parameter | Default | What it does |
| --- | --- | --- |
| `topSafeAreaColor` | none | Paints the area behind the clock and battery. |
| `topSafeAreaOpacity` | `1` | `0` = invisible, `1` = solid. Below `1`, the list scrolls behind it. |
| `showTopSafeArea` | `true` | `false` turns the color off without removing it. |

### Which sides to protect

| Parameter | Default | What it does |
| --- | --- | --- |
| `applyTop` | `true` | Keep content below the status bar. |
| `applyBottom` | `true` | Keep content above the navigation bar (follows `bottomBehavior`). |
| `applyLeft` / `applyRight` | `true` | Keep content away from side notches in landscape. |

On `SmartSafeAreaScaffold` and `SmartSafeArea`, these are called `top`, `bottom`, `left`, and `right`.

### Advanced (you usually don't need these)

| Parameter | Default | What it does |
| --- | --- | --- |
| `keyboardAware` | `false` | Content moves up above the keyboard. |
| `minimum` | `EdgeInsets.zero` | Smallest space to keep on each side. |
| `extraPadding` | `EdgeInsets.zero` | Extra space added on top of the safe area. Called `extra` on widgets. |
| `threeButtonNavThreshold` | `40` | Bottom size (in dp) that counts as 3-button navigation. |
| `adaptExistingSafeArea` | `true` | Makes Flutter's normal `SafeArea` follow the smart rules. |
| `enableEdgeToEdge` | `true` | Makes the system bars transparent so the background can show behind them. |

---

## Extra tools

### Test 3-button vs gesture without a real phone

Wrap your app to pretend it is a 3-button or gesture phone. Handy on the iOS Simulator or desktop.

```dart
SmartSafeAreaSimulator(
  nav: SimulatedSystemNav.threeButton, // or .gesture, .none
  child: MyApp(),
)
```

### Read the numbers yourself

```dart
final insets = context.smartSafeArea;   // the calculated spaces
final mode = context.systemNavMode;     // threeButton, gesture, or none

Padding(
  padding: EdgeInsets.only(bottom: insets.contentBottom),
  child: MyWidget(),
)
```

### How it decides

It measures the space at the bottom of the screen:

| Bottom space | It thinks the phone has… | Content moves up? |
| --- | --- | --- |
| 40 dp or more | 3 buttons | Yes |
| More than 0, less than 40 dp | Gesture line / iPhone | No |
| 0 | Nothing | No |

When the user changes navigation in phone Settings and comes back to your app, it checks again automatically.

---

## Widgets in this package

| Widget | Use it for |
| --- | --- |
| `SmartSafeAreaHost` | Turn the package on once for the whole app (Step 2). |
| `SmartSafeAreaScaffold` | A bottom bar, safe-area colors, or other extra options. |
| `SmartSafeArea` | A smarter replacement for Flutter's `SafeArea`. |
| `SmartSystemNavBar` | A bottom bar that fills under the 3 buttons. Added for you by `SmartSafeAreaScaffold`. |
| `SmartSafeAreaConfig` | App-wide settings. |
| `SmartSafeAreaSimulator` | Pretend to be a 3-button or gesture phone while testing. |

## Author

Talha Riaz  
[LinkedIn](https://www.linkedin.com/in/talha-riaz-7a21a8219/)

## License

MIT. See [LICENSE](LICENSE).

Full API reference: [pub.dev documentation](https://pub.dev/documentation/flutter_smart_safe_area/latest/).
