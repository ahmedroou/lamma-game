# International voice repair — 15 October 2026

These files document a manual editorial repair of the original questions
associated with `voice-051.mp3` through `voice-100.mp3`. The live bank belongs to
the root agent; `decisions.json` is staging, not a second published bank.

The original answers, IDs and `usageId` values are retained. A separate written
decision exists for each of the fifty original records. All proposed question
texts are neutral listening prompts. All hints were rewritten individually to
remove near-explicit identification. Seven option sets were edited for coherent
alternatives, including the male distractor in the Beauvoir question and the
group entry “Laurel and Hardy” in a question asking for one speaker.

## What was actually done

- Read the independent review and source builder, and the complete question
  records, including their six options and hints.
- Retained the old media and question records in `before/` and
  `original_questions.json` before replacing anything.
- Read file-specific source descriptions and license evidence via Commons file
  pages and source APIs. Raw responses are preserved in `sources/`.
- Re-downloaded selected original archival media. The conversion script uses
  literal, individually chosen source titles and cuts. A failed download stays
  failed. It never substitutes another voice.
- Converted to mono 24 kHz, 48 kbps MP3 with identifying embedded metadata
  removed. Exact decoded duration was measured from PCM sample length. This is
  media preparation, not an automated question-quality check.
- Kept all proposed records **quarantined**. An archival transcript and source
  description are evidence for a candidate, not evidence that a reviewer heard
  the final output.

No bank validator, test, automatic duplicate checker, hash audit, or automatic
editorial approval was run.

## Actual listening limitation

An MP3 was explicitly forwarded to the model through the available audio
content interface. The tool returned:

> audio content omitted because you do not support audio input

Consequently, **zero final clips received a listening approval**. The stage
`sourceVerified` is used only for selected source-and-license documented clips
with an existing time-aligned archival transcript. Other newly prepared source
candidates keep `unverified` when their exact cut still lacks a transcript.
None is `approved`, and none should become playable simply because it exists.

The authoritative prepared-source manifest is `source_verified_cuts.json`.
Each entry states its source URL, direct media URL, cut times, actual duration,
license, attribution, transcript evidence where available, and the pending
listening status. Failed downloads do not appear in that manifest.

Final delivered media for this pass: **eleven** newly sourced and converted
clips. Nine have archival timed transcript evidence (051, 052, 054, 056, 059,
060, 068, 074, 076); two are sourced archival candidates with transcript and
listening still pending (053 and 055). No replacement was delivered for the
other thirty-nine slots. The last requests for Thatcher 069 and Picasso 086
returned HTTP429; these were not repeatedly retried or replaced with a fallback.
The Reagan source emitted an input timestamp warning during conversion; its
decoded output duration is recorded as 9716 ms for the requested 710.3–720.0
second excerpt. That warning is another reason to listen to the final cut,
rather than infer approval from a successful conversion.

## Confirmed mistakes corrected or withdrawn

- Einstein: the old LibriVox material is read by **Paul Adams**, not Einstein.
  The replacement is Einstein's genuine 1943 address from UNLP's permissioned
  collection, CC BY-SA 3.0; the recording's final announcement of his name is
  excluded. Its subject is intellectual progress, not a mass-energy lecture.
- Edison, Steve Jobs and Conan Doyle: the builder's `Q 2008-...` files are
  recordings by **Bookkeeper reading quotations**. They do not establish the
  quoted person's voice.
- Chaplin: *Lorelei (A Tramp Abroad)* is instrumental clarinet material by
  **Beeswaxcandle**. `Charlie chaplin.ogg` is a French Wikipedia article reader.
  Neither is Chaplin. The official rights office identifies Roy Export as the
  rights holder of *The Great Dictator*; the previous CC0 claim was withdrawn.
- Churchill: *Be Ye Men of Valour*, 19 May 1940, differs from the “beaches”
  speech named in the old explanation.
- Kennedy: the replacement is the actual Berlin speech, 26 June 1963; the
  chosen ending avoids the early crowd chant of his name. The previous source,
  question context and builder context referred to different speeches.
- Roosevelt: *Americanism* is not the Pearl Harbor address. The selected
  *Roosevelt Infamy* derivative retains W. Guy Finley's CC BY-SA 2.0 credit,
  rather than silently treating the derivative as unencumbered.
- Nixon: the selected resignation excerpt is not a 1960 campaign advertisement.
- Hawking: the source is the White House lecture of 6 March 1998, NARA 5860063,
  with the Clinton Library's requested credit; it is not a TED recording.
- Mandela: the source is his 4 October 1994 US state visit, not his 1990 release
  speech, and is credited to the Clinton Library rather than SABC.
- Thatcher: the G7 file explicitly places her reading at **1:02**. The old
  builder's cut at one second did not establish that it was her voice. This
  event is in 1984, not the 1980 “lady's not for turning” speech.
- Picasso: the discovered file belongs to the UNLP radio collection, not the
  French institution named in the old question. Its precise cut needs a
  transcript and an actual listening reviewer.
- Hitler: the existing *last speech* file describes January 1945, not the 1942
  Mannerheim conversation. Its PD-1996 notice explicitly says it should not be
  used for sound recordings; no valid broad reuse clearance was established.
- Edison candidate: the genuine “Mary had a little lamb” file is identified as
  a **1927 re-enactment**, not the lost original 1877 recording.
- Tolstoy candidate: RGAFD's discovered recording is a 1908 letter to Davydov,
  not an address to children. It was not silently substituted.
- Joyce: a 1924 *Ulysses* recording and a 1929 *Anna Livia Plurabelle* recording
  are different recordings. The named sources did not establish a licensed
  current excerpt. The Joyce Tower presentation carries NC-ND restrictions.

## Useful primary rights references actually read

- [Chaplin rights office](https://charliechaplin.com/en/articles/130-The-Chaplin-Office)
- [Nobel Prize copyright information](https://www.nobelprize.org/about/copyright-information)
- [Feynman official copyright contact](https://feynman.com/contact/)
- [University at Buffalo Joyce recording script](https://library.buffalo.edu/jamesjoyce/catalog/ix/ixa5.html)
- [Joyce Tower 1929 recording artifact](https://joycetower.ie/collection/artefacts/jtaa_0097-james-joyce-reading-anna-livia-plurabelle)
- [Library of Congress Earhart source guide](https://guides.loc.gov/amelia-earhart/digital-resources)

## Reuse and final acceptance

Credits and exact licenses travel with each candidate. The edited MP3s derived
from CC BY-SA media are made available under the same indicated media license;
this statement applies to those sound assets, not to the application as a whole.
Cropping, MP3 conversion and metadata removal are disclosed. No endorsement by a
speaker, archive, institution or rights holder is implied.

Before any question is approved, an actual listener must compare the original
and final cut, confirm the speaker, reject narration/name announcements, check
clarity and wording, confirm transcript boundaries and then independently sign
off. The remaining unproved recordings should stay outside bundled playable
assets. These records do **not** establish a finished pack of one hundred famous
voices or one hundred iconic excerpts.
