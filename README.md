# Focus Mode

Focus Mode is a calm Android focus blocker built in Flutter. It is designed to block distracting apps during planned focus periods while keeping essential communication available.

## Name ideas

1. Detoxify
2. Unplug
3. Clarity

## What this app does

- Blocks selected distracting apps during focus sessions and scheduled block windows.
- Keeps essential apps available, such as Phone, WhatsApp, Messages, Email, Maps, and Camera.
- Tracks focus time, streaks, and weekly usage patterns.
- Uses a calm, minimal UI with supportive microcopy.

## Tech stack

- Flutter + Dart
- Riverpod for state management
- Hive for local persistence
- `fl_chart` for charts
- `flutter_local_notifications` for reminders and session completion nudges
- Android native channels for Usage Access, Accessibility Service, and overlay control

## Architecture

```text
lib/
  app.dart                    -> app bootstrap and theme selection
  core/
    data/                     -> seeded messages and sample app lists
    models/                   -> app settings, focus plans, schedule windows
    services/                 -> storage, notifications, native bridge
    theme/                    -> calm light/dark theme tokens
  features/
    onboarding/               -> setup and permission flow
    focus_session/            -> session timer and strict mode state
    blocking/                 -> full-screen block UI
    stats/                    -> charts and insights
    settings/                 -> app list, permissions, and preferences
    navigation/               -> bottom-tab shell
```

## Setup

1. Install the Flutter SDK and Android toolchain.
2. Run `flutter pub get`.
3. Launch on a physical Android device.
4. Grant Usage Access, Accessibility, overlay, battery optimization, and notifications when prompted.

## Known limitations

- Android-native blocking is scaffolded here and must be verified on real devices.
- OEM battery optimizers may still require manual exclusion.
- Background scheduling must be tested on each target device family.

## Screenshots

Placeholder section for store screenshots.




