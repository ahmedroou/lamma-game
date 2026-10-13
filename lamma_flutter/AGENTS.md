# Flutter development workflow

## Product decisions

Read `PROJECT_PLAN.md` before gameplay, question, ability, or setup changes. It is
the persistent product reference. Preserve 2–3 teams, exactly six selected normal
categories plus the automatic seventh ability category, and difficulty scores
100/200/300/400. Ability effects and risk probabilities remain user-defined;
do not invent final rules. Update the plan when new user decisions arrive.

Implemented confirmed rules are in PROJECT_PLAN.md: five questions
per category, device-wide non-repetition within a category cycle, and a seven-second window for
one opponent after the active team's time expires. With three teams, choose the
lower-scoring of the two opponents; on a tie, randomly choose one and display
whose opportunity it is. The previous simultaneous-opponent rule is superseded.
Persist that selection so pause/resume/reload never rerolls it. Do not clear the
device question-use ledger on a new match, or reveal the answer in that window.
User-approved exception: once every question in a category has been shown,
offer an explicit category renewal. Clear only that category's use flags in a
persisted transaction and retain other categories, scores and current-match
seen IDs. A new cycle draws randomly; never auto-renew after just five questions
or use renewal to silently erase damaged history.
Newest user decisions supersede text-based usage identity: use each question's
stable random decimal usageId, generated once by tool/assign_question_usage_ids.py.
Do not regenerate it when editing wording or media. Text comparison belongs to
editorial duplicate detection, not device history. Never allow multiple active
copies of the same question within a category merely because images differ.
If 1–4 unused questions remain, include them first and randomly fill the missing
slots from previously seen questions in the SAME category, without duplicating
a question within the current match. Save replay allocations and commit replay
claims before display. Zero unused questions still offers explicit category
renewal; fewer than five distinct valid authored questions cannot fill a match.
Auxiliary hints are card-gated: grant them only via a validated ability use or
a revealed opening surprise card. Bind and persist permission to the question,
recipient team and source card. Do not show hints freely or automatically with
answers. The three built-in who-am-I clues remain separate. Do not enable final
card types or draw probabilities before the user defines them.

Version one is local-only on a shared device. Questions and media should be
bundled locally; gameplay must not require an account, server, or network.
Do not add remote play, rooms, voice chat, or cloud sync unless newly requested.

## Project

This is `lamma`, an Arabic Flutter app with RTL UI and Tajawal fonts. Preserve
Arabic text, RTL behavior, and the existing design conventions. The SDK constraint
is in `pubspec.yaml`; installed dependency versions are in `pubspec.lock`.

## Tools and skills

- Automatically select relevant skills from the official enabled
  `dart-flutter@dart-flutter` plugin. Its 25 Dart/Flutter skills are installed
  globally; do not copy a second set into this project.
- Use the `dart` MCP server first for analysis, formatting, tests, symbol lookup,
  pub.dev search, dependency management, and runtime debugging. Add this directory
  as a root with `add_roots` before project operations. Inspect the live tool
  schemas and use Flutter testing for this Flutter app.
- After code changes, run static analysis and relevant existing tests. Use
  package management tools when dependencies change; preserve the lockfile unless
  a dependency update is part of the task.
- For debugging, discover devices/running apps through Dart MCP, launch or
  connect to the appropriate debug session, and inspect runtime errors and the
  widget tree. Follow the official hot reload workflow below.
- Use Context7 automatically for package/framework API questions, configuration,
  upgrades, or package-specific debugging. Resolve the library ID, then query
  docs with the actual project version and task. If Context7 has no matching
  version/docs, consult official Dart, Flutter, or package documentation and
  clearly identify the fallback.
- When a Figma file/frame link is supplied, use Figma MCP to retrieve design
  context, variables, assets, and a screenshot before UI implementation. Request
  Flutter/Dart context and translate any web-oriented output into Flutter widgets.
  Use the project's RTL, font, and responsive layout conventions. If Figma needs
  authentication or a design link, report the missing input; do not invent it.
- Use GitHub MCP for repository context, issues, pull requests, and CI. Determine
  owner/repository from the actual Git remote or a supplied GitHub URL. This folder
  had no Git repository/remote at setup; do not assume a repository or create one
  unless requested. Use local Git for local diffs/commits when a repo exists.
- Firebase is not used by the current app. Do not install Firebase MCP unless
  Firebase dependencies or configuration are added as part of an authorized task.
- Do not add parallel servers for capabilities already available. Keep account
  tokens out of repository files and logs. If an integration is unavailable,
  state the limitation and use the relevant local SDK/official documentation
  fallback instead of claiming MCP ran.

## Official Flutter hot reload workflow

Adapted from `flutter/agent-plugins/rules/flutter-hot-reload.md`:

For functional changes to Dart files under `lib/`, discover and connect to an
active application using the available Dart MCP runtime tools. If an app is
running, trigger hot reload for widget/build/simple-method changes; use hot
restart for initialization, global/static state, or `main()` changes. Skip reload
for comments/whitespace-only edits and files outside `lib/`. Do not launch a new
app merely to reload when no debug session is running.

## SDK fallback

The existing Windows SDK is `C:/Users/Admin/.cache/flutter-celebrations-sdk`.
If MCP is temporarily unavailable, run its `bin/flutter.bat` or `bin/dart.bat`
from this directory. The MCP config uses the native Dart executable so it does
not depend on desktop PATH. See `AI_DEVELOPMENT_SETUP.md` for setup verification.
