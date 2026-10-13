"""Render supplementary music symbols once, avoiding device font fallbacks.

Uses the cached, unmodified SIL OFL Bravura font; license and pinned revision
are kept alongside it. Existing question IDs, answers and choices stay intact.
"""
from pathlib import Path
import hashlib,json
from PIL import Image,ImageDraw,ImageFont

BASE=Path(__file__).parent
doc=json.loads((BASE/'symbols_signals.json').read_text(encoding='utf-8'))
manifest=json.loads((BASE/'media/manifest.json').read_text(encoding='utf-8'))
metadata=json.loads((BASE/'music_font/source.json').read_text(encoding='utf-8'))
font_path=BASE/'music_font/Bravura.otf'
assert hashlib.sha256(font_path.read_bytes()).hexdigest()==metadata['fontSha256']
font=ImageFont.truetype(str(font_path),200)
missing=bytes(font.getmask(chr(0x10ffff)))
items=[]
for q in doc['questions']:
 for section in q.get('presentation',{}).get('sections',[]):
  for item in section['items']:
   glyph=item['text']
   if not any(ord(c)>0xffff for c in glyph):continue
   assert len(glyph)==1 and bytes(font.getmask(glyph))!=missing
   box=font.getbbox(glyph);assert box[2]>box[0] and box[3]>box[1]
   picture=Image.new('RGB',(480,400),'#f2f7fc');draw=ImageDraw.Draw(picture)
   draw.text(((480-(box[2]-box[0]))/2-box[0],(400-(box[3]-box[1]))/2-box[1]),
             glyph,font=font,fill='#15283a')
   name=f'new_symbols_music_{ord(glyph):x}.webp';path=BASE/'media'/name
   picture.save(path,'WEBP',lossless=True,method=6)
   entry=dict(name=name,source=metadata['repository'],sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
              originalDrawing=False,width=480,height=400,
              renderedFrom='Unmodified Bravura under SIL OFL 1.1',fontRevision=metadata['revision'],
              unicodeCodepoint=f'U+{ord(glyph):X}')
   assert not any(m['name']==name for m in manifest)
   manifest.append(entry)
   q['imageAsset']='assets/question_media/'+name
   q['imageDescription']='رسم رمز موسيقي واحد؛ المطلوب تفسيره في سياق التدوين الموسيقي.'
   item['text']='الرسم المرفق'
   items.append(dict(questionId=q['id'],glyph=glyph,imageAsset=q['imageAsset']))
assert len(items)==13
(BASE/'symbols_signals.json').write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(BASE/'media/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(BASE/'music_symbol_portability.json').write_text(json.dumps(dict(records=items,font=metadata,
  mediaBytes=sum((BASE/'media'/Path(i['imageAsset']).name).stat().st_size for i in items)),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'renderedMusicSymbols':len(items),'totalImages':len(manifest)}))
