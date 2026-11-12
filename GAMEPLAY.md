# Gameplay systems

## Blackjack round

- Player and dealer receive two cards.
- Player can Hit, Stand, or Double (only on the first two cards and when the additional wager is affordable).
- Dealer behavior depends on the current opponent profile.
- Natural blackjack is resolved before normal player actions; dealer natural blackjack is checked immediately after the opening deal.
- A natural blackjack pays 3:2, ordinary wins pay 1:1, pushes return the stake, and losses forfeit the stake.

## Survival run

- Start with three hearts and 500 virtual chips.
- A loss costs one heart; a win restores one heart up to the maximum.
- Five wins complete the run. Three lost hearts end the run.
- A one-use 75-chip Medkit restores one heart if injured and affordable.

## Opponents

- Night Dealer: stands on soft 17.
- Collector: hits soft 17.
- The House: draws through 17 and stands on 18.

## Tactical items

- Marked Card: one use per run; reveals the dealer's hidden card for the current hand.
- House Bell: one use per run; prevents the dealer from drawing during that hand.
- Items are virtual gameplay effects only; no real-money wagering or payments are present.

## Persistence

- The game saves the last completed round's chips, health, wins/losses/pushes, medkit use, and remaining tactical items to `user://survival21.cfg`.
- A new hand begins when a saved unfinished run is restored. The current hand and deck are not resumed.
- The save is cleared when the player explicitly restarts the run.

## Encounter events

- Quiet Table: no modifier.
- Restless Dealer (every third round): forces the dealer to hit soft 17, except when House Bell is active.
- House Favor (every fourth round): adds 10 virtual chips to a push.
- Blood Toll (every fifth round): removes 10 additional virtual chips after a loss.
- Event cycle continues across completed-round saves.

## Horror character presentation

- The dealer is a darkened Quaternius humanoid model with red eye lights.
- A Quaternius Zombie Basic model idles beside the table. During Restless Dealer rounds it switches to the Idle_Attack clip.
- The zombie GLTF includes the atlas and 16 source animation clips; no separate external texture or animation files are required.

## Audio

- The game synthesizes an original low-frequency ambience loop at runtime.
- Card draw, win, loss, push, and item effects are generated from original oscillator waveforms.
- No third-party music or audio files are bundled.

## Keyboard controls

- H: Hit
- S: Stand
- D: Double
- N: Next hand
- M: Use Marked Card
- B: Use House Bell
- R: Restart after a run ends or chips are depleted

All game buttons are keyboard-focusable and expose tooltips.

## Audio settings

- Ambience volume and sound-effect volume have separate sliders.
- Slider values persist in `user://settings.cfg`.
- Both streams use original synthesized sounds and can be muted independently.

## Persistent archive and progression

- Lifetime profile statistics are stored separately from the current run, so restarting a run does not reset archive progress.
- Six unlocks: complete the first hand, defeat the Collector, defeat The House, escape a run, complete ten hands, and use both tactical items.
- Unlocks reveal short lore entries in the Archive panel; locked entries show their requirement.
- Current run saves migrate from version 1 to version 2 in place. Existing chip, health, win/loss, round, and item data is retained; missing fields receive safe defaults.

## Additional encounter events

- Whispering Table (every sixth round): every win grants 15 extra virtual chips.
- Rust Storm (every seventh round): a player bust costs 15 additional virtual chips.
- Dealer's Debt (every eighth round): beating a dealer who busts grants 20 extra virtual chips.
- Existing event priority is preserved when round intervals overlap.

## Gamepad and mobile input

- Touchscreen users can activate the large on-screen action buttons.
- Gamepad: A Hit, B Stand, X Double, Y Next Hand, Left Shoulder Marked Card, Right Shoulder House Bell, Start Restart after a run ends.
- Keyboard: H/S/D/N for core actions, M/B for tactical items, R for restart, and Escape to close an open settings or archive panel.
- The HIT button receives initial keyboard/controller focus; controls retain visible labels and tooltips.

## Accessibility options

- Settings include an adjustable UI scale (80%–130%) and high-contrast text colors.
- All primary actions remain labeled, keyboard-focusable, and have tooltips.
- Escape closes the settings or archive dialog.
- UI scale and contrast preferences persist independently from run progress.

## Reactive enemy animations

- The zombie switches to Idle_Attack during Restless Dealer encounters.
- After a hand, it reacts with HitReact after a player win, Punch after a loss, and Idle_Attack after a push.
- Completing a run triggers the zombie Death animation.

- The interface automatically scales down to fit smaller viewport sizes and reflows the archive dialog bounds when the window changes size.

## Screen reader support

- Godot 4.7.2 stable includes AccessKit for desktop screen readers. Android TalkBack support is not present in this stable engine line.
- Gameplay status is exposed as a polite live region so hand results and round changes can be announced without moving focus.
- Dealer hand, player hand, chips, opponent, encounter event, and survival progress labels expose descriptive accessibility names.
- Buttons, sliders, and the high-contrast toggle expose accessible names and action descriptions.
- Keyboard/gamepad focus follows a deliberate order through gameplay controls and settings; opening settings moves focus into the panel and closing returns it to the Settings button.
- Archive dialog content and its close action expose accessible descriptions.
- NVDA still requires interactive validation on Windows. Android TalkBack is blocked until a stable Godot release includes the Android AccessKit backend or a dedicated native bridge is added.

## Screen reader support

- Engine upgraded to Godot 4.7.2, which includes AccessKit integration.
- Accessible names, descriptions, focus order, and live announcements are being added to the gameplay controls and status labels.
- Screen-reader behavior still requires validation with TalkBack on Android and NVDA on Windows; CI cannot substitute for those interactive assistive-technology tests.

## Selectable starting opponents

- The Settings panel lets players choose Night Dealer, Collector, or The House as the starting opponent for the next run.
- Collector unlocks after defeating the Collector; The House unlocks after defeating The House.
- A selected Collector run escalates to The House after two wins. A selected House run begins at The House.
- The current run keeps its chosen starting opponent even if the next-run setting is changed. The selection is stored in the run save and migrated from save versions 1 and 2.

## Distinct dealer appearance

- Night Dealer uses a charcoal silhouette with red eyes.
- Collector uses a dark teal body finish and teal eye glow.
- The House uses a bronze-gold metallic finish and amber eye glow.
- The dealer appearance updates when the active run escalates to a new personality.

## Original background music

- The game generates an original eight-second dark ambient chord progression with a slow bass pulse and soft bell accents.
- Music loops seamlessly and has an independent volume slider, separate from ambience and sound effects.
- Music volume persists in settings and is included in automated audio/settings tests.

## Card presentation

- Face-up cards show a large central suit glyph with corner rank/suit indices and suit-specific red/black ink.
- The dealer's hidden card uses a dark navy back with a gold border and original Survival 21 emblem.
- Card border and face geometry are generated from simple meshes; no external card image pack is required.
- New hands deal in with a staggered drop-and-settle motion; newly drawn player/dealer cards animate individually.

## Outcome visual effects

- Winning hands flash the table light green-gold.
- Losses flash the table light red and trigger a short camera shake.
- Pushes flash the table light violet.
- The fill light eases back to its baseline color and intensity after each result.
