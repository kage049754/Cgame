# Third-party assets and licenses

## Imported assets

- **Quaternius Universal Base Characters — Superhero Male (Standard)**: `assets/characters/quaternius_superhero_male.glb`. A modified derivative of the official Standard model, retaining mesh, humanoid skeleton, and skin weights while using a matte material and omitting image payloads. Used as the dealer silhouette. CC0 1.0 Universal; notice: `assets/licenses/QUATERNIUS-CC0-1.0.txt`.
  - Official pack: https://quaternius.com/packs/universalbasecharacters.html
  - Free Standard download: https://quaternius.itch.io/universal-base-characters
  - Source derivative/provenance: https://github.com/programasweights/avatar/blob/main/ASSETS.md

- **Quaternius Zombie Apocalypse Kit — Zombie Basic**: `assets/enemies/quaternius_zombie_basic.gltf`. Embedded-buffer glTF with its atlas and 16 animation clips (including Idle, Idle_Attack, Walk, Run, Punch, HitReact, and Death). Used as an animated background threat beside the blackjack table. Original CC0 1.0 Universal license text is preserved at `assets/licenses/QUATERNIUS-ZOMBIE-APOCALYPSE-CC0.txt`.
  - Official pack: https://quaternius.com/packs/zombieapocalypsekit.html
  - Original pack date: March 2024
  - Source mirror used for the self-contained GLTF and license: https://github.com/ruiguitos/horde-breaker/tree/master/assets/models/quaternius_zombie_apocalypse
  - License: https://creativecommons.org/publicdomain/zero/1.0/

## Additional Quaternius candidates

- **Universal Animation Library** — 120+ retargetable humanoid animations for Godot, Unity, and Unreal. The official page identifies it as CC0 and allows commercial use. https://quaternius.com/packs/universalanimationlibrary.html
- **Zombie Apocalypse Kit environment and vehicles** — street pieces, containers, streetlights, barriers, water tower, and vehicles from the same CC0 pack; not yet imported.

Quaternius' site-wide Quaternius Asset License (QAL) v1.0, updated 2026-08-28, also permits commercial incorporation without attribution but prohibits redistributing assets as standalone asset packs. The two imported model files above retain their source CC0 1.0 license notices and provenance.

## Integration rules

Record the exact pack/version, source page, license, date obtained, and modifications for every imported asset. Prefer glTF/GLB. Do not commit paid-only Source-tier files or redistribute packs separately. Keep assets limited to models actually used by the game.
