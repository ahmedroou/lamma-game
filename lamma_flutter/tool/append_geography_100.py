"""Package manually authored, source-read rows; never generate facts or fill counts."""
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = {
    'infiltration': ('USGS، عوامل التسرّب والتغذية الجوفية', 'https://www.usgs.gov/water-science-school/science/infiltration-and-water-cycle'),
    'runoff': ('USGS، الجريان السطحي وتغير استعمال الأرض والتلوث غير النقطي', 'https://www.usgs.gov/water-science-school/science/runoff-surface-and-overland-water-runoff'),
    'groundwater': ('USGS، الخزانات الجوفية والضخ وحركة الماء', 'https://www.usgs.gov/water-science-school/science/aquifers-and-groundwater'),
    'aquifertypes': ('USGS، الخزانات المحصورة وغير المحصورة', 'https://api.waterdata.usgs.gov/ogcapi/v0/collections/aquifer-types?f=html'),
    'groundflow': ('USGS، مسارات جريان المياه الجوفية', 'https://www.usgs.gov/water-science-school/science/groundwater-flow-and-water-cycle'),
    'estcirculation': ('NOAA، تصنيف دوران الماء في المصبات', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est05_circulation.html'),
    'estgeology': ('NOAA، الأصول الجيولوجية للمصبات', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est04_geology.html'),
    'current': ('NOAA، تعريف التيارات ومسبباتها', 'https://oceanservice.noaa.gov/facts/current.html'),
    'upwelling': ('NOAA، الصعود والهبوط المائيان', 'https://oceanservice.noaa.gov/facts/upwelling.html'),
    'gyre': ('NOAA، الدوامات المحيطية الكبرى', 'https://oceanservice.noaa.gov/facts/gyre.html'),
    'tides': ('NOAA، أنماط الدورات المدّية', 'https://oceanservice.noaa.gov/education/tutorial_tides/tides07_cycles.html'),
    'storm': ('NOAA، الفرق بين عرام العاصفة والمستوى الكلي', 'https://oceanservice.noaa.gov/facts/stormsurge-stormtide.html'),
    'sealevel': ('NOAA، مستوى البحر العالمي والمحلي والعوامل المؤثرة', 'https://oceanservice.noaa.gov/facts/sealevel.html'),
    'conveyor': ('NOAA، الدورة المحيطية العالمية', 'https://oceanservice.noaa.gov/facts/conveyor.html'),
    'monitor': ('NOAA، قياس الملوحة والأكسجين والعكارة والكلوروفيل في المصبات', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est10_monitor.html'),
    'human': ('NOAA، الاضطرابات البشرية في المصبات', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est09_humandis.html'),
    'natural': ('NOAA، الاضطرابات الطبيعية في المصبات', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est08_natdisturb.html'),
    'ecosystem': ('NOAA، خدمات المصبات وحوض التصريف', 'https://oceanservice.noaa.gov/education/tutorial_estuaries/est03_ecosystem.html'),
    'knot': ('NOAA، الميل البحري والعقدة', 'https://oceanservice.noaa.gov/facts/nautical-mile-knot.html'),
}

def main():
    path = ROOT / 'assets/questions/geography.json'
    original = path.read_bytes()
    doc = json.loads(original.decode('utf-8-sig'))
    old = [q for q in doc['questions'] if int(q['id'].rsplit('-', 1)[1]) <= 200]
    assert len(old) == 800
    seen = {q['text'].strip() for q in old}
    counts = Counter()
    additions = []
    for line in (ROOT / 'tool/geography_expansion_20261013.tsv').read_text(encoding='utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        difficulty, source_key, text, answer, alternatives, hint, explanation = line.split('|')
        counts[difficulty] += 1
        qid = f'geography-{difficulty}-{200 + counts[difficulty]:04}'
        choices = [answer, *alternatives.split('~')]
        assert len(choices) == len(set(choices)) == 6, qid
        assert text not in seen, qid
        assert answer != hint and hint and explanation, qid
        seen.add(text)
        position = len(additions) % 6
        choices = choices[1:position+1] + [answer] + choices[position+1:]
        title, url = SOURCE[source_key]
        additions.append(dict(id=qid, categoryId='geography', difficulty=difficulty,
            text=text, answer=answer, acceptedAnswers=[], hint=hint, clues=[],
            explanation=explanation,
            sources=[f'{url} — {title}؛ قُرئت الصفحة في 2026-10-13. السيناريو التطبيقي من تأليفنا، والمبدأ مدعوم بالمصدر.'],
            options=[dict(id=chr(65+i), text=choice) for i, choice in enumerate(choices)],
            correctOptionId=chr(65+position), qualityStatus='unreviewed'))
    assert counts == dict.fromkeys(['easy', 'medium', 'hard', 'legendary'], 25), counts
    # Reject concurrent changes before replacing a file; preserve all original rows.
    assert path.read_bytes() == original, 'Concurrent edit detected; re-read before merging.'
    doc.update(targetCount=900, targetPerDifficulty=225, status='draft', questions=old+additions)
    staging = ROOT / 'tool/authoring_geography'
    staging.mkdir(parents=True, exist_ok=True)
    (staging / 'additions.json').write_text(json.dumps(additions, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(dict(categoryId='geography', added=len(additions), count=len(doc['questions']), difficulties=dict(Counter(q['difficulty'] for q in doc['questions'])))))

if __name__ == '__main__':
    main()
