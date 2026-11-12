# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. This is an original project inspired by the survival-card-game genre; all game code, presentation, and story content are original.

## Current implementation

- Procedural 3D blackjack table and 3D card visuals.
- Blackjack rules with ace handling, natural blackjack priority, busts, and dealer resolution.
- Hit, Stand, Double, and Next Hand actions.
- Virtual-chip wager deduction, double-down funding, win/push/loss settlement, and 3:2 natural blackjack payout.
- Survival run with three hearts, five wins to escape, loss tracking, opponent progression, and a one-use 75-chip medkit.
- Three dealer personalities with distinct draw rules: Night Dealer stands on soft 17, Collector hits soft 17, and The House draws through 17 and stands on 18.
- Quaternius Superhero Male humanoid model integrated as a dark dealer silhouette, with a red-eye visual treatment. Original CC0 license notice and asset provenance are included.
- Automated blackjack, survival progression, soft-hand, and opponent AI tests.
- Godot 4.4.1 headless scene smoke test.

## Verification status

- **Core import, gameplay tests, and scene smoke test:** passed in run #18 for commit `f2e4ef1`, before the Quaternius model integration.
- **Android APK export:** earlier attempts exposed missing export templates, Java SDK configuration, and a missing `curl` utility. The workflow now installs the download utilities, matching Godot 4.4.1 templates, and configures Android SDK/JDK paths. The current run is pending verification.
- **APK integrity and arm64 library inspection:** not yet passed.
- **Emulator/physical-device testing:** not yet performed.
- **Quaternius character asset:** source model and CC0 license notice are committed; the integrated scene still needs CI import and runtime verification.

## Development principles

- Godot 4 and GDScript; one shared codebase for Android and desktop.
- Offline single-player first. No real-money wagering, cash-out, or gambling payments.
- Gameplay rules are separated from presentation and covered by automated tests.
- Do not call a release complete until APK integrity, architecture, install/runtime behavior, and device QA are checked.

## Roadmap

- [x] Core blackjack rules and automated tests.
- [x] 3D table, cards, dealing, and player controls.
- [x] Opponent personalities and encounter-specific dealer behavior.
- [x] Initial survival health, win progression, and medkit.
- [ ] Additional tactical items and encounter events.
- [ ] Horror environments, enemy characters, audio, animations, and visual effects.
- [ ] Progression, unlockables, settings, and persistent save data.
- [ ] Android and desktop input adaptation, performance, and accessibility.
- [ ] Android and desktop release builds, emulator/device QA, and release documentation.

## Running locally

Install Godot 4.4.1, import `project.godot`, then run the main scene. To run automated tests:

```sh
godot --headless --path . --script res://tests/run_tests.gd
```

## Android build

GitHub Actions installs the matching Godot 4.4.1 export templates, configures Android SDK/JDK paths, and exports an arm64 debug APK using `export_presets.cfg`. The APK is published as the `Survival21-Android-arm64-debug` artifact only after export and integrity checks pass.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
