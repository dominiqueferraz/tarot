# Tarot Squared

A tarot puzzle game for iOS and Android. The Flutter app lives at the repository root alongside the [product requirements](docs/product-requirements.md), [campaign plan](docs/campaign-001-220.md) and [deck artwork](deck/).

The Dart package name is `tarot_squared`. The iOS bundle ID and Android application ID are both `group.kleinfour.games.tarot`. App versions and build numbers come from `pubspec.yaml`.

Play opens an ascending campaign path. Tap a phase to see its illustration, scoring suits, objective, move limit and difficulty, then play it from the preview. The campaign opens with **The Fool’s Step**. The guide teaches matching traces, rectangles and wildcard corners in six strokes. Rectangles clear pieces of every suit inside and along their sides. Light the trail marker by aiming Wand traces at it or enclosing it in a Wand square or rectangle. Settings offers English, Brazilian Portuguese and Spanish. Edit the locale resources in `lib/l10n/` and run `bin/flutter gen-l10n` to refresh the generated Dart code.

Clearing The Fool’s Step unlocks **Lamplighter**, where Cups fuel the quay lamp to 44 light. Clearing Lamplighter unlocks **High Water**, a 6 × 7 board where Cups fill the mill inlet with 32 units of water. High Water unlocks **The Mooring**, a wide 7 × 6 board where a Sword square links the two cords so an aimed cut reaches both. The Mooring unlocks **The Ferryman’s Fare**, an 8 × 8 board where both scale pans need 24 Coins. After paying the fare, the Fool reaches **Market Day** and helps open a bread stall using Wands, Cups and Coins. Market Day unlocks **The Fair Split**, where Cups must bring both sluice floats to their marks on the same move. The Fair Split unlocks **From Behind**, where eastbound Wand traces feed a west-facing lamp. From Behind unlocks **Keep Me a Partner**, where the Fool fills the landing basin before the night fishing crew sets out. Keep Me a Partner unlocks **Night Fishing**, where the crew sets out once their lamp is lit and the boat is free. The ten deals give 25, 22, 18, 26, 25, 18, 24, 18, 14 and 20 moves, respectively.

The win dialog shows a fragment of the Fool’s journey the first time you clear each of the opening ten phases. Tap **The Fool** on the path to see the collected scene assemble. The complete scene becomes the background for the abstract Fool card at the planned Leap acquisition in phase 013.

Five hearts show your lives on the campaign path and phase previews. Broken hearts mark spent lives. Running out of moves costs one life. When you leave an unfinished deal, you can keep playing or confirm that you want to spend a life and return to the path. Each spent life returns 20 minutes later, even while the app is closed. The timer below the hearts shows when the next life returns. At zero lives, you can browse the campaign while you wait to play or retry.

The home card uses the Moon (XVIII) from the Rider–Waite–Smith deck. The paper texture, suit shapes and ridge use the opening playtest artwork from the Arcana prototype archive.

## Author a puzzle

Edit [the puzzle catalog](assets/puzzles/fool.json). Entries appear in campaign order and unlock when the preceding puzzle is cleared. Each entry has a stable `id`, a `scene` (`ridge`, `quay`, `mill`, `dock`, `market`, `breadStall`, `sluice`, `lampPath`, `fishingLanding` or `nightFishing`), and a `textKey` for the title and objective.

