# Tarot Squared

A tarot puzzle game for iOS and Android. The Flutter app lives at the repository root alongside the [product requirements](docs/product-requirements.md), [campaign plan](docs/campaign-001-220.md) and [deck artwork](deck/).

The Dart package name is `tarot_squared`. The iOS bundle ID and Android application ID are both `group.kleinfour.games.tarot`. App versions and build numbers come from `pubspec.yaml`.

Play opens an ascending campaign path. Tap a phase to see its illustration, scoring suits, objective, move limit and difficulty, then play it from the preview. The campaign opens with **The Fool’s Step**. The guide teaches matching traces, rectangles and wildcard corners in six strokes. Rectangles clear pieces of every suit inside and along their sides. Light the trail marker by aiming Wand traces at it or enclosing it in a Wand square or rectangle. Settings offers English, Brazilian Portuguese and Spanish. Edit the locale resources in `lib/l10n/` and run `bin/flutter gen-l10n` to refresh the generated Dart code.

Clearing The Fool’s Step unlocks **Lamplighter**, where Cups fuel the quay lamp to 44 light. Clearing Lamplighter unlocks **High Water**, a 6 × 7 board where Cups fill the mill inlet with 32 units of water. High Water unlocks **The Mooring**, a wide 7 × 6 board where a Sword square links the two cords so an aimed cut reaches both. The Mooring unlocks **The Ferryman’s Fare**, an 8 × 8 board where both scale pans need 24 Coins. The five deals give 25, 22, 18, 26 and 25 moves, respectively.

The home card uses the Moon (XVIII) from the Rider–Waite–Smith deck. The paper texture, suit shapes and ridge use the opening playtest artwork from the Arcana prototype archive.

## Author a puzzle

Edit [the puzzle catalog](assets/puzzles/fool.json). Entries appear in campaign order and unlock when the preceding puzzle is cleared. Each entry has a stable `id`, a `scene` (`ridge`, `quay`, `mill`, `dock` or `market`), and a `textKey` for the title and objective.

- Write one or more nonempty `board` rows of equal length. The rows determine the board’s width and height. Use `W`, `C`, `S` and `O` for the suits, `.` for a masked cell and `L` for each fixture. Use `target` for one fixture or `targets` for several. Give each fixture a `cell`, scoring `suit`, progress `quota`, localized `label` key and optional `fade` amount per missed move. Set its `kind` to `marker`, `lantern`, `inlet`, `cord` or `pan` to select its artwork and progress wording. The `scene` selects the illustration above the board. Enable `linksTargets` for squares that link compatible target corners. Set moves, par and difficulty separately.
- Use `ribbons` refill with one repeating string per column in arrival order or `guided` refill with a seed and positive suit weights. Put square and rectangle scoring and guided refill tuning in the catalog's shared `rules`. The `refillLowerRow` threshold scales from the six-row reference board.
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

On iOS, run `bin/test integration_test/first_deal_test.dart --flavor 'Tarot Squared' -d <device-id>` to replay the first five deals, verify that the language and The Ferryman’s Fare unlock persist, and replay the mixed-target Market Day test board. On Android, run `bin/test integration_test/first_deal_test.dart -d <device-id>`.

## Archive for iOS

Run `bin/flutter build ios --config-only --no-codesign --flavor 'Tarot Squared'` to prepare the workspace, then open `ios/Tarot Squared.xcworkspace` in Xcode and select the **Tarot Squared** scheme. For device builds and signed archives, sign in to the Apple developer account in Xcode and add your development team ID to the ignored `ios/Flutter/Signing.local.xcconfig` file.

```xcconfig
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

With the development provisioning profile available in Xcode, run `bin/archive` with Python 3 and Xcode installed. Add `--open` to open the result in Organizer. Run `bin/archive --no-codesign` to verify the release archive locally without signing. Archives are written to `build/ios/archives/`. Update the version or build number in `pubspec.yaml` before archiving a new distribution build.
