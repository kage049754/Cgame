# SURVIVAL 21

A standalone 3D horror-survival blackjack game for Android and desktop, built with Godot 4. This is an original project inspired by the survival-card-game genre; it will use original code, presentation, characters, environments, and licensed assets.

## Current milestone

The repository is being initialized with a playable 3D blackjack prototype: a procedural table, 3D card visuals, player actions, dealer logic, and a virtual-chip match loop. Art assets will be added only when their licenses are verified.

## Development principles

- Godot 4 and GDScript; one shared codebase for Android and desktop.
- Offline single-player first. No real-money wagering, cash-out, or gambling payments.
- Blackjack rules are separated from presentation and covered by automated tests.
- Procedural placeholder meshes keep the first playable build self-contained.
- Android and desktop exports are verified through GitHub Actions before being called releases.

## Roadmap

1. Core blackjack rules and automated tests.
2. 3D table, cards, dealing and player controls.
3. Opponent AI and round progression.
4. Tactical items and survival encounters.
5. Horror environments, characters, audio and animations.
6. Progression, unlockables, settings and save data.
7. Android and desktop input, performance and accessibility.
8. Release builds, QA and documentation.

## Running locally

Install Godot 4.4.1 or a compatible Godot 4.x release, import `project.godot`, then run the main scene.

## License and assets

Project code will use the MIT License unless otherwise stated. Third-party assets retain their own licenses and attribution requirements; see `THIRD_PARTY_ASSETS.md`.