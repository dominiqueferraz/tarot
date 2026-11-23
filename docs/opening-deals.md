# The Fool · opening deals

## Level 001 · The Fool’s Step

The mobile tutorial uses the six guided strokes below. It teaches play using paths, a pointer, suit marks and aim arrows printed over the board. Each guided move opens a paper hint bubble on the board with one short explanation of the stroke’s effect. The subtitle states the objective. The Wand symbol, scoring suit and fixed trail marker with its light counter appear from the start. The guidance ends after the sixth stroke. The retry control appears only after a failure. The archived web study used the title **The First Step** and revealed the marker after move three.

The Fool's first puzzle teaches single-suit shapes and how to light one objective. The animated pointer hand draws each gesture on the live 6 × 6 board. The player repeats it and watches the pieces settle. The [campaign atlas](campaign-001-220.md#0--the-fool--prologue-001020) describes the rest of the Fool's prologue.

The Fool waits below a ridge with a staff and a bundle. The dark slope, gold circle and broken diagonal take their shapes from the card. As the trail marker gains light, the same progress reveals the path in the illustration. When it reaches 30 light, the trail becomes continuous and the Fool takes the first step. [The Fool card artwork](../deck/rider-waite-smith/svg/majors/00-the-fool.svg)

### Rules in play

The mobile opening teaches horizontal and vertical traces, squares and rectangles. Lozenges are reserved for a later puzzle group with its own combos. The archived web playtest examples below record the earlier lozenge rules.

**Objective.** Collect 30 light at E4. The 6 × 6 grid begins with the unlit marker at E4 and one suit piece in each other cell. The marker stays fixed and retains all light between moves.

**Scoring suit.** Show the Wand symbol to the right of the ridge scene from the start. Give it the accessible label **Wands**. The symbol identifies the suit that earns light even when the marker matches another suit as a wildcard corner. Print the light total and target on the marker’s plaque.

**Ordinary traces.** Connect two or more pieces of one suit through horizontal or vertical neighbours. The trace can turn and visit each cell once. Drag back over the previous piece to shorten the trace. Returning to the origin of an unfinished gesture should let the player choose another direction within the same drag. Release commits a valid stroke. An incomplete or cancelled gesture spends zero moves.

