"""Original, high resolution instructional drawings made from primitive shapes."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import math,hashlib,json
OUT=Path(__file__).parent/'media';OUT.mkdir(exist_ok=True)
FONT=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',64)
SMALL=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',48)
MAN=[]
def canvas():
 im=Image.new('RGB',(480,400),'white');return im,ImageDraw.Draw(im)
def line(d,pts,color='black',w=10):d.line(pts,fill=color,width=w,joint='curve')
def circle(d,box,outline='black',w=10,fill=None):d.ellipse(box,outline=outline,width=w,fill=fill)
def txt(d,xy,t,font=FONT,fill='black'):d.text(xy,t,font=font,fill=fill,anchor='mm')
def cross(d):line(d,[(115,70),(365,310)],w=14);line(d,[(365,70),(115,310)],w=14)
def arrow(d,points,color='black',w=18):
 x,y=points[-1];x0,y0=points[-2];a=math.atan2(y-y0,x-x0);n=max(18,w*2.5)
 line(d,points[:-1]+[(x-n*.75*math.cos(a),y-n*.75*math.sin(a))],color,w)
 d.polygon([(x,y),(x-n*math.cos(a-.6),y-n*math.sin(a-.6)),(x-n*math.cos(a+.6),y-n*math.sin(a+.6))],fill=color)
def save(im,key,source):
 path=OUT/f'new_symbols_{key}.webp';im.save(path,'WEBP',lossless=True)
 MAN.append({'name':path.name,'source':source,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'originalDrawing':True,'width':480,'height':400})
 return 'assets/question_media/'+path.name
def road(key):
 im,d=canvas();red='#c90023';blue='#0052a5';triangle=key.startswith('warn_');bluekeys={'ahead','left_ahead','left','keep_left','either_side','minimum','end_minimum'}
 if triangle:
  d.polygon([(240,35),(65,345),(415,345)],fill=red);d.polygon([(240,84),(110,320),(370,320)],fill='white')
 elif key=='stop':
  pts=[(240+165*math.cos(math.pi/8+i*math.pi/4),200+165*math.sin(math.pi/8+i*math.pi/4)) for i in range(8)];d.polygon(pts,fill=red);txt(d,(240,200),'STOP',fill='white')
 elif key=='give_way':
  d.polygon([(65,45),(415,45),(240,345)],fill=red);d.polygon([(110,74),(370,74),(240,299)],fill='white');txt(d,(240,130),'GIVE',font=SMALL);txt(d,(240,182),'WAY',font=SMALL)
 elif key=='one_way':
  d.rectangle((75,50,405,350),fill=blue);arrow(d,[(240,295),(240,90)],'white',w=35)
 else:circle(d,(70,30,410,370),red if key not in bluekeys else blue,22,blue if key in bluekeys or key in {'no_waiting','no_stopping'} else 'white')
 if key=='no_entry':d.ellipse((70,30,410,370),fill=red);d.rectangle((112,170,368,230),fill='white')
 if key=='national_limit':
  im,d=canvas();circle(d,(70,30,410,370),'#888',3,'white');line(d,[(113,324),(366,76)],w=48)
 if key in {'maximum','minimum','end_minimum'}:txt(d,(240,202),'30',fill='white' if key in bluekeys else 'black')
 if key=='end_minimum':line(d,[(115,320),(365,75)],red,w=20)
 if key in {'no_right','no_left','no_u_turn'}:
  if key=='no_right':arrow(d,[(208,290),(208,165),(312,165)])
  if key=='no_left':arrow(d,[(273,290),(273,165),(169,165)])
  if key=='no_u_turn':line(d,[(290,288),(290,172)],w=18);d.arc((184,115,290,225),180,360,fill='black',width=18);arrow(d,[(184,170),(184,288)])
  line(d,[(113,322),(366,78)],red,22)
 if key in {'no_waiting','no_stopping'}:
  line(d,[(113,322),(366,78)],red,23)
  if key=='no_stopping':line(d,[(113,78),(366,322)],red,23)
 if key=='ahead':arrow(d,[(240,305),(240,90)],'white',30)
 if key=='left_ahead':arrow(d,[(285,290),(285,157),(157,157)],'white',27)
 if key=='left':arrow(d,[(345,200),(135,200)],'white',32)
 if key=='keep_left':arrow(d,[(300,115),(155,290)],'white',30)
 if key=='either_side':arrow(d,[(235,170),(155,285)],'white',26);arrow(d,[(245,170),(325,285)],'white',26)
 if key=='priority_opposite':arrow(d,[(195,282),(195,130)],red,19);arrow(d,[(283,128),(283,282)],'black',24)
 if key=='priority_own':d.rectangle((75,45,405,355),fill=blue);arrow(d,[(195,280),(195,128)],'white',24);arrow(d,[(283,130),(283,282)],red,19)
 if key=='no_overtaking':
  for x,c in [(153,red),(253,'black')]:d.rounded_rectangle((x,155,x+75,255),radius=9,fill=c);d.rectangle((x+10,175,x+65,215),fill='white')
 if key=='no_cycle':
  for x in [180,302]:circle(d,(x-45,205,x+45,295),w=8)
  line(d,[(180,250),(221,173),(264,250),(180,250),(237,209),(302,250),(281,171)],w=8);line(d,[(208,171),(237,171)],w=8);line(d,[(280,173),(277,146),(304,146)],w=8)
 if key.startswith('warn_'):
  code=key[5:]
  if code=='crossroads':line(d,[(240,135),(240,300)],w=25);line(d,[(163,222),(317,222)],w=25)
  if code=='t_junction':line(d,[(240,295),(240,135)],w=25);line(d,[(240,220),(323,220)],w=14)
  if code in {'narrow_right','narrow_both'}:
   line(d,[(175,295),(175,211),(175 if code=='narrow_right' else 205,150)],w=16);line(d,[(305,295),(305,211),(275,150)],w=16)
  if code=='two_way':arrow(d,[(208,297),(208,152)],w=19);arrow(d,[(277,153),(277,297)],w=19)
  if code=='two_way_cross':arrow(d,[(158,215),(320,215)],w=19);arrow(d,[(320,270),(158,270)],w=19)
  if code=='traffic_lights':
   d.rounded_rectangle((214,120,266,290),radius=10,fill='black')
   for y,c in [(154,'red'),(206,'#e0ad00'),(257,'green')]:circle(d,(224,y-16,256,y+16),c,1,c)
  if code=='uneven':d.polygon([(132,296),(158,269),(186,251),(213,268),(239,295),(267,249),(297,234),(324,258),(350,296)],fill='black')
  if code=='bend_right':arrow(d,[(218,300),(218,242),(290,185),(290,135)],w=25)
  if code=='other':txt(d,(240,236),'!',font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',125))
 return im

def laundry(key):
 im,d=canvas();typ,_,mod=key.partition('_')
 if typ=='wash':
  line(d,[(100,118),(133,278),(347,278),(380,118)],w=10)
  pts=[(x,135+8*math.sin((x-100)*math.pi/28)) for x in range(108,377)];line(d,pts,w=6)
  if mod=='no':cross(d)
  else:
   temp,bars=mod.split('-');txt(d,(240,213),temp,font=SMALL)
   for i in range(int(bars)):line(d,[(135,302+i*24),(345,302+i*24)],w=8)
 elif typ=='bleach':
  line(d,[(240,78),(105,297),(375,297),(240,78)],w=10)
  if mod=='oxygen':line(d,[(182,264),(259,138)],w=9);line(d,[(221,282),(292,166)],w=9)
  if mod=='no':cross(d)
 elif typ=='tumble':
  d.rectangle((105,75,375,305),outline='black',width=10);circle(d,(135,85,345,295),w=10)
  if mod=='no':cross(d)
  else:
   for x in ([240] if mod=='low' else [215,265]):circle(d,(x-10,180,x+10,200),fill='black',w=1)
 elif typ=='dry':
  d.rectangle((105,75,375,305),outline='black',width=10)
  direction,count,shade=mod.split('-')
  for i in range(int(count)):
   if direction=='line':line(d,[(225+i*30,88),(225+i*30,294)],w=8)
   else:line(d,[(118,178+i*30),(362,178+i*30)],w=8)
  if shade=='shade':line(d,[(113,153),(190,83)],w=8)
 elif typ=='iron':
  line(d,[(101,280),(376,280),(363,168),(166,168),(123,213),(101,280)],w=10);line(d,[(191,166),(191,119),(315,119),(332,164)],w=10)
  if mod=='no':cross(d)
  else:
   dots=int(mod)
   for i in range(dots):circle(d,(240+(i-(dots-1)/2)*40-9,215,240+(i-(dots-1)/2)*40+9,233),fill='black',w=1)
 elif typ=='clean':
  letter,bars,no=mod.split('-');circle(d,(115,65,365,315),w=10)
  if letter!='none':txt(d,(240,191),letter,font=FONT)
  for i in range(int(bars)):line(d,[(141,339+i*22),(339,339+i*22)],w=8)
  if no=='no':cross(d)
 return im

def circuit(key):
 im,d=canvas();line(d,[(65,200),(160,200)]);line(d,[(320,200),(415,200)])
 if key=='resistor':d.rectangle((160,170,320,230),outline='black',width=9)
 if key in {'variable','potentiometer'}:
  d.rectangle((160,170,320,230),outline='black',width=9)
  if key=='potentiometer':arrow(d,[(240,95),(240,175)])
  else:arrow(d,[(310,110),(189,267)],w=7)
 if key in {'capacitor','polarized'}:
  line(d,[(160,200),(219,200)]);line(d,[(261,200),(320,200)]);line(d,[(219,135),(219,265)])
  if key=='capacitor':line(d,[(261,135),(261,265)])
  else:d.arc((235,133,291,267),90,270,fill='black',width=10);txt(d,(195,105),'+',font=SMALL)
 if key=='inductor':
  for x in [160,200,240,280]:d.arc((x,160,x+40,240),180,360,fill='black',width=9)
 if key=='cell':line(d,[(160,200),(220,200)]);line(d,[(260,200),(320,200)]);line(d,[(220,125),(220,275)]);line(d,[(260,160),(260,240)])
 if key=='lamp':circle(d,(155,115,325,285),w=9);line(d,[(182,143),(298,257)]);line(d,[(182,257),(298,143)])
 if key in {'diode','led','photodiode'}:
  line(d,[(160,200),(195,200)]);line(d,[(275,200),(320,200)]);d.polygon([(195,145),(195,255),(275,200)],outline='black');line(d,[(195,145),(195,255),(275,200),(195,145)],w=8);line(d,[(275,140),(275,260)])
  if key=='led':arrow(d,[(252,113),(303,73)],w=7);arrow(d,[(294,145),(345,105)],w=7)
  if key=='photodiode':arrow(d,[(299,66),(252,115)],w=7);arrow(d,[(342,99),(295,148)],w=7)
 if key in {'npn','pnp'}:
  im,d=canvas();line(d,[(65,200),(195,200)]);line(d,[(195,125),(195,275)]);line(d,[(195,168),(310,90),(310,50)]);line(d,[(195,232),(310,310),(310,350)])
  if key=='npn':arrow(d,[(230,255),(285,293)],w=9)
  else:arrow(d,[(285,293),(230,255)],w=9)
 if key=='spdt':
  im,d=canvas();line(d,[(65,200),(165,200)]);circle(d,(158,193,172,207),fill='black');line(d,[(172,200),(286,140)]);line(d,[(305,140),(415,140)]);line(d,[(305,260),(415,260)]);circle(d,(298,133,312,147),fill='black');circle(d,(298,253,312,267),fill='black')
 return im

def finalize():
 (OUT/'manifest.json').write_text(json.dumps(MAN,ensure_ascii=False,indent=2),encoding='utf-8')
