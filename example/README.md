# flutter_smart_safe_area example

The smallest app you need. Three steps, no settings — it runs on `auto`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: let the app draw behind the system bars.
  await SmartSafeAreaHost.ensureEdgeToEdge();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Step 2: turn the package on for the whole app.
      builder: SmartSafeAreaHost.materialBuilder(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Step 3: use SmartSafeAreaScaffold instead of Scaffold.
    return SmartSafeAreaScaffold(
      backgroundColor: Colors.blue,
      topSafeAreaColor: Colors.orange,     // optional
      bottomSafeAreaColor: Colors.black,   // optional
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text('My tab bar'),
      ),
      body: const Center(
        child: Text('I never hide under the navigation bar!'),
      ),
    );
  }
}
```

What you will see:

* **3-button phone** — the tab bar moves up above Back / Home / Recents, and the black color fills under them.
* **Gesture phone or iPhone** — the tab bar sits at the very bottom with no empty gap.

The full example in `lib/main.dart` adds a colorful scrolling list.