**Squares and rectangles.** Draw four straight sides along the rows and columns and close the outline. A square is a rectangle with equal sides. Start at a corner or along a side and draw in either direction. The ordinary corner pieces must share a suit. The trail marker can stand in for any suit at a corner and stays on the board. The sides can pass over other pieces and the marker. On release, pieces of every suit clear inside and along the outline, and any light earned from the rectangle goes to the marker. See the [shared gesture rules](product-requirements.md#what-happens-under-the-finger).

| Stroke | Light gained |
|---|---|
| A Wand trace ends immediately next to E4, with its final step pointing into the marker. | 1 per Wand in the whole trace. The last segment sets the aim even if the trace turns. |
| A rectangle whose ordinary corners are all Wands encloses E4 or passes over it along a side. | 4, regardless of its size. |
| E4 is a corner of a rectangle whose other corners are all Wands. | 1 per Wand cleared inside or along the sides, with a minimum of 1. |
| Any other legal trace or rectangle, including a rectangle of Cups, Swords or Coins that uses E4 as a corner. | 0. The clear can bring pieces into position for a later hit or rectangle. |

**Settle and refill.** A committed stroke costs one move. Surviving pieces fall within their columns, past the fixed marker where applicable, and new pieces enter at the top. The six guided moves use fixed arrivals. In free play, each column cycles through its own four-arrival sequence containing one of each suit. Restart restores the starting board, the guide and the refill sequence. There is no timer or Undo.

**Win and lose.** Reach 30 light by the end of move 25. The six guided moves count toward the limit, leaving 19 moves at handoff. An attempt ends when the move limit is reached with the marker incomplete or when there is no legal stroke. Restart is free.

| Moves used in a clear | Result |
|---|---|
| 13 or fewer | Three stars and the under-par mark |
| 14 | Three stars |
| 15–20 | Two stars |
| 21–25 | One star |

### Guided opening

| Move | What the hand draws | What the player sees |
|---|---|---|
| 1 | C1 → C2 | Two matching Wands clear. |
| 2 | D1 → F1 → F3 → D3 → D1 | The matching Wand corners close a 3 × 3 square and clear all nine pieces along and inside it. |
| 3 | A2 → D2 → D4 → A4 → A2 | The wider Cup rectangle clears twelve pieces across all four suits, including the Coin at B3 and the Cup at C3. The marker stays outside the outline at 0/30. |
| 4 | D2 → F2 → F5 → D5 → D2 | The taller Wand rectangle clears eleven pieces, including Coins and Swords, and adds 4 light to the enclosed marker. |
| 5 | E2 → E3 | The Wand trace ends beside the marker and points south into E4 for 2 more light. |
| 6 | E3 → F3 → F4 → E4 → E3 | The marker matches the three Coin corners as a wildcard. All three Coins clear and the marker stays at 6/30. The hand disappears with 19 moves left. |

### Replicate the deal

Use board `001`, titled **The Fool’s Step**, with the `ridge` scene, an empty hand, 30 light required, par 14 and a 25-move limit. Columns run A–F from left to right and rows run 1–6 from top to bottom. `W` is Wand, `C` Cup, `S` Sword, `O` Coin and `L` the fixed trail marker. The playtest stores the marker as a lamp receiver at zero-based index 22, caps Wand reach at one, and gives it no fading or blessing. The mobile opening uses the authored starting board and arrivals below. The archived web implementation used seed `18` and is in `playtest/boards.js` and `playtest/engine.js`.

```text
    A B C D E F
1   S S W W O W
2   C S W W C O
3   S O C W W W
4   C S S C L O
5   W S S W W W
6   W W S S C C
```

The hand marks one gesture at a time. The playtest waits for that gesture and spends a move only when it is released successfully. The first pair can be drawn in either direction. Squares and rectangles can start at a corner or along a side and run either way. The scoring trace in move 5 must point toward E4. A valid stroke away from the marked gesture during the guide leaves the board in place and repeats the instruction.

Use these arrivals with the six routes above. In each column, the first letter takes the lowest vacancy after the surviving pieces fall. An empty entry means that column receives no pieces on that move.

| Guided move | A | B | C | D | E | F | Pieces cleared | Light after the move |
|---|---|---|---|---|---|---|---:|---:|
| 1 | | | `SS` | | | | 2 | 0 |
| 2 | | | | `WCS` | `WWW` | `OWO` | 9 | 0 |
| 3 | `SCW` | `CCW` | `WWW` | `SWW` | | | 12 | 0 |
| 4 | | | | `WWWW` | `WWO` | `OOOO` | 11 | 4 |
| 5 | | | | | `WW` | | 2 | 6 |
| 6 | | | | | `W` | `OO` | 3 | 6 |

After the large Cup clear and after the handoff, the settled layout must match these checkpoints. `L` occupies E4 in both.

```text
    After move 3     After move 6
    A B C D E F      A B C D E F
1   W W W W W O      W W W W W O
2   C C W W W W      C C W W W O
3   S C W S W O      S C W W W O
4   S S S S L O      S S S W L O
5   W S S W W W      W S S W W O
6   W W S S C C      W W S S C C
```

**Free-play refill.** Start each column's sequence at its first letter on the first clear after handoff. Advance a column's cursor only when that column takes an arrival. Loop the sequence when it ends. The marker stays fixed while pieces fall through its row into vacancies below it. This is the reference supply for the recorded routes. [Refill and recovery follow-up](#playtest-follow-ups)

| Column | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Arrivals | `WSCO` | `WOSC` | `CSWO` | `CWOS` | `OWCS` | `OSWC` |

### Screen, scene and feedback

![Archived web playtest after its five guided moves, with the trail marker at 6/30 and 20 moves left](images/the-first-step-board.png)

- **Layout.** Run the back-arrow rule across the screen and keep the navigation controls within the safe area. Place the title and short objective just above the ridge scene. Center a large circle containing the remaining move count beside the title block and give the count a localized accessibility label. Frame the scoring-suit symbol in a square to the right of the scene, aligned beneath the count. Give both frames the same height and align their outer edges with the full square grid. Separate the row from the grid with a narrow gap. Use 100 × 100 logical units per cell and a 600 × 110 scene. Scale the scene and board so all 36 cells remain visible. Reuse the paper, grain, suit marks and warm inks from the archived stylesheet and drawing primitives in `playtest/style.css` and `dist/art.js`.
- **Ridge.** Use warm paper sky (`#f0dfb7`), the ochre sun (`#d5a03c`), a distant tan ridge (`#b8a17a`), the dark foreground slope and a blue facet. The Fool starts with a staff and bundle at `(142, 98)`. The trail follows `(142, 98)`, `(232, 96)`, `(321, 75)`, `(397, 54)`, `(478, 73)` and `(543, 94)` in scene coordinates. The scene marker sits just above the fourth point. Reuse the raised ochre disk and pale diamond of the grid marker.
- **Light and progress.** Show the waiting Fool, unlit markers and trail at deal time. Use the same light total to fill the disk from the bottom, grow the illustrated marker and light successive sections of the dashed trail. A directed Wand hit flashes from the endpoint into E4. At 30 light the marker blazes, the trail becomes solid and the Fool walks from the first point to the second. Reduced motion uses the settled illustration and the same tracker values.
- **Gesture timing.** The current guide traces each segment in 330 ms, with a pause of 400 ms before it starts and 650 ms after it closes or reaches the endpoint. Re-draw only the current guide gesture. The release and fall take 110 ms and 420 ms, respectively. Delay the next hand cue and hint until the fall settles. Place the hint near the demonstrated stroke on the board and clear it as soon as the player starts tracing. Reduced motion uses the still hand, marked points and a stationary bubble.
- **Controls and copy.** Accept touch and mouse drags and support arrow-key navigation with Space to select, Enter to commit and Escape to cancel. The objective reads “Light the trail marker.” Use the hand, ink outlines, arrows and the marker’s changing light to show each action. Keep the normal tile colors inside a rectangle and mark its outline and corners. Explain shared effects in suit-neutral terms and name Wands for lighting the trail marker. Localize the labels and hints in English, Brazilian Portuguese and Spanish.
- **Progression.** The playtest offers Next board after the clear. In the campaign, this clear also awards the first Fool fragment. The remaining fragments, Leap award and final encounter belong to the [Fool prologue](campaign-001-220.md#0--the-fool--prologue-001020).

### Verified reference replays

Play the six guided moves before either route. The light shown is the marker value after the stroke settles. Both routes use setup clears and scoring rectangles.

| Move | Par clear | Light | Alternate clear | Light |
|---:|---|---:|---|---:|
| 7 | A5 → A6 | 6 | E5 → D5 → D4 → D3 → D2 → D1 → E1 → E2 → E3 | 15 |
| 8 | B4 → C4 | 6 | B4 → C4 → C5 → B5 → B4 | 15 |
| 9 | A3 → A2 → B2 → C2 → C3 → D3 → D2 → D1 → E1 → E2 → E3 | 17 | B4 → B5 | 15 |
| 10 | D2 → E2 → E5 → D5 → D2 | 21 | A5 → A6 → B6 → B5 → B4 → C4 → D4 | 22 |
| 11 | C1 → E1 → E4 → C4 → C1 | 25 | A5 → B5 | 22 |
| 12 | A1 → B1 | 25 | A3 → E3 → E4 → A4 → A3 | 27 |
| 13 | B3 → E3 → E4 → B4 → B3 | 25 | C6 → D6 | 27 |
| 14 | B1 → E1 → E4 → B4 → B1 | 30 | D2 → E2 | 27 |
| 15 |  |  | D1 → E1 → E4 → D4 → D1 | 30 |

### Replaying the archived prototypes

Extract `playtest/`, `dist/` and the two `tools/*.test.js` files from `Arcana-Code-and-Prototype.zip` in Downloads into the same folder, preserving their paths. The prototype card images and paper grain are included under `dist/assets/`.

- Open `playtest/index.html#001` for The First Step and `playtest/index.html#R3` for Far Wreath.
- Open `dist/index.html` for the original tableaux or `dist/first-crossing.html` for the fixed-pair ferry study.
- From the extraction folder, run `node --test tools/engine.test.js tools/input.test.js` to check the par route, the marker reveal, the 6/30 handoff, matching and direction on release, and the first free-play arrivals.

### Playtest follow-ups

- **Backtracking.** Returning to the origin mid-drag can leave the player unable to start down a different path, especially after trying a diagonal. Check that returning from an abandoned diagonal or ordinary trace restores all legal directions while the pointer is still down. Closing a valid shape should leave it ready for release.
- **Recovery.** Players report that the current free-play refill supplies too few Wands after an inefficient stroke. Recheck recovery with different opening choices when tuning the supply. Keep useful setup clears in other parts of the board.
- **Shape scoring.** Verify that Cup rectangles using the marker as a corner clear their area without gaining light. Check Wand rectangles with the marker at a corner, on a side and inside. A closed square can clear the area even when its entire stroke also connects adjacent matching pieces.

## Level 002 · Lamplighter

The Fool follows the lit ridge trail down to the quay at night, where an empty boat is tied to a mooring post. The same staff and bundle identify the Fool at the landing. The illustrated lamp grows as it fills and its reflection stretches across the water. Both recede when the lamp loses light. At 44 light the lamp blazes over the moored boat.

The fixed lamp is at C3 on a 5 × 6 board. The player has 22 moves, par 15, and free play from the first stroke. Use Cups to pour oil into the lamp. Close **B2 → D2 → D4 → B4 → B2** for 4 light or aim **A3 → B3** for 2. Both use the same shared rules as 001. The lamp dims by 1 on a paid stroke that earns no light, down to zero. An actual loss briefly dims the lamp and contracts its glow. An in-board bubble explains the effect. The bubble clears at the start of a trace. The guided refill samples four weighted fills, with Cups three times as likely as each other suit before scoring, and favours matches in the lower rows and available aimed Cup pours. Retry restores the opening and the seed.

The [puzzle catalog](../assets/puzzles/fool.json) contains the starting grid, localization keys and refill seed. The next-puzzle action after 001 opens the preview for 002. The campaign path keeps both phases accessible once 002 is unlocked.

### Archived lamp-and-bell deal

This four-move study records the original simultaneous spark and falling Coin. Its routes, ribbons and presentation ideas describe that historical version.

**Goal shown at deal time** · Call the ferry. Light the quay lamp and ring the bell.

The player starts with an empty hand, a 6 × 6 field that refills from short authored ribbons, a visible limit of four moves, free Restart and no clock. The ferry waits in a strip of river along the top border. Its dark lantern repeats the shape of the quay lamp. A fine line runs up the quay from the bell pan to the bell in the illustration. Keep both goal markers visible on the grid after their animations end.

```
      A B C D E F
  1   C S O W O C
  2   C C W S W O
  3   O W G C W S
  4   S W W O L C
  5   O S P C C W
  6   W O S O W W
```

C, S, O and W are traceable Cups, Swords, Coins and Wands. G is the loose gold Coin with a stamped ferry on it. P is its fixed bell pan. L is the fixed quay lamp. Draw the loose Coin edge-on with a milled rim so it reads differently from the ordinary Coin suit. Only the loose ferry Coin rings this bell. It strikes the first time G lands immediately above P. Both the struck bell and the lit lamp stay marked. Ordinary pieces fall past the lamp and the pan, so every open cell refills from the top. Only the pan catches the loose gold Coin. When the Coin rings the bell, the ferry takes it as its fare and column C refills. Each column refills from its own measured ribbon, read left to right in arrival order. The first arrival takes the lowest open cell. No ribbon carries a Wand, so a spent lamp group can't be replaced in time. These ribbons belong to the earlier short deal.

| Column | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| Ribbon | SOCSCOSCOSOC | OCSOSCOCSOSC | SCOOSCSOCSCO | COSCOSSCOCOS | OSCCSOCSOSCO | CSOSCOOSCSOC |

*Earlier rule, kept for a future mechanic:* the first greybox spec sealed the chambers below the lamp and pan, with four-piece dry ribbons (CSOC, SOCS, OCSO, CSOC, SOCS, OCSO). See the [sealed-chamber proposal](design-notes.md#refill-around-fixtures-decided-for-now-sealing-kept-for-later).

| Player’s stroke | What the player sees |
|---|---|
| B4 → C4 | Two Wands send the spark east across D4 into the lamp at E4. As they leave, the loose Coin at C3 drops to C4 and hits the pan at C5. Two different sounds come from two places the finger just affected. The lantern catches, the bell swings, and the ferry pushes off. |
| E2 → E3, then C4 → B4 | The first spark travels south into the same lamp. The lit quay waits for a bell. The second stroke points west and releases the Coin, ringing the bell and summoning the same ferry. |

A player can also inspect the Cup group at the top left or trace the Wand elbow at the bottom right. Let a stroke away from the fixtures settle normally. After either finish, give the same card fragment. The one-stroke route gives a designer's par of one.
- **Limit.** Four moves, which is par + 3. Each of the 22 legal directed first traces can still lead to a win within four moves.
- **Losing line.** Try B4 → B3 and then E3 → E2. Both are legal northbound sparks. After these two strokes, no continuation can light the lamp in the two remaining moves. The loss message can say “No Wand can reach the lamp in time.”
- **Stars.** The two-stroke route earns two stars, and the one-stroke route three.
- **Running out.** If all four moves pass without both goals, name what is missing ("The bell has not rung") and offer Restart.

**Payoff.** B4 → C4: one stroke lights the lamp and rings the bell.

**Historical status.** The short board used the printed ribbons and a four-move limit. Its routes concern that layout. The archived core playtest uses one trail marker and the supply described above. The fixed-pair ferry study is a reference for the timing of the bell and boat.

## Level 003 · High Water

The Fool reaches a mill beside a dry intake channel. Fill the inlet at B5 with 32 units of water on a 6 × 7 board. The deal opens in free play with 18 moves and a par of 15. A Cup trace that ends facing the inlet pours one unit per Cup. A Cup rectangle can also feed the inlet under the shared scoring rules. Water carries over between strokes. As it rises, the channel fills, and the wheel turns on completion.

The opening has three ways in. These are example starts with verified clears from the [authored board and refill seed](../assets/puzzles/fool.json).

| Approach | Opening move | Example clear |
|---|---|---|
| Build a rectangle with gravity | Clear the Wands at C6 → C7. The Cups from C2 and C5 fall to C4 and C7. Close A4 → C4 → C7 → A7 → A4 to clear 11 pieces and pour 4 units. | 7 moves |
| Pour from below | Trace A6 → A7 → B7 → B6 for 4 units. The fall sets up a rectangle using the inlet as a corner. | 5 moves |
| Pour from the right | Trace D4 → D5 → C5 for 3 units. Use the lower Cup group next and clear around the inlet to bring new pours into reach. | 11 moves |

Guided refill weights Cups three times as heavily as each other suit. Following nearby Cup pairs without checking where the final step points can exhaust the moves. Lamplighter’s completion action opens the High Water preview and saves its unlock on the campaign path.

## Level 004 · The Mooring

At the dusk dock, cut 24 strands from each of two cords in 26 moves, with a par of 15. The board is 7 × 6, with A1 and G1 masked. Only playable cells receive pieces. The bow cord at C3 and stern cord at E5 stand at opposite corners of a square.

| Guided move | What the player sees |
|---|---|
| C3 → E3 → E5 → C5 → C3 | The Sword square cuts 5 strands from each cord. Blue rings and a bolt join them. The link has two moves left. |
| C1 → C2 | Aim at the bow. Both cords gain 2 cuts, and the bolt flashes. The guide hands back control at 7/24 on each cord with one linked move left. |

Try G5 → F5 after the handoff to use the last linked move from the stern side. Each cut from an aimed stroke reaches both linked cords in full. Any paid move uses one turn, including a miss. A new qualifying square refreshes the link. Rectangles still cut the cords they cover under the shared scoring rules.

Guided refill weights Swords three times as heavily as each other suit. The boat leaves once both counters reach 24. Clearing High Water unlocks The Mooring.

## Level 005 · The Ferryman’s Fare

Clearing The Mooring unlocks the market landing. Fill the west pan at C4 and the east pan at F4 with 24 Coins each in 25 moves, with a par of 15. B1 and G1 are masked on the 8 × 8 board. Guided refill uses seed 571 and gives all four suits equal weight. The illustrated scale tips toward the fuller pan and balances when both are paid.

The last step of a Coin trace sets its direction. E4 → D4 deposits two Coins in the west pan, and D4 → E4 deposits two in the east pan. Either opening removes the same pair and leaves the same pieces after the fall. A rectangle or square with Coin corners can feed either or both pans under the shared scoring rules. The pans keep independent counters for subsequent moves, and each pan caps at 24.

| Reference approach | Result |
|---|---|
| E4 → D4, then build toward the west pan | West fills first. Both pans are paid in 14 moves. |
| D4 → E4, then build toward the east pan | East fills first. Both pans are paid in 14 moves. |
| A2 → A3 spends two Coins without a deposit | Switch to the west opening after the fall. Both pans are paid in 18 moves. |
| Fill the west pan, then spend the remaining moves without feeding the east | The deal fails at 24 west and 14 east. |
| Open east and build a sequence of Coin squares and rectangles | Both pans are paid in six moves. The C1–F4 square pays seven Coins into each pan. |

[Puzzle catalog](../assets/puzzles/fool.json) · [Reference replays](../test/fool_deal_test.dart)

## Level 006 · Market Day

The ferry has crossed. On the far bank, the Fool stops at a baker’s shuttered stall before the market opens. Light the stall lantern at C3 with Wands so the baker can see, fill the water trough at F3 with Cups for the dough, and pay for a loaf by aiming Coins at C6. Each target needs 6 on the 7 × 7 board. The turn limit is 18, with a par of 12.

The lamp brightens, the water rises, and Coins stack in the pan as the player works. On a clear, the shutter opens and a loaf passes across the counter to the Fool. The result reads “Bread for the road.”

| Opening | What follows |
|---|---|
| E3 → D3 | The Wands give the lantern 2 light and their fall brings two Cups into position. Trace D3 → E3 to pour 2 into the trough. |
| E6 → D6 | The Coins make the first payment. A later Cup rectangle feeds the trough. |
| D2 → E2 | The Cups clear without watering the trough. A Coin rectangle can still deliver the full payment, leaving time to finish the lantern and trough. |

All three approaches have five-move reference clears with guided refill seed 613. On the opening grid, C3 → F3 → F6 → C6 → C3 makes a Wand square with all three fixtures as wildcard corners. Only the Wand lantern gains progress.

[Puzzle catalog](../assets/puzzles/fool.json) · [Reference replays](../test/fool_deal_test.dart)

## Lozenge playtest routes

Read columns left to right and rows top to bottom. A closed route can be drawn in either direction and started between any of its corners. For a route with a setup stroke, start on a fresh deal and play the steps in order.

| Deal | Route | What resolves |
|---|---|---|
| High Water · vertical setup | Clear C6 → C7, then close B4 → D6 → C7 → A5 → B4 | The first stroke brings existing Cups into four matching corners. The second clears seven pieces, feeds the inlet 4 and blesses it. |
| High Water · horizontal setup | From a fresh deal, clear A6 → B6, then close B2 → D4 → C5 → A3 → B2 | Lowering two columns builds a different Cup lozenge from existing pieces. It clears eight pieces away from the inlet. |
| The Wreath · one target | Close C3 → F6 → E7 → B4 → C3 | The lamp counts as a Wand corner. The stroke clears nine pieces and feeds the lamp 6. It passes over the inlet on a side. |
| The Wreath · two targets | From a fresh deal, close C3 → E5 → D6 → B4 → C3 | The lamp and inlet are both corners. The stroke clears six pieces, feeds them 5 and 1 respectively, and links them for two turns. |
| Twin Wreath · contained targets | Close C2 → E4 → D5 → B3 → C2 | Four Coins form the corners. Both targets inside the shape gain 4 and a blessing. |

To use the two-turn link in The Wreath, follow the linking lozenge with A5 → A4 → B4 → B3 → B2 → B1 → C1 → C2. The last step points into the lamp at C3, and both targets gain 8. One linked turn remains. Clearing C2 → B2 then uses the last turn without feeding either target. The lightning and countdown disappear.

### Far Wreath · the first four moves

The two goal suits are Wands and Cups. The guide marks one legal move at a time on the actual board. The 7 × 7 deal has a 25-move limit, a quota of 26 for each target, and a fade of 1 per stroke for each target the stroke leaves unfed.

| Step | Marked move | Lesson |
|---|---|---|
| 1 | D1 → G4 → D7 → A4 → D1 | Cups at the top and bottom and Wands at the sides form a mixed lozenge. It clears 35 pieces with the extra layer. |
| 2 | C1 → F4 → D6 → A3 → C1 | Four matching corners clear 16 pieces. The side passes through the inlet. Both targets gain 4 and a blessing. |
| 3 | E3 → D3 | Aim the spark left into the lamp for 4. |
| 4 | C5 → D5 | Aim the pour right into the inlet for 4. The player takes over here. |

An opening Hint on a replay can restart the guide. Once its four steps are finished, Hint explains the rules and leaves the move to the player. [Replay Far Wreath and run the tutorial checks](#replaying-the-archived-prototypes)

**Greyboxing the prologue.** The five archived briefs have recorded clears. Re-author subsequent mobile layouts for rectangles, and give each brief a shared deal on which different decisions can pay off. Replay each approach against the same supply, including an attempt that changes plans after a weak stroke. When a layout relies on a stranded pair, check whether a rectangle can clear its support or directly reach its goal. [Campaign atlas](campaign-001-220.md)

## Fool 013 · One impossible step

**Raise the drawbridge by pouring two units into its inlet.** The inlet starts empty. Deal one charge of Leap, three moves and a 6 × 6 field. The only Cups are in column D. A Wand sits between them. There is a second Wand across the gap. Both Cups and Wands can make use of the same card.

```
      A B C D E F
  1   S O S O S O
  2   S O O C O S
  3   O W # W S S
  4   S O S C O S
  5   O S O I S O
  6   O S O S O O
```

**Needs rework under the current refill rule.** This layout assumes fixtures seal the cells below them. With everything refilling, the D-column stack no longer rests on the inlet, and pieces fall past the gap. Rebuild it, or keep it for the [sealed-chamber proposal](design-notes.md#refill-around-fixtures-decided-for-now-sealing-kept-for-later).

I is the fixed inlet and # is a fixed gap. Each column has a short, dry ribbon. From A to F the ribbons are SO, OS, SO, OS, SO, OS in arrival order. In the earlier model, the inlet seals the cells beneath it into a separate chamber. Leap skips one intervening cell on one straight segment. If that segment ends the trace, aim one cell ahead from the landing piece in the direction travelled.

| What the player notices | What happens |
|---|---|
| “I can reach the inlet now.” | Leap with the Cups from D2 to D4 over the Wand. The trace finishes facing D5 and pours two. |
| “That Wand is holding a Cup up.” | Leap with the Wands from B3 to D3 over the gap. Clearing the support drops the upper Cup onto D3. Trace D3 → D4 normally and pour two. |
| “I moved my other Wand out of reach.” | Clearing the Swords B5 → B6 drops the B3 Wand to B5. The horizontal Wand jump is gone. The Cups can still Leap over the support and reach the inlet, with a move to spare. |

**What the original certificate assumed.** The fixed inlet supported the D-column stack and the only other Wand sat two columns away. The two intended traces above teach different uses of Leap. An upward Cup jump spends both Cups and misses the inlet.

**Cardless clear in the archived playtest.** With the listed layout and ribbons in the web build, clear A5 → A6 and then draw the four-Sword lozenge C1 → F4 → D6 → A3 → C1. It surrounds the inlet and feeds it 4, meeting the two-unit quota in two moves without Leap. Re-author and verify the mobile layout against traces and rectangles for the required-card certificate.

**Playtest question for a revised layout.** Do newcomers see the Wand as a support they can remove? Watch which suit they choose before showing a hint. Test both intended uses of Leap and how often players discover each one.

## Earlier finite-board studies (before refill)

These ten deals tested gravity, singletons and Leap before the campaign adopted physical objectives. Their solutions and minimum stroke counts apply only to these earlier clearing problems. They are reusable arrangements, not proofs for the revised campaign levels.

Every level below wins by clearing all ordinary pieces. No refill or column sliding. Coordinates use letters left to right and row numbers top to bottom. A coordinate always refers to the board *after* the previous settle. A period is empty and # is an impassable gap. A leap can pass over a gap or occupied intervening cell. Each listed stroke connects one suit; release after its last coordinate.

For these ten deals a separate exhaustive finite-state checker enumerated simple orthogonal traces of all lengths, optional single jumps, and vertical compaction per chamber. It checked shortest lengths, winning replays, and the listed dead openings. These are model checks of the proposed rules. The browser prototype currently uses a different refill model. A “dead opening” below means no complete clear even with unlimited subsequent strokes and the remaining power.

## 001 · First footprints

Three pairs. Start without cards.

```
CCO
WWO
```

**Winning sequence**  B1·A1 → C2·C1 → B2·A2.

**Minimum** 3 strokes. Empty hand.


## 002 · Around the bend

Two turning trios. Ask what would become of the third piece if the finger lifted after two.

```
CWW
CCW
```

**Winning sequence**  B2·A2·A1 → B2·C2·C1.

**Minimum** 2 strokes. Empty hand.

**Dead opening**  A2·A1. Restart restores the opportunity.

## 003 · Keep me a partner

The Cups begin vertically separated. Clearing the Wand elbow brings them together.

```
CWO
WWO
CSS
```

**Winning sequence**  A2·B2·B1 → C2·C1 → A3·A2 → C3·B3.

**Minimum** 4 strokes. Empty hand.

**Dead opening**  B2·B1. Restart restores the opportunity.

## 004 · The short way down

Clear the upper Wands before committing to the lower Cup chain.

```
SWWC
CCSS
SCSC
```

**Winning sequence**  C1·B1 → B3·B2·A2 → A3·A2 → C3·C2·D2 → D3·D2.

**Minimum** 5 strokes. Empty hand.

**Dead opening**  B2·A2. Restart restores the opportunity.

## 005 · The broken road

The gap in column B divides the upper field. Trace under it before clearing the final Cup crop.

```
S#CC
S#WC
WWWO
CCOO
```

**Winning sequence**  A2·A1 → A3·B3·C3·C2 → C4·D4·D3 → A4·B4·C4·D4·D3.

**Minimum** 4 strokes. Empty hand.

**Dead opening**  D1·C1. Restart restores the opportunity.

## 006 · One impossible step

Stop on the initially impossible position. Show the uncovered Fool, loan Leap, and award it at the win.

```
C#C
```

**Winning sequence**  C1·A1.

**Minimum** 1 strokes. Loan the Fool. A cardless clear is impossible.


## 007 · Over someone’s head

Jump the right-hand Coin. Its suit survives the trace and joins the final Coin group.

```
O#C
WWO
OOC
```

**Winning sequence**  C3·C1 → B2·A2 → C3·B3·A3·A2.

**Minimum** 3 strokes. Deal the owned Fool. A cardless clear is impossible.

**Dead opening**  A3·A1. Restart restores the opportunity.

## 008 · Far bank

Cross the break midway through the first Coin trace. The vertical alternative spends the only jump too early.

```
S#WS
O#OW
OSSS
```

**Winning sequence**  A3·A2·C2 → D2·C2 → A3·B3·C3·D3·D2.

**Minimum** 3 strokes. Deal the owned Fool. A cardless clear is impossible.

**Dead opening**  D3·D1. Restart restores the opportunity.

## 009 · The long detour

Wait until the fourth trace before jumping. The winning line depends on where the earlier supports fall.

```
WW#S
OW#S
WOCW
WWOC
```

**Winning sequence**  D2·D1 → B4·A4·A3 → C4·B4·A4 → A4·B4·B3·D3 → D4·C4.

**Reuse note.** The fourth stroke leaps over C3 after C3 has already emptied. This line is valid only if Leap skips any one cell, including empty paper. Under the narrower wording above it needs six strokes. Leaping on the third trace is also a shortest line, so the instruction to wait until the fourth is a suggestion, not a requirement.

**Minimum** 5 strokes. Deal the owned Fool. A cardless clear is impossible.

**Dead opening**  B2·B1·A1. Restart restores the opportunity.

## 010 · The traveller

The guide carries a letter across the road as the deal clears. The opening Coins can clear without the card.

```
OCWC
O#SS
WWCC
```

**Winning sequence**  A2·A1 → D1·B1 → D2·C2 → D3·C3 → C3·B3·A3.

**Minimum** 5 strokes. Deal the owned Fool. A cardless clear is impossible.

**Dead opening**  D3·D1. Restart restores the opportunity.

Every board shows a move limit (the PRD's tier policy):
- **Main route** in the first chapter: par + 3.
- **Mastery leaves:** par + 1 on 008, par on 009.
- **Stars** stay optional on the required route.

Displaying a hint never consumes the card, and a restart restores its charge. A dead opening is the place to name the cause in one line before offering Restart, for example "The last Wand has no partner left".
