# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. All game code, presentation, and story content are original.

## Current implementation

- Procedural 3D blackjack table, detailed 3D cards with corner indices, central suit glyphs, a gold-emblem card back, and staggered dealing animations.
- Post-apocalyptic arena dressing using Quaternius street-intersection, streetlight, and shipping-container models, with warm point lights.
- Blackjack rules with ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions, with keyboard shortcuts, gamepad mappings, and touchscreen buttons.
- Virtual-chip wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, opponent progression, and a one-use 75-chip medkit.
- Selectable starting opponents: choose any unlocked House personality for the next run; Collector and The House unlock by defeating them. A selected Collector escalates to The House after two wins.\n- Three dealer personalities with distinct draw rules and separate visual treatments: red-eyed Night Dealer, teal Collector, and gold-eyed metallic House. Night Dealer stands on soft 17, Collector hits soft 17, and The House draws through 17 and stands on 18.
- Tactical items: Marked Card reveals the dealer's hidden card once per run; House Bell prevents dealer draws for one hand, including after a Double action.
- Encounter events: Restless Dealer forces soft-17 draws, House Favor rewards pushes, Blood Toll taxes losses, Whispering Table rewards wins, Rust Storm taxes player busts, and Dealer's Debt rewards dealer busts.
- Run-end restart and completed-round save/load for chips, health, progression, and item counts.
- Quaternius Superhero Male as a dark dealer silhouette; Quaternius Zombie Basic reacts to encounter events and round outcomes with Idle, Idle_Attack, HitReact, Punch, and Death animations; its threat level changes its position as it approaches or retreats from the table.
- Original procedural horror ambience, looping dark ambient background music, and synthesized card, win, loss, and item sound effects; separate ambience, music, and effects volume controls.
- In-game settings for ambience/music/effects volume, UI scaling (80%–130%), selectable starting opponents, and high-contrast text; preferences persist. Godot 4.7.2 AccessKit support adds accessible names, descriptions, focus order, and polite live game-status announcements.
- Persistent six-entry survival archive with lifetime statistics, lore unlocks, and achievement tracking across runs.
- Save migration from versions 1 and 2 to version 3, preserving existing run data and adding the selected starting opponent.
- Automated blackjack, survival, opponent AI, item, event, save/load, animation, audio, and settings tests.

## Verification status

- **Gameplay, event settlement, opponent AI, progression unlocks, save migration, gamepad mappings, audio/settings, UI scale and high-contrast settings, responsive viewport scaling, reactive zombie animations, and main-scene smoke test:** passed in [run #53](https://github.com/kage049754/Cgame/actions/runs/43219550160).
- **Android arm64 debug APK:** exported, ZIP-tested, signed with the CI debug keystore, and verified with Android `aapt` in run #53. Package `com.kage049754.survival21`, version `0.1.0`, ABI `arm64-v8a`.
- **Windows x86_64 desktop executable:** exported and verified as PE32+ x86-64 in run #53. The game data is embedded in the executable.
- **Artifact downloads:** available from run #53; see `BUILD_VERIFICATION.md` for sizes and checksums.
- **Physical Android device, emulator, Windows runtime, and real gamepad playtesting:** not yet performed. Automated build and static artifact checks do not prove runtime behavior on those devices.

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, detailed procedural card faces/backs, dealing, and player controls.
- [x] Opponent personalities, selectable unlocked starting Houses, unique dealer appearances, and encounter-specific dealer behavior.
- [x] Survival health, progression, medkit, and tactical items.
- [x] Completed-round save/load and run restart.
- [x] Six encounter events with distinct payout, dealer, and bust modifiers; outcome-reactive zombie animation playback tests.
- [x] Quaternius dealer, zombie, and environment models.
- [x] Procedural horror ambience and core sound effects.
- [x] Keyboard, gamepad, and touchscreen controls; focus order and Escape dismissal.
- [x] Audio volume settings and persistence.
- [x] Outcome-reactive zombie animations and threat-level approach/retreat behavior, covered by tests.
- [x] Persistent archive achievements and version 1-to-2 save migration.
- [x] Responsive UI fit scaling and viewport resize handling, covered by layout tests.\n- [x] Add AccessKit labels/descriptions to gameplay and settings controls, logical keyboard focus order, and polite live game-status announcements; CI metadata test added.\n- [ ] Verify TalkBack/screen-reader behavior on physical Android, NVDA on Windows, performance, and physical-device input.
- [x] Upgrade to Godot 4.7.2 to enable AccessKit-based screen-reader support; add accessible names, descriptions, and live announcements, then verify TalkBack/NVDA.
- [ ] Performance profiling, physical-device QA, production signing, and release packaging.

## Running locally

Install Godot 4.7.2, import `project.godot`, then run the main scene. Automated checks:

```sh
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/zombie_animation_test.gd
godot --headless --path . --script res://tests/audio_generation_test.gd
godot --headless --path . --script res://tests/settings_test.gd
```

## Android build

GitHub Actions installs Godot 4.7.2 export templates, Android Platform 35, Build Tools 35.0.1, NDK 28.1.13356709, CMake 3.10.2.4988404, and Java 17. The project enables ETC2/ASTC texture import. The workflow exports an arm64 debug APK for phones, an x86_64 Android APK for emulator smoke tests, and a Windows x86_64 desktop executable. The workflow installs and launches the x86_64 APK on a Pixel 2 Android emulator, sends a keyboard activation to the focused game control, verifies the app process/activity remains alive, captures a screenshot and Android accessibility hierarchy, records Android frame and memory snapshots, and stores runtime logs as evidence. It checks APK ZIP integrity, package metadata, and native libraries before uploading both artifacts.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
