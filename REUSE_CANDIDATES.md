# Reusable systems and asset research

Reviewed for SURVIVAL 21 on 2026-11-12. Compatibility and license were checked before integrating anything. A repository is not integrated merely because it appears in this list.

| System | Repository/source | License evidence | Decision |
|---|---|---|---|
| Branching dialogue | [Nathan Hoad's Godot Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) | Repository LICENSE is MIT; README supports Godot 3 and 4 | Candidate for future narrative/encounter dialogue. Not integrated; current story fragments are in the in-game archive. |
| Resource-based inventory | [Signal-K/bumbling](https://github.com/Signal-K/bumbling) | Inventory documentation is present, but a root LICENSE file was not found during review | Do not copy code until its license is established. The game uses a small project-owned item system. |
| Full starter template | [Godot 2D Top-Down Template](https://github.com/stesproject/godot-2d-topdown-template) | MIT license, but contains unrelated 2D platform systems and bundled components | Not suitable as a whole-project dependency for this 3D card game. |
| Character models and animations | [Quaternius](https://quaternius.com/) Zombie Apocalypse Kit and Universal Base Characters | Imported source assets preserve CC0 1.0 notices; see `THIRD_PARTY_ASSETS.md` and `assets/licenses/` | Integrated: Superhero Male dealer, Zombie Basic enemy, 4-way street, streetlights, red container, and green container. |
| Additional humanoid animations | [Quaternius Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html) | Official pack page identifies CC0 | Candidate for later humanoid character animation; not imported yet. |

## Reuse policy

Prefer small, maintained, Godot 4-compatible components with an explicit permissive license. Vendor only files actually used, preserve license notices, and adapt the code to the game's architecture. Do not import repositories with missing or unclear licensing or redistribute asset packs as standalone collections.
