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
- Quaternius Superhero Male humanoid model integrated as a dark dealer silhouette with red-eye treatment. Original CC0 license notice and provenance are included.
- Automated blackjack, survival progression, soft-hand, opponent AI, and tactical-item tests.
- Godot 4.4.1 headless scene smoke test.

## Verification status

- **Core blackjack, opponent AI, and Quaternius model import:** passed in run #20.
- **Tactical item integration and House Bell interaction:** included in the latest main-branch commit; CI verification is pending.
- **Android APK export:** run #21 installed templates, Java, and a debug keystore, but Android export still reported configuration errors. The logs showed only Build Tools 33.0.2 available; Godot 4.4 requires the Android 34 platform, Build Tools 34.0.0, NDK 23.2.8568313, and CMake 3.10.2.4988404. The workflow now installs those documented SDK components before export.
- **APK integrity, package metadata, and arm64 library inspection:** not yet passed.
- **Emulator/physical-device testing:** not yet performed.

[Run #21 logs](https://github.com/kage049754/Cgame/actions/runs/43211310272)

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
- [ ] More tactical items and encounter events.
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

GitHub Actions installs the Godot 4.4.1 export templates, Android Platform 34, Build Tools 34.0.0, NDK 23.2.8568313, CMake 3.10.2.4988404, and Java 17. It exports an arm64 debug APK, then checks ZIP integrity, package metadata, and the arm64 native library before uploading the artifact.

## License and assets

Project code is MIT licensed. Third-party assets retain their own licenses; see `THIRD_PARTY_ASSETS.md`, `REUSE_CANDIDATES.md`, and `assets/licenses/`.
