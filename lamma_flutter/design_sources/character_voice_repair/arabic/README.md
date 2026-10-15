# Arabic half — manual editorial disposition — 15 October 2026

Scope: the fifty records linked to `voice-001.mp3` through `voice-050.mp3`,
irrespective of their ordering in `character_voice.json`. The final bank is owned
by the parent agent; this directory is staging and provenance only.

I read each record's question, answer, hint, explanation, all six choices, source
and license claim. `arabic_decisions.json` contains a separate written decision
for each original ID and keeps its existing usage ID. This is not an automatic
quality check, identity classifier, duplicate detector or listening approval.
`transcribe_decisions.py` only copies the fifty explicitly written decisions and
original records to files. No tests, validators or builds were run.

## Outcome

- **One source-backed replacement prepared:** Sadat (`voice-001`).
- **Forty-nine original records quarantined:** speaker/source/rights/cut chain
  is not established; their old generic license strings are not accepted as
  evidence. They have individual reasons, including specific contradictions.
- **Zero clips approved after listening.** I could not audition voice input in
  the available model/tool path. The replacement is `sourceVerified`, not
  `approved`, and its question remains `draft` pending that step.

The old fifty media files are backed up under `original_assets/`. The backup of
`voice-001` was taken before replacement. I changed only the bundled
`voice-001.mp3`; I did not delete other runtime files or edit the final bank,
catalog, usage registry, Dart, pubspec or Git. The parent must prevent all
unverified records from being drawn and remove/quarantine the unused bad media
from the bundle as part of its final integration.

Quarantine here means that this submitted recording is not established. It is
**not** a claim that no genuine recording of that person exists anywhere. In
particular, alleged wax cylinders of Ahmad Orabi, Hussein of Hejaz and Ahmad
Shawqi have no primary evidence in the submission. Actors portraying historical
figures and later readers of their texts cannot be substituted.

## Prepared Sadat replacement

Original answer retained: **محمد أنور السادات**. Existing question ID and usage
ID retained. Its six existing alternatives are political figures, with one
matching answer; the visible question was made generic and the hint reduced
to a useful Egyptian political context without naming the Nobel prize or war.

This actual downloaded source is a speech at the White House conclusion of the
Camp David meetings on **17 September 1978**, not the old claimed Jerusalem
speech in 1977:

