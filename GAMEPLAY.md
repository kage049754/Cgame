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
