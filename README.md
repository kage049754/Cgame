# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. This is an original project inspired by the survival-card-game genre; all game code, presentation, and story content are original.

## Current implementation

- Procedural 3D blackjack table and 3D card visuals.
- Blackjack rules with ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions.
- Virtual-chip wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, loss tracking, opponent progression, and a one-use 75-chip medkit.
- Three dealer personalities with distinct draw rules: Night Dealer stands on soft 17, Collector hits soft 17, and The House draws through 17 and stands on 18.
- Tactical items: Marked Card reveals the dealer's hidden card once per run; House Bell prevents dealer draws for one hand, including after a Double action.
- Encounter events: Restless Dealer forces soft-17 draws, House Favor adds chips on a push, and Blood Toll deducts extra chips after a loss.
- Run-end and empty-chip restart control; completed-round save/load for chips, health, progression, and item counts.
- Quaternius Superhero Male humanoid model integrated as a dark dealer silhouette with red-eye treatment.
- Quaternius Zombie Basic model integrated as an animated background threat, with Idle/Idle_Attack animation switching on encounter events.
- Original CC0 license notices and source provenance included for both models.
- Automated blackjack, survival progression, soft-hand, opponent AI, tactical-item, encounter-event, and save/load tests.
- Godot 4.4.1 headless scene smoke test.

## Verification status

- **Core blackjack, opponent, tactical-item, save/load, and scene tests:** passed in run #26 before encounter-event and zombie-scene integration.
- **Encounter-event rules:** added in commit `637b2f5`; run #28 is testing them.
- **Zombie asset and animation integration:** added in the latest commit; pending scene import and runtime verification.
- **Android APK export:** the project enables ETC2/ASTC texture import and the workflow installs the matching Android SDK, NDK, CMake, and export templates. APK export is pending run #27/#28.
- **APK integrity, package metadata, arm64 library inspection, and device testing:** not yet passed.

[Run #26 gameplay tests](https://github.com/kage049754/Cgame/actions/runs/43212237303)

## Development principles

- Godot 4 and GDScript; one shared codebase for Android and desktop.
- Offline single-player first. No real-money wagering, cash-out, or gambling payments.
- Gameplay rules are separated from presentation and covered by automated tests.
- Do not call a release complete until APK integrity, architecture, install/runtime behavior, and device QA are checked.

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, cards, dealing, and player controls.
- [x] Opponent personalities and encounter-specific dealer behavior.
- [x] Initial survival health, win progression, medkit, and tactical items.
- [x] Completed-round save/load and run restart.
- [x] First encounter events (tests pending).
- [ ] More encounter events and item variety.
- [ ] Horror environments, enemy characters, audio, animations, and visual effects.
- [ ] Progression, unlockables, settings, and save migration.
- [ ] Android and desktop input adaptation, performance, and accessibility.
- [ ] Android and desktop release builds, emulator/device QA, and release documentation.

## Running locally

Install Godot 4.4.1, import `project.godot`, then run the main scene. To run automated tests:

```sh
godot --headless --path . --script res://tests/run_tests.gd
```

## Android build

GitHub Actions installs Godot 4.4.1 export templates, Android Platform 34, Build Tools 34.0.0, NDK 23.2.8568313, CMake 3.10.2.4988404, and Java 17. The project enables ETC2/ASTC texture import. The workflow exports an arm64 debug APK, then checks ZIP integrity, package metadata, and the arm64 native library before uploading the artifact.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
