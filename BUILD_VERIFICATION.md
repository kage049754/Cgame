# Build and verification record

## Latest verified build

- Workflow: [Survival 21 CI run #51](https://github.com/kage049754/Cgame/actions/runs/43218673836)
- Commit: `f79b448de2081f86066e200b93fba7f059d779c4`
- Result: success
- Automated test job: success
- Android and Windows export job: success

## Android debug APK

- Artifact: `Survival21-Android-arm64-debug`
- APK filename: `Survival21.apk`
- APK size: 27,911,737 bytes (about 26.6 MiB)
- SHA-256: `29930c0ae6f2a2c317bd8c3755576cf3ac601e79a3ba9c3051101fc3e2a4d8b1`
- Package: `com.kage049754.survival21`
- Version: `0.1.0` (version code 1)
- ABI: `arm64-v8a`
- Android platform / compile SDK: 34
- APK ZIP integrity: passed
- APK signing and signature verification: passed with the CI debug keystore
- Android package metadata: verified using `aapt dump badging`
- Native libraries: `lib/arm64-v8a/libc++_shared.so`, `lib/arm64-v8a/libgodot_android.so`
- Download: [GitHub Actions run #51](https://github.com/kage049754/Cgame/actions/runs/43218673836)

## Windows desktop build

- Artifact: `Survival21-Windows-x86_64-debug`
- Filename: `Survival21.exe`
- Executable size: 96,115,952 bytes (about 91.6 MiB)
- SHA-256: `a855bc6cfc9f8f150d7a1698db35776191b4df01747426e9ec6e867f9665f50e`
- Format: PE32+ Windows GUI executable, x86-64
- Game data: embedded PCK
- File type validation: passed
- Download: [GitHub Actions run #51](https://github.com/kage049754/Cgame/actions/runs/43218673836)

## Automated checks

Run #51 passed:
- Project import and required-file checks.
- Blackjack, opponent, survival, encounter-event settlement, and item tests.
- Persistent profile achievement and save migration tests.
- Gamepad button mapping tests (A/B/X/Y, LB/RB, Start).
- Audio settings, UI scale, and high-contrast preference persistence.
- Procedural ambience and sound-effect generation.
- Quaternius Zombie Basic Idle, Idle_Attack, HitReact, Punch, and Death animation playback.
- Main-scene headless smoke test.
- Android APK export, signature, package ID, ABI, and ZIP checks.
- Windows x86-64 export and PE format check.

## Not yet verified

- Installation and runtime behavior on a physical Android phone.
- Android emulator input, rendering, audio, and lifecycle behavior.
- Responsive layout across portrait, landscape, and unusual aspect ratios.
- TalkBack/screen-reader behavior and accessibility on a real device.
- Windows runtime playtest on a real Windows system.
- Physical gamepad behavior on a real controller.
- Performance, thermal behavior, memory use, and long-session stability.
- Production release signing. The current APK is a debug build and is not a Play Store release.
