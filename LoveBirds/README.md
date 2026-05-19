# Love Birds

A private Apple Watch app for sending an instant heart to someone you're thinking about. A Lokei product.

This folder contains the Xcode project source. Built around an XcodeGen project descriptor so the `.xcodeproj` is generated from `project.yml` — no fragile checked-in pbxproj.

## What's in here

| Target | What it is |
|---|---|
| `LoveBirds` (iOS) | iPhone companion — pairing, settings, timeline, tip jar |
| `LoveBirdsWatch` (watchOS) | The main attraction. Tap to send a heart. |
| `LoveBirdsWidget` (WidgetKit extension) | Complications, Lock Screen widgets, StandBy, Live Activities |
| `LoveBirdsMessages` (iMessage extension) | Send hearts inside Messages |
| `LoveBirdsKit` (Swift Package) | Shared models, CloudKit sync, haptics, StoreKit, App Intents |

## Setup

You need: macOS, Xcode 15.4+, an Apple Developer team for signing.

```bash
# Once
brew install xcodegen

# In this directory
xcodegen generate
open LoveBirds.xcodeproj
```

Then in Xcode:

1. Select the `LoveBirds` target → **Signing & Capabilities** → choose your Team.
2. Repeat for `LoveBirdsWatch`, `LoveBirdsWidget`, `LoveBirdsMessages`.
3. Change the bundle ID prefix from `com.lokei.lovebirds` to something using your Team's prefix if needed (in `project.yml` then re-run `xcodegen generate`).
4. The default iCloud container is `iCloud.com.lokei.lovebirds` — change to match your bundle ID and create it under **Certificates, Identifiers & Profiles** at developer.apple.com.
5. Build & run `LoveBirdsWatch` on a paired Apple Watch (real device — the simulator doesn't play haptics).

## Universal Links

Pairing invites use `https://getlokei.com/lovebirds/pair?t=...` so that tapping a shared link in Messages opens the app. To enable this you need an `apple-app-site-association` file at `https://getlokei.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "details": [{
      "appIDs": ["TEAMID.com.lokei.lovebirds"],
      "components": [{ "/": "/lovebirds/pair*" }]
    }]
  }
}
```

Replace `TEAMID` with your Apple Developer Team ID. Add the **Associated Domains** capability with `applinks:getlokei.com` to the iOS target. Until that's set up, the in-app QR/`ShareLink` fallback still works.

## Capabilities the project expects

- **iCloud / CloudKit** — for end-to-end encrypted partner sync via shared zones
- **Push Notifications** — for haptic-on-arrival via APNs / CloudKit subscriptions
- **App Groups** — `group.com.lokei.lovebirds` for sharing state between app, watch, widget, iMessage
- **HealthKit** — opt-in heart rate read for "pulse share"
- **Sign in with Apple** — optional, only used when a partner wants the public name of a stranger pairing
- **Background Modes** — Remote notifications, Background processing (for delivering hearts when the receiver's screen is off)

## Architecture

```
LoveBirdsKit  (Swift Package, multi-platform)
   ├─ Models       Heart, Partner, HeartVibe, HapticPattern, Memory
   ├─ Sync         CloudKit shared zones, conflict resolution, subscriptions
   ├─ Store        @Observable HeartStore, PartnerStore (single source of truth)
   ├─ Haptics      AHAP pattern engine + composer primitives
   ├─ StoreKit     Tip jar (consumable IAPs)
   ├─ Intents      App Intents for Shortcuts, Action Button, Siri
   ├─ Notifications  Local + remote routing, quiet hours
   ├─ Health       HealthKit pulse-share live read
   ├─ LiveActivity ActivityKit attributes shared between iOS app and widget
   └─ Util         Streak math, memory-on-this-day, logger

iOS app    →  LoveBirdsKit
Watch app  →  LoveBirdsKit
Widget     →  LoveBirdsKit
Messages   →  LoveBirdsKit
```

State flows one direction: `HeartStore` is the source of truth. Views observe it. Sync updates it. Intents publish to it.

## What's wired up vs what needs hardware tuning

**End-to-end working in code:**
- Tap → send → CloudKit shared zone → push → receiver haptic
- All complication families (Modular, Circular, Corner, Inline)
- iPhone Lock Screen widgets + StandBy
- Live Activity for incoming heart pulses
- iMessage extension with animated hearts
- StoreKit 2 tip jar
- App Intents for Shortcuts + Action Button
- Quiet hours / Focus filter routing
- Local rule-based "smart nudges" ("you haven't tapped in 3 days")
- Streaks + memories-on-this-day
- Family / multi-partner mode

**Scaffolded — compiles, needs polish on real hardware:**
- Custom AHAP haptic composer (basic UI; full timeline editor is its own project)
- HealthKit live pulse share (entitlement + flow are in place; timing needs device tuning)
- Long-distance map (coarse-rounded home-zone; map view stubbed)
- Voice pings (recording infra ready; UX polish needed)
- Apple Intelligence nudges (rule-based now; gated for iOS 18.1+ FoundationModels upgrade)

## Privacy model

There are no Love Birds servers. Sync happens through Apple's CloudKit shared private zones, which are end-to-end encrypted between paired Apple Accounts. The app does not collect analytics, does not embed third-party SDKs, and does not require an account separate from your Apple Account.

See [/privacy.html](../privacy.html) on the marketing site for the long version.

## License

© 2026 Lokei. All rights reserved.
