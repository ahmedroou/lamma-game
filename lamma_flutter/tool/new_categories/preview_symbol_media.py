from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
base=Path(__file__).parent/'media';rows=json.loads((base/'manifest.json').read_text())
out=Image.new('RGB',(1280,((len(rows)+5)//6)*140),'#ddd');d=ImageDraw.Draw(out);font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',12)
for i,r in enumerate(rows):
 im=Image.open(base/r['name']);im.thumbnail((190,110));x=(i%6)*213;y=(i//6)*140
 out.paste(im,(x,y));d.text((x+3,y+112),r['name'].replace('new_symbols_','').replace('.webp',''),font=font,fill='black')
out.save(base/'contact_sheet.jpg')
