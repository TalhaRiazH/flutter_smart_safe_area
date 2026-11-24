# test_safe_area

Local Android test app for `flutter_smart_safe_area`.

This app is **not** published to pub.dev (`publish_to: none`). It is only in GitHub so you can run it on a real phone.

## Run on Android

1. Enable Developer options and USB debugging on the phone.
2. Plug in the phone (or use wireless debugging).
3. On the phone: **Settings → System → Navigation** and switch between **3-button** and **Gesture**.

```bash
cd test_safe_area
flutter devices
flutter run
```

Leave **Simulate** on `device` to use the phone’s real insets. Use the chips only when you want to fake 3-button / gesture.
