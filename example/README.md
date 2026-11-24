# smart_safe_area example

Minimal app-level setup:

```dart
import 'package:flutter/material.dart';
import 'package:smart_safe_area/smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartSafeAreaHost.ensureEdgeToEdge();
  runApp(
    MaterialApp(
      builder: SmartSafeAreaHost.materialBuilder(),
      home: SmartSafeAreaScaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('Content is inset. Background is not.'),
        ),
      ),
    ),
  );
}
```

Run the interactive demo:

```bash
cd example
flutter run
```

Use **Simulate a device** to preview 3-button vs gesture navigation. Toggle
`extendBackground` and `bottomBehavior` to see how backgrounds and content change.
