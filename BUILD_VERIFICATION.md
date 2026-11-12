# Build and verification record

## Latest verified build

- Workflow: [Survival 21 CI run #45](https://github.com/kage049754/Cgame/actions/runs/43217230158)
- Commit: `ce7a6ae2f358f4c886ecb77791f0fb7bea1bf19f`
- Result: success
- Automated test job: success
- Android and Windows export job: success

## Android debug APK

- Artifact: `Survival21-Android-arm64-debug`
- APK filename: `Survival21.apk`
- APK size: 27,907,641 bytes (about 26.6 MiB)
- SHA-256: `263cc31585e6d39c152329ba0b862960d74c0a4a33498c325123f4ddbd3e95a8`
- Package: `com.kage049754.survival21`
- Version: `0.1.0` (version code 1)
- ABI: `arm64-v8a`
- Android platform / compile SDK: 34
- APK ZIP integrity: passed
- APK signing and signature verification: passed with the CI debug keystore
- Android package metadata: verified using `aapt dump badging`
- Native libraries: `lib/arm64-v8a/libc++_shared.so`, `lib/arm64-v8a/libgodot_android.so`
- Download: [GitHub Actions run #45](https://github.com/kage049754/Cgame/actions/runs/43217230158)

## Windows desktop build

- Artifact: `Survival21-Windows-x86_64-debug`
- Filename: `Survival21.exe`
- Executable size: 96,112,688 bytes (about 91.6 MiB)
- SHA-256: `a2132078ca8f06fbbf376b22578ce64ca80f89da27cf5d1c40766d0c645cdbce`
- Format: PE32+ Windows GUI executable, x86-64
- Game data: embedded PCK
- File type validation: passed
- Download: [GitHub Actions run #45](https://github.com/kage049754/Cgame/actions/runs/43217230158)

## Automated checks

Run #45 passed:
- Project import and required-file checks.
- Blackjack, opponent, survival, encounter-event settlement, and item tests.
- Persistent profile achievement and save migration tests.
- Gamepad button mapping tests (A/B/X/Y, LB/RB, Start).
- Audio settings persistence.
- Procedural ambience and sound-effect generation.
- Quaternius Zombie Basic Idle and Idle_Attack playback.
- Main-scene headless smoke test.
- Android APK export, signature, package ID, ABI, and ZIP checks.
- Windows x86-64 export and PE format check.

## Not yet verified

- Installation and runtime behavior on a physical Android phone.
- Android emulator input, rendering, audio, and lifecycle behavior.
- Windows runtime playtest on a real Windows system.
- Physical gamepad behavior on a real controller.
- Performance, thermal behavior, memory use, and long-session stability.
- Production release signing. The current APK is a debug build and is not a Play Store release.
