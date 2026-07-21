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




//I’m checking the workspace shape first so I can anchor the scaffold to the existing files, then I’ll build the app incrementally around the blocking path and validate each slice as I go.



The folder is empty, so I’m treating this as a fresh Flutter app scaffold rather than a modification pass. I’m pulling the project-setup instructions next so I can initialize the right structure instead of improvising the first layout.

Read skill project-setup-info-local

I’ve confirmed there’s no existing code to preserve, so the next discriminating check is whether the Flutter toolchain is already available. If it is, I can scaffold the app directly; if not, I’ll need to adjust the setup plan before editing anything.

flutter --version
dart --version
I’ve got the key constraint now: there’s no Flutter SDK in this environment, so I can still build the project files and native scaffolding, but I can’t run an actual app build here. I’m switching to a stage-1 scaffold that is structured for the real blocking engine, with a clean handoff point for your device testing.

Created 7 todos

I’ve got enough context to make the first real edit now. I’m laying down the Flutter package, the Riverpod state layer, the calm UI shell, and the Play Store docs in one pass so the next step can focus on Android-native blocking instead of scaffolding.

Apply Patch

The first patch is narrowed to the package, persistence, state, and bridge layer so I can validate the foundation before adding the UI screens. That keeps the first failure surface small and makes the next edit easier to isolate.


The foundation is in place. I’m doing a quick diff pass now to catch any syntax-level mistakes before I add the screens and navigation shell on top of it.

git diff -- lib/main.dart lib/app.dart lib/core/providers.dart lib/core/theme/app_theme.dart lib/core/data/sample_apps.dart lib/core/data/motivation_messages.dart lib/core/models/app_models.dart lib/core/services/storage_service.dart lib/core/services/native_platform_service.dart lib/core/services/notification_service.dart lib/core/controllers/settings_controller.dart lib/core/controllers/focus_session_controller.dart README.md privacy_policy.md play_store_prep.md pubspec.yaml analysis_options.yaml
The diff command didn’t have a repo baseline to compare against cleanly, so I’m switching to a cheap workspace sanity check: confirm the files landed and inspect the current tree shape before I add the UI layer.


I have the scaffold files on disk. Before I extend the UI, I’m checking the two spots most likely to break compilation from the first pass: the platform check in the native bridge and the session controller’s timer flow.



I found two real issues in the first foundation pass: one platform check that won’t compile and one controller dependency that was reaching across the Riverpod layer in the wrong direction. I’m tightening those before the UI layer goes in.

The controller no longer needs the raw Ref, so I’m trimming that now. That keeps the session layer cleaner and avoids an analyzer warning before I add the presentation widgets.

Edited
focus_session_controller.dart+1-2
Edited
providers.dart+1-1
I’m adding the visible app now: the onboarding flow, bottom-tab shell, home/stats/settings screens, and the block overlay route. I’m also correcting one quote interpolation bug and making the onboarding transition reactive instead of forcing navigation.

One of the settings callbacks needs a small type shim so it fits Flutter’s onPressed signature cleanly. I’m fixing that before moving on to the Android native layer.

Edited
settings_screen.dart+6-1
I’ve got the screens wired. I’m doing one more narrow sanity pass on the edited Dart files so I can catch any obvious type mismatches before I switch to the Android channel and service stubs.





I found one definite type mismatch in onboarding and a few imports that are only noise. I’m cleaning those now so the tree stays analyzer-friendly before I touch the Android files.

Edited
onboarding_flow.dart+3-2
Edited
settings_screen.dart+0-1
Edited
home_screen.dart+0-1