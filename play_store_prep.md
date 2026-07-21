# Play Store Prep

## Listing draft

Short description:
Block distractions. Stay focused. Keep the apps that matter.

Full description:

Focus Mode helps you reclaim time from distracting apps without turning your phone into a punishment device. Choose the apps that pull you away, allow the ones you need, and start a calm focus session when you want to work, study, or rest your attention.

Features:

- Real blocking for selected distracting apps during focus periods
- Allowed app lists for essentials like Phone, WhatsApp, Messages, Email, Maps, and Camera
- Scheduled quiet windows for recurring routines
- Streaks and gentle motivation without shame or guilt
- Usage charts and time-saved tracking
- Strict mode for stronger friction when you are trying to break impulsive habits

## Screenshot suggestions

1. Home screen with the big Start Focus Session button
2. Onboarding app-selection screen
3. Blocking overlay shown on top of a distracting app attempt
4. Stats dashboard with charts and time saved
5. Scheduled block window settings
6. Settings screen with permissions and app lists

## App icon guidance

- App icon: 512 x 512 px
- Feature graphic: 1024 x 500 px
- Keep the visual language calm and uncluttered
- Use soft blues/greens with the purple accent token already in the app

## Signed release build steps

1. Create a keystore with `keytool`.
2. Store the keystore file outside the repo.
3. Add signing values to `android/key.properties` locally.
4. Configure the release signing block in `android/app/build.gradle`.
5. Build an App Bundle with `flutter build appbundle --release`.

## Accessibility policy checklist

- Declare the Accessibility Service in Play Console permissions disclosure.
- Explain that the service is used only for local app blocking.
- State clearly that no user content or sensitive data leaves the device.
- Avoid using accessibility for analytics, ads, or unrelated automation.
- Provide a visible in-app explanation before the permission prompt.
- Link the public privacy policy from the Play listing.
