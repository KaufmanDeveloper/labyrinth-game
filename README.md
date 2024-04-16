# labyrinth-game

Choose your own adventure RPG! I've outlined the general structure of the API below.

## Battle

Battle scenes are per instance and contain one enemy each. AP, HP, and MP are reset after each battle.

- Take a `enemies` and `bash` parameters. **TODO**: All mini game action buttons should be parameters in a `battle` object.
- Battle objects emit a `finished` signal with a succeeded parameter.

## Chapter

- Takes `Elements` and `Track`. Elements are an array of `Dialogue`s and a `Decision`.

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
