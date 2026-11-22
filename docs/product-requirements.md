# Arcana Tableau
## Product requirements

**Arcana Tableau is a game about drawing paths through a changing field of four tarot suits.** From the first deal, a player can scan the rows, spot a cluster, trace around a corner, and decide where to lift their finger. The last segment aims the suit action. The pieces that leave make room for the next opportunity. A good turn feels satisfying as a gesture and interesting as a decision.

The archived core playtest contains five prologue deals and three Wreath studies. The original tableaux remain references for powers and moving targets. The fixed-pair ferry study records an earlier bell experiment. [Open the archived prototypes](opening-deals.md#replaying-the-archived-prototypes)

Companion designs · [Opening deal and move-by-move routes](opening-deals.md) · [Campaign atlas](campaign-001-220.md) · [Deck artwork references](#deck-artwork-references) · [Design notes](design-notes.md)

### What is ready to build

Design for a player who enjoys spotting a chain on a phone. The first deal should work with the sound off and without knowing tarot. Its central question is simple enough to ask with a finger on the board. If I trace these same two Wands in the other direction, what still falls, and where does the spark go?

| Decision | Evidence at this revision | What would settle the next question |
|---|---|---|
| Teach **The Fool’s Step** on the full 6 × 6 field. | The hand demonstrates a matching pair, a Wand square and a Cup rectangle. Then the player lights the marker with an enclosing Wand rectangle and an aimed Wand hit, and matches a Coin square using the marker as a wildcard corner. The guide hands over at 6/30. | Watch whether newcomers can finish lighting the marker after the hand disappears. [Opening layout](opening-deals.md) |
| Use the five playable studies to test suits, powers and moving targets. | Moon Pool, Justice, Hanged Man, Crab Walk and Runaway Coin are interaction studies with their own rules. | Bring the campaign’s powers and moving targets into the turn resolver once the core stroke and board loops hold up in play. |
| Author the prologue before committing to a volume. | The atlas contains 230 proposed deals across 22 chapters. The Fool and Magician both use numbers 011–020. Each first reading states a reason its card is needed. Testing those claims requires the authored layouts and supply. | Build and measure the prologue through its first reading and encounter. Verify every required card, check difficulty with players, and cost a second batch before setting a release cadence. [Campaign atlas](campaign-001-220.md) |

### What other games suggest testing

| Reference and observed design | Question for Arcana |
|---|---|
| **Two Dots** connects matching neighbours across rows and columns, refills the board, and gives a square a distinctive payoff. [Official play guide](https://dots.helpshift.com/hc/en/3-two-dots/faq/368-how-do-i-play-two-dots/) | Can someone familiar with tracing games close the guided rectangles and feed the marker independently after the hand disappears? |
| **Into the Breach** shows enemy attacks ahead of time and uses deterministic outcomes during the player's turn. [Subset Games’ design postmortem, with board examples](https://media.gdcvault.com/gdc2019/presentations/Into%20the%20Breach%20Postmortem%20Final.pdf) | On Crab Walk, ask where the crab will stand after a lure and after an ordinary clear. A correct destination with an unexpected cause calls for a clearer on-grid cue. |
| **Patrick’s Parabox** used fresh testers and watched how their understanding of rules changed over a sequence. [Patrick Traynor’s GDC design notes](https://media.gdcvault.com/gdc2024/Slides/GDC%2Bslide%2Bpresentations/Traynor_Patrick_SystemCentricPuzzle.pdf) | On Fool 012–014, record how the player describes the stranded Cups before the loan, what they use Leap on in 013, and whether they can apply it to the new float and bell arrangement on 014 without prompting. A successful imitation on 013 alone tells us little about transfer. |
| **Railbound** puts harder puzzles on branches. **Hearthstone’s Death Knight prologue** teaches a power before awarding the class and its cards on completion. [Afterburn’s campaign description](https://store.steampowered.com/app/1967510/Railbound/) · [Blizzard’s prologue notes](https://hearthstone.blizzard.com/en-us/news/23882860/25-0-patch-notes) | From a fresh album, skip Fool 016–017, complete 020, and enter the Magician chapter with one Fool card. Replay 013 and restore the save at the award boundary. The same card and next chapter must remain available. |

These comparisons inform the test design. Arcana's first-attempt clear rate, perceived difficulty and willingness to pay require observations from its own players.

### Several ways to clear a board

Give the player a goal they can keep working toward as the pieces fall. A player who notices a different opportunity halfway through should often be able to take it. The game checks the visible goal in the settled state. Every clear within the limit earns the same story progress, card or fragment. Par and extra stars give players who enjoy efficiency a reason to return.

**Justice already shows how this feels.** Each pan must finish with exactly two Coins. You can shorten a four-Coin chain, pay two to the left and two to the right, and keep your card. Or you can send all four left and use Equalize to split the load. Both work in the playable study. The choice changes how you trace, what the pans show and whether you spend your card. Open `dist/index.html#justice` from the extracted archive.

| Kind of board | Where the difficulty comes from | How to leave room for choice |
|---|---|---|
| Open quota | Choosing which cluster to use as new pieces arrive | Bank useful pours or sparks. Give more than one approach to the fixture. A small pour now and a larger one after a fall both advance the same counter. |
| Measured supply | Deciding where a limited resource does the most good | Keep the supply visible. A card can act on the goal itself or on its support. On Fool 013 the same Leap can join the Cups for an immediate pour or remove the Wand between them so gravity brings them together. |
| Hard or Super Hard | Reading a consequence several strokes ahead, or coordinating an actor with a second demand | Give the player a real trade: spend a charge to reach the near window now, or keep the charge and prepare the far window. Put both within the clear limit. Missing an early window can make the later one more expensive. |

Players can discover approaches the author never anticipated. Welcome these when they follow the printed rules. For the first batch, aim for **three different approaches on an ordinary campaign board**. Keep **at least two** on a tightly measured board, an encounter or a first reading. Count approaches by what the player does differently with a target, resource, fall or power. Swapping independent moves, tracing the same group from another starting cell with the same effect, or spending spare moves before the same finish counts once. These are starting targets for authoring. Test whether people actually notice the choices.

### The delight loop

The delight loop is the core of the game. Every rule, board and reward exists to keep it turning. It runs at four scales, and each scale has to pay off on its own.

| Scale | The loop | Where the delight comes from |
|---|---|---|
| **The stroke** (seconds) | Spot a group → trace it → release → the board answers | A gesture that turns into a consequence. The action lands on its target, pieces fall, and the scene above responds in the same order the grid shows. The best strokes do **two things at once**, like a rectangle that clears a wide area and feeds two fixtures. |
| **The board** (minutes) | Read the goal → take an opportunity → read the fall → adapt → clear or retry | With open supply, rhythm: many satisfying strokes building toward a quota. With measured supply, the pleasure of spotting another use for a scarce piece or power while there is still time to act. A failure can be explained from what was visible, and the restart is instant. Stars invite a second look for the shorter, cleverer line. |
| **The chapter** (a session) | Uncover fragments → meet an impossible position → the card is lent → win it → the encounter changes the place | Ownership. The thing that couldn't be done becomes the player's power, and the world visibly changes because of it. |
| **The campaign** (months to years) | Learn a grammar → meet its entries in new combinations → a new grammar arrives once the old ones are spent | Recognition. A new board uses familiar things in a way the player didn't expect but can predict: a dignity pair never seen before, a trump on a different system, a grown piece meeting a card. |

**Archived web playtest.** The First Step teaches single-suit lozenges and how to light an objective. In High water, clearing C6 → C7 drops existing Cups into a lozenge around the inlet. The Wreath gives a second setup with a deadline. A lozenge charges the lamp and inlet and links them for two moves. The player can then spend a trace to feed both. Ask whether players spot those setups, connect the animation to the stroke, and find a useful move after the fall. Chapter and campaign payoffs still need playable readings, rewards and encounters. [Verified example routes](opening-deals.md#lozenge-playtest-routes)

**Rules that protect the loop**
1. **Every stroke pays off visibly.** Even a setup stroke resolves its action, settles the board and gets a response from the scene. No stroke is silent, and no consequence happens off the grid.
2. **Show the gesture, then resolve it.** During the drag, show the selected path, its aiming direction for a trace, or the turns of a closed shape. Keep the board in its current state until release. Then show which pieces clear, what the stroke hits and how the columns settle.
3. **Reward the setup the player made.** A large rectangle opens space. A link lights up its targets and gives the player a limited window to use it. Tie each reaction to the arrangement the player can point to on the board.
4. **Every board has a payoff stroke.** Each board is authored with at least one stroke that does two jobs or completes a visible chain. The atlas describes an example **payoff**. Accept any play that achieves the visible goal.
5. **Failure teaches, then gets out of the way.** A loss shows the unmet objective or exhausted move count and offers an instant retry. Retries are free and unlimited.
6. **Give a stuck player somewhere to go.** Offer a familiar board or an unlocked sibling when the route branches. At a required reading or encounter, offer a free retry on failure.
7. **The first thirty seconds pay off at once.** On 001 the first connection clears a pair, then a square and a wider rectangle show how the same gesture can clear a much larger area.
8. **Teach the grammar, then let its entries appear.** Dedicated boards teach only the basics:
   - the four suit tools, gravity and gaps;
   - values and feeding;
   - the dignity relations, using one friendly pair and one contrary pair;
   - the trump rule;
   - each card.

   Everything a known grammar predicts arrives without a tutorial, with a one-line legend and a first board where it is the payoff. That covers the remaining dignity pairs, a trump for a power the player already knows, long-trace charges, and combinations of anything owned. Then it joins the pool. The combinatorial space is huge, so the campaign spends it slowly: each new entry should feel like a discovery, not a lesson.
9. **Every board can be lost.** Every board, including 001, rest boards and generous open boards, has a **losing line**: a plausible sequence that a reasonable player might choose, not just deliberate waste. Being able to lose is what makes a win mean something. Each board's brief names its losing line. Tune the cost of repeated missed opportunities while preserving several ways to clear and room to recover on the main route.
   Because every board refills, a bad stroke can usually be recovered when new pieces arrive. So a losing line is one of two things:
   - a recovery that costs more moves than remain; or
   - a stranding nothing can replace: a suit no ribbon carries, a piece in a dry column, a blank stone, a relic, an actor.

   On measured boards the second kind is common. On open boards the first kind is.

### The play surface

Use visible text for labels, controls, titles, values, a short puzzle objective and brief explanations in guided hint bubbles. Teach play through gestures demonstrated on the live board with temporary ink paths, rings, arrows and pointer drawings. Keep the same landmarks recognizable with motion disabled and label the board and controls for assistive technologies. Offer retry only after a failed deal.

**Board sizes.** The reference board is **six columns by six rows**. Each board fixes its own footprint from the start of the board to the end.
- **Range.** Footprints run from **4 × 4 up to 8 columns by 9 rows** in portrait. A board may mask out cells to make an irregular outline: a quay, a tower, a riverbank.
- **Which boards use which sizes.** Measured boards default to 6 × 6 or smaller, so every piece can matter. Open boards and encounters may use the larger footprints for room to breathe.
- **The limit is legibility.** At the largest footprint, every cell must stay visible during tracing. Every piece must still pass the thumb-size recognition test on a narrow phone, which means cells of roughly 42 points or more across at eight columns.
- **Size never earns a tier.** A bigger board is not a harder board. Like more colours, size alone never raises the rating.

A **fixture** is a fixed board object that accepts a suit action. A lamp accepts Wands, an inlet accepts Cups, a cord accepts Swords and a pan accepts Coins. In player-facing text, use the object's name or call it a target. Early levels arrange generous groups around a small number of targets. Leave useful groups elsewhere in the field, including the lower rows.

Frame the grid and the shallow illustration above it as one printed tableau. Carry the deck’s paper, fine rules, silhouettes, ink blue, ochre, olive and vermilion across the seam. Align the banks of a stream, a tower window or the top of a shaft with the board feature it belongs to. A player should recognize a Cup by its bowl and a Wand by its cut branch at thumb size. Preserve the deck’s Marseille numbering and untitled XIII. Use English for the default card faces, interface, documentation and source text. Keep future translations in locale-specific resources.

On a phone, the goal, every row, the illustration and the active power must be readable during play. Place the single card invocation within reach; select its target on the grid. On a wide screen the card art and objective may sit beside the tableau, as in the prototype. Keep the empty-hand opening visually quiet. Mouse, touch and keyboard all give access to the same paths, cancellation and retry after failure. The move counter stays visible beside the goal.

### What happens under the finger

1. **Find a path.** Join two or more pieces of one suit through horizontal or vertical neighbours. A trace can turn and visit each cell once. Slide back over the previous piece to shorten it. Return to the origin of an unfinished gesture to clear the selection and try a new direction within the same drag. The last segment aims.

   **Area clears** use squares and rectangles.
   - **Outline.** Close a four-sided outline along the rows and columns. A square is a rectangle with equal sides. Start at a corner or along a side and draw in either direction. The turns determine the corners. Sides can pass over pieces, targets, gaps or masked cells. A valid rectangle resolves as an area clear on release, even if the drag began as an ordinary trace. A gesture that forms neither a valid rectangle nor a valid trace spends zero moves.
   - **Corner suits.** Ordinary corners match one suit. A fixture is a wildcard corner and can match that suit. It gains progress only when the rectangle uses its scoring suit.
   - **Area and progress.** A square or rectangle clears pieces of every suit inside it and along its sides. With ordinary pieces at all corners, the shape grants 4 progress to each compatible fixture inside or on a side. Fixtures, gaps and masked cells stay fixed. Removing a support can let a loose relic fall. The same thresholds and effects apply in every puzzle. A bonus to later aimed hits is reserved for a future shape.
   - **Target corners.** A fixture at a corner gains 1 progress per cleared piece of its scoring suit, with a minimum of 1, when the rectangle qualifies for that fixture. A fixture matched with a different suit still allows the normal area clear. In later multi-target boards, two or more compatible target corners also link for that many subsequent moves. A trace that feeds any of them shares the same amount with all linked targets. Each paid stroke uses one turn, including a stroke that misses. A new link replaces the current one at full duration.
2. **Aim the endpoint.** While dragging, connect each selected symbol with a continuous ink line and mark the last direction. Resolve the action and the fall on release.
3. **Release and read the fall.** Resolve the suit action, remove the traced pieces and settle each column. Ordinary pieces fall past lamps, inlets, pans and gaps, so every open cell refills from the top. The loose gold Coin is caught when its fall reaches the cell directly above the bell pan. It rings the bell, is collected as fare, and its vacated space refills in the same stroke. Sealed chambers, where a fixture or shelf holds the cells below it apart, are reserved for a later mechanic (see the [sealed-chamber proposal](design-notes.md#refill-around-fixtures-decided-for-now-sealing-kept-for-later)). An ordinary trace also works as a setup move even when it misses a fixture. Each column then refills from the board's supply (see *Every board refills*). Guided supply keeps a stroke available whenever the vacancies can give two pieces a match. An available rectangle also keeps a board playable.
4. **Read the next board.** Resolve landings and fixture reactions, then advance active creatures and runners by their printed step. Check delivery, escape and victory, then age turn-based effects. Chain reactions and card invocation consume no extra actor steps.

**Moves and restarts.**
- **There is no Undo.** A released stroke is committed and spends one move from the board's visible limit. Playing a card is free.
- **Restart is instant.** Restart Deal restores the initial board, hand, charges, ribbon cursors, move counter, actor pose and illustration. In a two-phase encounter, Retry Phase restores that same state from the phase checkpoint.
- **Resolve once on release.** The same stroke from the same state produces the same board and ordered events. Age durations once per paid stroke, including strokes that trigger several settles. A free invocation may resolve a goal immediately. Check the completed stroke for victory before declaring the move budget spent.
- **Running out ends the attempt.** When the moves run out, or the game can tell that the goal is no longer reachable, the board names the cause and offers a restart.
- **No real time.** There are no timers, no speed scoring and no leaderboards. The player can think as long as they like. Every countdown in the game counts strokes (beats), never seconds. Stars and the under-par mark are personal records, not rankings.

| Suit | What the last stroke does | Why a shorter path might be better |
|---|---|---|
| Wands | Send one light per Wand into the adjacent fixture in the direction of the last step. The Fool’s Step uses Wands to light its trail marker. | Two Wands facing a lamp can light it. Extending the path around a corner changes its aim. |
| Cups | Pour one unit per Cup into the adjacent fixture or accessible creature in the final direction. In Lamplighter, the Cups pour oil into the quay lamp, yielding one light per Cup. Water follows printed channels and persists as specified. | Stop at the waterline that meets a ferry landing. Another Cup could send the ferry past it. |
| Swords | Cut one strand per Sword on an adjacent binding. The released object moves when its support permits. | Preserve the third Sword for a second cord once the first weight falls. |
| Coins | Deposit the trace length on the adjacent pan. The pan retains its load. A loose rolling Coin is a distinct relic with its own track and arrow. | Deposit exactly two from a run of four and leave the other two for the opposite pan. |

**Fading fixtures (in playtest).** A board can print a fading rate for its lamps and inlets.
- **The rule.** After each paid stroke that doesn't feed a lamp or inlet, that fixture loses that much light or water, and never drops below zero. Victory is checked first, so a stroke that completes the goal still wins.
- **Why.** Fading turns a quota into a sustained effort instead of a pile of unrelated strokes. The phase lasts longer, and keeping two fixtures topped up becomes the plan.
- **Feedback.** When Lamplighter loses light, briefly dim the lamp and let its glow contract. Show a bubble explaining the loss and clear it when the player starts tracing again. With reduced motion, update the light immediately and show the same bubble. A miss at zero produces no loss and no bubble.
- **Boards.** In the playtest, 002, R2 and R3 fade by 1. 001 doesn't fade, so the first board stays forgiving.

A deal can ask the player to deliver, release, balance, illuminate or restore something. It can ask for a quota of suit actions, or for every piece of one suit, or for every ordinary piece. Show the goal and tracked quantities when the board is dealt. When a guided lesson reveals a target later, show its goal and tracker at the reveal.

For each suit-based objective, show its scoring suit or suits next to its name and progress in the goal tracker. Pair each suit's familiar piece symbol with its name and keep it visible during the attempt. On a board with multiple targets, show which suit belongs to each target. For a wildcard corner, display the suit that earns progress regardless of which suit completes the shape.

### Every board refills

Every board refills, and refill works the same way in every column. The board's **supply** chooses the new pieces. New pieces always enter at the top of their column, above everything already there. Column invariance and vertical order both still hold, so certificates keep working.

What gives a board its character is how its ribbons are written. The two ends of the dial below are not two kinds of board: most boards sit between them, and one board can mix both, for example an open field with one measured column.

| Knob | Open supply | Measured supply |
|---|---|---|
| Contents | Every suit, in generous amounts | Limited stock shared by several useful actions. A target suit may run out. |
| Placement | Even across columns | Deliberate: a run with no Wands in one column, a key arrival in another |
| Visibility | New pieces are revealed after release | Every arrival that matters is on view, because the arrivals are part of the puzzle |
| Moves | Par about 15, limit about 25 | Par about 15 with less slack, or a short teaching hook |
| Feel | Rhythm: many satisfying strokes building toward a quota | Choosing which use of a scarce piece to commit to, with the arrivals in view |

**Rules for every board**
- **Measured ribbons.** Each column has its own authored sequence. Ribbons loop unless the column is marked dry. The next arrivals can be shown before a stroke.
- **Guided supply.** Settle the entire board after each paid stroke and evaluate seeded candidate fills against that position. Favour lower rows and columns with legal pairs, suit variety and several ways to aim at targets. Also project the fall after a visible legal pair clears to see which isolated lower cells would gain a partner. Evaluate these possibilities without playing turns on the player's behalf.
- **Rectangles.** Weight compatible arrivals toward available corners. Reward a ready rectangle and moves that can assemble one from pieces already visible. A player can build the shape by lowering one column or shifting several together. Keep ordinary pairs available alongside those opportunities.
- **Fair arrivals.** Weights govern the suits available to fill an empty cell. Starting pieces and surviving pieces keep their printed suits. Restart repeats the deal and the same choices repeat the same draws. A drag spends no moves and draws no pieces until it is committed.
- **No legal stroke.** Guided fill chooses a match involving one or more arrivals if its sampled fills would leave the board jammed and the supply can create a pair. Authored ribbons keep their exact arrivals. If there is no trace or rectangle available after settling and the player has no way to create one, offer Restart.
- **Opening boards.** Authors lay out fixtures, gaps, masked cells, relics and teaching examples such as the ferry’s Wand pair. Guided fill deals the rest with particular weight on playable lower rows and a trace for each suit. An individual piece can sit alone until the player sets up its match.
- **Arrivals are puzzle material.** A Cup that will drop into column D after three clears can be the partner a plan is waiting for. Planning around what is coming next is a decision every board can use.
- **Dry columns.** A ribbon outlasts the move limit unless the board marks a **dry column** at its top. A dry column stops refilling when its ribbon ends, and its cleared cells then stay empty paper. Dry columns and suits the ribbons never carry are how a board makes a stranding final.
- **Aim matters even in a quota.** A pour counts only if the stroke *ends facing* the inlet, so open boards keep Arcana's core decision: which piece to finish on.
- **Goals.** Quotas of suit actions aimed at fixtures (pour 8, deposit 12, light the lamp with 10, cut 6 cords). Object goals (ring the bell, seat the key, balance two against two). **Clear every piece of one suit**, where no ribbon carries that suit. A full-board Clear needs every column dry, so it is rare.
- **Card certificates quote the ribbons.** A board that requires a card can refill, as long as its certificate holds over every ribbon and says so ("and no ribbon carries a Cup").
- **Vary the dial across a chapter.** Open supply carries rhythm, rest boards and daily deals. Measured supply carries teaching moments, first readings and most Hard and Super Hard boards. Encounters can change supply between phases.
- **A loss says why, and how close it came.** "Two Cups short." "No ribbon brings another Cup."

### One scene, one puzzle state

Every outcome that affects success has an address on the grid: a cell, a marked stretch of track, an edge exit or a visible link between fixtures. The illustration gives that outcome scale, expression and sound. The move resolver supplies one ordered sequence of events to both views. The illustration has no separate physics, input, timer or victory condition.

A blue lightning bolt and blue rings mark linked targets on the grid. The bolt flickers while the link is active and flashes when a trace sends progress across it. The goal tracker shows the remaining turns. With reduced motion, the bolt stays steady while active and the counters still show every gain.

| On the grid | Across the upper edge | Consequence the player can read on the grid |
|---|---|---|
| A Wand lights the Moon’s right tower socket. | A spark runs up the same tower and its gold window catches. The wolf turns toward it. | The right bank marker opens for the indicated interval. The player can time the next Cup stroke from that marker. |
| A deposit changes Justice’s pan totals. | The illustrated beam tilts with those same totals. | The rail changes slope and its arrow predicts the loose Coin’s next step. The upper scale and the on-grid arrow update together. |
| Suspension reverses one column. | The Hanged Man’s crossbar extends over that column and the key enters its ceiling lock from below. | Upward chevrons, the two-beat countdown and the adjacent falling weight remain visible throughout. |

Start an effect at the touched piece, carry it through its actual target, and let the art continue the motion. A cut cord recoils, a falling weight depresses a plate, a bell sounds where it is struck. Settle to a stable, inspectable state after the beat. Keep optional audio muted by default. Reduced motion shows the same order with local highlights, persistent states and a concise result. A sound, screen shake or animation above the grid must never be the player's only clue.

### First thirty seconds · The Fool’s Step

Start with an empty hand, a 6 × 6 tableau and an unlit trail marker fixed at E4. Show the light goal on the marker. Center a large circled move count beside the title block and frame the Wand symbol to the right of the ridge scene. The pointer hand draws a matching pair, a Wand square and a wider Cup rectangle with a Cup inside. An on-board hint bubble explains the shared rule and names the scoring suit where it determines the effect. The bubble clears when the player starts tracing. The player repeats each gesture on the live board. Show a taller Wand rectangle enclosing the marker for 4 light, then a Wand trace aimed at it for 2 more. Finish with a Coin square that uses the marker as a wildcard corner. The guide disappears at 6/30 with 19 moves left. The marker can complete a corner match for any suit. Wand rectangles add light, and other suits clear pieces to set up new moves.

The guided moves use fixed arrivals. After the guide, each column cycles through a sequence with one of each suit. The player uses setup strokes to make new chances to light the marker. The Fool waits below the dark ridge from the card. The broken trail brightens as the marker gains light. At the quota, the trail becomes continuous and the Fool sets out. Par is 14 and the move limit is 25, including the six guided strokes. [Opening rules and scoring](opening-deals.md#rules-in-play) · [Replication data and replays](opening-deals.md#replicate-the-deal) · [Playtest follow-ups](opening-deals.md#playtest-follow-ups)

### Future lozenge group

Introduce four-sided diagonal lozenges in a later puzzle group after the opening teaches rectangles. Author a separate combo set and certify its puzzles against those rules. The archived Wreath studies preserve the earlier experiments.

### Combos worth setting up

A combo resolves when a single stroke causes two related changes that matter on the grid. It can branch, as when one rectangle feeds two fixtures and removes a support. It can also unfold in sequence, as when a cut releases a weight, the weight tilts a pan, and the changed slope turns a runner away from a drain. Keep ordinary matches under player control. Automatic reactions belong to printed rules the player can inspect.

- **With the Moon**, prepare two units of water while preserving a Wand pair. Arm Reflection and aim at the accessible tower. Its twin lights and the far bank opens. The remaining Cup stroke can finish the crossing before the wolf turns back.
- **With Justice**, test the direction of a four-Coin run, then shorten it. Two well-aimed deposits can balance the pans directly. One large deposit and Equalize can turn a runaway Coin around. The useful reward is seeing the arrow change while the Coin is still recoverable.
- **With values**, feed two Cups into a third so it reads 3. Keep it safe while the column settles, then trace it with one neighbour for a pour of four. On a board with dignities, a Sword stroke that ends facing a Wand also grows that Wand by one, because air feeds fire.
- **With the Hanged Man**, cut a binding before disturbing the matching row. Suspend the column containing the key. A single horizontal stroke then opens room above the key and below the neighboring weight. One rises, the other falls, and both arrivals can be seen at once.

A level designer should be able to name the prior choice that made the combo possible and what would happen with a different endpoint or order. Test whether a player can point to the connection afterward. Extra bells, birds and musical intervals can celebrate an extended route. Campaign access and card rewards stay fixed. Avoid streak loss, random jackpots, paid extra moves and automatic replay.

**Combos are never scripted.** Every combo resolves through the single turn order and the general rules, including two cards in one hand or a card meeting a trump on the board.
- **Each pair is ruled once.** Every pair of concepts gets one ruling in the interaction table (see *Long-lived production*). Only pairs where one changes the meaning of the other headline a board.
- **Order should matter.** Prefer pairs where playing A then B differs from playing B then A.
- **Round trips are rare.** A card played with its own reversal is a rare showcase. Its certificate must show that something changes in between.

### Values, feeding and elemental dignities

These rules let a piece change what it is worth, so combinations grow out of what sits in each square: one Cup or two, one Wand or two, and how they meet. Each rule is printed on the boards that use it, so older boards keep their meaning.

**Values.** A piece can show a small ink numeral beside its emblem: its value, from 1 to 5. A piece without a numeral is worth 1. A trace's strength is the sum of its values, so a Cup worth 1 traced with a Cup worth 2 pours 3. Values are taught in the Empress chapter.

**Feeding.** On boards that show values, a trace that ends facing a piece of its *own* suit feeds it:
- The traced pieces leave, and no action fires.
- The facing piece's value rises by the trace's strength, up to 5.
- The grown piece shows its new numeral after the stroke.

The decision is spend or save. You can spend a group now, or feed it into one piece and keep that charge for a bigger stroke later: one Cup and two Cups become a Three of Cups, ready for a large pour two strokes on. Feeding is taught in the Empress chapter.

**Long-trace charge.** On boards that print it, a trace of five or more pieces leaves its last piece behind after the action fires. That piece is worth 2, or 3 if the trace was seven or more. This rewards the long stroke the way match-3 games reward long matches, but the reward is only a higher value, never a new kind of special piece. It first appears in Volume 2, with a one-line legend.

**Elemental dignities.** Each suit carries its element, in the most common attribution: Wands fire, Cups water, Swords air, Coins earth. Readers in the Golden Dawn tradition weigh neighbouring cards by how their elements relate. Arcana uses the same three relations when an action ends facing a piece of *another* suit:

| Relation | Pairs | Effect on the facing piece |
|---|---|---|
| Friendly | Fire with air (Wands and Swords). Water with earth (Cups and Coins). | Its value rises by 1 |
| Contrary | Fire with water (Wands and Cups). Air with earth (Swords and Coins). | Its value falls by 1. At 0 it becomes a blank stone, which supports pieces but can't be traced. |
| Neutral | Fire with earth. Water with air. | No effect |

The action otherwise resolves as usual; a spark, for example, keeps travelling. Boards that use dignities show an element mark beside the goal. Temperance's second movement introduces the grammar with one friendly pair and one contrary pair. The remaining pairs then appear without tutorial boards, each with a one-line legend, because the three relations predict them.

**Certificates.**
- Values turn Count and Arithmetic arguments into sums.
- Feeding and contrary dignities can only reduce the number of traceable pieces. They never create a partner.
- Blank stones are new permanent blockers, and authors check certificates against them.

### Pieces from the deck

The board is drawn from the same deck as the album. Today's suit pieces stand for the Minor Arcana's pips. Later volumes add the rest of the deck to the board without changing what an ordinary piece does. [Piece design](design-notes.md#7--the-minor-arcana-on-the-board) · [Card motifs for future levels](#card-motifs-for-future-levels)

**Trump pieces (the Major Arcana on the board).** A trump belongs to no suit.
- **The rule.** A trace of any suit may end on a trump. The traced pieces leave, and the trump fires its card's power from its own cell. The trace's last segment aims it, and the power uses the trace's suit and length where it needs them. Then the trump leaves and its column settles.
- **Where and when.** A trump falls like any piece, so the player sculpts *where* it fires through gravity and chooses *when* by ending a trace on it.
- **The Fool is the Excuse.** Traces may step over its cell without including it, and it never leaves.
- **Teaching a card.** In chapters whose card shows a figure or an act, the opening boards teach the power through its trump in place of a new environmental rule. The first reading then lends the card, so the player can choose the place as well.
- **Reprising a card.** Once a card is owned, its trump can reappear on later main-route boards at no new learning cost.

**The Minor Arcana**, in order of arrival:

| Layer | On the board | Behaviour | Arrives |
|---|---|---|---|
| Pips | The ordinary suit pieces | Trace, fire, fall | Level 1 |
| Aces | A fixture: the suit's source at the top of a column | It supplies vacancies reachable from the top, in ribbon order | Earlier as the visible source of a ribbon, or with the Minor Arcana volume |
| Values (1–5) | An ordinary piece showing a small ink numeral | Adds its value to the trace's strength, and grows by feeding (see *Values, feeding and elemental dignities*). Rising or falling runs come later, as a constraint. | Values and feeding with the Empress (Volume 1). Runs with the Minor Arcana volume. |
| Court figures | Page, Knight, Queen, King of each suit | The Page falls and delivers its action where it lands. The Knight moves one cell per paid stroke. The Queen never leaves and adds 1 to any trace through her. The King fixes the direction his trace fires in. | The Minor Arcana volume. Earlier as encounter characters. |

**Limits on special pieces.**
- **Invariants.** Each special piece or rule states which certificate invariant it breaks, and authors check certificates against the table below.
- **One per Normal board.** A Normal board carries at most one special piece type, a trump or a court rank. Hard boards may carry two.

| Piece or rule | What it breaks |
|---|---|
| Knight, Wheel trump, Lovers trump, Draw Together | Column invariance, for the pieces they move |
| Hanged Man trump, Suspension | The assumption that everything falls toward the floor, for two paid strokes. Reversing gravity alone preserves the order of surviving pieces within a chamber |
| Queen | Count arguments: her suit never runs out beside her |
| King | Reach arguments built on the endpoint's direction |
| The Fool (the Excuse) | Isolation arguments across its cell |
| Values, feeding, dignities | Count and Arithmetic arguments, which must use sums. Feeding and contrary dignities only reduce the number of traceable pieces, and blank stones are new blockers. |
| Refill | No invariant, because arrivals enter above. A ribbon can still bring a partner, so a certificate names the ribbons it relies on. |

**Visual direction.** The current look is the starting point. It can evolve later, but these mechanics must not be the reason it changes.
- **Ordinary pieces** start from their current emblems: the Wand's cut branch, the Cup's bowl, the Sword, the Coin. They use the current palette of ink, ink blue, ochre, olive and vermilion. Calling them "pips" is design vocabulary; it doesn't mean they should be redrawn as pip cards.
- **New piece types** are additions in the same flat, printed language:
  - A piece with a value is the current emblem with a small ink numeral in the card-label type. A blank stone is a plain paper tile with a fine rule.
  - A court figure is the unchanged emblem with a small rank mark in silhouette: cap, horse's head, veil or crown.
  - A trump is a small framed card face carrying its Marseille numeral and one silhouette taken from that card's own illustration, such as the Sun's disc or the Tower's crown.
  - An Ace is drawn as a fixture, like the lamp or the pan.
- **The usual tests apply.** Every new type must pass the thumb-size recognition test and the non-colour shape test before it ships.

### Campaign and acquisition

The Major Arcana span three volumes, one per act, in deck order. The Fool is a prologue of about twenty boards. Volume 1 covers chapters I–VII, Volume 2 VIII–XIV, and Volume 3 XV–XXI, which completes the album at about level 525. A chapter runs about twenty boards in Volume 1, about 24 in Volume 2 and about 28 in Volume 3. The extra boards are reprises, combinations and layered Hard boards, which the growing pool of concepts can supply. [Design notes](design-notes.md#design-space) sets out the cadence and the shape of a chapter's second movement. A chapter introduces one player power. It teaches that power either through an environmental rule or through the card's trump piece on the board. The rule or trump makes a situation worth reasoning about; the card in hand lets the player intervene where and when they choose. A chapter's boards should change *what decision the player makes*, not merely move the starting pieces around.

**The Fool has its own sequence.** Boards 001–012 are cardless. Fragments appear at 001, 003, 006, 009 and 012. Board 013 lends Leap and awards the Fool on a clear. Board 014 tests independent use, 016–017 are optional, and 020 closes the free prologue with a two-phase encounter. Keep these dependencies when opening boards in parallel. For later chapters, identify a brief by chapter and local slot until the atlas receives final release numbers.

| Chapters I–XXI · local slots | Hand, unlock and intent |
|---|---|
| 1–3 | New location. The new card is still missing. Read or manipulate its environmental rule, or fire its card's trump piece, using the suits. These are empty-hand boards by default. |
| 4–5 | See the rule interact with a familiar constraint. In later chapters a named, previously earned card may be dealt. |
| 6 | **First reading.** The illustrated card appears face up as a loan. One activation is available. Winning grants permanent ownership, immediately and exactly once. Give the loaned power at least two consequential uses that can each reach the goal. Record why the goal requires the card and replay examples of both uses (see *Solvability by design*). |
| 7 | First independent use of the owned card. The level deals it face up. The move limit leaves room for a weak first use of the card, and a restart costs little. |
| 8–9 | Optional challenge leaves. Revisit the rule in two different settings. Preview the hand and difficulty before entering. Rewards are an alternate illustrated vignette and a recorded clear. |
| 10 onward | The chapter's second movement: reprises, a trump reprise, a twist, a rest board, combinations, and optional layered Hard and Super Hard boards (see [chapter shape](design-notes.md#10--chapter-shape-in-each-volume)). |
| Last | The chapter encounter closes the location. Completing the main route unlocks it. Optional boards can be revisited at any time. Beating the encounter opens the next chapter. |

A card has one charge per attempt unless an encounter explicitly says otherwise. Charges reset on restart. Owned cards live in an illustrated album; campaign designers deal a small, fixed hand from that album. A combined board may specify two once-per-attempt cards. Do not require random draws, duplicate copies, grinding, optional victories, purchases, or out-of-order cards for progression. Later optional “choose one” deals list only verified winning hands. A visiting player can play a daily puzzle with a temporary loan without changing campaign awards. Persist the completion and the award together; replay, offline resume, and device restore must never consume or duplicate a card.

#### Future deck unlocks

**Proposal.** Add a deck shelf to the album where players can preview editions and see how to earn them. A short, optional reading built around an edition’s artwork unlocks that edition permanently. For example, a Three of Swords reading could use three cuts on a rain-soaked board to unlock the [abstract Rider–Waite–Smith deck](#deck-artwork-references). Players can switch between earned editions in the album. The unlock grants alternate artwork for cards as the player earns them. Each card’s identity, ownership and powers carry across editions, and authored deals retain their rules and progress.

### Progression

**Campaign path.** Play opens a vertical route that starts at the bottom and winds upward around fragments of the deck. Each numbered marker carries its scoring-suit badge and opens a closable preview with its puzzle illustration, scoring suit, goal, move limit, difficulty and Play control. Locked phases are available to preview. Clearing a puzzle unlocks the next phase, and the completion action opens its preview.

**Three acts.** The Major Arcana follow the traditional Fool's journey, laid out in three rows of seven cards. Each act is one volume.

| Act | Chapters | Job |
|---|---|---|
| The Fool (prologue) | 0 | The four suit tools, gravity, gaps and Leap, with one fixture per suit |
| I · The tools | I–VII | Choosing what a piece does: suit changes, folds, values and feeding, chambers, ordered events. Boards stay static until the Chariot's cart closes the act. |
| II · The countdowns | VIII–XIV | Moving things that all follow one actor grammar, and the elemental dignities. The light, support, identity and water systems deepen. |
| III · The world answers | XV–XXI | Every system returns under stress, leading to a finale that recombines them |

**Rules for every chapter**
1. **Extend a system before adding one.** Each chapter names the system it extends: light, water, support, weight, identity, value, countdowns or topology. It keeps that system's fixtures and names.
2. **Reprise on the main route.** Each chapter brings back an earlier system, or the trump of a card the player already owns, on its main route. Every owned card returns on the main route at least once after its own chapter.
3. **The twist is on the main route.** Each chapter's most surprising board sits on the main route, not only in optional slots. That board shows a consequence nobody expected, or uses the card against its grain.
4. **One actor grammar.** Every actor advances one step per paid stroke and marks its current direction on the grid. Actor types differ in exactly one way:
   - the rim follows a schedule;
   - the cart follows switches;
   - the runner Coin follows the tilt;
   - the lion follows a cycle;
   - the crab seeks a goal and can be lured.
5. **Unlock in parallel.** In chapters I–XXI, open small groups of boards that share prerequisites (for example slots 1–3, then 4–5, then 10–13). The Fool’s Step opens the Fool’s prologue on its own. Open later groups only when their suit tool or card is available.
6. **A ramp, not a sawtooth.** Tiers are judged against everything the player owns by that point, so a Normal board in Act III combines two systems. Each chapter names one or two rest boards and places them after its hardest main-route board.
7. **No layers in a concept's first chapter.** A concept never meets a layer (see *Layers on hard boards*) in the chapter that introduces it.

### Challenge, hints and fairness

Use Normal, Hard and Super Hard as player-facing predictions, judged against everything the player has learned by that board.
- **Normal** asks for a readable local decision.
- **Hard** asks players to anticipate how a setup will affect a later fall or opportunity. A tempting move can cost a resource or a window two or more strokes later. Keep an identifiable way to adapt when the remaining resources allow it. For the depth target, look for at least four dependent strokes in the setup. Check that another approach to the same goal remains viable.
- **Super Hard** overturns something the game has taught the player to believe. It often does this by asking them to coordinate two stroke countdowns, preserve a resource across a change of state, or use one stroke for two distant goals.

More colours, hidden refills, bigger boards and very low move limits do not, on their own, earn a higher rating.

**Move limits and stars.** Every board shows a move limit. Set the clear limit by replaying the approaches the board invites, including a recovery on the main route. Set par separately as an optional efficiency target that has been achieved on the same deal. The difference between them is the slack. **Board length.** A board is a phase of play, not a single trick. The best solves take **about 15 moves**, the limit tops out at **about 25**, and running past the limit loses the board. Quotas, fading fixtures and the supply are tuned together to hit that range. Use the ranges below as authoring defaults. Where an atlas brief proposes a tighter limit, record the intended pressure and test its losing line before accepting the exception.

| Tier | Typical par | Limit |
|---|---|---|
| Normal | About 15 | About 25 |
| Hard | 15–18 | Par + 5 to 7 |
| Super Hard | 18–20 | Par + 3 to 5, never above 25 |

- **Short hooks are rare exceptions.** A teaching board can be short on purpose. On 001 par is 14, as demonstrated by a clear that includes the six guided strokes. Name intentional short boards in the atlas.
- **Archived web playtest.** All eight archived deals have reproducible clears at their recorded seeds. Automated checks exercise rules, falls and authored routes. Use human play to judge time to the first useful trace, recovery in lower rows, variety of approaches and how often players intentionally build a lozenge. Pay particular attention to The Mooring, The Ferryman's Fare and Twin Wreath. [Run the archived checks](opening-deals.md#replaying-the-archived-prototypes)

- **Stars.** Any clear earns one star. A clear within par plus half the slack (rounded up) earns two. A clear at or under par earns three. A clear under par also earns a distinct mark, so a shorter line rewards the player instead of exposing a defect.
- **The main route never needs more than one star.** Tight limits belong to Hard and optional boards.
- **Keep the restart cheap.**
  - When supply is tight, keep attempts short and leave enough moves for the slower viable approach.
  - On open boards, a loss says how close it came, and main-route slack is generous.
  - Encounters: checkpoint at their phase change, so a failure in the second phase restarts that phase.
- **Design the first failure.** Place the first likely loss on purpose, on the board where a partner is stranded just before Leap. It teaches Restart and the singleton lesson together.

**Tutorial guidance and feedback.**
- **Opening guides.** The Fool’s Step demonstrates each of its six gestures with a pointer hand and waits for the player to repeat it. Reduced motion uses the same path with still markers. The archived Far Wreath guide demonstrates the former lozenge rules. Play proceeds independently after the last demonstration. [Opening routes](opening-deals.md)
- **Feedback** distinguishes four cases: an illegal gesture, a legal setup move, an opportunity that closes after a set number of strokes, and an unrecoverable loss. A loss is declared only when it is certain, for example when a needed suit is down to one piece, an actor has escaped, or the moves left are fewer than the groups that can never merge. The check always counts the rest of the supply ribbons, which the game knows exactly because they are authored. A single Cup is not stranded if a ribbon still holds a Cup for its column or a neighbouring one. So a board declares an early loss only when something no ribbon replaces is stranded, or when an upper bound on what the remaining moves can produce falls short of the goal. Otherwise it plays on until the moves run out. Include reduced motion, non-color suit shapes, clear focus, readable lane arrows and a text description of the expected move.

### Layers on hard boards

A Normal board has one puzzle: the board itself. Hard and Super Hard boards can add **layers**. Each layer is a second set of conditions, coupled to the board.
- **The inner constraint.** A condition printed in the board's frame or on the goal. Families:
  - *Path:* every stroke turns; no stroke is longer than three; each stroke is longer than the last.
  - *Conservation:* never strand a suit; a named piece never moves.
  - *Order:* play the suits in a printed cycle.
  - *Run:* values ascend or descend along a trace.
  - *The reading:* a small framed window must end showing a printed arrangement.
- **The upper scene.** The illustration gets a discrete state track with one position per column. Only addressed board events change it: a bell in column C pulls the ferry one step toward C. This keeps *One scene, one puzzle state*, because the track works as a row 0 that the goal tracker mirrors.
- **The spread.** The hand is laid out so that each card's position limits how it can be played:
  - *Past · Present · Future:* cards are played left to right.
  - *The cross:* the crossing card is played on the same beat as the card it covers.
  - *Two paths:* playing one card discards the other.

**Rules for layers**
1. **Tiers.** Normal boards have no layers. Hard boards have one. Super Hard boards have two, set against each other, so the board's best move is bad for the other layer.
2. **Coupling.** At most two coupling channels connect the board and the scene. The board's brief names them.
3. **Make constraints readable.** Mark restricted cells, legal suit orders and remaining turns on the current board. A warning can describe an already drawn path that breaks a printed rule. Show the resulting board after the stroke resolves.
4. **Each layer can be read on its own.**

Layers multiply every concept without adding engine rules, so they are the long-term source of fresh hard boards.

### The board brief

Before layout work begins, every board's entry states:

| Field | Question |
|---|---|
| Misbelief | What wrong belief does this board overturn? A tutorial or rest board may leave this blank, but must be labelled as one. |
| Cast | Which pieces can serve different plans? Which supply a needed quantity or support something that can fall? |
| Pressure | What makes a careless stroke costly: scarcity, a countdown, or the move limit? Every board has at least one. |
| Supply | Where does the board sit between open and measured supply, and which ribbons matter? |
| Payoff | Which stroke does two jobs or completes a visible chain? |
| Choice and recovery | Which approaches spend a different resource, aim at a different target or cause a different fall? After a plausible weak move, what useful opportunity remains, and at what cost? |
| Losing line | Which repeated mistake or consequential commitment can put the goal out of reach? |
| Layers and certificate | Which layers the board uses and how they couple. On a board that requires its card, the one-line certificate. |

### Solvability by design

**1 · Design around a decision.** Start with a goal and something the player has to manage, such as the inlet’s exact capacity or one charge of Leap. Name two or three different things a player could sensibly try. Put the pieces, targets and visible supply on the same deal so those choices can actually work. Building backward from a satisfying fall is a useful way to place the first few pieces. Then build a second use for a piece or power and play forward from the common start.

Test a decision *after* the opening, too. On a main-route board, try a plausible inefficient stroke, keep every consequence and look for a clear from there. If all reasonable choices lead back to the same compulsory combination, change a support, add another reachable endpoint or bring a useful piece forward in the ribbon. Add moves when the problem is the cost of recovery. Extra turns alone cannot free a permanently isolated piece.

**2 · Write a card certificate.** Every board that requires a card states, in one line a reviewer can check by eye, why it cannot be cleared without it. If no such sentence can be written, the board is not ready. For chambers with ordinary vertical gravity, check the following invariants. Consider the complete supply, meaning every piece on every ribbon, and every available transport, conversion or rotation before relying on either argument. Refill never breaks the invariants, because arrivals always enter above the pieces already in a column. But it can bring a partner, so a certificate that depends on a suit being absent must say which ribbons lack it.
- *Pieces never leave their column*, so a piece can only ever touch pieces in its own column or a neighbouring one.
- *Pieces in a column keep their vertical order*, even as they fall past fixtures, so nothing below a piece can ever rise above it. Where a later mechanic seals a chamber, the same holds within that chamber.

Check rectangles alongside traces. An isolated piece can still be cleared inside a shape. A target unreachable by its usual suit action can still be fed by a matching area clear, a legal target corner, or a link. Fool 013's earlier layout has a reproduced cardless clear and needs a new certificate. [Reproduced route](opening-deals.md#fool-013--one-impossible-step)

| Certificate | The argument | Typical boards |
|---|---|---|
| **Isolation** | A piece can never become adjacent to any partner. Either no partner exists in its own or neighbouring columns, or every possible meeting depends on that piece leaving first. | Gaps, separated rows, pockets |
| **Count** | A suit has a single piece left, or too few pieces exist for the required stroke. | Singletons, exact-length strokes |
| **Arithmetic** | The fixture needs an exact quantity that no combination of reachable deposits or pours produces. | Pans, basins, pools |
| **Reach** | No cell exists where a trace of the right suit can end aimed at the target. | Lamps, seals, keystones, windows |
| **Timing** | An actor or window resolves in *k* beats, and every cardless route needs more than *k*. | Patrols, rims, latches, runners |
| **Budget** | The board contains *g* groups that can never merge, so it needs at least *g* strokes, and the budget is below *g*. | Boards locked by their stroke allowance |

Each certificate names which necessity claim it supports: *impossible at any length* or *impossible within the budget*.

**3 · Check the budget against different approaches.** Save short replays as test cases. Verify each starts with the same hand and ribbons, achieves the goal and fits the clear limit. Record separately which ones earn par. Keep the clearest, most economical play as an optional discovery.

**4 · Challenge the design in play.** Replay the approach, recovery and losing line through the same engine the player uses. Try the required card’s level without the card to challenge the certificate. Watch where players repeatedly spend a stroke on the same target, miss an available setup or cannot explain their loss. Keep a replay per approach, the card certificate wherever a power is required, and the observed playtest results. Repeat after edits to layout, supply, card rules or budget.

### Stories and encounters

In encounters the same grid persists across phases, and a phase may change the supply, for example an open phase followed by a measured one. Change which bank is accessible, which rail is loaded or which fixture is lit. Show the transition in the upper illustration while retaining its on-grid counterpart. The opening needs no story exposition. Across the opening boards, reveal five distinct card fragments, in the Fool's prologue on 001, 003, 006, 009 and 012. The first reading awards the assembled illustration and opens its scene in the album. On the final deal of each chapter a figure or location asks something of the player using the chapter’s rules. The Hanged Man can ask the player to recover a bell while lowering its counterweight. The Moon can ask for safe passage for a creature that is afraid of the light. An encounter can change conditions between two visible phases. Show both goals, carry state across the transition, and keep dialogue skippable and replayable. Avoid real-time combat as a requirement.

### Long-lived production

Treat the 22 Major Arcana as the vocabulary of the main campaign. The rest of the 78-card deck supplies suit patterns and court figures for later levels. A volume can be a journey through new locations, a three-card spread with different orderings, a story about a returning character, or an optional daily deal. Release fewer levels when a new system needs proving. Decades is a sustainability goal, not a content-volume forecast. [Card motifs for future levels](#card-motifs-for-future-levels)

- Author levels as versioned data: the footprint and terrain, the supply ribbons and dry columns, ordinary and loose pieces, gravity and supply, fixtures, actor routes, triggers, goal predicates, hand and charges, sample clears with the decision that distinguishes each, a recovery example, any required card certificate, state-aware hints, chapter dependencies, the cell or edge and shared state event behind each presentation cue, accessibility text and localization keys.
- Build an editor with turn scrubbing, copy/reflect, dependency checks, runner and replay export. Initially hand-author the main route. Later generate candidates from human-authored relationships, reject duplicates and blind guesses, and curate before release. Archive a versioned ruleset or migrate and retest old levels deliberately.
- Validation follows *Solvability by design*: distinct sample clears, a written certificate wherever a card is required, and a verifier pass that respects the shipped turn order, all legal trace lengths, charges, actor step counters, ribbon cursors and the move limit. The verifier’s attacks include shortcuts such as winning by repeated arbitrary clears. Visible, authored ribbons make sample clears and card certificates reproducible.
- Rotate among evergreen campaign, optional mastery, and shorter side stories. Introduce occasional new objects only when their interactions yield several worthwhile boards; return to familiar objects to control tutorial and maintenance cost. Keep completed chapters available indefinitely. A content release can add a storyline with zero new engine rules.
- **Concept ledger.** Keep one ledger of everything a player must learn, weighted by how much it costs to learn:
  - **1:** a new rule, fixture, actor behaviour, piece type or upright power.
  - **½:** something derived from known concepts: a system extension, a reversed card, a constraint family, a spread.
  - **0:** a known concept in a new place or with a new number.
- **Interaction table.** Rate every pair of concepts:
  - **Inert:** never feature it.
  - **Additive:** use it for volume: open boards, rest boards, daily deals.
  - **Transformative:** use it for novelty: feature boards, first readings, Hard boards.
- **When to add a concept.** Introduce the next concept only when the pool's unfeatured transformative pairs fall below about one chapter's worth, four to six pairs. The gaps between new concepts then widen on their own as the pool grows.
- **Active sets.** After Volume 3, each volume declares an active set of about 8–12 concepts and rotates a few in and out. That keeps its interaction table and its refresher small.
- **Grammars that multiply.** Build concepts from small axes at right angles:
  - suit × fixture role (receiver, store, gate, emitter);
  - power × upright or reversed;
  - power × hand or board (card or trump);
  - court rank × suit;
  - suit × value;
  - action suit × facing suit (the dignities).

  Each axis behaves the same everywhere and can be read on the piece. A combination that needs its own exception is a new concept.

### After the third volume

The album is complete. The player can now choose *where* the deck goes next. Keep a chronological map for people who want a long journey, alongside a shelf of standalone volumes for newcomers and returning players. Every volume lists its required concepts and opens with one short refresher. Loan its fixed hand on entry so a new player can join a side story immediately. Preserve earned ownership in the original album.

| Expansion proposal | Returning systems | A new decision an author can build around |
|---|---|---|
| The winter ferry | Temperance basins, Chariot switches, Strength patrols | Ice closes a surface channel one beat after the last pour. Ferry a creature across on the wet beat, then use the frozen channel as a solid crossing. Ship only after those two uses are demonstrably distinct. |
| Letters from the old mint | Justice rails, Judgement memorials, the courier | A recipient weighs down a pan by taking delivery. The player can recall the old payment after delivery changes who is standing on the scale. A story told in three visits to the same room needs no new card. |
| The night market | Hermit sight lines, Moon mirroring, Emperor shelves | Three stallholders ask for different deliveries. A raised awning helps the lantern keeper and blocks the moonlit stall. Give two valid orderings and let the last delivery select the closing vignette. |

**Reversed cards.** Once the album is complete, players revisit each location to earn its card reversed. A revisit uses the same tableau, at night or in another season.
- **One operation per reversal.** Every reversed power comes from its upright power by exactly one operation: invert the effect, swap the target (the player's trace for the world), or invert the time.
- **Four tests.** Each reversed power must:
  1. produce decisions the upright power doesn't;
  2. show its resolved effect on the grid;
  3. not dissolve a whole certificate type;
  4. allow a first reading that carries a certificate.

  A card with no reversal that passes stays upright only.
- **The revisit.** It opens with boards that use the upright card against its grain. Its first reading awards the reversed card, which hangs upside down beside its partner in the album.

See the [draft inventory of reversed cards](design-notes.md#inventory-first-proposals-there-to-show-the-space-exists) for all 22.

For each future episode, commission a one-sentence player discovery, build a teaching room and a reversal of that lesson, then ask a second designer to create a third puzzle from the same rule. If the third is only a larger layout, develop it as a one-off encounter or retire the rule. Commission further rooms after a blind playtest. Reserve space for quiet familiar levels between discoveries. Following a season, use completion and return data to choose which location to revisit and preserve the old deals for replay.

**Capacity example.** At an illustrative pace of one curated chapter of about twenty boards per quarter, 20 years would require about 1,600 additional authored boards, plus compatibility testing. That is a production scenario, not a release commitment. Measure hours for layout, certificates and verifier runs, accessibility, localization, encounter art and retuning on the first two batches. Use those figures to choose an affordable cadence. Commission a guest-authored chapter against the same editor and acceptance tests before investing in community publishing.

### Commercial model and success criteria

Proposed launch model: a free chapter through the first encounter, followed by a permanent campaign unlock. Test willingness to pay with the actual chapter and a transparent count of available boards. Later sell complete illustrated story volumes. Keep restarts, hints and all cards needed for purchased puzzles included. Never sell moves, lives or restarts. Track production and localization cost per accepted level before promising a release cadence.

| Decision gate | Evidence needed |
|---|---|
| Can a newcomer read the board? | In a first test with ten players, target at least eight completing The Fool’s Step on their first attempt with the built-in guide and without extra hints or facilitator help. Record the time to the first clear and to the first light gained. After the hand disappears, observe whether the player can light the marker independently and explain the path they chose. |
| Can players read and build a rectangle? | After The Fool’s Step, watch for unaided setup strokes, starts along a side and attempts through a target. On later link boards, ask players to identify the linked targets, read the duration and use the available window. |
| Do board and illustration read as one scene? | Test Moon, Justice and Suspension with sound off and reduced motion on. Ask players to point to the cell that caused the reaction above and predict the next playable consequence. With the panorama temporarily covered, the objective, legal next moves, stroke countdowns and outcome must still be legible from the board and its goal tracker. |
| Does the grid retain its feel? | Inspect 001, a moving-target deal, an 8 × 9 open-supply board and a two-phase encounter on a narrow phone. Every cell stays visible during tracing. Players can find an alternate group, turn a trace, backtrack, aim its endpoint and commit without shifting to a separate control surface. |
| Is acquisition legible? | After Fool 013, ask what the player now owns. On 014, observe whether they use Leap independently, then restart and ask how many charges are available. Verify that replaying 013 awards the card exactly once. |
| Do players see choices? | Observe unprompted first attempts. Record how each player used the key resource, whether they changed plans after a fall, and where they felt forced to restart. If everyone repeats one combination, show a fresh group the same board after making the alternative easier to see. |
| Is difficulty genuine? | For each candidate tier log unhinted first-attempt clears, restarts and the stroke each failed attempt ended on, moves used against the limit, stars earned, hint depth, solve-time distribution (an internal playtest measure, never shown to players), abandonment and players’ explanations. Compare experienced players separately. Fool 008 currently proposes three strokes against a four-stroke Hard requirement. Review its witness and retune the layout or tier, then compare observed results. |
| Can production scale? | Test the Fool’s 20-board prologue and three later greyboxes covering a moving target, opposing gravity and a combination of powers. Measure hours per accepted puzzle, review backlog, and number of genuinely distinct interactions per new rule. Expand to the next batch only after certificate review, the heuristics verifier and human review work reliably. |
| Can the campaign ship? | Each release board has reproducible, meaningfully different clears with its dealt hand; every card-required board has a written certificate that survived a verifier pass; every acquisition has a permanent award; the main route clears from a fresh profile without side content. Restore mid-puzzle, replay old saves and preserve accessibility across all mechanics. |

**First production milestone**

Playtest the 6 × 6 opening and full clear with touch, mouse and keyboard. Observe how players read the traced path, the fixture reaction and the fall, then change their plans. Test a full 8 × 8 open board and a measured board whose stranding depends on its ribbons. Use the Moon’s moving target and the Hanged Man’s opposing gravity as the first later-campaign integration checks. The atlas spans all three volumes. Its level numbers will be reassigned as chapters are re-authored at their new length. Treat numbered entries as release candidates after layout, refill, budget and playtest sign-off.

### Card motifs for future levels

This is an authoring inventory for all 78 cards in each tradition. The motif columns identify the parts of the card that can carry a game rule, such as a tool, vessel, creature, structural feature, repeated shape, or spatial relationship. The level uses are Arcana design proposals. Use Major Arcana motifs in their campaign chapters or later reprises. Draw on the numbered and court cards for subsequent Minor Arcana levels and encounters. These are candidates for future deals and do not assign level numbers or require a separate mechanic for every card.

Use a fixed fixture for an addressable source, receiver, store, gate, switch or support. Give moving creatures and figures a cell or marked route that a fixture can affect. Treat portable weights, vessels and keys as relics. Shape and spacing can supply the level layout or its win condition. For each selected motif, specify the initiating stroke, the visible state change and the decision it creates. Reuse the suit verbs and existing turn order. Test that ordinary traces, lozenges and linked progress respect the authored goal and any required-card certificate.

#### Deck artwork references

- **Marseille with abstract courts.** The 78-card edition extends the original Major Arcana with Marseille-style pips and 16 geometric court cards. It uses Justice VIII, Strength XI and an untitled XIII. [Full sheet](../deck/marseille-abstract-courts/sheets/full-deck.png) · [Card manifest](../deck/marseille-abstract-courts/manifest.json)
- **Abstract Rider–Waite–Smith.** The 78-card edition distills each scene into geometric forms. It uses Pentacles, the numbered Fool, Strength VIII, Justice XI and a titled Death. [Full sheet](../deck/rider-waite-smith-abstract/sheets/full-deck.png) · [Card manifest](../deck/rider-waite-smith-abstract/manifest.json)

- **Marseille.** Uses the same Major Arcana and numbered suit cards as the edition with abstract courts, with a different set of 16 court cards. [Full sheet](../deck/marseille/sheets/full-deck.png) · [Card manifest](../deck/marseille/manifest.json)
- **Rider–Waite–Smith.** The scenic edition uses more of the figures and settings from Pamela Colman Smith’s illustrations. [Full sheet](../deck/rider-waite-smith/sheets/full-deck.png) · [Card manifest](../deck/rider-waite-smith/manifest.json)

The original Portuguese sheet is the source for the Marseille Major Arcana. It is stored as `deck/reference/tarot.png` in `Arcana-Code-and-Prototype.zip` in Downloads. Each edition retains its SVGs and a full-deck contact sheet. [Rendering card PNGs](../deck/rider-waite-smith/README.md#rendering-card-pngs)

#### Marseille tarot · reference and use

Use Jean Dodal's Lyon pack, dated 1701–1715 by the BnF, as this inventory's historical reference. Details vary among Marseille prints. Arcana retains its own Marseille-based artwork, Justice VIII, Strength XI and untitled XIII. Read the numbered cards through their suit emblems, quantities, divisions and ornament. For example, crossed batons can suggest routes and curved swords can suggest boundaries. The board arrangements below are adaptations of the pip patterns. [BnF catalogue record](https://catalogue.bnf.fr/ark:/12148/cb40918567t) · [Original card scans held by the BnF](https://commons.wikimedia.org/wiki/Category:Jeu_de_tarot_de_Marseille_destin%C3%A9_%C3%A0_l%27exportation_-_jeu_de_cartes,_estampe_-_btv1b10537343h)

##### Marseille · Major Arcana

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Fool · unnumbered | Traveller, walking staff, shoulder bundle, animal at his heels | Put a traveller and bundle on separate sides of a gap. Leap can reach the bundle's landing marker. A trailing animal can make the slower route cost a turn. |
| I · Magician | Worktable, raised baton, vessels, counters and small implements, table legs | A workbench accepts tools from distinct lanes and changes the suit of the next piece that lands on its stamp. Clear a table support to bring a stored tool into reach. |
| II · High Priestess | Open book, facing pages, veil or drapery, seat and headdress | Make paired page panels that expose one suit or gate at a time. A seal holds one leaf in place while its partner turns. |
| III · Empress | Eagle shield, sceptre, crown, throne | Put a sceptre-shaped feed post beside a seed plot. The shield protects a grown piece while the player clears its neighbours. |
| IV · Emperor | Throne, sceptre, eagle shield, crossed legs and solid seat | Build a shelf on supports. Its shield arrests a falling piece, and the space below it becomes a measured chamber. |
| V · Hierophant | Crozier, raised blessing hand, two attendants, tiered headpiece | Use a crozier-shaped signal post to route two actions to the attendants in order. An inscribed bell can report the accepted sequence. |
| VI · Lovers | Three figures, blindfolded winged archer, bow and arrow | Aim at one of two paired latches. Both must receive their marked actions within the same stroke window. Use the arrow to mark which latch the stroke reaches. |
| VII · Chariot | Wheeled car, two horses, canopy and its posts, shield on the car | Put cargo on a cart whose two approaches meet at a switch. A canopy post can narrow a lane. Clear a wheel stop before releasing the cart. |
| VIII · Justice | Balance beam and pans, sword, winged seated judge | Load the two pans to a stated balance. The beam tilts a runner's rail. The sword can release a stop when the right pan is level. |
| IX · Hermit | Lamp or lantern, staff, cloak and solitary figure | Put the lantern on a fixed light post. A screen stops its beam. Shift the staff-shaped support to open a sightline while leaving shade on a second cell. |
| X · Wheel of Fortune | Wheel, rim, axle, support frame and riders at different positions | Rotate a printed rim one step per paid stroke. The axle can hold the inner area steady. Meet a rider or a socket at the right phase. |
| XI · Strength | Figure's hands and the lion's open jaws, broad hat | Give the lion a visible patrol and a gate whose access depends on its pose. Hold its current pose for a delivery through the gate. |
| XII · Hanged Man | Suspended figure, ankle tether, crossbar, two supports, bent free leg | Set a hanging weight across an upward shaft and a downward lane. Cutting its tether releases it. Temporarily reversing a column lets the other load reach a ceiling socket. |
| XIII · Untitled | Skeleton, scythe, dark ground and scattered heads or limbs | Use scythe-shaped clearing lanes and stubble squares. Clear a marked crop for its support effect and let the stubble supply a known replacement. |
| XIV · Temperance | Winged figure, two vessels, stream between them, high and low positions | Pour between basins with distinct capacities. An overflow channel connects them. The decision is how much to transfer while keeping both within their marks. |
| XV · Devil | Winged figure, face on the torso, pedestal, raised implement, two tethered figures, cords | Tie two loose loads to a post so one can hold the other above a socket. The second face can show the shared load. Cut the tether once both loads have safe destinations. |
| XVI · Tower | Masonry, openings, displaced crown, upward burst, falling figures, scattered drops | Separate a removable keystone from the foundation. Once it clears, the crown and rubble fall into marked cells and open a route. |
| XVII · Star | Large star and smaller stars, two ewers, water and bank, vegetation and bird | Divide one pour between a stream channel and a seed bed. A star marker records a completed branch. A bird can carry a relic between two fixed perches. |
| XVIII · Moon | Frontal moon, rays and drops, two towers, two canids, pool and crustacean | Use two light sockets to control guarded banks. A Cup action lures the crustacean from the pool toward a marked exit. Use reflected light to affect the far tower. |
| XIX · Sun | Sun and rays, two figures, low wall and falling drops | Let the wall cast a grid shadow. Open a window to charge one yard while protecting a seedling or freeing the route between the two figures. |
| XX · Judgement | Cloud-borne angel, trumpet, banner, rising figure, tomb and witnesses | A trumpet post recalls a suit on a memorial cell. Choose when to repeat a stroke so the restored pieces open the tomb and finish the sequence. |
| XXI · World | Wreath, central figure and baton, human or angel, eagle, bull and lion at the corners | Use the wreath as a visible seam between edges. Give its four landmarks distinct suit goals, then complete a route across the linked edges. |

##### Marseille · Wands

The cut baton, crossing diagonals and the spaces between them inform spark sources, supports and route junctions.

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Single heavy baton, grip and branch stubs | Mark the top cell of a Wand ribbon with an Ace. The player clears a column to draw its next piece and form the first spark. |
| Two | Two crossing batons, central junction | Use an X-shaped switch that sends the spark along one of two marked routes. |
| Three | Crossed pair and central baton | Add a straight branch through a switch. Keep one clear route for the lamp while opening the other. |
| Four | Even crossed frame, enclosed centre | Four posts define a bay. A trace can clear its supports to drop a useful piece into the centre. |
| Five | Crossed framework around a central baton | Give the central post the last stop on a five-unit relay. Feed it after the side branches are ready. |
| Six | Repeated diagonal bars and crossings | Fit two banks of three contacts into a shared rack. Use one trace to prepare the second bank's alignment. |
| Seven | Dense crossed frame with a central axis | Reach a central relay through a rack of supports. The first clear changes which side can aim in. |
| Eight | Dense lattice and remaining gaps | Arrange two four-post banks. Choose which side of the lattice to open so a long spark keeps a clear lane. |
| Nine | Layered bars and central axis | Place a braced long relay with one usable approach at a time. Clear the correct brace to keep a second spark available. |
| Ten | Full intersecting array | Use the whole rack as a measured supply puzzle. Sequence clears so the final fall joins the last two Wand groups. |
| Page | Standing attendant, carried baton, direction of pose | A falling Page ignites the beacon at its landing post. Choose the support that puts the post below it. |
| Knight | Rider, horse and baton | A mounted courier follows a track and sends a spark when it reaches a marked post. Switch its route before it arrives. |
| Queen | Seated figure, baton and throne | A fixed court piece can add one to a Wand trace that passes through it. Use its seat as the junction between two potential paths. |
| King | Crowned seated figure and upright baton | Give the King a printed firing direction. Form a trace that can use the King to reach a lamp across another lane. |

##### Marseille · Cups

Bowl, stem, foot, vessel openings and floral divisions inform containers, capacity marks, channels and planted ground.

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | One large chalice, architectural lid, bowl and pedestal | Use a covered Cup source with an inlet below. A seal opens the lid. Clear the right column to obtain the arriving partner. |
| Two | Paired chalices, central ornament and maker's banner | Fill two cisterns on opposite banks, using the central divider to keep their supplies separate. Use the banner to label the shared capacity. |
| Three | Three vessels with a divided arrangement | Supply three small basins from two sides. Preserve a short pour for the last low-capacity basin. |
| Four | Four chalices around the centre | Place corner vessels around a central valve. The valve opens once all four reach their printed marks. |
| Five | Four outer vessels and an extra cup in the centre | Feed outer cups to release a reserve in the middle. Use the reserve to finish a basin the outer channels cannot reach. |
| Six | Two repeated groups of three vessels | Form two banks of three tanks. Pass water through the shared channel without overflowing the near bank. |
| Seven | Two groups with a distinct middle vessel | Feed a central header tank and choose the branch that remains available for the final pour. |
| Eight | Multiple rows of paired vessels | Alternate two outlets along a chain of cups. Find the trace that fills the last pair within the remaining moves. |
| Nine | Nine repeated cup positions | Divide a cistern field into three groups of three goals. Use an area clear to prepare several aiming lanes at once. |
| Ten | Full array of ten cups | Use a large catchment with a final overflow target. Set the early water levels so the last pour reaches the exit. |
| Page | Standing attendant with displayed vessel | Drop a carried cup onto one of two water sockets. Its landing selects which basin receives the pour. |
| Knight | Horse, rider and upright cup | Deliver water to a marked trough on a beat track. A valve can send it to the next stop instead. |
| Queen | Seated figure, prominent covered vessel and throne | Put a fixed Cup court piece beside a reservoir. Its extra unit can fill the high basin, so reserve a shorter path for the low one. |
| King | Crowned figure with cup and seat | Fix the direction of a royal outlet. Use a bent trace to supply the court piece while its pour faces a second lane. |

##### Marseille · Swords

Use curved blades, their oval enclosure, central ornament, straight blades and paired ends as cues for boundaries, cut points and open lanes.

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Hand-held straight blade with crown and foliage | Put a marked Sword source over a single binding. The first arriving pair reaches the cut point that frees a load. |
| Two | Paired curves around a central space | Place two cuttable boundaries around a chamber. Decide which side to open to preserve the other side's support. |
| Three | Curved frame with a straight central blade | A central cut releases the inner load. Either outer boundary can provide the setup for the aimed stroke. |
| Four | Nested curves enclosing a centre | Use two layers of bindings around an object. Open the outer route before spending the inner cut. |
| Five | Nested blade frame and one central straight blade | Put one indispensable cutting lane through two enclosing boundaries. Use a separate setup to make its last step face in. |
| Six | Repeated curved blades and a central enclosure | Arrange three paired barriers across a corridor. Opening the first pair changes which way the next pair is reachable. |
| Seven | Dense enclosure with a straight axis | Use an inner drop marked by the straight blade. Clear one bank so the falling relic reaches it while the other stays supported. |
| Eight | Dense rings around an open centre | Work around a fenced central area. Cut a path for an actor while leaving a brace that keeps the upper route open. |
| Nine | Dense frame with a final central blade | Place the last useful Sword behind several bindings. Plan the release that leaves it aligned with the final cord. |
| Ten | Full oval made of curved blades with two interior straight blades | Use a two-lane centre for two final cuts. Opening the outside lets the player decide which load to release first. |
| Page | Standing attendant and raised or carried sword | A falling Page cuts at the landing marker. A side release can redirect the fall to another binding. |
| Knight | Mounted figure and sword | Send a cutter along a marked route to a series of cords. The chosen track determines which binding it reaches first. |
| Queen | Seated figure, sword and throne | Make a fixed court piece strengthen an aimed cut. Preserve the weaker path for a fragile support. |
| King | Crowned seated figure and displayed sword | A fixed-direction court piece opens a gate normally inaccessible from the remaining Sword cluster. |

##### Marseille · Coins

Use rosetted discs, round holes and repeated placements for weight, sockets, payments and balanced arrangements.

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Large ornamented disc inside surrounding foliage | Make a mint the visible source of a measured Coin ribbon. Time its first useful fall into the pan lane. |
| Two | Two discs linked by a maker's ribbon | Use a pair of pans coupled by a ribbon or belt. Load one to move the other into reach. |
| Three | Three discs arranged around an open interval | Give a rail junction three sockets. Two deposits free a rolling weight for the remaining socket. |
| Four | Four discs framing an interior | Four weights lock a square plate. Remove a support to shift one weight while holding the opposite corners steady. |
| Five | Four outer discs and a central disc | A heavy centre weight opens access only after side pans are loaded. Decide where to bank the scarce fifth Coin. |
| Six | Two repeated banks of three discs | Balance two banks of three sockets. Split a trace across the quota over several moves. |
| Seven | Paired outer discs and an extra centre position | Keep both sides balanced while allocating a reserve Coin to the central pan. |
| Eight | Eight discs around a patterned field | Give two paths to fill eight sockets. Alternate the deposit lanes so each release brings a new pair into line. |
| Nine | Nine repeated disc positions | Use a three-part payment with a rolling Coin that can finish whichever group the player leaves short. |
| Ten | Full field of ten discs | Make a mint inventory with a complete set of weight sockets. Finish the two banks with the same stock under a printed limit. |
| Page | Standing attendant and displayed disc | A falling Page pays the socket where it lands. Clear a support to choose the destination. |
| Knight | Horse, rider and displayed disc | Send a weight courier to a toll post along a switched track. The player can pay early on one route or later on the other. |
| Queen | Seated figure, disc and throne | Put a fixed court piece at a counting bench to add one to a deposit. Pick the pan whose capacity can take the stronger trace. |
| King | Seated ruler, disc and dais or throne | Turn a court piece into a directional till. A trace routed through it can deposit into a pan outside the trace's usual aim. |

#### Rider–Waite–Smith · reference and new deck requirement

Use Pamela Colman Smith's designs for Arthur Edward Waite and William Rider as the reference. The deck was first published in 1909. Use the card plates for visual details and Waite's accompanying descriptions as a cross-check. The ordinary scenes on the numbered cards supply locations, tools and actions as well as pip counts. [Morgan Library & Museum exhibition and collection examples](https://www.themorgan.org/exhibitions/tarot) · [Waite and Smith's Major Arcana plates](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2) · [Their Minor Arcana plates](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3)

**Future production deliverable.** Develop the 78 [abstract Rider–Waite–Smith reference faces](#deck-artwork-references) into a separate production deck before releasing its levels. Complete the card back, suit and court marks, and board-scale artwork for the fixtures and actors selected below. Preserve the distinctive scenes, Pentacles, the numbered Fool at 0, Strength VIII, Justice XI and the title Death on XIII. The Marseille album and campaign keep their own artwork and order. Give matching card identities stable names across the two editions so a different printed numeral can never change a rule or a saved deal. Keep Pentacles on the shared deposit and weight rules carried by Coins. Establish the art and playtest sample boards before assigning a chapter or release date.

##### Rider–Waite–Smith · Major Arcana

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| 0 · Fool | Cliff edge, traveller and staff, bundle, white rose, small dog, mountains and sun | Leap across a cut in a mountain path. Carry the bundle to an exit post while a signal from the dog makes the next edge safe. |
| I · Magician | Table with wand, cup, sword and pentacle, raised rod, pointing hand, infinity sign, flower border | Use a four-suit workbench with one source above and one receiver below. Feed it from a chosen side to transform the next arrival. A flower border can delimit the affected area. |
| II · High Priestess | B and J pillars, patterned veil with palms and pomegranates, scroll, crescent, water beyond | Put a reversible screen between two keyed columns. Use a scroll seal to keep one bank unchanged while turning the veil to expose the other. |
| III · Empress | Wheat, stream and trees, Venus shield, sceptre, throne and star crown | Set a water channel beside wheat plots. The shield shelters one plot from a clear while the stream feeds the next stage of growth. |
| IV · Emperor | Ram-headed stone throne, mountains, orb and ankh sceptre, armour | Assign strong supports to the ram posts. A counterweight socket releases the slab above a chamber once both posts are safe. |
| V · Hierophant | Two pillars, crossed keys, triple cross, raised hand and two attendants | Open one post per key, then route the two attendant signals through the cross in a printed order. |
| VI · Lovers | Angel and sun, two figures, fruit tree and serpent, tree with flames, mountain | Feed the two gardens through different actions. A shared gate opens while the two signals overlap. The serpent can occupy a printed path to the fruit. |
| VII · Chariot | Light and dark sphinxes, wheeled car, star canopy, wand, winged emblem on the car, city and water | A cart with two distinct inputs can take one of two routes. Set a switch beside the water gate before committing the second input. |
| VIII · Strength | Lion, figure's hands, flower garland, infinity sign | Use a garland post to hold the lion's current stance for a fixed number of turns. Route the delivery before its gate closes again. |
| IX · Hermit | High ridge, staff, six-pointed star inside a lantern, cloak | Make an elevated lantern illuminate a single mountain path. Move a support so the beam reaches a lower socket without uncovering the unsafe route. |
| X · Wheel of Fortune | Inscribed wheel, sphinx with sword, serpent and ascending figure, four winged readers with books | Keep the four corner posts fixed while the rim rotates. Align a marked spoke with its corresponding reader before releasing the rim rider. |
| XI · Justice | Scales, upright sword, twin pillars, curtain, throne | Load the pans to an exact balance to raise the curtain. A Sword action cuts the stop only when the scale opens its lane. |
| XII · Hanged Man | Living T-shaped crossbar, leaves, ankle tether, halo and crossed leg | Suspend a load between a growing support and a ceiling socket. Use the halo as the ceiling marker and cut the tether after the opposing fall. |
| XIII · Death | Armoured rider, white horse, black flag with a white flower, figures, river, twin towers and rising sun | Run a reset procession along a marked route. Its banner clears spent growth and exposes replacement seeds. Time the crossing before the tower gate changes phase. |
| XIV · Temperance | Winged figure, two cups and water transfer, one foot on land and one in water, irises, path, distant crown, triangle inside square | Use a split-capacity basin beside an irrigated bank. A measured transfer opens the path to a crown socket without drowning the flower bed. |
| XV · Devil | Winged figure, chained pair, post, inverted pentagram, lowered torch and contrasting tails | Connect movable weights to a fixed post with visible slack. A torch can open a latch on one side, while a cut releases the pair once two landing cells are clear. |
| XVI · Tower | Lightning bolt, displaced crown, windows, flame and sparks, two falling figures, rocky foundation | Feed a lightning receiver at the top to release the crown. Prepare both rubble landings so a falling piece opens one gate while the other route stays usable. |
| XVII · Star | One large star and seven smaller ones, two vessels, pool and land, branching rivulets, bird on a tree | Separate the board into a deep reservoir and several irrigation channels. Light stars at outlets in order. A perch can signal that one isolated branch is complete. |
| XVIII · Moon | Moon with faces and rays, falling droplets, dog and wolf, crayfish, pool, path, two towers and hills | Route an actor through two tower windows. Reflected light changes which side is guarded, and a Cup trace can draw the crayfish across an exposed bank. |
| XIX · Sun | Sun disc, white horse and child, red banner, sunflowers and wall | Open gaps in the wall to light the flowers as the rider advances. The banner marks the route where a shadow must be removed first. |
| XX · Judgement | Trumpet and cross banner, angel and clouds, groups rising from coffins, water and mountains | Send one trumpet action through two banks of memory cells. Restore the correct suit groups in sequence to open their lids and reveal a route. |
| XXI · World | Oval wreath with tied ribbons, central figure and two batons, human or angel, eagle, bull and lion in the corners | Pair two edge seams with the ribbon knots as switches. Two baton-shaped sockets allow crossings in alternate directions once the four corner goals are ready. |

##### Rider–Waite–Smith · Wands

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Cloud-hand and sprouting staff, river and distant castle | A cloud gate releases the next Wand into a ribbon. Use a fall to complete the spark that reaches the castle lamp across the river. |
| Two | Figure on battlements, globe, two staffs with one fastened, coast or harbour | Use a signal turret with fixed and selectable beams. Set the globe-shaped switch to choose the coast or the inner yard. |
| Three | Three planted staffs, watcher on a height, ships and water | Light three lookout posts while a boat crosses the lower track. Choose the post that gives enough time for the last signal. |
| Four | Four poles, suspended garland, raised bouquets, figures and buildings | Set a garland gate over four sockets. Completing its corner posts opens a route for the party crossing the courtyard. |
| Five | Five figures and intersecting staffs | Several moving bars share a crossing. Clear the correct post to free one line while preserving another for the next spark. |
| Six | Mounted figure, laurel and wreath-topped staff, procession with poles | Deliver a wreath to a finish post. The route asks the player to move the procession through two gates in order. |
| Seven | Raised defender, six staffs from below, high ground | Place a relay on a high shelf. The bank below offers several places to clear, and just one setup brings a useful aiming pair onto the shelf. |
| Eight | Eight airborne staffs, diagonals, hills and river | Mark a falling relay's landing cells across a river. Free its supports in the order that leaves the destination open. |
| Nine | Bandaged watcher and staff, row of upright staffs | Use a palisade with a single removable stop. Keep enough support for the watch post while opening a channel for a second trace. |
| Ten | Carrier, bundle of ten staffs, town and road | A porter can carry a limited load. Split the bundle at a staging post so both the porter and the spare cargo reach town. |
| Page | Young figure, sprouting staff, desert and distant hills | An announcement post lights where the Page lands. Route the Page to the post that can signal the next lane. |
| Knight | Rider with staff, rearing horse, desert and pyramids, patterned clothing | Put a courier on a printed route with a departure gate. Open its turn before it reaches the fork. |
| Queen | Sunflower, staff, black cat, lion-marked throne | Add a sunflower receiver and a cat that moves between perches. A court trace can feed the flower while its shadow keeps the cat's route open. |
| King | Flowering staff, crown and throne, lions and salamanders | Use a directional fire post with a salamander-shaped track. Aim its boosted Wand shot across the square that releases the next support. |

##### Rider–Waite–Smith · Cups

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Cloud-hand, overflowing cup, descending dove and wafer, falling water, lily pool | Seat a round relic in the cup to open a multi-outlet fountain. Direct the overflow toward a basin and a lily bed. |
| Two | Exchanged cups, paired serpents and winged lion head, two figures | Two coupled vessels share a short window. Feed either to start the interval, then complete the other before the connection fades. |
| Three | Three raised cups, celebrants, fruit and ground | Fill three separate cups to open a market gate. Each successful pour can also water an adjacent plot. |
| Four | Seated figure under a tree, three cups on the ground, fourth held by a cloud-hand | Start with three reachable vessels and a fourth supplied from above. Trigger its arrival after moving a blockage below the tree. |
| Five | Three spilled cups and two upright, cloak, water, bridge and keep | Recover two remaining reservoirs after a spill. Open the bridge by routing the precious water away from the tipped cups. |
| Six | Children, flower-filled cups, courtyard and buildings | Fill two flower sockets in a handoff. The first delivery grows a support that allows the second vessel to reach its bed. |
| Seven | Seven cloud-borne cups with a head, veiled figure, serpent, tower, jewels, wreath and dragon, skull mark on the wreath cup | Use seven marked sockets with distinct outputs. Choose the socket whose printed icon matches the missing tool or route. |
| Eight | Stacked cups with a gap, traveller with staff, rocky stream and moon | The visible gap becomes an exit lane past a cluster of stores. Save a Cup for the far crossing while the traveller moves uphill. |
| Nine | Nine cups on a draped display, seated host and bench | Fill a rack of small stores without using a scarce reserve. A fold in the display can uncover a lower outlet once the rack is charged. |
| Ten | Arc of cups in a rainbow, family, house and river valley | Use the arc as a sequence of connected outlets. Complete the home basin while enough water remains to open the return path. |
| Page | Cup with emerging fish, attendant and shore | Land a carried cup on a water socket to release the fish into a marked channel. Prepare the exit before the fish begins moving. |
| Knight | Rider with cup, winged helmet and stream crossing | Deliver a measured cup on a slow route. Raise or lower the ford with an inlet before the courier reaches it. |
| Queen | Ornate covered cup, carved throne, shore and stones | Use a lidded reservoir on a fixed court cell. Open its seal with a short pour and use the strengthened trace to reach the far bank. |
| King | Throne amid the sea, cup and sceptre, ship and leaping sea creature | Put a directional outlet at a sea throne. Feed it in time to raise the ship's lane while keeping the creature's channel open. |

##### Rider–Waite–Smith · Swords

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Cloud-hand, upright sword through a crown, foliage and mountain horizon | Open one crowned latch with a straight cut. Free the support that lets a Sword pair land in the marked lane. |
| Two | Blindfold, crossed swords, stone seat, rocky sea and crescent | Print two opposed barriers with visible destinations. Choose which to release based on the next fall, then reach the other from a new angle. |
| Three | Heart, three blades, rain and clouds | Use a heart-shaped seal with three cut points on separate approaches. Drain a rain basin as the last binding opens. |
| Four | Recumbent effigy, tomb, three swords above and one below, stained-glass window | Keep three wall bindings fixed while freeing the single support beneath a chamber. Align the window signal with the released block. |
| Five | Three gathered blades, two grounded blades, departing figures, shore and clouds | Route three portable tools to a rack. Keep the two fixed tools in place as supports for the exit lane. |
| Six | Punt, ferryman and passengers, six carried swords, calm and rough water | Shift cargo to control a ferry's load, then open the landing gate before the boat's next step. |
| Seven | Five carried swords, two left planted, tents and camp | Move the portable blades to a stockpile while keeping the planted pair for a later cut. Decide which gate to open first. |
| Eight | Bound and blindfolded figure, blade enclosure, wet ground and fortress | Cut a binding and open one side of a fenced route. Keep the other side in place until the traveller has passed. |
| Nine | Row of swords overhead, bed, patterned cover and seated figure | Time the release of an overhead row into side sockets. Preserve the covered resting cell by choosing which beam to clear first. |
| Ten | Ten blades and prone figure, shore and dawn | Use a pinned load beside a shoreline. Clear enough pins to free it once its printed landing is open. |
| Page | Two-handed upright sword, uneven ground, windblown clouds and birds | A relay changes which approach the Page watches on each beat. Clear the footing that drops the Page next to the needed binding. |
| Knight | Charging rider, drawn sword, windswept trees and clouds | Commit a fast mounted cutter to a lane. Open its switch before it crosses so it reaches the correct cord. |
| Queen | Upright blade, open hand, carved throne and clouds | A fixed court piece strengthens an aimed cut. Use the open-hand side as a receiving socket for a released relic. |
| King | Seated figure, unsheathed blade, decorated throne and trees | A fixed court piece directs a cut along its printed line. Arrange two groups so one uses the King's reach and the other saves a support. |

##### Rider–Waite–Smith · Pentacles

| Card | Usable motifs | Candidate for future levels |
|---|---|---|
| Ace | Cloud-hand with pentacle, garden path, hedge arch and mountains | Put a measured deposit source above a garden arch. Load the marked socket to open the path through it. |
| Two | Two pentacles joined by a figure-eight cord, juggler, ships on waves | Couple two pans so one descends as the other rises. Time the shared movement to bring a boat to the correct landing. |
| Three | Three pentacles set above a stone arch, mason, bench and people with plans | Restore a three-socket arch. The mason's bench acts as a support, and the plans can show the order in which sockets accept load. |
| Four | Disc held at the chest, one over the crown, two beneath the feet, seat and city | Anchor two floor weights and a top weight around a central store. Change which release moves the store while keeping one pan loaded. |
| Five | Lit stained-glass window with five pentacles, snow, two travellers, crutches | Light a warming window with a deposit quota, then open a sheltered route for the travellers before they pass it. |
| Six | Scales, donor and two recipients, distributed coins | Weigh and divide one supply between two receivers. Use a split trace to leave the final payment within both capacity marks. |
| Seven | Six discs on foliage and one near the worker's foot, garden and staff or tool | Grow weights on a vine in visible stages. Use the accessible ground disc now, or wait for a later fall that completes a larger payment. |
| Eight | Artisan, workbench, tools and pentacles in different stages of placement, town | Use a workbench with finished sockets and a live work socket. Deposits advance the work one place so the player can time the final handoff. |
| Nine | Vineyard, nine discs, hooded bird on a glove, snail and estate | Send a bird between perches as the vineyard gains weight. Keep one shaded corridor clear for a slower actor moving along the ground. |
| Ten | Ten pentacles, archway, elder, family, two dogs and estate | Open a courtyard arch after arranging deposits at inherited sockets. Route the dogs on separate tracks to open the two final latches. |
| Page | Raised pentacle, young figure, field and distant mountain | Drop a portable weight from a visible holder. Its landing chooses which weighing post advances the objective. |
| Knight | Heavy horse at rest, rider, pentacle and ploughed field | Send a slow weight courier along a furrow track. Use the longer safe lane if the nearest socket cannot accept its load. |
| Queen | Seated figure with pentacle, carved throne, roses and rabbit | Keep a fixed court store beside a garden gate. A deposit feeds the load socket and frees the rabbit's route through the hedge. |
| King | Pentacle, sceptre, bull-marked throne, vines and castle | Use a fixed-direction till to load a winepress or gate counterweight. Time the deposit so the rising gate preserves the vineyard's useful supports. |
