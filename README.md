# labyrinth-game

Choose your own adventure RPG

## Battle

- Battle objects emit a `finished` signal with a succeeded parameter.

## Decision

- Decisions require a `Background Texture`, `Current Actor Texture`, `First Choice`, and `Second Choice`. Emits a `finished` signal.
  **TODO: Pass up the choice made as a parameter.**

## Dialogue

- Dialogues require a `Dialogue File Path` parameter that accept a JSON dialogue file.

## Globals

- **DecisionTree**: Contains a `CurrentDecisionsTree` and `HistoricalDecisionsTree`. Current is for the current save file, historical determines which decisions can be routed to using the "Routes" feature.

## Images

- TODO: Delete this, was for initial testing

# Scenes

- TODO: Delete this, was for initial testing
