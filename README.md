# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. All game code, presentation, and story content are original.

## Current implementation

- Procedural 3D blackjack table, 3D cards, and a support pedestal.
- Post-apocalyptic arena dressing using Quaternius street-intersection, streetlight, and shipping-container models, with warm point lights.
- Blackjack rules with ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions.
- Virtual-chip wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, opponent progression, and a one-use 75-chip medkit.
- Three dealer personalities with distinct draw rules: Night Dealer stands on soft 17, Collector hits soft 17, and The House draws through 17 and stands on 18.
- Tactical items: Marked Card reveals the dealer's hidden card once per run; House Bell prevents dealer draws for one hand, including after a Double action.
- Encounter events: Restless Dealer forces soft-17 draws, House Favor adds chips on a push, and Blood Toll deducts extra chips after a loss.
- Run-end restart and completed-round save/load for chips, health, progression, and item counts.
- Quaternius Superhero Male as a dark dealer silhouette with red-eye treatment.
- Quaternius Zombie Basic as an animated threat, with Idle and Idle_Attack playback verified in CI.
- CC0 license notices and source provenance for all imported Quaternius models.
- Automated blackjack, survival, opponent AI, item, encounter-event, save/load, and zombie animation tests.

## Verification status

- **Gameplay, item, save/load, and encounter-event tests:** passed in run #28.
- **Zombie Basic scene import and main-scene smoke test:** passed in run #29.
- **Zombie Idle and Idle_Attack animation playback:** passed in run #30.
- **Android arm64 APK export:** passed in run #29 for commit `493bd5f`; APK integrity, package identifier, and arm64 libraries verified. The APK from that run does not yet include the environment prop additions below.
- **Latest environment props:** added after run #29; awaiting the next scene import and Android build.
- **Emulator/physical-device testing:** not yet performed.

[Run #29 Android APK](https://github.com/kage049754/Cgame/actions/runs/43213052304)

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, cards, dealing, and player controls.
- [x] Opponent personalities and encounter-specific dealer behavior.
- [x] Survival health, progression, medkit, and tactical items.
- [x] Completed-round save/load and run restart.
- [x] Initial encounter events.
- [x] Quaternius dealer, zombie, and environment models; zombie animation playback.
- [ ] More varied encounter events and enemy behaviors.
- [ ] Audio, music, ambient effects, and polished animations.
- [ ] Progression, unlockables, settings, and save migration.
- [ ] Android and desktop input adaptation, performance, and accessibility.
- [ ] Android and desktop release builds, emulator/device QA, and release documentation.

## Running locally

Install Godot 4.4.1, import `project.godot`, then run the main scene. To run automated tests:

```sh
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/zombie_animation_test.gd
```

## Android build

GitHub Actions installs Godot 4.4.1 export templates, Android Platform 34, Build Tools 34.0.0, NDK 23.2.8568313, CMake 3.10.2.4988404, and Java 17. It enables ETC2/ASTC texture import and exports an arm64 debug APK. The workflow verifies ZIP integrity, package metadata, and native libraries before uploading the artifact.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
