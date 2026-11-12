# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. All game code, presentation, and story content are original.

## Current implementation

- Procedural 3D blackjack table, 3D cards, and support pedestal.
- Post-apocalyptic arena dressing using Quaternius street-intersection, streetlight, and shipping-container models, with warm point lights.
- Blackjack rules with ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions, with keyboard shortcuts, gamepad mappings, and touchscreen buttons.
- Virtual-chip wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, opponent progression, and a one-use 75-chip medkit.
- Three dealer personalities with distinct draw rules: Night Dealer stands on soft 17, Collector hits soft 17, and The House draws through 17 and stands on 18.
- Tactical items: Marked Card reveals the dealer's hidden card once per run; House Bell prevents dealer draws for one hand, including after a Double action.
- Encounter events: Restless Dealer forces soft-17 draws, House Favor rewards pushes, Blood Toll taxes losses, Whispering Table rewards wins, Rust Storm taxes player busts, and Dealer's Debt rewards dealer busts.
- Run-end restart and completed-round save/load for chips, health, progression, and item counts.
- Quaternius Superhero Male as a dark dealer silhouette; Quaternius Zombie Basic as an animated threat with Idle and Idle_Attack playback.
- Original procedural horror ambience and synthesized card, win, loss, and item sound effects.
- In-game audio settings with saved ambience and effects volume sliders.
- Persistent six-entry survival archive with lifetime statistics, lore unlocks, and achievement tracking across runs.
- Save migration from version 1 to version 2, preserving existing run data and filling missing fields.
- Automated blackjack, survival, opponent AI, item, event, save/load, animation, audio, and settings tests.

## Verification status

- **Gameplay, event settlement, opponent AI, progression unlocks, save migration, settings persistence, audio generation, zombie animation playback, and main-scene smoke test:** all passed in [run #44](https://github.com/kage049754/Cgame/actions/runs/43216815391).
- **Android arm64 debug APK:** exported, ZIP-tested, signed with the CI debug keystore, and verified with Android `aapt` in run #44. Package `com.kage049754.survival21`, version `0.1.0`, ABI `arm64-v8a`.
- **Windows x86_64 desktop executable:** exported and verified as PE32+ x86-64 in run #44. The game data is embedded in the executable.
- **Artifact downloads:** available from run #44; see `BUILD_VERIFICATION.md` for sizes and checksums.
- **Physical Android device, emulator, and Windows runtime playtesting:** not yet performed. Automated build and static artifact checks do not prove runtime behavior on those devices.

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, cards, dealing, and player controls.
- [x] Opponent personalities and encounter-specific dealer behavior.
- [x] Survival health, progression, medkit, and tactical items.
- [x] Completed-round save/load and run restart.
- [x] Six encounter events with distinct payout, dealer, and bust modifiers.
- [x] Quaternius dealer, zombie, and environment models; zombie animation playback.
- [x] Procedural horror ambience and core sound effects.
- [x] Keyboard, gamepad, and touchscreen controls; focus order and Escape dismissal.\n- [x] Audio volume settings and persistence.
- [ ] More varied encounter events and enemy behaviors.
- [x] Persistent archive achievements and version 1-to-2 save migration.
- [ ] UI scaling across device aspect ratios, TalkBack/device accessibility checks, and performance profiling.
- [ ] Android and desktop release builds, emulator/device QA, and release documentation.

## Running locally

Install Godot 4.4.1, import `project.godot`, then run the main scene. Automated checks:

```sh
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/zombie_animation_test.gd
godot --headless --path . --script res://tests/audio_generation_test.gd
godot --headless --path . --script res://tests/settings_test.gd
```

## Android build

GitHub Actions installs Godot 4.4.1 export templates, Android Platform 34, Build Tools 34.0.0, NDK 23.2.8568313, CMake 3.10.2.4988404, and Java 17. The project enables ETC2/ASTC texture import. The workflow exports an arm64 debug APK and a Windows x86_64 desktop executable. It checks APK ZIP integrity, package metadata, and native libraries before uploading both artifacts.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
