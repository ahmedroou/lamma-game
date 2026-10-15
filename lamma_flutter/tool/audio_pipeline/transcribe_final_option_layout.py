"""Apply the root editor's literal option-position decisions after reading all100 rows.

This transposes existing choice texts only. It does not judge identity, alter
answers/usage IDs, generate questions or approve any recording. Apply once.
"""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[2]
path = root / 'assets/questions/character_voice.json'
bank = json.loads(path.read_text(encoding='utf-8-sig'))
by_id = {question['id']: question for question in bank['questions']}
positions = {
    'easy':      'D A F C B E B F D A C E A D F B E C F C A E D B A'.split(),
    'medium':    'B E A F D C F D C B A E E A D C F B C F B E D A B'.split(),
    'hard':      'E C B A F D A F E D C B D B A E F C B D C F A E C'.split(),
    'legendary': 'F B D E A C C A E F B D B D F C E A E C A D F B D'.split(),
}
notes = []
for difficulty, placement in positions.items():
    for number, destination in enumerate(placement, 1):
        question = by_id[f'character_voice-{difficulty}-{number:04}']
        choices = {option['id']: option for option in question['options']}
        source = question['correctOptionId']
        before = [dict(option) for option in question['options']]
        choices[source]['text'], choices[destination]['text'] = (
            choices[destination]['text'], choices[source]['text'])
        question['correctOptionId'] = destination
        notes.append({'questionId': question['id'], 'decision': 'editorial_choice_position',
                      'originalOptions': before, 'originalCorrectOptionId': source,
                      'correctOptionId': destination,
                      'reason': 'Remove the repeated-B answer-position cue; preserve all six person choices, the reference answer and usageId. No audio approval.'})
path.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
(root / 'design_sources/character_voice_repair/root_option_layout.json').write_text(
    json.dumps(notes, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
