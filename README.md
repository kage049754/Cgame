# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. This is an original project inspired by the survival-card-game genre; it will use original code, presentation, characters, environments, and licensed assets.

## Current implementation

- Procedural 3D blackjack table and 3D card visuals.
- Standard blackjack hand evaluation, ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions.
- Virtual chips with wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, loss tracking, opponent stage labels, and a one-use 75-chip medkit.
- Automated rule and survival-progression tests.
- Godot 4.4.1 headless scene smoke test.

## Verification status

- **Godot import and script registration:** passed in GitHub Actions run #10.
- **Automated gameplay tests:** passed in run #10; log reported `All Survival 21 tests passed.`
- **Headless main-scene smoke test:** passed in run #10.
- **Android APK export:** configured in the current workflow; awaiting its first real export result.
- **Emulator/physical-device testing:** not yet performed.
- **Third-party 3D assets:** not yet imported; candidate packs and license notes are tracked in `THIRD_PARTY_ASSETS.md`.

[Run #10 validation](https://github.com/kage049754/Cgame/actions/runs/43209664348)

## Development principles

- Godot 4 and GDScript; one shared codebase for Android and desktop.
- Offline single-player first. No real-money wagering, cash-out, or gambling payments.
- Gameplay rules are separated from presentation and covered by automated tests.
- Procedural placeholder meshes keep the project self-contained until licensed assets are integrated.
- Do not call a release complete until APK integrity, architecture, install/runtime behavior, and device QA are checked.

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, cards, dealing, and player controls.
- [ ] Opponent personalities and encounter-specific behavior.
- [x] Initial survival health, win progression, and medkit.
- [ ] Additional tactical items and encounter events.
- [ ] Horror environments, character models, audio, animations, and visual effects.
- [ ] Progression, unlockables, settings, and persistent save data.
- [ ] Android and desktop input adaptation, performance, and accessibility.
- [ ] Android and desktop release builds, emulator/device QA, and release documentation.

## Running locally

Install Godot 4.4.1, import `project.godot`, then run the main scene. To run the automated tests:

```sh
godot --headless --path . --script res://tests/run_tests.gd
```

## Android build

GitHub Actions exports an arm64 debug APK using the Android preset in `export_presets.cfg`. The APK is published as the `Survival21-Android-arm64-debug` workflow artifact when the export and integrity checks pass.

## License and assets

Project code will use the MIT License unless otherwise stated. Third-party assets retain their own licenses and attribution requirements; see `THIRD_PARTY_ASSETS.md`.
