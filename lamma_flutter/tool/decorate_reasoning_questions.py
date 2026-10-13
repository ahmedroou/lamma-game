"""Render original map diagrams and save reviewable final-bank snapshots."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,re,math,hashlib

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'tool/authoring_final_science_puzzles';OUT.mkdir(exist_ok=True)
def digest(b):return hashlib.sha256(b).hexdigest()
def spaced(s):
    s=re.sub(r'(?<=[\u0621-\u064aA-Za-z])(?=\d)', ' ',s)
    s=re.sub(r'(?<=\d)(?=[\u0621-\u064aA-Za-z])', ' ',s)
    return s
def diagram(p):
    W,H=520,460;im=Image.new('RGB',(W,H),'#17232c');d=ImageDraw.Draw(im)
    font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',23)
    small=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',19)
    if p['engine']=='graph':
        n=p['n'];xy=[(W/2+175*math.cos(-math.pi/2+i*2*math.pi/n),H/2+175*math.sin(-math.pi/2+i*2*math.pi/n)) for i in range(n)]
        placed=[]
        for a,b,w in p['edges']:
            xa,ya=xy[a];xb,yb=xy[b];d.line((xa,ya,xb,yb),fill='#6cafbc',width=4)
            # Diameter chords share a midpoint. Locate captions elsewhere on
            # their own edge and keep them separated from existing captions.
            spots=[(xa+t*(xb-xa),ya+t*(yb-ya)) for t in [.36,.64,.46,.54,.28,.72]]
            x,y=max(spots,key=lambda p:min([math.hypot(p[0]-u,p[1]-v) for u,v in placed]+[100]))
            placed.append((x,y))
            d.rounded_rectangle((x-17,y-14,x+17,y+14),radius=6,fill='#17232c');d.text((x,y),str(w),font=small,anchor='mm',fill='#ffd58a')
        for i,(x,y) in enumerate(xy):
            d.ellipse((x-23,y-23,x+23,y+23),fill='#2f5868',outline='#c0e4df',width=2);d.text((x,y),chr(65+i),font=font,anchor='mm',fill='white')
    else:
        n=p['n'];step=66;left=(W-n*step)/2;top=65
        for c in range(n):d.text((left+(c+.5)*step,top-20),chr(65+c),font=font,anchor='mm',fill='white')
        for r in range(n):d.text((left-20,top+(r+.5)*step),str(r+1),font=font,anchor='mm',fill='white')
        for i in range(n*n):
            r,c=divmod(i,n);x,y=left+c*step,top+r*step
            if p['engine']=='regions':color='#3b9064' if p['grid'][i] else '#318eb7';text=''
            elif i in p.get('blocked',[]):color='#4d5560';text='×'
            else:
                color='#347d75';text=str(p['heights'][i])
            d.rectangle((x,y,x+step,y+step),fill=color,outline='#17232c',width=2)
            if text:d.text((x+step/2,y+step/2),text,font=font,anchor='mm',fill='white')
        d.text((W/2,25),'N ↑',font=font,anchor='mm',fill='#d4edf4')
    path=ROOT/'assets/question_media'/f'original_{p["id"]}.webp'
    im.save(path,'WEBP',lossless=True)
    return 'assets/question_media/'+path.name
def main():
    proofs=json.loads((ROOT/'tool/reasoning_proofs.json').read_text(encoding='utf-8'));pd={p['id']:p for p in proofs}
    fixed_ids=set(json.loads((ROOT/'tool/reasoning_original_ids.json').read_text(encoding='utf-8')))
    # IDs whose earlier source/editorial review was actually recorded.
    reviewed={'how_it_works-legendary-0074','riddles-medium-0106','riddles-hard-0001','riddles-legendary-0001'}
    manifest={};media=0
    for cat in ['riddles','maps','how_it_works']:
        path=ROOT/'assets/questions'/f'{cat}.json';raw=path.read_bytes();bank=json.loads(raw.decode('utf-8-sig'))
        for q in bank['questions']:
            owned=q['id'] in fixed_ids or int(q['id'].split('-')[-1])>200
            if q['id'] not in reviewed:q['qualityStatus']='unreviewed'
            if not owned:continue
            for key in ['text','hint','explanation']:q[key]=spaced(q[key])
            p=pd.get(q['id'])
            if cat=='maps' and p and p['engine'] in ['graph','drainage','terrain_path','regions']:
                q['imageAsset']=diagram(p);q['imageDescription']='مخطط أصلي تظهر فيه جميع نقاط الشبكة أو خلايا الخريطة وقيمها، دون إظهار مسار الحل.';media+=1
                if p['engine']=='regions':
                    q['text']=re.sub(r'الصفوف من الشمال للجنوب، داخل كل صف من الغرب للشرق: .*?\. الاتصال', 'الخريطة مرفقة؛ الأخضر يابسة والأزرق ماء، والشمال أعلى الصورة. الاتصال',q['text'])
                elif p['engine']=='drainage':
                    q['text']=re.sub(r'الصف 1 في الشمال والأعمدة من A شرقًا\. .*?\. ماء', 'الخريطة مرفقة؛ الشمال أعلى الصورة، وكل خلية تحمل ارتفاعها بالمتر. ماء',q['text'])
                elif p['engine']=='terrain_path':
                    q['text']=re.sub(r'ارتفاعات الخلايا بالمتر: .*?\. من', 'الخريطة المرفقة تبين ارتفاع كل خلية بالمتر؛ علامة× تعني خلية مغلقة. من',q['text'])
                else:
                    q['text']=re.sub(r'والروابط الثنائية الوحيدة هي: .*?\. من', 'والرسم المرفق يبين جميع الروابط الثنائية وتكلفة كل منها. من',q['text'])
        payload=(json.dumps(bank,ensure_ascii=False,indent=2)+'\n').encode('utf-8')
        assert digest(path.read_bytes())==digest(raw),'Another writer changed '+cat
        path.write_bytes(payload);assert path.read_bytes()==payload
        (OUT/path.name).write_bytes(payload);manifest[cat]=dict(sha256=digest(payload),count=len(bank['questions']))
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Final snapshots:',manifest,'Original map diagrams:',media)
if __name__=='__main__':main()
