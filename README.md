# Tarot Squared

A tarot puzzle game for iOS and Android. The Flutter app lives at the repository root alongside the [product requirements](docs/product-requirements.md), [campaign plan](docs/campaign-001-220.md) and [deck artwork](deck/).

The Dart package name is `tarot_squared`. The iOS bundle ID and Android application ID are both `group.kleinfour.games.tarot`. App versions and build numbers come from `pubspec.yaml`.

Play opens an ascending campaign path. Tap a phase to see its illustration, scoring suit, objective, move limit and difficulty, then play it from the preview. The campaign opens with **The Fool’s Step**. The guide teaches matching traces, rectangles and wildcard corners in six strokes. Rectangles clear pieces of every suit inside and along their sides. Light the trail marker by aiming Wand traces at it or enclosing it in a Wand square or rectangle. Settings offers English, Brazilian Portuguese and Spanish. Edit the locale resources in `lib/l10n/` and run `bin/flutter gen-l10n` to refresh the generated Dart code.

Clearing The Fool’s Step unlocks **Lamplighter**. Follow the trail to the quay and use Cups to fuel its lamp to 44 light. Both puzzles use the same square and rectangle rules.

The home card uses the Moon (XVIII) from the Rider–Waite–Smith deck. The paper texture, suit shapes and ridge use the opening playtest artwork from the Arcana prototype archive.

## Author a puzzle

Edit [the puzzle catalog](assets/puzzles/fool.json). Entries appear in campaign order and unlock when the preceding puzzle is cleared. Each entry has a stable `id`, a `scene` (`ridge` or `quay`), and `text` with a title, objective and target label in each supported language.

- Write six `board` rows of six symbols. Use `W`, `C`, `S` and `O` for the suits and one `L` at the coordinate in `target.cell`. Set the target's scoring suit and light quota, optional fading per missed move, move limit and par. Set `difficulty` to `normal`, `hard` or `superHard`.
- Use `ribbons` refill with six repeating column strings in arrival order or `guided` refill with a seed and positive suit weights. Put square and rectangle scoring and guided refill tuning in the catalog's shared `rules`.
- Add an optional `guide` with a cue of `match`, `square`, `rectangle`, `enclose`, `aim` or `wildcard`. Each step uses coordinates separated by spaces, a hint position `[x, y, tail]` in board units, and six arrival strings. List exactly the pieces the move needs to replace in each column, from the lowest vacancy up. Replay authored guides and solutions with `bin/test`.
- Edit the SVGs in [assets/art](assets/art/) for symbols, scenery and story figures. Adjust spacing, timing, palette and scene placement in [design_tokens.dart](lib/design_tokens.dart). Shared interface copy and hints live in `lib/l10n/`.

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

On iOS, run `bin/test integration_test/first_deal_test.dart --flavor 'Tarot Squared' -d <device-id>` to verify language persistence, the six guided strokes and the transition to Lamplighter. On Android, run `bin/test integration_test/first_deal_test.dart -d <device-id>`.

## Archive for iOS

Run `bin/flutter build ios --config-only --no-codesign --flavor 'Tarot Squared'` to prepare the workspace, then open `ios/Tarot Squared.xcworkspace` in Xcode and select the **Tarot Squared** scheme. For device builds and signed archives, sign in to the Apple developer account in Xcode and add your development team ID to the ignored `ios/Flutter/Signing.local.xcconfig` file.

```xcconfig
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

With the development provisioning profile available in Xcode, run `bin/archive` with Python 3 and Xcode installed. Add `--open` to open the result in Organizer. Run `bin/archive --no-codesign` to verify the release archive locally without signing. Archives are written to `build/ios/archives/`. Update the version or build number in `pubspec.yaml` before archiving a new distribution build.