- [File-specific source, creator and PD-CIA rights statement](https://commons.wikimedia.org/wiki/File:Egyptian_President_Sadat%27s_Remarks_at_the_Camp_David_Agreement,_17_September_1978.webm)
- [Direct media actually downloaded](https://upload.wikimedia.org/wikipedia/commons/f/fd/Egyptian_President_Sadat%27s_Remarks_at_the_Camp_David_Agreement%2C_17_September_1978.webm)
- [Timed transcript, cues 9–10](https://commons.wikimedia.org/wiki/TimedText:Egyptian_President_Sadat%27s_Remarks_at_the_Camp_David_Agreement,_17_September_1978.webm.en.srt)
- [Historical full transcript, separately identifying Sadat's words](https://www.presidency.ucsb.edu/documents/remarks-the-president-president-anwar-al-sadat-egypt-and-prime-minister-menahem-begin)

Selected source interval: **34,300–42,730 ms**, requested cut duration **8,430 ms**.
Transcript: “The challenge was great, and the risks were high.”
The selected words contain neither the speaker's name nor a biographical
giveaway. This is English spoken by an Arab historical figure; do not advertise
it as an Arabic-language recording. The evidence establishes a real historical
occasion, but not a claim that this particular utterance is iconic in itself.

FFmpeg extracted that interval from the downloaded WebM, discarded video and
metadata, encoded mono 44.1 kHz MP3 at 64 kbit/s. No unrelated-source fallback or
voice synthesis was used. `durationMs` is the defined source interval length,
not a claim that the encoded file's container duration was independently
measured. The official creator is the CIA, and the file page specifically marks
it as a U.S. Government work in the U.S. public domain; the attribution states
that territorial scope rather than offering a universal legal warranty.

The alternative genuine Sadat recording from 6 August 1981 was downloaded as
`sadat-1981-original.ogg` during research but **was not used** in the replacement:
the submitted question incorrectly conflated it with Jerusalem 1977. Its
[file page](https://commons.wikimedia.org/wiki/File:Anwar_Sadat_voice.ogg) gives
CC BY 3.0 attribution to the Reagan Library, an official WHTV source and NARA
identifier 5730544. The temporary WAV beside it is research material only and
is not a listening approval.

## Other actual source findings and rejected shortcuts

### Bourguiba

[Reagan Library video / CC BY 3.0 file-specific license](https://commons.wikimedia.org/wiki/File:President_Reagan%27s_and_President_Habib_Bourguiba_of_Tunisia_Remarks_on_June_18,_1985.webm)
is a promising **real** source, unlike the generic Archive.org identifier in the
original question. It identifies WHTV production, NARA 45739851 and the official
Reagan Library channel. The [primary transcript](https://www.reaganlibrary.gov/archives/speech/remarks-following-discussions-president-habib-bourguiba-tunisia)
explicitly says he spoke French and his remarks were interpreted. I did not
guess a timestamp or package the interpreter's voice as Bourguiba. The current
question therefore remains quarantined until an original-speaker segment is
located and auditioned.

### King Hussein

The [Karameh file](https://commons.wikimedia.org/wiki/File:King_Hussein%27s_speech_after_the_Battle_of_Karameh_1968.ogg)
contains a PD-Jordan explanation addressing photographs/applied art; I did not
extend that automatically to this broadcast recording. An [official Reagan
Library departure video](https://www.youtube.com/watch?v=SeGhAZugWZ0) identifies
WHTV production on 3 November 1981 and unrestricted use, NARA 66383700. The
[primary WHTV inventory](https://www.reaganlibrary.gov/archives/whtv-1981-89-video-collection?field_tape_number_value=&order=field_personal_reference&page=310&sort=asc)
also identifies it as record 0660-2M-S052-70Bc. No correctly timed original voice
cut was prepared, so this is a research lead, not a repaired or approved asset.

### Nasser and Arafat

The [Mansheya source](https://commons.wikimedia.org/wiki/File:Nasser_speech_at_mansheya.oga)
is tagged PD-Egypt. I did not silently turn that into unrestricted worldwide
status for a recording whose rights across jurisdictions have not been
resolved. The originally cited UAR file could not be inspected successfully in
this tool, so its proposed metadata is not established.

The [Arafat file](https://commons.wikimedia.org/wiki/File:Yassir_Arafat.ogv)
identifies Visnews as author yet carries a U.S. Government PD tag. Merely being
held by NARA (652977) is expressly not proof of copyright status on that page.
I did not accept this unresolved conflict or call the UN 1974 archive public
domain without a grant from the relevant rightsholder.

### Mahfouz and Abdulaziz

The [primary Nobel lecture page](https://www.nobelprize.org/prizes/literature/1988/mahfouz/lecture/)
says **Mohamed Salmawy read Mahfouz's lecture**. It cannot provide Mahfouz's
voice. This potential shortcut was rejected rather than changing the answer.

[NARA's primary transcript for the 1945 meeting film](https://www.archives.gov/social-media/transcripts/transcript-president-roosevelt-meets-middle-east-leaders-39051.pdf)
labels a **narrator** describing Ibn Saud's meeting and an interpreter. It does
not establish the purported audio of King Abdulaziz's conversation. The old
question's confident 1945 attribution must not survive as a reviewed claim.

### Reciters and other public figures

The pipeline maps Abdul Basit, Mustafa Ismail, Mohamed Refaat and Al-Hussary to
Quran recitations but their questions claim spoken interviews about recitation.
Those are different media contexts, with no corresponding rights proof. A
Quran text's status does not automatically license a modern performance or
recording. Similarly, a public lecture, free download, educational documentary,
governmental speech or institution name is not itself a specific reuse license.

No automated speech identity, transcript match, license classifier or audio
quality check was used. Remaining factual/hint/options repairs should follow
the acquisition of each correct speaker's licensed original and a real
listening review; polishing metadata cannot repair a wrong speaker.
