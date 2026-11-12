# Build and verification record

## Latest verified build

- Workflow: [Survival 21 CI run #44](https://github.com/kage049754/Cgame/actions/runs/43216815391)
- Commit: `9f86d63876d1af1a22f8980affd52e5c46c1ac9c`
- Result: success
- Automated test job: success
- Android and Windows export job: success

## Android debug APK

- Artifact: `Survival21-Android-arm64-debug`
- APK filename: `Survival21.apk`
- APK size: 27,907,474 bytes (about 26.6 MiB)
- Package: `com.kage049754.survival21`
- Version: `0.1.0` (version code 1)
- ABI: `arm64-v8a`
- Android platform / compile SDK: 34
- APK ZIP integrity: passed
- APK signing and signature verification: passed with the CI debug keystore
- Android package metadata: verified using `aapt dump badging`
- Native libraries: `lib/arm64-v8a/libc++_shared.so`, `lib/arm64-v8a/libgodot_android.so`
- Download: [GitHub Actions run #44](https://github.com/kage049754/Cgame/actions/runs/43216815391)

## Windows desktop build

- Artifact: `Survival21-Windows-x86_64-debug`
- Filename: `Survival21.exe`
- Executable size: 96,110,240 bytes (about 91.6 MiB)
- Format: PE32+ Windows GUI executable, x86-64
- Game data: embedded PCK
- File type validation: passed
- Download: [GitHub Actions run #44](https://github.com/kage049754/Cgame/actions/runs/43216815391)

## Automated checks

Run #44 passed:
- Project import and required-file checks.
- Blackjack, opponent, survival, encounter-event settlement, and item tests.
- Persistent profile achievement and save migration tests.
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
- Performance, thermal behavior, memory use, and long-session stability.
- Production release signing. The current APK is a debug build and is not a Play Store release.
