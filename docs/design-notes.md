# Arcana Tableau design notes

The PRD carries the current rules and decisions. Use these notes for playtest observations, draft mechanics, examples, and research. The finite-board review describes an earlier version with different refill, move limits, and Undo rules. [Product requirements](product-requirements.md) · [Opening deals](opening-deals.md) · [Campaign atlas](campaign-001-220.md)

## Core playtest findings

| Observation | Design decision | What to check in play |
|---|---|---|
| Lower rows often felt stranded when arrivals were chosen without enough regard for the settled position. | Guided refill evaluates legal pairs on the resulting board, prioritizes lower-row access and can favour a fall that builds a lozenge from visible pieces. The player chooses every stroke. Authored tests replay the rules and supply. | Watch how long the lower rows go unused, whether players can recover from an ordinary miss, and whether they move a pair to build a shape they spotted. |
| Players drew recognisable lozenges over targets or started along a side and sometimes saw them fail. A press near the edge of a corner tile could be mistaken for a side start, with different results in the two directions. | Use the four diagonal turns as the outline. Keep corner and side interpretations when a press could belong to either. A target on a side allows passage. A target at a turn counts as its accepted suit. | Test off-centre presses as well as centred ones, with pointer samples between turns. Include both directions, starts along a side and passes over targets. |
| The early ferry study asked beginners to read aim, gravity and a bell payoff together. | The First Step demonstrates a connection and two sizes of single-suit lozenge. Then it reveals one trail marker and shows how a hit and an enclosing lozenge light it before handing over. Save the falling Coin and bell for a later lesson. | Watch whether players can repeat the loop and finish lighting the trail marker after the hand disappears. |
| A preview of the resulting board would reveal the fall before the player commits. Long walkthroughs would also hide where players stop reading the board for themselves. | Use live path feedback and a short guide that marks the next legal move in Far Wreath. Stop drawing the route after four moves. | Observe what the player chooses next and whether they can reuse the two shape rules on a fresh board. |
| Charging a target and using a link are distinct payoffs. | Give any target corner immediate progress. Link multiple corner targets for one turn per target. Use lightning to show the connection and text for the remaining turns. | Ask players to predict the result of tracing into one linked target and the effect of spending a turn on a miss. |

Automated checks cover seeded clears for all eight deals, bottom-row pairs through eight consecutive lower-field clears per deal, lozenge starts and directions, Far Wreath's teaching handoff and links with two to four targets. Browser play confirmed a two-turn link, shared progress and expiry on a spent move. Those checks establish that the rules work in those cases. The delight loop still needs observation with players who are seeing the boards for the first time. [Replay the archived checks](opening-deals.md#replaying-the-archived-prototypes)

**Campaign consequence.** A release witness or required-card certificate must account for ordinary traces, area clears and progress from enclosed or linked targets. A two-move cardless clear bypassed the Leap requirement on the archived drawbridge layout. The mobile drawbridge deal uses a row-one inlet and a refill strategy to enforce its final Leap. [Layout and archived route](opening-deals.md#fool-012--one-impossible-step)

## Finite-board review

### 1 · The Fool's opening deals (001–010)

I hand-checked these ten small boards against their written claims, trying every legal move. All ten hold: the winning lines, the stated minimums, the dead openings, and "a cardless clear is impossible" for 006–010. The exceptions are design-text issues:

- **What can Leap jump?** The rule says a leap passes "over a gap or occupied intervening cell". 009's winning line needs a leap over a square that is *already empty* (stroke 4, B3→D3 over C3). Under the written rule, 009 needs 6 strokes, not 5. **Direction:** "Leap skips exactly one cell, whatever it holds." That is simpler to explain and keeps 009 as written.
- **Designer notes overstate what the board forces.**
  - 009 says "Wait until the fourth trace before jumping". Leaping on the third also gives a shortest solution.
  - 010 lists the Coins first, then the leap. Leaping first is just as short.
  - If the timing is the intended lesson, tighten the board. Otherwise phrase the note as "the line we expect", not "the line you must play".
- **The tiers don't match the traps.** 008 (Hard) has a single solution and 9 of 10 openings dead. That is as harsh as 009 (Super Hard) and 010. 004 and 005 are labelled Hard at levels 4–5 of a first session. Retune the labels once there is playtest data.
- **PRD wording.** "Before 006 the player *must* have encountered a singleton and tried Undo" can't be guaranteed: a careful player can avoid every trap. Either script one deterministic stranding, or say "is very likely to".
- **Small text mismatches.** Atlas 005 says "the middle column", but the gaps are in column B of a 4-wide board. Atlas 010 says "lower road", but the gap is in the middle row.

### 2 · Consistency across the documents

| # | Issue | Where | Direction |
|---|---|---|---|
| C1 | **Mixed timing units.** Foundation, Suspension and Bind last "two settles". Hold the Beast lasts "two actor advances". Lovers latches use "two successive strokes". Lamps age per move. Reap, Breach, Drive and Turn the Wheel cause settles outside a stroke, so it is unclear whether Reap uses up one of Foundation's two settles. | Atlas IV, VI, XI, XII, XIII, XV | One clock: the **paid stroke** ("beat"). Every duration is in beats, and card-triggered settles never age timers. Write one turn order that covers every card. The current order has no step for Rite's echo or Recall. |
| C2 | **Spark travel is undefined.** Does a spark pass through pieces? 093 and 098 depend on the answer. | PRD core rules | Decide and write it down. Suggestion: travels up to *n* cells, passes through pieces, stops at the first fixture or screen. |
| C3 | **Base fixtures are never introduced.** Lamps (013), pans (017), shutters (018), inlets (021), cords (023), and relics with sockets (042) all appear without a teaching beat. "Lantern" means three things: the Wand target (013), the Hermit fixture (091), and the Sun's solar lantern (191). | Atlas I–IV, IX, XIX | Teach the base vocabulary (see §4). Call the Wand target a "lamp" and reserve "lantern" for one object. |
| C4 | **Mixed naming.** Earlier drafts used multiple names for the High Priestess and the Tower. Power references should use Close the Wreath (216) and Illuminate (199). Use *crayfish* for the Moon’s creature (184). | Atlas | Use the same English card names on the faces and in the atlas. Refer to powers by name. |
| C5 | **Two different slot-6 tests.** The PRD asks that removing the card make "the stated budget impossible". The Fool deals meet the stronger test, impossible at any length. | PRD, Atlas | Keep both, and label each level with the one it meets (see §3). |

Checked with no problems found: chapter numbering matches Marseille (Justice VIII, Strength XI). Every guest card was earned earlier on the main route. Encounters rely only on skills taught in slots 1–7.

### 3 · Designing levels that are solvable, and that need their power

Proving solvability by exhaustive search does not scale to full 6×6 boards with fixtures and actors. Building levels so their properties are evident does. There are three separate obligations, each with its own design answer.

#### 3a · "It can be cleared": build backward from the witness

Author each level by *un-playing* it. Start from the end state (an empty board, or the goal state). Add strokes in reverse: each one inserts a same-suit trace and pushes the pieces above it back up their column.
- The witness exists by construction, so solvability is never in doubt.
- The card's reverse stroke goes in deliberately. To need Leap, insert one reverse trace that crosses a gap. To need Suspension, insert one upward settle. The card's role in the level is then a design decision, not a discovery.
- It matches the PRD's intent: a level is *authored around a relationship* and then dressed. The order of reverse strokes *is* the intended lesson. "Keep the high Cups until last" means the high Cups were the first reverse stroke.

#### 3b · "It can't be cleared without the card": a one-line certificate

Every card-required level carries a short argument that a reviewer can check by eye. Nearly all atlas slot-6 entries already imply one. Six kinds cover the campaign:

| Certificate | The argument | Atlas examples |
|---|---|---|
| **Isolation** | Pieces never change column, and a gap is permanent. So two pieces separated by a gap, or by a piece that can never leave, can never become adjacent. | 006, 008, 216 |
| **Count** | A suit with exactly one piece left can never clear. A suit with two pieces must clear as one pair, so the pair must meet. | 006, 136 |
| **Arithmetic** | The fixture needs an exact quantity, and every reachable deposit or pour adds up to the wrong total. | 086 (4 can only go left; 2/2 needs a split), 146 (sealed basins) |
| **Reach** | No cell exists where a trace of the right suit can end aimed at the target. | 016 (no alternate firing lane), 026 (no reachable seal), 196 (bricked window), 126 (no updraft) |
| **Timing** | An actor or window resolves in *k* beats, and every cardless route needs more than *k*. | 116, 106, 187 |
| **Budget** | The board has *g* groups that can never merge, so it needs at least *g* strokes. The budget is lower than *g*. | Within-budget slot-6 boards |

Two useful invariants support these certificates: **pieces never leave their column**, and **pieces in a chamber keep their vertical order**. Most isolation arguments are one sentence long because of them.

**Direction:** add a "why the card is needed" line to every slot-6 entry in the atlas, naming its certificate type. If a designer can't write the sentence, the level isn't ready. The sentence also becomes hint level 1 ("an observation") almost word for word.

#### 3c · "Within a range of moves": stop promising optimality

Proving that no shorter line exists is the expensive obligation. Drop it.
- **Par = the designer's witness**, not a proven minimum. A player who beats par gets a distinct mark ("under par", as KAMI 2 does). That turns a verification risk into a discovery reward.
- **Budget = par + slack**, set by the level's job (as the atlas's budget policy already says). Only the upper bound matters, and the witness provides it.
- Where a budget *is* the lock (a Budget certificate), the lower bound comes from the certificate's group count, not from search.

