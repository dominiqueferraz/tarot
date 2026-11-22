# Project instructions

- Respond in English unless the user asks for another language. Use English for default player-facing text, documentation and source text.
- Use visible text for labels, controls, titles, values, a short puzzle objective and brief explanations in guided hint bubbles. Explain shared rules in suit-neutral terms and name the scoring suit when it determines the effect. Teach gestures with temporary paths, highlights, arrows and a pointer in the board's visual style. Put the guided hint on the board near its stroke and clear it as soon as the player starts tracing. Provide localized accessibility labels for the controls and board. Offer retry only after a failed deal.
- Follow the product requirements in `docs/product-requirements.md`. Keep shared puzzle component behavior and presentation consistent wherever a component appears.
- When puzzle rules change, update the affected design documentation, in-game help and tutorial instructions together where applicable.
- Run `flutter analyze` and `bin/test` for app changes. Check on the affected mobile platforms when changing native builds, input or layout.

## Git

- Work in a `codex/*` branch or worktree unless the user explicitly authorizes work on `main`. Get explicit authorization before promoting to `main`, pushing or opening a pull request.
- Preserve unrelated work and stage only the files intended for the task. When asked to commit, make one commit per cohesive outcome and include the related source, tests and documentation.
- Keep commit subjects and all body lines at 80 characters or fewer. Use a body of up to three sentences only when it adds context, with a blank line after the subject. Validate the exact message before committing or amending and omit attribution trailers.
