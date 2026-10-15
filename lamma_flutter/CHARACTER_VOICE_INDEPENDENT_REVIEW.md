# Independent review — character_voice — 15 October 2026

Historical pre-repair findings. The original builder cited below is preserved
under `design_sources/character_voice_repair/original/`; current repair status
and remaining limitations are in `CHARACTER_VOICE_REPAIR_STATUS.md`.

## Verdict

Not approved as 100 correctly attributed voice questions. The bank and local
voice-001 through voice-100 assets are present, and integration code was added,
but the source-selection pipeline has correctness blockers. This is a manual
inspection of code, selected full question records, documentation and primary
source pages; it is not a complete listening review of 100 files.
No scripts, automated validators, tests, builds or repair generators were run.
No runtime files, media, question statuses or usage IDs were changed by this review.

## Blockers

1. **Unrelated-speaker fallback.**
   `tool/audio_pipeline/build_character_voice_complete.js:171` defines a pool
   of six existing recordings. At line244, a failed or absent source mapping
   chooses from this pool by index; lines246–262 trim or copy it into the new
   person's filename. Question answers, attributions and source URLs are then
   retained from staging. Changing a slice does not change the speaker.
   This mechanism cannot produce correctly attributed independent questions.
   Exact affected-file inventory requires provenance reconstruction and listening;
   this review does not claim that all100 files used the fallback.

2. **Einstein source is an audiobook reader.**
   The explicit mapping at line103 for voice-054 selects *Sidelights on
   Relativity, Part2 — Geometry and Experience*. The Commons page points to
   LibriVox. The original LibriVox catalog explicitly identifies Paul Adams as
   the reader of both parts. The corresponding question
   `character_voice-easy-0017` instead answers Albert Einstein and describes
   Einstein explaining mass–energy conversion. This is a different speaker and
   inconsistent recording context, regardless of whether the download succeeded
   or the unrelated-speaker fallback was taken.
   Sources actually read:
   https://commons.wikimedia.org/wiki/File:Sidelights_on_Relativity_by_Albert_Einstein,_Part_2_-_Geometry_and_Experience.ogg
   https://librivox.org/sidelights-on-relativity-by-albert-einstein/

3. **Chaplin source is instrumental music.**
   The mapping at line107 for voice-058 selects *Lorelei (A Tramp Abroad)*.
   Its Commons description says the voice part was rendered as a clarinet,
   produced by uploader Beeswaxcandle in2013. The corresponding question
   `character_voice-easy-0021` answers Charlie Chaplin and describes his1940
   Great Dictator speech. Neither this mapped file nor a fallback from the
   six-person pool establishes the claimed recording.
   Source actually read:
   https://commons.wikimedia.org/wiki/File:Lorelei_(A_Tramp_Abroad).ogg

4. **Reviewed flags are assigned automatically.**
   Lines316,357,403 of the builder label records reviewed while assembling
   staging data; there is no per-record listening or attribution approval tied
   to those assignments. The final JSON also declares status reviewed.
   These flags and the generated documentation are not editorial evidence.

## Further quality problems seen in the sample

- The Einstein prompt already supplies his famous-equation clue; the Chaplin
  prompt identifies a distinctive film context. The Heidegger prompt explicitly
  names his book *Being and Time*. Such prompts often become written trivia
  rather than recognizing a voice. Several hints nearly give away the answer.
- The builder and final question source URLs differ for the checked recordings.
  The generated documentation repeats question metadata rather than documenting
  the actual successful download and final cut.
- License values such as `Creative Commons / ...`, `Public Domain / official
  speeches`, and `Educational / Public Domain Excerpt` do not identify a precise
  file-specific license and supporting evidence. This review does not establish
  reuse rights for those recordings.
- `getAudioDurationMs` returns7000 after a successful FFmpeg process without
  parsing duration (line65). The apparent uniform seven-second durations are
  therefore not reliable evidence of the actual cut lengths.

## Required before approval

Remove unrelated-speaker fallback entirely. Keep failed sources pending rather
than manufacture a completed question. For every retained clip, establish the
actual source-to-file chain, original speaker, transcript, cut timestamps and
specific license/attribution. Listen to the final clip, remove any answer leak,
then review six options, hint and difficulty individually. Replace the two known
bad mappings and any contaminated clips while preserving existing usage IDs.
Only then claim the verified total; do not claim100 complete from file counts.