#### 3d · Check the design in play

Save legal replays for the payoff, an alternate route and a recovery after a plausible mistake. Run them through the same engine as the browser. A clear without the required card refutes the card certificate. Observe where players find their own routes, and ask them to point to the stroke or fall that made the difference.

### 4 · Are mechanics introduced progressively?

**Within the Fool: yes, and well.** Pairs (001), then turning trios (002), a partner brought together by gravity (003), a tempting wrong pair (004), a gap (005), and Leap (006). One idea per step, and each board's trap is real.

**Across the campaign: three gaps.**

1. **The suit tools are never taught.** The Fool has no fixtures. Chapter I then introduces, in one chapter: palette stamps, Wand range and direction (013), lamps, pans and deposit counts (017), sealed pockets and shutters (018), and Transmute. Pours first appear at 021 and cuts at 023, inside other chapters' rules.
   - **Direction: make the Magician the tools chapter.** The Marseille Magician sits at a table laid out with his implements: wand, cups, coins and knife. Use slots 1–4 for spark, pour, cut and deposit, slot 5 to combine them, and keep Transmute as the card. Move palette stamps to Chapter II with the folded pages (both change suits), or keep them as a light secondary rule.
2. **Relics, sockets, plates and keys** first appear at 042 as a side effect of shelves. Give falling relics one plain board before they carry a puzzle.
3. **The tier pattern is the same in all 22 chapters** (N N N H H · N N H SH H). The main route is always 5 Normal plus 3 Hard: no campaign-level ramp and no named rest boards. Directions:
   - Grade by accumulated vocabulary: a Normal at 211 is not a Normal at 011.
   - Name "quiet familiar" boards in the atlas. The PRD asks for them, but the atlas never designates one.
   - Vary the first reading. 22 rounds of "borrow the card and do the obvious thing" become routine. Some slot-6 boards should make *where* or *when* the question, the way 008 does for Leap.

