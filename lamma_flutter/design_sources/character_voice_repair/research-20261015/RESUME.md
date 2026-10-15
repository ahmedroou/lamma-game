# Updated approval checkpoint — 15 October 2026

The user subsequently authorized publishing the current available pack using
source and machine transcripts if human listening is unavailable. The live bank
now contains 27 available clips (11 same-person repairs, 16 replacements), with
SHA-bound dual-model evidence and explicit per-clip decisions; 73 stay quarantined.
The app records machineTranscribed, never listened. Version 0.2.7+9 is prepared
for signed publication; consult PROJECT_PLAN.md and GitHub for publication result.
The old pending questions below are historical and no longer block this release.

---

## Historical checkpoint before the latest user authorization

# Voice completion checkpoint — 15 October 2026

The live app/bank has NOT been changed or republished by this work. Release
0.2.6+8 remains the latest published version. No clip received approval.

The human authorized replacing an unavailable personality with a different
personality. Two questions are pending in the chat: whether a mainly global
100-speaker pack is acceptable, and whether source plus actual-clip machine
transcription may replace the previous human-listening requirement. Do not
interpret preselected options, elapsed time, or this staging work as approval.

## Completed independent preparation

- Actual primary Commons metadata was downloaded for 467 general voice files
  and 284 BBC voice excerpts. `commons-candidates.json` and `bbc-candidates.json`
  preserve source descriptions, attribution, licenses, source SHA1 and URLs.
- `selected_bbc_speakers.tsv` explicitly selects 89 different replacement
  candidates, each with a BBC source released under CC BY 3.0. These are
  predominantly English-speaking global personalities; this is a proposal,
  not an assertion that the former 50/50 Arabic/global target was met.
- Sixteen BBC originals and their mono/24 kHz/48 kbps excerpts are prepared
  outside app assets in `../prepared-bbc-20261015/`. Each downloaded original
  matched the exact Commons SHA1 before conversion. Source download throttling
  returned HTTP 429 and Retry-After 600 seconds; no access bypass was attempted.
- Eleven existing archival excerpts are retained as candidates. The Florence
  Nightingale candidate was excluded from this proposal because its actual
  excerpt failed to yield intelligible speech in either model.
- Actual excerpts were transcribed locally with Faster Whisper tiny.en and
  small.en, using CPU/int8 and FFmpeg-decoded waveform input. Results include
  source-file SHA256, segment/word timestamps and recognition probabilities.
  These are NOT human listening or biometric speaker identification. Source
  identity still comes from the original recording's documentary metadata.
- Small.en caught Whoopi Goldberg saying her own name where tiny.en missed it.
  `cut_overrides.json` records a new cut beginning after the introduction. The
  new actual cut was transcribed again; its latest SHA-bound transcript starts
  "And this is a great book..." and excludes her name.
- `proposed-character-voice.json` stages exactly 100 questions (25 per tier),
  six choices each, all still quarantined. `distractor_pools.json` is an explicit
  editorial proposal grouping distractors by comparable field/personality.
  The 11 same-person repairs retain their old identities; 89 replacements have
  new stable random decimal usage IDs and new r2 IDs. Nothing has been added to
  the live usage registry or device ledger. `replacement-identities.json` maps
  each old record to the proposed replacement.
- `REVIEW_CANDIDATES.html` is a local individual-listening worksheet with source
  links, actual available clips, machine transcripts and explicit per-clip
  checkboxes. It has no bulk approve or automatic publication button.

## Remaining work

1. Read the human's pending answers before changing acceptance rules or replacing
   the Arabic majority. If human listening is required, do not set listened.
2. Complete the 73 remaining BBC downloads, respecting source cooldowns. Use
   the existing metadata/cache rather than re-querying the whole Commons catalog.
3. Transcribe every final actual cut with small.en. Inspect each transcript,
   documentary speaker identity, rights, clarity and name leakage individually.
   Poor or ambiguous excerpts need a different cut or a different source/person.
4. Review all six answer options, hints and difficulty per question. The proposed
   group pools and difficulty assignments are still editorial drafts.
5. Only after the chosen acceptance method is actually satisfied: integrate the
   final bank/media/registry, keep historical device usage, update credits and
   document the real review method. Never label machine transcription listened.
6. Build and publish a NEW signed version; verify public update.json, APK digest,
   package version and production certificate. Do not replace a published APK.
   The earlier human preference against automated test/validator runs remains;
   do not describe media preparation as a completed test suite or human review.

## Resume commands (Flutter project root)

Python: `C:/Users/Admin/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`

Set `PYTHONIOENCODING=utf-8` for Arabic terminal output. Helpers:

```
tool/audio_pipeline/prepare_replacement_candidates.py
tool/audio_pipeline/transcribe_prepared_candidates.py --model small.en --once
tool/audio_pipeline/stage_replacement_questions.py
tool/audio_pipeline/render_replacement_review.py
```

Use the transcription command again as more files arrive; it reuses SHA-bound
completed rows. CTranslate2, Whisper models and dependencies are in the user's
local `.cache/lamma-audio-review/`, not the app or release. A PyAV native codec
import hung in this Windows runtime; the research helper explicitly uses FFmpeg
waveform input and rejects the unused PyAV decode path. This does not affect
the Flutter audioplayers implementation.

All task download/transcription processes were stopped at this checkpoint;
there is no hidden background publication or automatic follow-up.
