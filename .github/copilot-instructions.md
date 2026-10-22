# Orbit space quiz

## Running and browser checks

Open `index.html` directly in a browser using a `file://` URL. The application must work without a server, dependency installation, or network access.

Validate changes in the integrated browser when available. Reload the file after edits. For a single focused check, reload, press `2` on question 1 (Mars), and verify `1 point`, green/checkmark feedback, `10%` progress, and focus on Next. Reload again to reset.

For a full smoke test:
- Use Tab/Shift+Tab and Enter/Space on native buttons, plus the `1`-`4` answer shortcuts. Modified and repeated shortcuts must not select answers.
- Choose Venus on question 1 to exercise incorrect feedback: red/shake state, a cross, Mars revealed as correct, an explanation, and no score increase.
- Verify answers lock after selection, repeated input cannot add points, and Next is disabled until an answer is recorded.
- Finish all ten questions with mixed answers. Check score, accuracy, ten answer indicators, 100% progress, and the results heading receiving focus.
- Exercise result tiers at scores below 5, 5-7, and 8-10; replay must reset score, progress, answer history, and mission status.
- Check both system color schemes, reduced motion, and narrow layouts down to 320px.

Browser-dispatched `KeyboardEvent`s can exercise shortcut handlers but do not verify native Tab navigation or Enter/Space activation. Report that distinction when native key delivery is unavailable.

## Architecture

`index.html` is the complete deliverable: inline CSS, semantic HTML, inline SVG artwork, and a classic inline JavaScript script. Keep runtime assets self-contained; do not introduce a framework, external fonts, or a build step.

The script implements an in-memory state machine:
- `questions` contains ten records with `category`, `question`, four `answers`, zero-based `correct`, and `fact`.
- `current`, `score`, `answered`, and `history` track the active question, correct count, selection lock, and ordered boolean results. `history` is the quiz state variable, not browser navigation history.
- `renderQuestion()` creates fresh answer buttons and resets per-question UI.
- `selectAnswer()` is shared by clicks and numeric shortcuts. It locks answers, updates score/progress, reveals feedback, and moves focus to Next.
- `showResults()` switches the `hidden` state of quiz/results and derives accuracy, reaction, rank, and answer indicators.
- Next advances explicitly; answers do not auto-advance. Restart resets state and renders question 1.

## UI conventions and coupled behavior

- Preserve the centered 550px maximum column, 15px sans-serif body, purple mission-control palette, grid background, and monospace instrument labels.
- Use the CSS custom properties in `:root`; dark theme overrides live under `prefers-color-scheme: dark`. Keep animations compatible with the existing `prefers-reduced-motion` override.
- Mission status follows `Awaiting input` -> `Answer recorded` -> `Mission complete`, returning to the first state on each new question and replay.
- Progress measures answered questions, not the currently displayed question. Keep fill width, visible percentage, and `aria-valuenow` synchronized.
- The ten-question count is coupled to static header copy, `aria-valuemax="10"`, ten CSS progress segments, and result copy/score thresholds. Keep these surfaces consistent if quiz length changes.
- Correct answers use `.correct`, green feedback, and a checkmark; wrong selections use `.wrong`, red feedback, and shake. Reveal the correct option after a wrong selection. Do not rely on color alone.
- Keep native answer buttons, visible focus outlines, polite live score/feedback regions, answer labels, and labeled progress semantics. Question/results headings have `tabindex="-1"` for programmatic focus.
- Render answer text and explanations with `textContent`/text nodes; existing `innerHTML` is used for controlled markup and numeric score displays.
- Hide inactive screens with the `hidden` attribute; the stylesheet enforces `[hidden] { display: none !important; }`.
