# Third-party assets and licenses

## Imported assets

- **Quaternius Universal Base Characters — Superhero Male (Standard)**: `assets/characters/quaternius_superhero_male.glb`. Modified derivative retaining mesh, humanoid skeleton, and skin weights while using a matte material and omitting image payloads. Used as the dealer silhouette. CC0 1.0 Universal; notice: `assets/licenses/QUATERNIUS-CC0-1.0.txt`.
  - Official pack: https://quaternius.com/packs/universalbasecharacters.html
  - Source derivative/provenance: https://github.com/programasweights/avatar/blob/main/ASSETS.md

- **Quaternius Zombie Apocalypse Kit — Zombie Basic**: `assets/enemies/quaternius_zombie_basic.gltf`. Embedded-buffer GLTF with atlas and 16 animation clips; used as the animated threat. CC0 1.0 Universal; notice: `assets/licenses/QUATERNIUS-ZOMBIE-APOCALYPSE-CC0.txt`.
  - Official pack: https://quaternius.com/packs/zombieapocalypsekit.html
  - Source mirror: https://github.com/ruiguitos/horde-breaker/tree/master/assets/models/quaternius_zombie_apocalypse

- **Quaternius Zombie Apocalypse Kit environment subset**:
  - `assets/environment/street_4way.gltf` — road intersection tile used as the arena floor.
  - `assets/environment/streetlights.gltf` — streetlight props paired with runtime OmniLight3D nodes.
  - `assets/environment/container_red.gltf` and `assets/environment/container_green.gltf` — shipping containers framing the table.
  - These glTF files contain embedded buffers and atlas images. They share the Zombie Apocalypse Kit CC0 1.0 license above.
  - Source mirror: https://github.com/ruiguitos/horde-breaker/tree/master/assets/models/quaternius_zombie_apocalypse/environment

## Additional Quaternius candidates

- **Universal Animation Library** — 120+ retargetable humanoid animations for Godot, Unity, and Unreal. Official page: https://quaternius.com/packs/universalanimationlibrary.html. Not imported yet.
- More Zombie Apocalypse Kit vehicles and environment pieces are available, but only the models used in the current scene are included.

Quaternius' site-wide Quaternius Asset License (QAL) v1.0, updated 2026-08-28, permits commercial incorporation without attribution but prohibits redistributing assets as standalone packs. The specific models above are preserved under their CC0 1.0 license notices and source provenance.

## Integration rules

Record the exact pack/version, source page, license, date obtained, and modifications for every imported asset. Prefer glTF/GLB. Do not commit paid-only Source-tier files or redistribute assets as standalone packs.