- Write one or more nonempty `board` rows of equal length. The rows determine the board’s width and height. Use `W`, `C`, `S` and `O` for the suits, `.` for a fixed wall cell and `L` for each fixture. Use `target` for one fixture or `targets` for several. Give each fixture a `cell`, scoring `suit`, progress `quota`, localized `label` key and optional `fade` amount per missed move. Set its `kind` to `marker`, `lantern`, `inlet`, `cord` or `pan` to select its artwork and progress wording. The `scene` selects the illustration above the board. Enable `linksTargets` for squares that link compatible target corners. Set moves, par and difficulty separately.
- Set `fillTogether: true` on a two-target deal that requires both targets to reach their quotas on the same stroke. A target that reaches its quota by itself settles one unit below the mark.
- Give a target `aimDirection` (`north`, `east`, `south` or `west`) to score only from matching traces that finish in that direction. Its arrow shows the approach. Rectangles still clear the area and can use the fixture as a wildcard corner.
- Use `ribbons` refill with one repeating string per column in arrival order or `guided` refill with a seed and positive suit weights. Set `showArrivals: true` on a ribbon refill to show the next three pieces for each column. Put square and rectangle scoring and guided refill tuning in the catalog's shared `rules`. The `refillLowerRow` threshold scales from the six-row reference board.
- Add an optional `guide` with a cue of `match`, `square`, `rectangle`, `enclose`, `aim`, `wildcard`, `linkSquare` or `linkedAim`. Each step uses coordinates separated by spaces, a hint position `[x, y, tail]` in board units, and one arrival string per column. Columns are labeled A through Z, then AA, AB and onward. List exactly the pieces the move needs to replace in each column, from the lowest vacancy up. Replay authored guides and solutions with `bin/test`.
- Add titles, objectives and target names to the ARB files in [lib/l10n](lib/l10n/). Define new keys in [puzzle_definition.dart](lib/fool/puzzle_definition.dart), map them to the generated getters in [puzzle_presentation.dart](lib/fool/puzzle_presentation.dart), and run `bin/flutter gen-l10n`.
- Edit the SVGs in [assets/art](assets/art/) for symbols, scenery and story figures. Adjust spacing, timing, palette and scene placement in [design_tokens.dart](lib/design_tokens.dart).

## Run and check

Use Flutter 3.50 and Python 3. Run `bin/flutter doctor` to check the Xcode and Android SDK toolchains. Use `bin/flutter` for commands in this repository so the generated iOS plugin registrar goes into the Tarot Squared target. The launcher uses the Flutter SDK on PATH or the directory specified by `FLUTTER_ROOT`. From the repository root, run the following commands.

```sh
bin/flutter pub get
bin/flutter gen-l10n
bin/flutter analyze
bin/test
bin/flutter devices
```

- On iOS, run `bin/flutter run --flavor 'Tarot Squared' -d <device-id>` to select the app's Xcode scheme.
- On Android, run `bin/flutter run -d <device-id>`. To build a debug APK, run `bin/flutter build apk --debug`. Android release signing is pending.

On iOS, run `bin/test integration_test/first_deal_test.dart --flavor 'Tarot Squared' -d <device-id>` to replay all ten deals and verify language settings, progress, life storage and offline refill. On Android, run `bin/test integration_test/first_deal_test.dart -d <device-id>`.

## Archive for iOS

The Xcode scheme uses the project’s Flutter launcher to rewrite sibling header imports in the generated `Flutter.framework` to `<Flutter/Header.h>` before signing. The launcher can drop this patch once Flutter ships [framework-style imports](https://github.com/flutter/flutter/issues/60025).

Run `bin/flutter build ios --release --config-only --flavor 'Tarot Squared'` to prepare the workspace, then open `ios/Tarot Squared.xcworkspace` in Xcode and select the **Tarot Squared** scheme. Device builds and archives use automatic Apple Development signing with the team in `ios/Flutter/Signing.xcconfig`. Sign in to that team’s Apple developer account in Xcode. To select a different team locally, set `DEVELOPMENT_TEAM` in the ignored `ios/Flutter/Signing.local.xcconfig` file.

```xcconfig
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

Run `bin/archive` with Python 3 and Xcode installed. Xcode can update the development provisioning profile during the archive. The command checks the embedded profile and verifies the code signature before reporting success. Add `--open` to open the result in Organizer for distribution. Archives are written to `build/ios/archives/`.

Use `bin/archive --patch`, `bin/archive --minor`, or `bin/archive --major` to bump the release version and increment the build number. Minor and major bumps ask for confirmation. The command saves the new version to `pubspec.yaml` after verifying the signed archive. With no bump option, it builds the version and build number already in `pubspec.yaml`. Add `--no-codesign` to verify a release archive locally without signing or saving a version bump.
