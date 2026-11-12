# Reusable systems research

Reviewed for SURVIVAL 21 on 2026-11-12. A repository is not integrated merely because it appears in this list; compatibility and license must be checked first.

| System | Repository/source | License evidence | Decision |
|---|---|---|---|
| Branching dialogue | [Nathan Hoad's Godot Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) | Repository LICENSE is MIT; project README supports Godot 3 and 4 | Candidate for narrative/encounter dialogue milestone. Not integrated yet. |
| Resource-based inventory | [Signal-K/bumbling](https://github.com/Signal-K/bumbling) | Inventory documentation is present, but a root LICENSE file was not found during review | Do not copy code until its license is established. Implement a small project-owned item system instead. |
| Full starter template | [Godot 2D Top-Down Template](https://github.com/stesproject/godot-2d-topdown-template) | MIT license, but contains unrelated 2D platform systems and bundled components | Not suitable as a whole-project dependency for this 3D card game. |
| Character models and animations | [Quaternius packs](https://quaternius.com/) | Specific Zombie Apocalypse, Universal Base Characters, and Universal Animation Library pages identify CC0 | Candidate assets tracked in `THIRD_PARTY_ASSETS.md`; no asset files imported yet. |

## Reuse policy

Prefer small, well-maintained, Godot 4-compatible components with an explicit permissive license. Vendor only the files needed, preserve their license notices, and adapt the code to the game's architecture. Do not import repositories with missing or unclear licensing.
