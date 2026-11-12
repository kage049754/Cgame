# Build and verification record

## Latest verified build

- Workflow: [Survival 21 CI run #53](https://github.com/kage049754/Cgame/actions/runs/43219550160)
- Commit: `e2925748a77784bf94d5a4fcbce2f2a75b5f5ff5`
- Result: success
- Automated test job: success
- Android and Windows export job: success

## Android debug APK

- Artifact: `Survival21-Android-arm64-debug`
- APK filename: `Survival21.apk`
- APK size: 27,916,008 bytes (about 26.6 MiB)
- SHA-256: `7fedb0a70dfa5feebb67ffedd3f03e74a56d285031390f0d88cee2e65a356738`
- Package: `com.kage049754.survival21`
- Version: `0.1.0` (version code 1)
- ABI: `arm64-v8a`
- Android platform / compile SDK: 35
- APK ZIP integrity: passed
- APK signing and signature verification: passed with the CI debug keystore
- Android package metadata: verified using `aapt dump badging`
- Native libraries: `lib/arm64-v8a/libc++_shared.so`, `lib/arm64-v8a/libgodot_android.so`
- Download: [GitHub Actions run #53](https://github.com/kage049754/Cgame/actions/runs/43219550160)

## Windows desktop build

- Artifact: `Survival21-Windows-x86_64-debug`
- Filename: `Survival21.exe`
- Executable size: 96,117,872 bytes (about 91.6 MiB)
- SHA-256: `163185fee704937cd68d732bcf26b7256f97b60114d4f9578875edc208d4c8a8`
- Format: PE32+ Windows GUI executable, x86-64
- Game data: embedded PCK
- File type validation: passed
- Download: [GitHub Actions run #53](https://github.com/kage049754/Cgame/actions/runs/43219550160)

## Automated checks

Run #53 passed:
- Project import and required-file checks.
- Blackjack, opponent, survival, encounter-event settlement, and item tests.
- Persistent profile achievement and save migration tests.
- Gamepad button mapping tests (A/B/X/Y, LB/RB, Start).
- Responsive UI scaling tests for landscape, compact-phone, small-viewport, and invalid-size cases.
- Audio settings, UI scale, and high-contrast preference persistence.
- Procedural ambience and sound-effect generation.
- Quaternius Zombie Basic Idle, Idle_Attack, HitReact, Punch, and Death animation playback.
- Main-scene headless smoke test.
- Android APK export, signature, package ID, ABI, and ZIP checks.
- Windows x86-64 export and PE format check.

## Android emulator runtime

- Workflow includes an x86_64 Pixel 2 emulator install/launch, active-activity check, keyboard activation, process-alive check, screenshot, and AndroidRuntime log scan.
- Run #57 installed and launched the app and confirmed its process stayed alive for 20 seconds. It failed afterward because the emulator action executes each script line separately and the multi-line shell `if` was split; this is corrected to a single-line condition. The emulator also reported an ANR in the Android phone service under high CPU pressure, not in the game process.
- Emulator run also collects Android `gfxinfo` frame statistics and `meminfo` process memory after the initial gameplay interaction. Screenshot, accessibility hierarchy, activity dump, performance snapshots, and crash logs are uploaded even when a later assertion fails.

## Not yet verified

- Installation and runtime behavior on a physical Android phone.
- Android emulator input, rendering, audio, and lifecycle behavior.
- TalkBack/screen-reader announcements and focus navigation on Android.
- NVDA/screen-reader behavior on Windows.
- Physical gamepad behavior on a real controller.
- Performance, thermal behavior, memory use, and long-session stability.
- Production release signing. The current APK is a debug build and is not a Play Store release.

## Engine support note

The project still uses Godot 4.7.2 at this build. Godot 4.4 is end-of-life, and the 4.5 series introduced built-in AccessKit-based screen-reader support with accessibility names and descriptions. The next milestone upgrades to the current supported 4.7.2 stable release before implementing screen-reader labels and live status announcements.

## Engine upgrade

- Godot engine and export templates upgraded to 4.7.2 stable.
- Android SDK baseline upgraded to Platform 35, Build Tools 35.0.1, and NDK 28.1.13356709 as required by the Godot 4.7 export documentation.
- AccessKit-based screen-reader integration is available in this engine line; project-level accessible labels and live announcements are the next implementation step.

## Accessibility metadata implementation

- AccessKit labels/descriptions, polite live game-status announcements, and explicit focus navigation are implemented in the UI.
- CI includes a headless accessibility metadata test. This verifies property assignment and focus paths, not the spoken output of TalkBack or NVDA.
- Interactive TalkBack/NVDA validation remains pending.
