from pathlib import Path
from collections import Counter
import json,re,hashlib
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def clean(s):
    s=re.sub(r'(?<=[\u0621-\u064a])(?=[A-Za-z0-9])',' ',s)
    s=re.sub(r'(?<=[A-Za-z0-9])(?=[\u0621-\u064a])',' ',s)
    s=re.sub(r'([A-G]) ([1-5])',r'\1\2',s)
    return s.replace('الخطالأزرق','الخط الأزرق')
def main():
    manifest={};media=set()
    for c in ['how_it_works','maps','riddles']:
        p=ROOT/'tool/staging'/f'{c}.json';raw=p.read_bytes();b=json.loads(raw.decode('utf-8'))
        for q in b['questions']:
            for key in ['text','answer','hint','explanation','imageDescription']:
                if key in q:q[key]=clean(q[key])
            q['acceptedAnswers']=[clean(a) for a in q['acceptedAnswers']]
            for o in q['options']:o['text']=clean(o['text'])
            if q.get('imageAsset'):
                asset=ROOT/q['imageAsset'];assert asset.exists();media.add(asset)
        assert p.read_bytes()==raw,'Concurrent staged writer changed '+c
        payload=(json.dumps(b,ensure_ascii=False,indent=2)+'\n').encode('utf-8');p.write_bytes(payload)
        manifest[c]=dict(sha256=hashlib.sha256(payload).hexdigest(),count=len(b['questions']),difficultyCounts=dict(Counter(q['difficulty'] for q in b['questions'])),qualityCounts=dict(Counter(q['qualityStatus'] for q in b['questions'])),status=b['status'])
    for p in media:
        with Image.open(p) as im:im.verify()
    original=[p for p in media if p.name.startswith('original_')]
    manifest['originalMapMedia']=dict(count=len(original),bytes=sum(p.stat().st_size for p in original),allImagesDecoded=True)
    (ROOT/'tool/staging/science_puzzles_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(manifest,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