**Overlapping rules and powers dilute novelty.**
- Near-twin powers: Leap and Close the Wreath (join cells that aren't adjacent); Transmute and Lantern (a one-trace suit change); Foundation, Bind, Suspension and Hold the Beast (four "hold for two").
- Near-twin rules: palette and folded pages; buds and stubble seeds; bells and latches; Hermit sight lines and Sun shadows; Moon guardians and Strength patrols.
- Either present them as deliberate rhymes (the Wreath as the "world-sized Leap"), or apply the PRD's own test now: *if the third puzzle is only a larger layout, retire the rule*.

**Combination play is mostly optional.** About 20 of the 31 guest appearances are on slots 8–9. Main-route players meet cross-chapter interactions mainly on slot-5 boards and in encounters. Use counts are uneven: Emperor and Chariot are guests 4 times each, Magician, Empress, Hierophant, Lovers and Hermit once each, and Devil, Tower, Sun and Judgement never. Once earned, most cards are rarely played again, so the album risks being decorative. Give every card at least one main-route reprise, and make 201–220 an explicit recombination finale.

### 5 · Playability and longevity

**Strengths**
- Unlimited thinking time, visible actor cycles, and the requirement that a dead end be explainable from visible information.
- Finite boards that end naturally.
- Free hints and undo.
- Versioned levels with guest-author testing before user-made content.
- The decision gates are measurable.

**Risks and directions**
- **Undo plus no budget invites trial and error** on small boards. 008 has only 10 openings. That is acceptable for teaching, but replay value has to come from mastery layers.
- **Board legibility.** A 6×6 portrait board carrying base fixtures, a chapter rule, a guest rule and an actor can exceed what one-handed play can read. Cap each board at about three fixture types plus one guest.
- **Rule interactions grow by pairs.** 22 rules can form 231 pairs, and each needs a ruling. Keep an interaction table (allowed, forbidden, or undefined), and only combine pairs that are already ruled.
- **Authored puzzles are solved once.** Cheap mastery layers:
  - "Under par" marks.
  - A **cardless clear** badge on slot 7–10 boards where one exists.
  - A longest-trace record.
  - Later, a daily deal built backward (§3a), so it is solvable by construction.

## Depth and progression

### 1 · Are the boards interesting and challenging?

#### What works

- **One gesture carries four decisions.** Suit, length, aim and removal all come from a single stroke. Removal then drives gravity, so every stroke also rearranges the board. Few tracing games tie the path this tightly to the consequence. Two Dots and Dungeon Raid treat the chain mostly as a quantity.
- **The 001 pattern.** One stroke with two jobs, spread across two places on the board. It is the PRD's Super Hard criterion, but at 001 it reads as a delight, not a strain. That shows it can be taught early.
- **Iconography that *is* a rule.** The Hanged Man's inverted gravity, Justice's pans, the Wheel's rim, the Tower's collapse, the Star's pouring. These need no explanation. They are worth protecting even where the progression changes.
- **Certificates and backward authoring.** These already give the project a discipline most puzzle teams lack.

#### Where the depth leaks out

**a · Boards are sentences, not spaces.** A typical entry reads "Cut the shelf pin while its chute is empty" (042) or "Clear two Cups directly above a key" (121). That describes the witness, not a puzzle space. On a full 6 × 6 field, the other ~30 pieces are either irrelevant, so the real puzzle is three cells big, or they are uncontrolled and offer workarounds the sentence never anticipated. Snakebird, Jelly no Puzzle and Stephen's Sausage Roll are hard because every tile on a small board has a job. Arcana's footprint is fixed at 6 × 6, but nothing requires every cell to hold a piece.

**b · New rules crowd out discoveries.** Count the concepts on the main route: 22 environmental rules, 22 powers, and about fifteen base fixtures and objects (lamp, pan, loose Coin, bell, inlet, float, cord, key and lock, shelf and chute, channel, cart, siding, rail, drain, shutter, plate). That is roughly 60 concepts across 176 main-route boards (slots 1–7 plus 10). Each rule gets an introduction and, at best, one twist before the chapter ends.

Compare the long-lived games:
- *Stephen's Sausage Roll* builds a whole game from one mechanic.
- *The Witness* uses about a dozen symbol types across hundreds of panels.
- *Patrick's Parabox* spends each chapter on one implication of a single idea, recursion.
- *Railbound* adds a new element roughly every ten levels and keeps every one of them forever.

Arcana's rate of new concepts is closer to a casual saga game. Saga games get their longevity from randomness and obstacle recombination, not from authored insight.

**c · Slot 6 is a lock and key, 22 times.** By design, the certificate proves the card is necessary, and the layout makes its use unique. Ten of the 22 certificates are **Reach**: "this target is unreachable, and here is the card that reaches it" (016, 026, 046, 076, 096, 126, 166, 176, 186, 196). The player is never asked to *find* the card's use, only to perform it. That works once as a tutorial. Twenty-two times, it trains the player to expect that the card is the answer and the answer is obvious.

**d · "Hard" rarely bites.** The PRD defines Hard as a setup whose value appears on a later settle, with a tempting alternative. In many draft Hard entries, the tempting move fails immediately. A stroke commits on release. Running out of moves or leaving an unfinished deal costs a life. Give the player enough visible information to read a tradeoff that pays out two or three strokes later. For the depth target, look for four or more interdependent strokes and check it in play.

**e · The native mechanics are unmined.** Several properties exist only because of Arcana's own rules, and no chapter builds on them:
- **The trace's shape is the shape of the fall.** A horizontal trace of four frees one space in each of four columns. A vertical trace of four frees four spaces in one column. An L redistributes the vacancies. In High Water, a vertical Wand pair drops two visible Cups into a rectangle around the inlet. The archived study also used horizontal and vertical pairs to set up different lozenges. [Mobile deal](opening-deals.md#level-003--high-water) · [Archived routes](opening-deals.md#lozenge-playtest-routes)
- **The path chooses who stays.** In a blob of six Cups, which three you take, and which three you leave behind as future supports, partners or fuel, is a routing problem. It is played on the same grid the player is already reading.
- **Arrive from behind.** The endpoint aims, so to fire *east* into a lamp, the trace has to end by moving east. That often means looping around the group to approach from the west. This is a Witness-style path constraint that comes free with the base rules.
- **Length partitions a resource.** Five Cups can make a 5, a 3 + 2, or a 2 + 2 with one Cup stranded. Which split is reachable depends on geometry, not just arithmetic.
- **Column invariance.** Pieces never change column and keep their order. Players feel this before they can put it into words, and puzzles can surface it as a discovery ("it can *never* get past that Sword").

#### Principles for deeper boards

**P1 · Reveal an implication, don't add a rule.** Jonathan Blow and Marc ten Bosch made this argument in *Designing to Reveal the Nature of the Universe* (IndieCade 2011): good puzzles show players consequences of rules they already hold. For every board, write down the *misbelief* it overturns ("clearing below a piece always helps it fall", "a longer trace is always stronger", "the card goes where the problem is"). If the board overturns nothing, it is a tutorial or a rest board, and it should be labelled as one. Backward authoring fits this well: start from the misbelief, then choose the reverse stroke that punishes it.

**P2 · Declare the cast.** Every piece on a board has one of three roles:
- **cast:** in the witness, and needed;
- **fuel:** interchangeable, but its *count* matters;
- **ballast:** it matters only as weight in a column.

Anything else is noise. Remove it, or make it inert paper. Dense boards suit casual, exploratory play. Sparse boards with scarce suits are where hard puzzles live.

**P3 · Declare the pressure.** Every board names what makes a careless stroke costly. **Scarcity**: the key suit has exactly the pieces the witness needs. **A countdown**: an actor advances on each paid stroke. **A budget**: a stroke limit backed by a Budget certificate. Every board needs at least one of these, because every board must be losable (see the PRD's delight loop). On a rest board the pressure can simply be the move limit.

**P4 · Delay the failure.** On Hard boards, the wrong choice should look fine for at least two strokes. This is the single most useful test to run on the existing Hard entries.

**P5 · Use the native patterns.** A short pattern library to author from, roughly from gentlest to hardest:

| Pattern | The decision | Native property |
|---|---|---|
| Two jobs, one stroke | Use a lozenge to clear the area and feed a target or set up a link | The Wreath charges two targets and gives the player two moves to share a trace's progress |
| Sculpt the fall | Pick the trace *shape* that brings two pieces level across columns | Trace shape = fall shape |
| Leave the right ones | Choose which members of a group stay behind as supports or partners | Path chooses the subset |
| Arrive from behind | Route the trace so its last segment faces the fixture | The endpoint aims |
| The split | Turn one group into two exact actions at two fixtures | Length = strength |
| The support is the ammo | The piece holding up a relic is also the piece you need to fire | Supports are ordinary pieces |
| It can never get past | Find out that a needed meeting is impossible and change the plan | Column invariance |
| Against the grain | Use a card in the opposite way to its first reading (Leap to *avoid* joining, Suspension to make a counterflow shaft fall) | Powers interact with rules |

Most of these need no chapter rule at all. They are the reason a new rule is worth having. A new rule should multiply these patterns, not replace them.

**P6 · First readings ask where or when.** Keep the certificate (the card is necessary), but give the card three plausible uses on the board, two of which fail later. Vary the certificate types across the campaign. Isolation, Count and Timing first readings tend to produce real decisions. Reach first readings tend to produce lock-and-key boards.

---

### 2 · Why the progression jumps around

**The Fool previews later chapters.** The opening ten boards now show the player systems that are "introduced" much later:

| Fool board | System previewed | Formally introduced |
|---|---|---|
| 004 shelf, chute and gate | Shelves and chambers | Emperor, 041 |
| 005 channel, cart and siding | Carts and switched routes | Chariot, 071 |
| 008 counterweighted pan | Scales | Justice, 081 |
| 009 rail, runaway Coin and two bells | Runner Coin; bells | Justice, 081; Hierophant, 051 |
| 002, 006, 007 inlets and floats | Water levels | Temperance, 141 |

When Justice arrives at 081, the runaway Coin is neither new nor familiar. The player has seen it once, 72 boards earlier, and it was never explained.

**Goal types swing back and forth.** The Fool uses physical object goals. Then the Magician, Priestess and Empress lean on abstract clears ("Clear six pieces", "Clear three suit families", "Clear the folded margin"). The Emperor brings back object goals, and the Hierophant and Lovers switch to abstract sequences. Each switch changes what the player is looking *for*.

**Chapters are islands.** Each rule lives for one chapter. Guests sit mostly on optional slots, and Devil, Tower, Sun and Judgement never appear as guests. So when gravity returns at the Hanged Man (XII), the Devil (XV) and the Tower (XVI), it comes back with new fixtures and new names, not as the Emperor's shelves under new stresses.

**Actors arrive one type at a time, each with its own clock.** The cart (VII), runner Coin (VIII), rim (X), lion (XI) and crab (XVIII) are each new. Each has its own timing words ("one edge after each stroke", "two actor advances", "printed notch").

**The difficulty is a sawtooth.** Every chapter runs N N N H H · N N H SH H, and slot 6 always resets to Normal. A Normal board at 181 asks for about as much as one at 011.

#### The deck order already spirals

Sort the chapters by the material system each one actually works on. A cycle appears:

| System (suit) | Fixture introduced in the Fool | Chapters that deepen it |
|---|---|---|
| Light (Wands) | Lamp | Hermit IX · Moon XVIII (towers) · Sun XIX |
| Water (Cups) | Inlet, float | Temperance XIV · Star XVII · Moon XVIII (pool) |
| Value and element | — | Empress III (values, feeding) · Temperance XIV (elemental dignities) · later boards, where dignity pairs appear untaught |
| Support (Swords) | Cord, loose relic | Emperor IV · Hanged Man XII · Devil XV · Tower XVI |
| Weight (Coins) | Pan | Justice VIII · Wheel X (if the rim carries weight) |
| Suit identity | — | Magician I · Priestess II · XIII · Judgement XX |
| Countdowns and actors (counted in strokes) | — | Hierophant V · Lovers VI · Chariot VII · Justice VIII · Wheel X · Strength XI · Moon XVIII |
| Topology | Gap | Fool 0 · Lovers VI (Draw Together) · World XXI |

Every system returns every five to seven chapters. That is the shape of a spiral curriculum, which is what you would design on purpose. It doesn't *feel* like one because each return comes back as a new location with new fixtures. The fix is to make the return visible, not to reorder the deck. That keeps the Marseille order and the iconography intact.

**Coins are under-served.** After Justice, weight barely appears again. Pick one later chapter to deepen it: the Wheel's rim carrying weight that tips a pan, or the Devil's chained relics landing on pans.

---

### 3 · A progression that feels natural

#### Three acts of seven

Tarot writing has long laid the Major Arcana out as the Fool's journey through three rows of seven (popularised by Eden Gray). That gives a structure that is both traditional and mechanically useful:

| Act | Chapters | Mechanical job | Character of the boards |
|---|---|---|---|
| **The Fool** (prologue) | 0 | The four suit verbs, gravity, gaps, Leap. One fixture per suit: lamp, inlet, cord, pan. | Physical, friendly, obvious goals. |
| **I · The tools** | I–VII | Choosing *which* verb a piece performs (Transmute, folds), growth, chambers, ordered events. Static boards throughout. The first moving actor, the cart, arrives at VII as the act's closing turn. | Object goals throughout. Clears only as named quiet boards. |
| **II · The countdowns** | VIII–XIV | Runner, rim and patrol all follow **one actor grammar**. Sight lines, counterflow, seeds and basins deepen the light, support, identity and water systems. | Time pressure becomes normal. Boards take four or more strokes. |
| **III · The world answers** | XV–XXI | Every system returns under stress: chained and collapsing support, channels, reflection, shadow, memory, wrap. Ends in a recombination finale. | Main-route combinations of two or three systems. |

The card is 0 and unnumbered, so the Fool can sit **outside the 22 × 10 grid as a prologue**. It can be longer than ten boards if the four verbs need the room. Act II's first chapter, Justice, then becomes the natural place to introduce stroke countdowns, because the runner Coin is the first actor the player directly steers.

#### Rules for every chapter

1. **Extend a system before adding one.** Each chapter names the system it extends and the one twist it adds, and keeps that system's fixtures and names. Temperance's basins are the Fool's inlet and float with capacity. The Sun's shade is cast by the Hermit's screens. The Devil's chains hang from the Emperor's shelves. XIII's harvest reaps the pieces the Empress taught players to grow, so the reaper takes what she raised.
2. **Main-route reprise.** Slots 1–3 of each chapter after the Fool open with a board that brings back an *earlier* system under the new location's rule. The player arrives somewhere new and recognises something old. Every owned card gets at least one main-route use after its chapter.
3. **Follow the four beats, with the twist on the main route.** Nintendo's Koichi Hayashida described Super Mario 3D Land's stages as a sequence that introduces, develops, twists, and concludes an idea. In the current template the twist sits on optional slots 8–9. Move one twist into slots 4–5 or 7. The twist is the most memorable board of the chapter, and most players should get to see it.
4. **One actor grammar.** Every actor advances one step per paid stroke and previews its next step on the grid. Each actor type then differs in exactly one way: the rim follows a schedule, the cart follows switches, the runner follows tilt, the lion follows a cycle, and the crab seeks a goal and can be lured. Introduce them in order of how much the player steers them. The deck order already roughly does this.
5. **Fewer, deeper rules.** Use a working budget of about one new concept per eight main-route boards, roughly 22 concepts in all. The design review's near-twins are where to start cutting. Merge stamps into folds, so the Magician's "rule" becomes the four tools themselves and Transmute is the new thing. Make Lovers' latches a property of the Hierophant's bells. Share fixtures where §3 rule 1 already pairs systems. Cut any rule that fails the PRD's own "third puzzle" test.

#### Difficulty as a ramp, not a sawtooth

- **Define tiers by accumulated vocabulary.** Normal means one readable decision *using everything owned so far*. By Act III, a Normal board combines two systems.
- **Hard means a delayed failure** (P4), with a solution of four or more interdependent strokes.
- **Super Hard means overturning a belief** the game has reinforced (P1), not coordinating more things at once.
- **Name the rest boards.** Mark one or two per chapter as quiet and familiar, and place them right after each chapter's hardest main-route board.
- **Open boards in parallel.** Baba Is You, The Witness and Patrick's Parabox all leave several puzzles open at once, so a stuck player can go elsewhere. Unlock slots 1–3 together, then 4–5 together, rather than strictly in sequence.

#### A thematic mastery layer: reversed cards

Tarot reads every card upright or reversed. Once a chapter is complete, offer its **reversed** boards: the same tableau, art and fixtures, each built around one *against the grain* insight (P5), for example:
- The Hanged Man reversed, where Suspension makes a counterflow shaft fall.
- The Fool reversed, where Leap is used to *avoid* joining a piece that would otherwise strand its partner.

This gives a Super Hard layer that is cheap to produce (no new location art) and fits the deck's own grammar. It also keeps the main route gentler without losing hard content.

---

### 4 · Worked example · the Hanged Man rebuilt as implications

The same rule and the same card, reorganised so each board overturns one belief. The misbelief column is the authoring brief.

| Slot | Board | The misbelief it overturns | Pattern |
|---|---|---|---|
| 1 | Upward fall | "Clear beneath a thing to move it." In the shaft, you clear *above*. | — |
| 2 | Two directions | "One stroke moves things one way." A single horizontal trace lowers the weight and raises the key. | Two jobs, one stroke |
| 3 | The ceiling holds | "Supports are below." A relic in the shaft rests on the piece *above* it. The Fool's support rule, inverted. | The support is the ammo |
| 4 | Passing in the night | "Neighbours meet by waiting." Two Cups in columns of opposite gravity only come level if the trace takes the right number of cells from each column. | Sculpt the fall |
| 5 | Falling tools | "Take the obvious clear." Clearing above the key lifts the only Sword out of the cutting line, but the cord only comes into play two strokes later. | Delayed failure |
| 6 | No updraft (first reading) | "The card goes on the key's column." Three columns could plausibly be suspended. Only one, activated after its clearance is ready, still has an upward settle left when the key needs it. *Timing certificate.* | Where and when |
| 7 | The Hanged Man | "Suspension makes things rise." Suspend the counterflow shaft itself, so a weight drops onto its plate. | Against the grain |
| 10 | The bell diver | Recombine: the fixed updraft for one relic, Suspension for the other, with a returning Emperor shelf. | Reprise |

Slot 7 requires Suspension to be legal on a counterflow shaft. That is a ruling to make on purpose. It is exactly the kind of interaction that turns a rule into a system.

## Design space

### 1 · How Two Dots paces mechanics, and what transfers

At launch, Two Dots introduced a new obstacle about every 20 levels, matched to the current world's theme. Anchors, ice and fire dots arrived this way ([Gamezebo](https://www.gamezebo.com/reviews/twodots-review-brother-can-you-spare-a-dot/), [Game Developer](https://gamedeveloper.com/business/two-dots-too-charming)). I couldn't find a level-by-level record of the later cadence, so "one every hundred or two" is unverified. Nothing below depends on that exact figure.

The slowdown works because each new obstacle can combine with every obstacle already in the game. The number of boards a new concept makes possible grows with the size of the pool. Concept 5 has 4 partners; concept 40 has 39. Under a steady demand for freshness, the gaps between introductions can widen.

Three cautions keep this logic honest for an authored puzzle game:
1. **Most pairs are inert.** A crab and a palette stamp can share a board without changing what either one means. Only pairs where one concept changes the meaning of the other produce new decisions.
2. **Two Dots has a second source of content.** Score targets, move limits and refill give it volume. Arcana combines quotas and move limits with guided or authored supply. Guided boards carry open play with regular matching opportunities. Measured boards get their freshness from specific interactions between the pieces, the supply and the goal. [Supply rules](product-requirements.md#every-board-refills)
3. **Legibility caps the combinations.** Boards hold about three fixture types plus one guest. The usable pool is therefore combinations of up to about four concepts at a time, not the whole set. That is still very large.

### 2 · The concept ledger

Keep one ledger of everything a player must learn, weighted by how much reading it costs:

| Weight | Kind | Examples |
|---|---|---|
| **1** | A new environmental rule, fixture, actor behaviour, piece type or upright power | The cart, Suspension, the trump rule, court Knights |
| **½** | A concept *derived* from known ones: an extension of a known system, a reversed card, a constraint family, a spread | Basins (the inlet with capacity), Plumb, "no stroke longer than three" |
| **0** | A known concept in a new place or with a new number | A trump of an owned card, a pan that accepts exactly 4, a Knight of a different suit |

Each pair of concepts gets one ruling in the interaction table:

| Rating | Meaning | Use |
|---|---|---|
| **Inert** | They share a board without affecting each other | Never feature it. It adds visual load and no decision. |
| **Additive** | Both apply, and neither changes what the other means | Volume: Normal boards, daily deals, rest boards |
| **Transformative** | One changes what the other means | Novelty: feature boards, first readings, Hard boards |

**The cadence rule.** Introduce the next concept when the pool's *unfeatured transformative pairs* drop below about one chapter's worth, four to six pairs.

**Retire and rotate.** Each volume after Volume 3 declares an **active set** of about 8–12 concepts from the ledger, with a few rotating in and out per volume. This keeps standalone volumes learnable: the PRD already requires each one to list its concepts and open with a short refresher. It also bounds how much of the interaction table each volume has to test.

### 3 · The cadence, with the split

The current atlas introduces about 60 concepts in 220 levels, about one every 3.7. With the Major Arcana spread over three acts, and with chapters that grow as the pool grows (§9), the cadence becomes:

| Span | Levels | What arrives | Weighted concepts | Levels per concept |
|---|---|---|---|---|
| Prologue · the Fool | 1–20 | Four suit fixtures, loose relic, gap, Leap; open and measured supply | 7 | ~3 (tutorial pace) |
| Volume 1 · Act I | 21–160 (7 × 20) | Seven powers, the trump rule, values and feeding (with the Empress, replacing root beds), about two other rules or extensions, path constraints | ~12 | ~12 |
| Volume 2 · Act II | 161–328 (7 × 24) | Seven powers, the actor grammar, the elemental dignity grammar (Temperance), long-trace charges at ½, system extensions, scene tracks, conservation constraints | ~12 | ~14 |
| Volume 3 · Act III | 329–524 (7 × 28) | Seven powers, extensions, the World's seams, "the reading", order constraints. The remaining dignity pairs appear untaught, at weight 0. The album completes. | ~10 | ~20 |
| Reversed readings | 525–1100 | Reversed cards at ½ each, spreads | ~11 | ~50 |
| The Minor Arcana on the board | 1101–2000 | Court figures, Aces, runs (values already arrived in Volume 1) | ~6 | ~150 |
| Beyond | 2000+ | An occasional new fixture or system | — | 150–250 |

Three things make the later volumes slower without making them thinner:
- **Trumps stand in for rules.** Several chapters teach their card through its trump piece instead of a new environmental rule (§6).
- **Systems are extended at half weight.** The companion note's spiral makes each return an extension of a known system, not a new concept.
- **Chapters lengthen.** The extra boards are reprises, combinations and layered Hard boards, which the growing pool can supply.

At the PRD's illustrative pace of 40–80 authored boards a year, level 1100 is about 7–14 years after launch. Between concepts, volume comes from the active set: rest boards, side stories, and daily deals authored backward from a witness. These never introduce concepts.

**Reversed before Minor, or the other way round.** Reversed cards come first in this plan because they reuse powers players already own. Values and feeding already arrive in Volume 1, so the Minor volume adds only figures, Aces and runs. The order is flexible. Court figures can appear in encounters as story characters long before they behave as pieces.

### 4 · Grammars that multiply

Concepts are cheapest when they come from **two small grammars at right angles**. The player learns each axis once, and every combination is readable on sight, the way Baba Is You pairs nouns with properties.

| Grammar | Axis A | Axis B | Yield |
|---|---|---|---|
| Fixtures | Suit | Role: receiver, store, gate, emitter | Lamp, basin, cord and pan are four of sixteen. A Coin gate or a Wand store is readable without a tutorial. |
| Cards | 22 powers | Upright or reversed | 44 verbs (§5) |
| Where a power lives | 22 powers | In the hand (a card) or on the board (a trump) | One verb in two places (§6) |
| Figures | Rank: Page, Knight, Queen, King | Suit | 16 figures from 8 concepts (§7) |
| Pips | Suit | Value 1–5 | Strength as a sum, grown by feeding (§7) |
| Elemental dignities | Action's suit | Facing piece's suit | Three relations (same suit feeds; friendly +1; contrary −1; neutral nothing) predict all sixteen meetings, so new pairs appear untaught |

Two conditions:
- **Each axis behaves the same everywhere.** Anything of the Wand suit answers to a spark. Any Knight moves one step per paid stroke.
- **Each axis is legible on the piece.** Suit is the silhouette, role is the frame shape, rank is a small silhouette mark, and number is a small ink numeral. Each sits alongside the current emblem; none replaces it.

A combination that needs its own exception isn't part of the grammar. It is a new concept, at weight 1.

---

### 5 · Cards: upright, reversed, combined

#### Three ways to reverse a card

Tarot reads a reversed card as the same energy blocked, turned inward or turned around. Every reversed power comes from its upright power by exactly one of three operations, so players can predict a reversal before they read it:
- **Invert the effect.** Same target, opposite effect: raise becomes lower, join becomes part, fill becomes drain.
- **Swap the target.** The same effect, applied to the world instead of to the player's trace, or the other way round.
- **Invert the time.** Now becomes next, or forward becomes back.

Every reversed power must pass four tests:
1. It produces decisions the upright card doesn't.
2. Its target and conditions are readable on the grid before committing, and its effect is readable after resolution.
3. It isn't a **trivializer**, a power that dissolves a whole certificate type.
4. Its reversed first reading can carry a certificate.

#### Inventory (first proposals, there to show the space exists)

| Card | Upright | Reversed proposal | Operation | Status |
|---|---|---|---|---|
| 0 Fool | Leap: a trace jumps one cell | **Stumble**: a falling relic crosses one gap cell | Swap target | Strong |
| I Magician | Transmute a piece's suit | **Retool**: change the suit a *fixture* accepts | Swap target | Strong. Reaches the fixture grammar directly. |
| II Priestess | Turn the Page | **Veil**: a piece becomes a blank stone for two beats. It still supports but can't be traced. | Invert effect | Strong |
| III Empress | Grow suit to the side neighbours | **Prune**: remove one piece without firing it | Invert effect | Trivializer risk: it dissolves Count and Isolation certificates. Limit it or redesign. |
| IV Emperor | Foundation: add a shelf for two beats | **Collapse**: remove a printed shelf for two beats | Invert effect | Strong |
| V Hierophant | Rite: echo the next action | **Silence**: the next stroke fires no action | Invert effect | Strong |
| VI Lovers | Draw Together | **Part**: push two adjacent same-suit pieces to opposite ends of their row | Invert effect | Strong. Controls the size of a group. |
| VII Chariot | Drive a cart sideways | **Reverse**: send a cart back along its last edge | Invert time | Good |
| VIII Justice | Equalize the pans | **Tip**: move every stored Coin to the heavier pan | Invert effect | Strong |
| IX Hermit | Lantern: a wildcard endpoint | **Shade**: a piece acts as an opaque screen for two beats | Swap target | Good |
| X Wheel | Turn the rim one slot | **Stay**: skip the next scheduled tick | Invert time | Strong |
| XI Strength | Hold the Beast | **Rouse**: the guardian advances one step now | Invert time | Strong |
| XII Hanged Man | Suspension | **Plumb**: a counterflow shaft falls for two settles | Swap target | Strong |
| XIII | Reap a suit | **Sow**: every stubble square sprouts now | Invert time | Good if beds remain |
| XIV Temperance | Decant | **Drain**: send 1–3 units down the overflow | Invert effect | Good |
| XV Devil | Bind two relics | **Exchange**: two chained relics swap places | Invert effect | Needs testing |
| XVI Tower | Breach | **Rebuild**: the rubble returns to its column | Invert time | Strong |
| XVII Star | Place an inlet | **Dam**: block a channel segment for two beats | Invert effect | Strong |
| XVIII Moon | Reflection | **Moonset**: swap the lit and unlit states of a pair of crescents | Invert effect | Needs work |
| XIX Sun | Illuminate a column | **Eclipse**: shade a column | Invert effect | Strong |
| XX Judgement | Recall | Still open | — | Leave unreversed until a proposal passes the tests |
| XXI World | Join opposite edges for one trace | **Orbit**: for one settle, pieces that fall off the bottom re-enter at the top of their column | Swap target | Strong |

About fourteen of these look strong, which is enough for a reversed volume. A card can stay upright-only.

**Where reversed cards are earned.** Each is earned on a *second visit* to its location. The tableau is the same, at night or in another season. The visit opens with boards that use the upright card against the grain, and its first reading awards the reversed card. In the album, the reversed card hangs upside down beside its upright partner.

#### Combos come from rules, not scripts

Match-3 games often script special-piece combos (Candy Crush's striped plus wrapped candies). Each scripted combo is another rule to teach and maintain. With 44 cards and 22 trumps, that becomes unmanageable. Arcana scripts none:

- **One turn order resolves everything.** This is the design review's C1. A combo is two effects resolving in that order.
- **Order is where the depth is.** Feature only pairs where A then B differs from B then A.
- **Round trips are rare.** These are a card and its own reversal (Suspension then Plumb, Breach then Rebuild). They are rare showcase boards, and their certificate must show that something changes in between, so the pair is not just an undo.
- **Hand meets board.** A card in hand combined with a trump on the board counts as a combo too, and it goes through the same table (§6).

#### Spreads: the hand as a constraint

| Spread | Constraint |
|---|---|
| Past · Present · Future | Cards are played left to right |
| The cross | The crossing card is played on the same beat as the card it covers |
| Two paths | The hand offers two cards; playing one discards the other |

Spreads have weight ½ and work with every card. They are for Hard boards and above.

---

### 6 · The Major Arcana on the board: trump pieces

In the card game of tarot, which is still played widely in France, the Major Arcana are **trumps**: they beat any suit. The Fool is the **Excuse**, played to avoid following suit and then taken back. Arcana can use both ideas, and stay faithful to the deck.

#### One rule for every trump

> A trump piece belongs to no suit. A trace of any suit may **end** on it. The traced pieces leave. The trump then fires its card's power from its own cell, aimed by the trace's last segment, and using the trace's suit and length where the power needs them. Then it leaves the board, and the column settles.

- **A trump is its card's power, with the *where* given to the board.** In the hand, the player chooses both where and when. On the board, the trump sits in a cell, and the player chooses when, by ending a trace on it. The trump falls with gravity like any piece. So where it fires is still the player's work, done by sculpting the fall. This uses the third reversal operation from §5, swapping the target, at the level of the whole deck.
- **Learning cost.** The rule itself is weight 1, introduced once. A trump for a power the player already knows is weight 0. A trump for a new power counts once, together with its card.
- **The Fool is the Excuse.** Any trace may step over the Fool's cell without including it, and the Fool never leaves. It is Leap fixed in place, and it is the only trump that is never used up.

#### Two jobs for trumps

**1 · Teaching the card before the loan.** In chapters whose iconography is a figure or an act, such as the Magician, Empress, Hierophant, Lovers, Hermit, XIII and the Sun, slots 1–5 put the card's trump on the board instead of adding a new environmental rule. The progression is then natural:
- Slots 1–5: the power is fixed in place, and you choose *when*.
- Slot 6: the first reading lends the card. Its certificate is that the board's trump is in the wrong place and cannot be brought to the right one. That is a Reach certificate that the player has already felt.
- Slot 7 onward: you own the card and choose both where and when.

Chapters whose iconography is a place keep their environmental rule: the Moon's pool, the Tower's masonry, the Wheel's rim, the Star's channels, Justice's scales and the Hanged Man's shaft.

**2 · Bringing earned cards back.** In any later chapter, a trump of an owned card can sit on the board at weight 0. This is how every card gets the main-route afterlife the companion note asks for. It also makes the album *play*, not just display. A board in the Moon chapter might hold the Tower's trump. A board in the World chapter might hold the Fool, the Sun and the Star together.

**How a trump looks.** A small framed card face carrying its Marseille numeral and one silhouette taken from its card's existing illustration. It is drawn in the current palette and line weight. The frame is what tells a player, at a glance, that this piece is not a suit.

#### Example trumps

| Trump | Fired from its cell | The decision it creates |
|---|---|---|
| 0 Fool (the Excuse) | Never fires. Traces may step over it. | A permanent bridge that falls. Where it settles decides which groups can join. |
| I Magician | Turns its trace's suit onto its four neighbours | Set the suit of a whole crossroads, so the endpoint picks the colour |
| X Wheel | Rotates the eight pieces around it one step clockwise | A rim you carry with you: a local rotation puzzle anywhere on the board |
| XII Hanged Man | Its column rises for two settles | Where the trump falls decides which column turns over |
| XVI Tower | Breaks the masonry below it in its column | Drop it onto the right stack first |
| XVII Star | Leaves an inlet in its cell for the next pour | A source of water that has to be put in place before it fills |
| XIX Sun | Lights every lantern along its row or column, in both directions from its cell, up to the first opaque object | See the worked example below |
| XXI World | Joins the two ends of its row for the next trace | A seam that moves |

#### Worked example · *Sunset over the quay* (Sun chapter, slot 2)

**Board.** Two solar lanterns are fixtures at A4 and F4, the left and right ends of row 4. The Sun trump starts at C1 with three pieces of mixed suits below it in column C. There is a decoy lantern in row 2. A screen at E4 is held by a cord.

**What happens.** Every cell cleared beneath the Sun lowers it by one. The Sun "sets", one row at a time.

**The play.** The player has to:
- clear exactly three cells beneath the Sun, so it lands in row 4;
- cut the cord, so the screen at E4 drops out of the row;
- finish with a horizontal trace that ends on the Sun from B4 or D4, so its light runs both ways along row 4.

**What the board teaches.**
- *Misbelief:* "light comes from above", which the Sun chapter's windows have just taught.
- *The trap:* ending a trace on the Sun early, in row 2, lights only the decoy. That ends the board as a loss, because the trump is used up.
- *Pressure:* scarcity. There are only enough pieces of the suit next to row 4 to make one finishing trace.

**A later reprise.** In Act III's second movement, the Sun trump sits in a Hanged Man counterflow shaft. Clearing above it raises it: *Sunrise*.

---

### 7 · The Minor Arcana on the board

**The suit pieces already stand for the Minor Arcana.** This is a design framing, not a change of look. The ordinary pieces start from their current emblems and palette (see the PRD's *Pieces from the deck*). The look can evolve on its own terms. Later volumes then add the rest of the Minor Arcana around pieces players already know. The deck adds four layers to the board, in this order:

| Layer | On the board | Behaviour | Learning cost | Arrives |
|---|---|---|---|---|
| **Pips** (unnumbered) | Ordinary pieces | Trace, fire, fall | — | Level 1 |
| **Aces** | The **emitter** role in the fixture grammar: the suit's source | An Ace at the top of a column is the visible source of its supply ribbon. Each beat, it releases the next piece of its suit. | 1 for the role, 0 per suit | Early as supply sources if refill deals need them. Otherwise in the Minor volume. |
| **Values** (1–5) | The current emblem with a small ink numeral | Adds its value to the trace's strength, and grows by feeding and friendly dignities | 1 for values and feeding together | The Empress, Volume 1 |
| **Court figures** | Page, Knight, Queen, King of each suit | One behaviour per rank (below) | 1 per rank, 0 per suit | Minor volume. Earlier as story characters in encounters. |

**Values** keep the ordinary piece's emblem and add a small ink numeral in the card-label type. The emblem stays dominant, so the suit still reads first at thumb size. Values are capped at 5 on pieces so sums stay easy to do in your head. Higher numbers appear only on fixtures. Values are printed per board: a board without numerals plays exactly as before. The PRD's *Values, feeding and elemental dignities* gives the full rules.

They also enable a constraint the deck has been waiting for: a **run**, where a trace must ascend or descend in value, the way solitaire builds a column. That is where the name *Tableau* finally pays off. Fortune's Foundation, the nearest neighbour in theme (see the [comparison with other games](#6--lessons-from-comparable-games)), is built on exactly this kind of play.

**Court figures** get one behaviour per rank, each tied to a system the player already knows:

| Rank | Behaviour | Extends |
|---|---|---|
| **Page** (messenger) | Can't be traced. Falls like a loose relic. Delivers its suit's action at strength 1 to the fixture it lands next to. | Loose relics and fixtures |
| **Knight** (traveller) | Moves one cell along its facing per paid stroke, trading places with ordinary pieces. It counts as its suit, so groups change as it rides. | The actor grammar |
| **Queen** (keeper) | Never falls and never leaves. A trace may pass through her: she adds 1 to its strength and stays. | Shelves and anchors |
| **King** (commander) | A trace that includes the King fires in the King's facing direction, not along the last segment. He leaves with the trace. | Aiming |

### 8 · Each new piece type names the invariants it breaks

Certificates rest on two invariants: *pieces never leave their column*, and *pieces keep their order within a chamber*. Every new piece type ships with one line in the certificate checklist saying which of these it breaks:

| Piece | Breaks |
|---|---|
| Knight, Wheel trump, Lovers trump, Draw Together | Column invariance, for the pieces they move |
| Hanged Man trump, Suspension | Vertical order, for two settles |
| Queen | Count arguments: her suit can never run out next to her |
| King | Reach arguments built on the direction of the endpoint |
| Fool (Excuse) | Isolation arguments across its cell |
| Values, feeding, dignities | Count and Arithmetic certificates must use sums. Feeding and contrary dignities only reduce traceable pieces. Blank stones are new blockers. |

**Legibility cap.** On a Normal board: ordinary pieces plus at most *one* special piece type (one trump or one court rank). Hard boards allow two. A board's special pieces count toward the cap of about three fixture types plus one guest.

---

#### Future mechanic · Spreading water and rubble

Prototype a hazard that starts at a marked source and claims adjacent cells one at a time. Water could spread from an overtopped basin along low ground. Crumbling masonry could deposit rubble in the next cell along a fault. Sketch one version first, with the next threatened cell visible and announced before the player commits a move. Resolve the spread after a paid stroke so the player has time to divert the water or clear a route through the rubble.

Decide how affected cells treat the pieces already there and how they receive arrivals before authoring a deal. Playtest whether players can read the next step, use a move to intervene and recover after losing a cell.

### 9 · Layers: a puzzle within the board, and one above it

Normal boards have one puzzle: the board. Harder boards add **layers**. Each layer is a second set of conditions coupled to the board.

#### The inner constraint

The inner constraint is printed inside the board's frame or on the goal. Every stroke must meet it, or the final state must.

| Family | Examples | What it forces |
|---|---|---|
| Path | Every stroke turns. No stroke turns. No stroke longer than three. Each stroke longer than the last. | Routing and partition choices the base board leaves open |
| Conservation | Never strand a suit. A named piece never moves. The gold Coin never falls more than two cells. | Planning the whole board, not just the next stroke |
| Order | Play the suits in a printed cycle | Sequencing across systems |
| Run | Every trace ascends or descends in value (boards with values only) | A solitaire discipline layered on the trace |
| **The reading** | A small framed window (2 × 2 to 3 × 3) must end showing a printed arrangement | Sculpting the fall to compose a picture inside the board |

#### The upper scene

The upper scene gives the illustration above the grid its own **discrete state track**, with one position per column. Examples:
- a ferry on the river;
- a procession on the quay;
- the moon's phase;
- the tower the wolf is watching.

The track changes only through addressed board events: a bell in column C pulls the ferry one step toward C. The scene has its own one-sentence rule, for example "the ferry carries one passenger". The track works like a row 0 with an address for every state. That keeps the PRD's "one scene, one puzzle state", and the board still passes the cover test.

#### Rules for layers

1. **Tiers.**
   - Normal: no layers.
   - Hard: one layer, either an inner constraint or a scene coupling.
   - Super Hard: both layers, set *against* each other, so the board's best move is bad for the scene.
2. **No layer on a concept during its first chapter.**
3. **At most two coupling channels** between the board and the scene, each named in the entry.
4. **Mark constraints on the current board.** The player can see restricted cells, paths or suit orders while choosing a stroke. Show the result when the stroke resolves.
5. **Each layer must be readable on its own.**

#### A Super Hard sketch · *The night crossing* (Moon revisit)

- **Constraint:** no stroke may be longer than three.
- **Scene:** the ferry must be at column D when the D lamp lights. Each bell strike pulls the ferry one step toward that bell's column.
- **The conflict:** the four-Wand line to the D lamp is forbidden. Three Wands reach only the C lamp, and Reflection can carry its light to D. But the reflection also turns the wolf toward the ferry's bank. So the player has to ring the bell first, while keeping a pair of Cups to lure the crab off the landing.
- **Certificate:** Timing.

**Why layers matter for decades.** Mechanics *add* to the pool; layers *multiply* it. Each constraint family and each scene track works with every concept in the ledger. That is how chess problems and Sudoku variants (killer, thermo, arrow) kept producing fresh puzzles long after their base rules were fixed.

---

### 10 · Chapter shape in each volume

A chapter lengthens as the pool grows, because the extra boards are reprises and combinations. Slots 1–9 keep the PRD's roles. The **second movement** follows, and the encounter closes the chapter.

| Slots (Volume 1, 20 boards) | Role | Route |
|---|---|---|
| 1–9 | As in the PRD: the rule or trump, the familiar constraint, the first reading, first independent use, two optional leaves | Main route, except 8–9 |
| 10–11 | **Reprise**: the new card meets a returning system | Main |
| 12 | **Trump reprise**: an earlier card's trump meets this chapter's rule | Main |
| 13 | **Twist**: the against-the-grain or implication board | Main |
| 14 | **Rest**: a named, quiet, familiar board | Main |
| 15–16 | **Combination**: this card with a guest, where the order matters | 15 main, 16 optional |
| 17–18 | **Layered Hard**: one inner constraint or one scene coupling | Optional |
| 19 | **Super Hard**: both layers | Optional |
| 20 | **Encounter** | Main |

That gives 14 main-route boards and 6 optional boards per chapter.

Volume 2 chapters (about 24 boards) add two more reprises and two more combinations. Volume 3 chapters (about 28 boards) add more again, and lead into a recombination finale. Unlock in parallel (companion note §3): slots 1–3 together, then 4–5, then 10–13 together.

---

### 12 · Archived lozenge studies

The notes below record the older web experiments with area clears. The mobile opening teaches squares and rectangles with those powers. A later puzzle group introduces lozenges with a separate combo set. [Current gesture rules](product-requirements.md#what-happens-under-the-finger)

Ordinary traces stay horizontal and vertical, and the last segment aims. The design supports lozenges, squares and triangles as closed shapes with the same area clear and scoring rules. A lozenge closes four diagonal sides around an area. The turns define a shape's corners, so a player can start midway along a side or at a corner and take either direction. Sides can pass over targets. Keep the outline clear of blocked cells. A target at a turn normally counts as the suit it accepts. The trail marker in The First Step can match any suit at a corner and gains light only from Wand shapes. [Opening rules and playtest status](opening-deals.md#rules-in-play)

Match the ordinary corners in one suit. In boards that teach mixed shapes, a second rule admits uneven mixes of goal suits and every corner order. Far Wreath uses Wands and Cups because its goals are the lamp and inlet. [Core rules](product-requirements.md#what-happens-under-the-finger)

- **Make the two clears feel different.** Four matching pieces can feed and bless targets caught in the shape. Mixed pieces clear an extra layer. Far Wreath puts the two payoffs back to back, with a 35-piece mixed clear followed by a matching clear that feeds two targets.
- **Let the player build the shape.** A vertical clear can lower pieces in one column. A horizontal clear can lower several columns together. Both produce opportunities from visible pieces. Keep lozenge opportunities regular through guided supply while leaving the choice of when and where to draw them with the player.
- **Treat target corners as a shared effect.** Any legal shape with a target corner clears its normal area. Each eligible target corner receives at least 1 progress, scaling with how many matching pieces cleared. Two or more eligible target corners make a link lasting one turn per target. Linked traces share their progress across those targets, and every paid stroke uses a turn. A new link refreshes the duration for its own set of corners.
- **Show the cause and the time left.** Connect linked targets with lightning, flash the link when progress travels and show the remaining turns in text. With reduced motion the link stays steady. A shape crossing a target keeps the same gesture rules in either direction.
- **Teach one consequence at a time.** Far Wreath marks four real moves, then leaves the rest of the deal to the player. Keep the live drag focused on the path and its aim. The clear, fall and any linked gain appear on release. [Verified playtest routes](opening-deals.md#lozenge-playtest-routes)

#### Other benefits to try later

| Lozenge around… | Possible benefit | Watch for |
|---|---|---|
| A loose relic (the gold Coin) | Holds it in place for two beats, or lifts it one cell | Overlap with Foundation and Bind |
| A gap | Bridges it permanently, joining the column | Too strong for the prologue. It could be a reversed or World power. |
| An actor (crab, lion) | Wards it: it skips its next step | Overlap with Hold the Beast |
| A fixture, with a friendly or contrary suit | Friendly: blesses it without feeding it. Contrary: seals it for two beats. | Wait for dignities in Temperance |

#### Refill around fixtures: decided for now, sealing kept for later

**Now: everything refills.** Ordinary pieces fall past lamps, inlets, pans and gaps, so every open cell refills from the top. Under this rule:
- cells refill while ribbons last;
- the lozenge stays available around mid-board fixtures.

**Registered for later: sealed chambers.** A fixture or shelf that *holds* the cells below it apart. Pieces under it still fall within their chamber, but nothing refills there, so the space becomes a finite, measured stock. Where it fits:
- **The Emperor's shelves (IV).** Their rule is already "a fixed shelf divides a column into independent gravity chambers". Sealing belongs there first, as a printed, visible property.
- **Sealed fixture variants.** For example, a basin that rests on the floor and holds what's above it. Use them only where a board needs a stack that stays put, as the legacy Fool drawbridge layout did, and draw the seal as a visible ledge.
- **Concept ledger.** Weight ½, as an extension of the support system. It breaks no invariant, but certificates must say which chambers are sealed.

The archived drawbridge layout and the first 001 greybox with dry ribbons used seals. The Fool 012 refill strategy uses open columns. [Opening deals](opening-deals.md#fool-012--one-impossible-step)

### Falling Coin movement lesson

The prologue uses fixed markers. Coin traces and rectangles fill its pans and bells. In a future lesson on moving pieces, a distinct edge-on Coin could fall when a stroke clears its supports and ring a bell at its catch point.

The earlier Broken Road study put the loose Coin at E2 above a bell at E6. A Cup trace across the bottom, then a Wand pair and a Cup pair at D5–E5, let it fall in three steps. The fixed-pair ferry study also records a one-stroke version. [Archived ferry study](opening-deals.md#archived-lamp-and-bell-deal)

The cadence figures are illustrative targets. The draft trump and figure examples still need testing on paper and in playtests. The PRD records the adopted split into three volumes and the current rules for pieces and trumps.

## Comparable game research

### 6 · Lessons from comparable games

| Game | Observed | Take for Arcana |
|---|---|---|
| SameGame / Clickomania | Deciding full clearability is NP-complete in general ([Biedl et al.](https://arxiv.org/abs/cs/0107031)) | This is why §3 builds solvability in by construction rather than verifying it afterwards. |
| Two Dots | A closed loop clears every dot of that colour ([help centre](https://dots.helpshift.com/hc/en/3-two-dots/faq/368-how-do-i-play-two-dots), [Wikipedia](https://en.wikipedia.org/wiki/Two_Dots_(video_game))) | Players of tracing games *expect* shape to matter. Say "loops do nothing" early, or give loops a meaning late (the World's wreath). |
| Dots & Co | Companions charge from special dots, then fire a power ([guide](https://www.androidcentral.com/dots-and-co-beginners-guide)) | A later-volume option: charge a card by clearing its suit, so the power is earned within the level. Keep it previewable. |
| Balatro | 22 tarot cards as one-use consumables that transform cards ([guide](https://insider-gaming.com/how-to-use-tarot-cards-in-balatro-all-tarot-cards-explained/)) | Players already read tarot as "one-shot transformation", which supports one charge per attempt. It also shows 22 distinct one-shot effects can be kept apart. |
| Fortune's Foundation (Zachtronics) | Tarot solitaire with the 22 Major Arcana as their own foundation, known for being hard ([PC Gamer](https://www.pcgamer.com/zachtronics-combined-tarot-with-solitaire-and-its-my-new-daily-jam/)) | The nearest thematic neighbour, and "tableau" is solitaire vocabulary. Make the difference obvious in store art. A short "reading" on clear suits the audience. |
| KAMI 2 | Moves-to-par "Perfect", a daily challenge, a puzzle builder; reviewers criticise paid hints ([App Store](https://apps.apple.com/us/app/id1133161444)) | Supports par as the designer's line plus an "under par" reward (§3c), free hints, and eventually a builder. |
| Good Sudoku | Generated puzzles with dialled difficulty; hints teach named techniques ([MacStories](https://www.macstories.net/reviews/game-day-good-sudoku/), [VICE](https://www.vice.com/en/article/good-sudoku-is-making-me-good-at-sudoku)) | Grade by *required technique*, not stroke count. Keep a technique list per chapter, and have hints name it (§3d). |
| Hexcells / Tametsi | "Never requires guessing" is a headline promise ([Tametsi on Steam](https://store.steampowered.com/app/709920)) | Arcana can promise "every board can be cleared with the cards dealt, and the reason you need the card is visible". The certificates (§3b) are what back that promise. |
| Snakebird (and Sturtevant et al.) | Tiny gravity levels; single-tile edits change solution length a lot, 28 → 41 in one case ([AIIDE 2020](https://ojs.aaai.org/index.php/AIIDE/article/view/7421)) | Levels are fragile. Re-check the certificate and witness after *any* layout edit, and lock layouts late. |
| Stephen's Sausage Roll | Few mechanics pushed very deep; critics split on whether that is too thin ([Game Informer](https://gameinformer.com/games/stephens_sausage_roll/b/pc/archive/2016/05/02/stephens-sausage-roll-game-informer-review)) | The opposite risk from Arcana's 22 rules. Fewer, deeper rules per volume would be more memorable and cheaper to make. |
| The Witness | Rules taught by clusters of panels with no text; regions each have a rule set; late areas combine them ([Wikipedia](https://en.wikipedia.org/wiki/The_Witness_(2016_video_game))) | This matches chapter = region. Borrow the combination finale for 201–220 on the main route. |
| Into the Breach | Enemies telegraph their attacks on the current board. [Game Developer](https://gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i-) | Mark the current direction, targets and constraints so players can anticipate consequences. Reveal the settled board after commitment. |
| Hitman GO / Lara Croft GO | Enemies move one step per player move; each type has a distinct colour and pattern ([Wikipedia](https://en.wikipedia.org/wiki/Hitman_Go)) | Each actor type (crab, runner Coin, cart, lion, rim) keeps one fixed behaviour, silhouette and colour. Never vary behaviour per level. |
| A Monster's Expedition | Mechanics taught subtly by layout; every system either removes friction or provides rest ([Game Developer](https://www.gamedeveloper.com/game-platforms/the-relaxing-open-world-puzzle-design-of-i-a-monster-s-expedition-i-)) | Name the rest boards. Let the album, map and vignettes be the rest. |
| Opus Magnum | Per-puzzle histograms of several scores drive long-tail replay ([community summary](https://biggieblog.com/tracking-the-global-opus-magnum-records/)) | Several small mastery axes beat one par medal: strokes, longest trace, cardless clear. |
| Toon Blast | A tap-to-collapse game that reached 3,000+ levels by recombining a fixed set of obstacles (2020 figures) ([GameRevolution](https://www.gamerevolution.com/guides/645245-how-many-levels-are-in-toon-blast-2020)) | Scale comes from recombining a stable vocabulary, not from adding rules. This supports the PRD's "a release can add zero new engine rules". |

### Campaign progression precedents

Research question: can clearing be intrinsically interesting first, then support a collection, difficult optional puzzles and recurring characters? The observations below are from developer, publisher or official reference material. The campaign decisions are our design inferences. Terra assisted with the finite-clear, systemic-puzzle and optional-route research.

| Reference | Observed design | Decision for Arcana Tableau |
|---|---|---|
| Same Game | Groups need multiple same-colored blocks. Removing them changes the remaining arrangement through falling and horizontal compaction. A full clear wins; isolated leftovers can end a run. [Official rules](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/doc/samegame.html) | Give the opening one visible physical goal. Retain finite-clear arrangements as exercises in preserving partners. Trace selection and fixed columns let us build traps around preserving a partner. A losing singleton is understandable on a finite board. |
| Baba Is You | Rules are visible, movable objects. Rearranging them changes what objects can do and what counts as winning. Its developer describes more than 200 puzzles. [Developer listing](https://store.steampowered.com/app/736260/Baba_Is_You/) | Spend complexity on relationships players can see. Example: an Emperor shelf catches a falling key, then returns in the Sun chapter as the thing casting a shadow. Keep the goal printed even when a fixture changes state. |
| Railbound | Main-route levels introduce rail decisions at a relaxed pace. Forks offer harder problems using switches, tunnels and timed barriers. [Developer listing](https://store.steampowered.com/app/1967510/Railbound/) | Give every chapter two optional mastery boards. They can require several moves of foresight without holding an earned card, the storyline or the next chapter hostage. |
| Two Dots | Its map identifies designer-selected Hard and Ultra-Hard levels before entry. [Official difficulty guide](https://dots.helpshift.com/hc/en/3-two-dots/faq/380-what-does-the-fire-on-the-level-nodes-mean/) | Display the tier and hand on the map. Separate *designer intent* in the atlas from the published rating, which comes from human tests. The help page establishes the labels; it supplies no thresholds for our players. |
| Deadly Rooms of Death (DROD) | Caravel describes five major campaigns, smaller themed releases, a level editor, user-made campaigns and compatibility with earlier holds. Its archives contain authored rooms from 2004 and releases from 2025. [Caravel guide](https://forum.caravelgames.com/site/guide) · [2004 archive](https://forum.caravelgames.com/holds.php?arch=Doom) · [2025 archive](https://forum.caravelgames.com/holds.php?arch=Xindaris) | This is a concrete precedent for decades of authored puzzle material. Build an internal editor first, preserve older room versions and invite a guest designer to make a complete short campaign before considering public submissions. |
| Candy Crush Soda Saga | King’s community team publishes a recurring level-release bulletin, groups additions into episodes and describes weekly updates across platforms. [King’s release bulletin](https://community.king.com/en/candy-crush-soda-saga/discussion/285846/what-is-the-latest-level-in-candy-crush-soda-saga) | An episode can be the unit of writing, QA, translation and release. Estimate capacity from completed batches. One studio’s cadence gives us no basis for promising weekly releases from this team. |
| Hearthstone, Death Knight Prologue | The story prologue demonstrates a hero power and runes. Completing it unlocks the class and adds a specified set of cards to the collection. [Blizzard’s 25.0 patch notes](https://hearthstone.blizzard.com/en-gb/news/23882860/25-0-patch-notes) | Give a first use inside a supervised puzzle, then award the depicted card permanently. A loan makes a missing tool playable and a named reward makes the next chapter’s prerequisites knowable. |
| Monument Valley 3 | The publisher describes a character journey, a growing village, hidden puzzles, and a further chapter-based adventure. Its mobile offer includes free opening chapters and a permanent unlock. [Developer’s mobile listing](https://play.google.com/store/apps/details?id=com.ustwogames.mv3) | Let the atlas remember what the player repaired. A later chapter can revisit the same bridge during a flood. A paid volume can tell a complete new story with the tools players already understand. |

### Card acquisition alternatives

| Candidate | What the player does | Tradeoff and use |
|---|---|---|
| Uncover the illustration | Earn one fragment per phase across the first ten win dialogs. The fragments fit into the Fool’s journey. | Builds anticipation and makes the art part of progression. A simple count of interchangeable fragments would invite repetitive play. Use each fragment as a unique visual checkpoint, with zero currency value. |
| First reading | Borrow the face-up card for one puzzle where it can solve a previously impossible position. On victory the card slides into the album. | Connects ownership to understanding. Adopt this as the acquisition event. The first Fool card lets the player join two separated survivors after learning why a singleton matters. |
| Choose one after an encounter | Pick one of two known cards or blessings to carry into the next scene. | Interesting in a replayable side journey. Every selectable deal must be solvable with that choice, or offer a guaranteed loan at the next encounter. Reserve for later volumes after the fixed-hand campaign establishes the rules. |

**Decision.** Combine the first two. Ordinary play fills the ten journey slots from phases 001–010. Prologue board 012 awards the abstract Fool card and Leap over the assembled journey. In chapters I–XXI the first reading awards the card at local slot six. The encounter at the end uses the acquired card to change a place in the world. A player arriving at Wheel of Fortune slot seven, for example, already owns the Wheel from slot six, can use it once without spending it, and can retry immediately. Optional prizes can add sketches or another character’s interpretation of the same image.

**Evidence limit.** These precedents demonstrate viable structures. They do not establish Arcana’s retention, willingness to pay, future release rate, or the difficulty of a proposed level. Test those independently with the nineteen-board Fool prologue and later greyboxes.
