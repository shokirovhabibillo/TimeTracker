# iOS Screen Time (DeviceActivity) integration — native scaffold notes

Apple does **not** expose per-app usage stats to normal app code the way
Android's `UsageStatsManager` does. To get the iOS equivalent of the
Focus Analytics Engine you need to add, on the native side (Xcode, Swift):

1. Enable the **Family Controls** capability for the app's App ID in the
   Apple Developer portal (requires an approved entitlement request from
   Apple — this can take a few days on first submission).
2. Add a **Device Activity Monitor Extension** target in Xcode
   (`File > New > Target > Device Activity Monitor Extension`).
3. In the extension, implement `DeviceActivityMonitor` callbacks
   (`intervalDidStart`, `intervalDidEnd`, `eventDidReachThreshold`) to
   observe `ApplicationToken`/`CategoryToken` activity, matching the
   categories used by `UsageStatsService` in the Dart code
   (social / games / entertainment / productivity).
4. Use `FamilyActivityPicker` (SwiftUI) so the user can select which
   apps/categories to monitor — Apple does not allow reading the full
   list of installed apps for privacy reasons, unlike Android.
5. Bridge the extension's results back into the Flutter app via a
   `MethodChannel` (e.g. `channel: "com.focuslifetracker/device_activity"`)
   so `UsageStatsService.syncTodayUsage()` can call it on iOS the same
   way it calls the `usage_stats` plugin on Android.

Until this native extension is added, `UsageStatsService.isNativeSupported`
returns `false` on iOS and the Analytics screen shows an explanatory
notice instead of usage data — the rest of the app (planner, focus mode,
notifications, theming) is fully functional on iOS without it.
