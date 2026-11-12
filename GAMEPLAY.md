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
