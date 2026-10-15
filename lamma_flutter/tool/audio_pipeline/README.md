# Voice repair tools

The original pack is rejected. Its file count and former `reviewed` flags were
not evidence of speaker identity. Do not run the old staging, search or test
scripts as a publication workflow. No automated validators/tests were run for
this repair, as requested by the user.

`build_character_voice_complete.js` now delegates to
`prepare_verified_sources.cjs`. It has no default source, six-speaker fallback,
copy-on-error path, fixed seven-second duration, answer rewriting or automatic
publication/approval. `fix_answers.js`, `update_doc.js` and
`verify_character_voice.js` are retired entry points that change nothing.

## Media preparation

With `ffmpeg-static` available from this directory's package.json:

```powershell
node tool/audio_pipeline/prepare_verified_sources.cjs path/to/researched-sources.json
```

This is media conversion, not an identity or copyright checker. Supply a JSON
document with a `recordings` array. Each entry must be an individually researched
record for the original question and speaker:

```json
{
  "questionId": "original question id",
  "speaker": "exact original reference answer",
  "recordingId": "stable identity of the actual original recording",
  "assetPath": "assets/question_audio/voice-001.mp3",
  "sourceUrl": "https://archive.example/actual-record-description",
  "sourceMediaUrl": "https://archive.example/actual-original-media",
  "license": "specific license and attribution conditions",
  "licenseUrl": "https://archive.example/actual-license-evidence",
  "attribution": "actual recording creator / required credit / edits",
  "sourceStartMs": 1000,
  "sourceEndMs": 9000,
  "transcript": "words in this exact excerpt, without naming the answer",
  "sourceVerifiedBy": "reviewer who actually inspected the source"
}
```

The example domains are schema placeholders, never usable recording evidence.
Use the actual researched provenance under
`design_sources/character_voice_repair/` instead of guessing archive titles.

Every source must download and convert successfully on its own. Failure leaves
an error for that record. Prepared files, actual decoded durations, provenance
and pending listening status are written to a new directory outside app assets.
The tool does not change the bank, usage registry, declared speaker or answer.

## Individual approval

Before publishing a recording, review the actual final clip, original speaker,
absence of a spoken answer or unrelated interpreter, transcript/cut, rights and
attribution, six choices, hint and difficulty. Preserve the old question id and
usageId when repairing its original speaker. Unsupported candidates stay
quarantined; remove their audio field rather than creating a zero-duration
QuestionAudio or copying another person's voice.

Human-listening approval records `reviewMethod: humanListening` and
`listeningStatus: listened` only after actual listening. On 15 October 2026 the
user explicitly authorized publishing the currently available 27 clips using
source plus actual-clip machine transcripts instead. This temporary method is
recorded as `sourceTranscript` / `machineTranscribed`, never `listened`.

`integrate_temporary_voice_release.py` applies only the individually named
entries in `temporary_editorial_decisions.json`. Each needs both tiny.en and
small.en transcripts bound to the actual final file SHA256, documentary source,
rights, cut, and an explicit editorial decision. File counts alone never approve
anything. The tool preserves the original bank snapshot, keeps same-person IDs,
adds new IDs for different people, and retains all historical usage IDs.

The 27 published-method records include their evidence ID, digest, model names,
reviewer and date. The runtime enforces this metadata and verifies the bytes
before playback. The archive states the temporary method. The remaining 73
questions stay quarantined. See `CHARACTER_VOICE_DOCUMENTATION.md`.

New research helpers are `research_voice_sources.py`, `research_bbc_sources.py`,
`prepare_replacement_candidates.py`, `transcribe_prepared_candidates.py`,
`stage_replacement_questions.py` and `render_replacement_review.py`. Preparation
respects source cooldowns; ASR reuses final-file SHA-bound results. Local models,
Python dependencies and original source downloads are not shipped in the app.
These helpers prepare candidates; they do not silently authorize future clips.
