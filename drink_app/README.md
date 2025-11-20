# drink_app (Drink Reminder)

Minimal Drink Reminder app skeleton. This project currently keeps the
default counter example UI so tests remain valid while giving the app a
clear name and a place to grow into a full reminder application.

## How to run

1. Ensure you have Flutter installed: https://flutter.dev/docs/get-started/install
2. From the project root run:

```powershell
cd .\drink_app
flutter pub get
flutter run
```

## Notes

- The app title and theme were updated to "Drink Reminder".
- Tests still pass against the example counter UI. Replace the home
	widget when adding reminder/scheduling features; update tests accordingly.

If you want, I can scaffold a reminders model, local persistence, and
notification wiring (requires adding platform plugins) as the next step.
