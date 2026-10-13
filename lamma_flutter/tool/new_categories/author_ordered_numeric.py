"""Reproducible drafting from archived primary corpora. No production assets modified.

Every generated record stays unreviewed. Corpus arithmetic and option uniqueness
are checked independently; these checks are not a human editorial review.
"""
from pathlib import Path
from collections import Counter, defaultdict
from itertools import permutations, combinations
from decimal import Decimal
import json, random, math, re, xml.etree.ElementTree as ET
from fetch_numeric_sources import URLS

BASE=Path(__file__).parent
SRC=BASE/'numeric_sources'
RNG=random.Random(2026101304)
DIFF=['easy','medium','hard','legendary']
LETTERS=list('ABCDEF')
BANK=defaultdict(list)
VERIFY=[]
OPTION_POS={}
for _di,_d in enumerate(DIFF):
    _positions=LETTERS*12+(LETTERS[:3] if _di%2==0 else LETTERS[3:])
    RNG.shuffle(_positions)
    OPTION_POS[_d]=_positions

def source(key, detail=''):
    assert (SRC/(key+'.raw')).exists(), key
    return URLS[key]+ (' — '+detail if detail else '')

ORIGINAL='تأليف أصلي؛ تحقق رياضي مستقل موضح في explanation وأداة author_ordered_numeric.py.'

def items(seq):
    return [{'id':f'i{i+1}','text':str(x)} if x!='؟' else {'id':f'i{i+1}','text':'؟','missing':True} for i,x in enumerate(seq)]

def presentation(kind, seq, title=''):
    return {'type':kind,'sections':[{'id':'items','title':title,'items':items(seq)}]}

def add(cat,d,text,answer,options,hint,explanation,sources,pres=None,subtype=None,checks=None):
    options=list(dict.fromkeys(options))
    assert len(options)==6 and answer in options,(cat,text,options)
    n=sum(q['difficulty']==d for q in BANK[cat])+1
    assert n<=75,(cat,d,n)
    desired=OPTION_POS[d][n-1]
    others=[v for v in options if v!=answer]
    RNG.shuffle(others)
    opts=[]
    for l in LETTERS:
        opts.append({'id':l,'text':answer if l==desired else others.pop()})
    q={'id':f'{cat}-{d}-{n:04d}','categoryId':cat,'difficulty':d,'text':text,'answer':answer,'acceptedAnswers':[],
       'hint':hint,'clues':[],'explanation':explanation,'sources':sources,'options':opts,'correctOptionId':desired,'qualityStatus':'unreviewed'}
    if pres:q['presentation']=pres
    if subtype:q['subtype']=subtype
    BANK[cat].append(q)
    if checks:VERIFY.append({'id':q['id'],**checks})

ELEMENT_NAMES='الهيدروجين|الهيليوم|الليثيوم|البيريليوم|البورون|الكربون|النيتروجين|الأكسجين|الفلور|النيون|الصوديوم|المغنيسيوم|الألومنيوم|السيليكون|الفوسفور|الكبريت|الكلور|الأرغون|البوتاسيوم|الكالسيوم|السكانديوم|التيتانيوم|الفاناديوم|الكروم|المنغنيز|الحديد|الكوبالت|النيكل|النحاس|الزنك|الغاليوم|الجرمانيوم|الزرنيخ|السيلينيوم|البروم|الكريبتون|الروبيديوم|السترونشيوم|الإيتريوم|الزركونيوم|النيوبيوم|الموليبدينوم|التكنيتيوم|الروثينيوم|الروديوم|البلاديوم|الفضة|الكادميوم|الإنديوم|القصدير|الأنتيمون|التيلوريوم|اليود|الزينون|السيزيوم|الباريوم|اللانثانوم|السيريوم|البراسيوديميوم|النيوديميوم|البروميثيوم|الساماريوم|اليوروبيوم|الغادولينيوم|التيربيوم|الديسبروسيوم|الهولميوم|الإربيوم|الثوليوم|الإيتربيوم|اللوتيتيوم|الهافنيوم|التانتالوم|التنغستن|الرينيوم|الأوزميوم|الإيريديوم|البلاتين|الذهب|الزئبق|الثاليوم|الرصاص|البزموت|البولونيوم|الأستاتين|الرادون|الفرانسيوم|الراديوم|الأكتينيوم|الثوريوم|البروتكتينيوم|اليورانيوم|النبتونيوم|البلوتونيوم|الأمريسيوم|الكوريوم|البركليوم|الكاليفورنيوم|الأينشتاينيوم|الفيرميوم|المندليفيوم|النوبليوم|اللورنسيوم|الرذرفورديوم|الدوبنيوم|السيبورغيوم|البوهريوم|الهاسيوم|المايتنريوم|الدارمشتاتيوم|الرونتغينيوم|الكوبرنيسيوم|النيهونيوم|الفليروفيوم|الموسكوفيوم|الليفرموريوم|التينيسين|الأوغانيسون'.split('|')
assert len(ELEMENT_NAMES)==118
SYMBOLS=dict((int(n),sym) for n,sym in re.findall(r'\b(\d+) ([A-Z][a-z]?)\b',(SRC/'elements.txt').read_text(encoding='utf-8')))
assert len(SYMBOLS)==118
ELEMENTS=[{'name':x,'symbol':SYMBOLS[i+1],'z':i+1} for i,x in enumerate(ELEMENT_NAMES)]
QURAN=[dict(x.attrib) for x in ET.parse(SRC/'quran.raw').findall('./suras/sura')]
assert len(QURAN)==114
NOBEL=json.loads((SRC/'nobel.raw').read_text(encoding='utf-8'))['nobelPrizes']
NOBEL=[x for x in NOBEL if int(x['awardYear'])<=2024 and x.get('laureates')]
CAT_AR={'Physics':'الفيزياء','Chemistry':'الكيمياء','Literature':'الأدب','Peace':'السلام','Physiology or Medicine':'الطب أو علم وظائف الأعضاء','Economic Sciences':'العلوم الاقتصادية'}

# Arabic forms for widely familiar laureates; unfamiliar names preserve the original spelling.
NAME_AR={
 'Wilhelm Conrad Röntgen':'فيلهلم كونراد رونتغن','Albert Einstein':'ألبرت أينشتاين','Niels Bohr':'نيلز بور','Max Planck':'ماكس بلانك',
 'Marie Curie':'ماري كوري','Pierre Curie':'بيير كوري','Henri Becquerel':'هنري بيكريل','J.J. Thomson':'جوزيف جون طومسون',
 'Ernest Rutherford':'إرنست رذرفورد','James Chadwick':'جيمس تشادويك','Paul Dirac':'بول ديراك','Erwin Schrödinger':'إرفين شرودنغر',
 'Werner Heisenberg':'فيرنر هايزنبرغ','Enrico Fermi':'إنريكو فيرمي','Richard P. Feynman':'ريتشارد فاينمان','Abdus Salam':'عبد السلام',
 'Ahmed Zewail':'أحمد زويل','Naguib Mahfouz':'نجيب محفوظ','Jean-Paul Sartre':'جان بول سارتر','Albert Camus':'ألبير كامو',
 'Ernest Hemingway':'إرنست همنغواي','William Faulkner':'ويليام فوكنر','John Steinbeck':'جون شتاينبك','Rudyard Kipling':'روديارد كيبلينغ',
 'Rabindranath Tagore':'رابندرانات طاغور','George Bernard Shaw':'جورج برنارد شو','Winston Churchill':'ونستون تشرشل',
 'Gabriel García Márquez':'غابرييل غارسيا ماركيز','Toni Morrison':'توني موريسون','Kazuo Ishiguro':'كازو إيشيغورو',
 'Bob Dylan':'بوب ديلان','Abdulrazak Gurnah':'عبد الرزاق قرنح','Orhan Pamuk':'أورهان باموق','Pablo Neruda':'بابلو نيرودا',
 'Samuel Beckett':'صمويل بيكيت','Hermann Hesse':'هرمان هسه','Thomas Mann':'توماس مان','T.S. Eliot':'توماس ستيرنز إليوت',
 'Selma Lagerlöf':'سلمى لاغرلوف','Sully Prudhomme':'سولي برودوم','Theodor Mommsen':'تيودور مومزن','Ivan Pavlov':'إيفان بافلوف',
 'Robert Koch':'روبرت كوخ','Alexander Fleming':'ألكسندر فليمنغ','Francis Crick':'فرانسيس كريك','James Watson':'جيمس واتسون',
 'Howard Florey':'هوارد فلوري','Ernst Boris Chain':'إرنست بوريس تشين','Tu Youyou':'تو يويو','Robert G. Edwards':'روبرت إدواردز',
 'Henry Dunant':'هنري دونان','Theodore Roosevelt':'ثيودور روزفلت','Woodrow Wilson':'وودرو ويلسون',
 'Martin Luther King Jr.':'مارتن لوثر كينغ الابن','Nelson Mandela':'نيلسون مانديلا','F.W. de Klerk':'فريدريك دي كليرك',
 'Mother Teresa':'الأم تيريزا','Malala Yousafzai':'ملالا يوسفزاي','Kailash Satyarthi':'كايلش ساتيارثي','Barack Obama':'باراك أوباما',
 'Jimmy Carter':'جيمي كارتر','Muhammad Yunus':'محمد يونس','Anwar al-Sadat':'أنور السادات','Menachem Begin':'مناحم بيغن',
 'Yasser Arafat':'ياسر عرفات','Shimon Peres':'شمعون بيريز','Yitzhak Rabin':'إسحاق رابين','Kofi Annan':'كوفي عنان',
 'United Nations':'الأمم المتحدة','International Committee of the Red Cross':'اللجنة الدولية للصليب الأحمر',
 'Médecins Sans Frontières':'أطباء بلا حدود','World Food Programme':'برنامج الأغذية العالمي',
 'Linus Pauling':'لينوس باولنغ','Dorothy Crowfoot Hodgkin':'دوروثي كروفوت هودجكن','Frederick Sanger':'فريدريك سانغر',
 'Jacobus H. van \'t Hoff':'ياكوبوس فان هوف','Emil Fischer':'إميل فيشر','Svante Arrhenius':'سفانت أرينيوس',
 'Fritz Haber':'فريتز هابر','Robert B. Woodward':'روبرت وودوارد','Jennifer A. Doudna':'جنيفر دودنا','Emmanuelle Charpentier':'إيمانويل شاربنتييه',
 'Milton Friedman':'ميلتون فريدمان','Paul A. Samuelson':'بول سامويلسون','Amartya Sen':'أمارتيا سن','John F. Nash Jr.':'جون ناش',
 'Daniel Kahneman':'دانيال كانيمان','Elinor Ostrom':'إلينور أوستروم','Friedrich August von Hayek':'فريدريش هايك','Joseph E. Stiglitz':'جوزيف ستيغليتز',
}

def laureate_name(x):
    s=x.get('knownName',x.get('orgName',{})).get('en')
    assert s
    return NAME_AR.get(s,s)

PLANETS='عطارد|الزهرة|الأرض|المريخ|المشتري|زحل|أورانوس|نبتون'.split('|')
# NASA NSSDCA metric fact sheet, last updated 18 March 2025. Moon and Pluto columns omitted.
PVALUES={
 'القطر الاستوائي':('كم',[4879,12104,12756,6792,142984,120536,51118,49528]),
 'الكتلة':('10^24 كغ',[.330,4.87,5.97,.642,1898,568,86.8,102]),
 'الكثافة المتوسطة':('كغ/م³',[5429,5243,5514,3934,1326,687,1270,1638]),
 'جاذبية السطح وفق اصطلاح جدول ناسا':('م/ث²',[3.7,8.9,9.8,3.7,23.1,9,8.7,11]),
 'سرعة الإفلات':('كم/ث',[4.3,10.4,11.2,5,59.5,35.5,21.3,23.5]),
 'مقدار فترة الدوران النجمي':('ساعة',[1407.6,5832.5,23.9,24.6,9.9,10.7,17.2,16.1]),
 'طول اليوم الشمسي':('ساعة',[4222.6,2802,24,24.7,9.9,10.7,17.2,16.1]),
 'متوسط البعد عن الشمس':('مليون كم',[57.9,108.2,149.6,228,778.5,1432,2867,4515]),
 'مسافة الحضيض الشمسي':('مليون كم',[46,107.5,147.1,206.7,740.6,1357.6,2732.7,4471.1]),
 'مسافة الأوج الشمسي':('مليون كم',[69.8,108.9,152.1,249.3,816.4,1506.5,3001.4,4558.9]),
 'فترة المدار حول الشمس':('يوم أرضي',[88,224.7,365.2,687,4331,10747,30589,59800]),
 'متوسط السرعة المدارية':('كم/ث',[47.4,35,29.8,24.1,13.1,9.7,6.8,5.4]),
 'اللامركزية المدارية':('قيمة بلا وحدة',[.206,.007,.017,.094,.049,.052,.047,.010]),
 'ميل محور الدوران إلى المدار':('درجة',[.034,177.4,23.4,25.2,3.1,26.7,97.8,28.3]),
 'متوسط درجة الحرارة في جدول ناسا':('درجة مئوية',[167,464,15,-65,-110,-140,-195,-200]),
}

BOOKS={
 'alice':('أليس في بلاد العجائب','جحر الأرنب|بركة الدموع|سباق الأحزاب وحكاية طويلة|الأرنب يرسل فاتورة صغيرة|نصيحة من يرقة|خنزير وفلفل|حفلة شاي مجنونة|ملعب كروكيه الملكة|حكاية السلحفاة الزائفة|رقصة الكركند|من سرق الفطائر؟|شهادة أليس'.split('|')),
 'looking_glass':('عبر المرآة','بيت المرآة|حديقة الزهور الحية|حشرات المرآة|تويدلدَم وتويدلدي|صوف وماء|هامبتي دامبتي|الأسد ووحيد القرن|إنه من اختراعي|الملكة أليس|الهز|الاستيقاظ|من الذي حلم؟'.split('|')),
 'sherlock_adventures':('مغامرات شرلوك هولمز','فضيحة في بوهيميا|عصبة ذوي الشعر الأحمر|قضية هوية|لغز وادي بوسكومب|بذور البرتقال الخمس|الرجل ذو الشفة الملتوية|الجوهرة الزرقاء|العصابة الرقطاء|إبهام المهندس|النبيل الأعزب|تاج البريل|أشجار الزان النحاسية'.split('|')),
 'sherlock_memoirs':('مذكرات شرلوك هولمز، نسخة غوتنبرغ 834 التي تضم صندوق الورق المقوى','النجم الفضي|صندوق الورق المقوى|الوجه الأصفر|كاتب سمسار البورصة|غلوريا سكوت|طقوس مسغريف|سادة ريغيت|الرجل الأحدب|المريض المقيم|المترجم اليوناني|المعاهدة البحرية|المشكلة الأخيرة'.split('|')),
 'sherlock_return':('عودة شرلوك هولمز','البيت الخالي|بنّاء نوروود|الرجال الراقصون|راكبة الدراجة المنفردة|مدرسة الدير|بيتر الأسود|تشارلز أوغستس ميلفرتون|تماثيل نابليون الستة|الطلاب الثلاثة|النظارة الذهبية|لاعب الظهير المفقود|أبي غرانج|البقعة الثانية'.split('|')),
 'jungle':('كتاب الأدغال، ترتيب القصص السبع بعد استبعاد القصائد من الفهرس','إخوة ماوكلي|صيد كا|نمر! نمر!|الفقمة البيضاء|ريكي تيكي تافي|توماي الفيلة|خدم صاحبة الجلالة'.split('|')),
 'oz':('ساحر أوز العجيب','الإعصار|المجلس مع المانشكينز|كيف أنقذت دوروثي الفزاعة|الطريق عبر الغابة|إنقاذ الحطاب القصديري|الأسد الجبان|الرحلة إلى أوز العظيم|حقل الخشخاش المميت|ملكة فئران الحقل|حارس البوابات|مدينة الزمرد في أوز|البحث عن الساحرة الشريرة|الإنقاذ|القرود المجنحة|اكتشاف أوز الرهيب|فن الخداع السحري|كيف أُطلق المنطاد|نحو الجنوب|هجوم الأشجار المقاتلة|بلاد الخزف الرقيقة|الأسد يصبح ملك الوحوش|بلاد الكوادلينغ|غليندا الساحرة الطيبة تحقق أمنية دوروثي|العودة إلى البيت'.split('|')),
}

GEO={
 'الفترات الاثنتا عشرة لدَهْر الحياة الظاهرة، مع فصل الباليوجين والنيوجين والرباعي': 'الكمبري|الأوردوفيشي|السيلوري|الديفوني|الكربوني|البرمي|الترياسي|الجوراسي|الطباشيري|الباليوجين|النيوجين|الرباعي',
 'عهود حقبة الحياة الحديثة': 'الباليوسين|الإيوسين|الأوليغوسين|الميوسين|البليوسين|البليستوسين|الهولوسين',
 'أعمار العصر الجوراسي': 'Hettangian|Sinemurian|Pliensbachian|Toarcian|Aalenian|Bajocian|Bathonian|Callovian|Oxfordian|Kimmeridgian|Tithonian',
 'أعمار العصر الطباشيري': 'Berriasian|Valanginian|Hauterivian|Barremian|Aptian|Albian|Cenomanian|Turonian|Coniacian|Santonian|Campanian|Maastrichtian',
 'أعمار العصر الترياسي': 'Induan|Olenekian|Anisian|Ladinian|Carnian|Norian|Rhaetian',
 'أعمار العصر البرمي': 'Asselian|Sakmarian|Artinskian|Kungurian|Roadian|Wordian|Capitanian|Wuchiapingian|Changhsingian',
 'أعمار العصر الديفوني': 'Lochkovian|Pragian|Emsian|Eifelian|Givetian|Frasnian|Famennian',
 'أعمار العصر الأوردوفيشي': 'Tremadocian|Floian|Dapingian|Darriwilian|Sandbian|Katian|Hirnantian',
 'عهود العصر السيلوري': 'Llandovery|Wenlock|Ludlow|Pridoli',
 'أعمار العصر السيلوري، باستثناء عهد Pridoli الذي لا يقسم إلى أعمار': 'Rhuddanian|Aeronian|Telychian|Sheinwoodian|Homerian|Gorstian|Ludfordian',
 'أعمار العصر الكربوني': 'Tournaisian|Visean|Serpukhovian|Bashkirian|Moscovian|Kasimovian|Gzhelian',
 'فترات دهر طلائع الحياة': 'Siderian|Rhyacian|Orosirian|Statherian|Calymmian|Ectasian|Stenian|Tonian|Cryogenian|Ediacaran',
}

PREFIXES=[('كويكتو','q',-30),('رونتو','r',-27),('يوكتو','y',-24),('زيبتو','z',-21),('أتو','a',-18),('فيمتو','f',-15),('بيكو','p',-12),('نانو','n',-9),('ميكرو','µ',-6),('ملي','m',-3),('سنتي','c',-2),('ديسي','d',-1),('ديكا','da',1),('هكتو','h',2),('كيلو','k',3),('ميغا','M',6),('غيغا','G',9),('تيرا','T',12),('بيتا','P',15),('إكسا','E',18),('زيتا','Z',21),('يوتا','Y',24),('رونا','R',27),('كويتا','Q',30)]

ROYALS=[('وليام الأول',1066),('وليام الثاني',1087),('هنري الأول',1100),('ستيفن',1135),('هنري الثاني',1154),('ريتشارد الأول',1189),('جون',1199),('هنري الثالث',1216),('إدوارد الأول',1272),('إدوارد الثاني',1307),('إدوارد الثالث',1327),('ريتشارد الثاني',1377),('هنري الرابع',1399),('هنري الخامس',1413),('هنري السادس',1422),('إدوارد الرابع',1461),('إدوارد الخامس',1483),('ريتشارد الثالث',1483),('هنري السابع',1485),('هنري الثامن',1509),('إدوارد السادس',1547),('جين غراي',1553),('ماري الأولى',1553),('إليزابيث الأولى',1558),('جيمس الأول',1603),('تشارلز الأول',1625),('تشارلز الثاني',1660),('جيمس الثاني',1685),('وليام الثالث وماري الثانية',1689),('آن',1702),('جورج الأول',1714),('جورج الثاني',1727),('جورج الثالث',1760),('جورج الرابع',1820),('وليام الرابع',1830),('فيكتوريا',1837),('إدوارد السابع',1901),('جورج الخامس',1910),('إدوارد الثامن',1936),('جورج السادس',1936)]

CORP=[]
def corpus(key,rule,names,sources,difficulties,values=None,hint='اربط كل عنصر بموقعه في الترتيب المحدد؛ لا تعتمد على ترتيب عرضه.'):
    assert len(names)>=3 and len(set(names))==len(names),(key,names)
    CORP.append({'key':key,'rule':rule,'names':names,'sources':sources,'difficulties':difficulties,'values':values,'hint':hint})

corpus('quran','سور المصحف بترتيبها، لا بترتيب النزول',[x['name'] for x in QURAN],[source('quran','عنصر suras: index/name')],DIFF, list(range(1,115)), 'تتبع ترتيب السور في المصحف؛ تشابه أسماء السور لا يعني تجاورها.')
corpus('elements','العناصر بزيادة العدد الذري',[x['name'] for x in ELEMENTS],[source('elements')],DIFF, list(range(1,119)), 'المعيار هو عدد البروتونات، لا الكتلة ولا الترتيب الأبجدي.')
for n,(lo,hi) in enumerate([(1,2),(3,10),(11,18),(19,36),(37,54),(55,86),(87,118)],1):
    if hi-lo>=2:corpus(f'period{n}',f'عناصر الدورة {n} في الجدول الدوري من اليسار إلى اليمين، بما فيها الفئة f في موضعها من زيادة العدد الذري',ELEMENT_NAMES[lo-1:hi],[source('elements')],['medium','hard','legendary'],list(range(lo,hi+1)))
groups={1:[1,3,11,19,37,55,87],2:[4,12,20,38,56,88],4:[22,40,72,104],5:[23,41,73,105],6:[24,42,74,106],7:[25,43,75,107],8:[26,44,76,108],9:[27,45,77,109],10:[28,46,78,110],11:[29,47,79,111],12:[30,48,80,112],13:[5,13,31,49,81,113],14:[6,14,32,50,82,114],15:[7,15,33,51,83,115],16:[8,16,34,52,84,116],17:[9,17,35,53,85,117],18:[2,10,18,36,54,86,118]}
for n,zs in groups.items():corpus(f'group{n}',f'عناصر المجموعة {n} من الجدول الدوري من أعلى إلى أسفل',[ELEMENT_NAMES[z-1] for z in zs],[source('elements')],['medium','hard','legendary'],zs)
corpus('sun_order','الكواكب الثمانية من الأقرب إلى الشمس إلى الأبعد',PLANETS,[source('planet_sizes')],['easy','medium'],list(range(1,9)), 'ابدأ بالكواكب الصخرية الداخلية ثم انتقل إلى الكواكب العملاقة.')
for prop,(unit,vals) in PVALUES.items():
    if len(set(vals))<8:continue
    order=sorted(range(8),key=lambda i:vals[i])
    ds=['easy','medium'] if prop in ['القطر الاستوائي','متوسط البعد عن الشمس','فترة المدار حول الشمس'] else ['medium','hard','legendary']
    corpus('planet_'+prop,f'الكواكب الثمانية بزيادة {prop} بحسب جدول ناسا المحدث في 18 مارس 2025؛ الوحدة {unit}',[PLANETS[i] for i in order],[source('planets','القيم المدرجة في جدول metric، 18 March 2025')],ds,[vals[i] for i in order], 'قارن الخاصية المذكورة وحدها؛ الأكبر حجمًا ليس دائمًا الأعلى كثافة أو حرارة.')
corpus('dwarf_size','الكواكب القزمة الخمسة المعترف بها في صفحة ناسا المؤرخة 22 أبريل 2025 بزيادة القطر الاستوائي التقريبي',['سيريس','ماكيماكي','هاوميا','إيريس','بلوتو'],[source('planet_sizes')],['medium','hard'],[964,1434,1740,2326,2377])
corpus('galilean','أقمار غاليليو الأربعة بزيادة البعد عن المشتري',['آيو','أوروبا','غانيميد','كاليستو'],[source('spaceflight','Satellites of the Jovian Planets')],['easy','medium','hard'],None,'ابحث عن القمر البركاني الداخلي وعن القمر الخارجي كثير الفوهات.')
corpus('prefix','بادئات SI المعتمدة حتى قرار 18 نوفمبر 2022 بزيادة عامل الضرب، مع استبعاد العامل 1 غير المسبوق ببادئة',[x[0] for x in PREFIXES],[source('si','Table 7')],['medium','hard','legendary'],[x[2] for x in PREFIXES], 'ترتيب البادئات يتبع أسّ العدد 10؛ انتبه للحروف الكبيرة والصغيرة.')
corpus('osi','طبقات النموذج المرجعي OSI من الطبقة 1 إلى 7',['الفيزيائية','ربط البيانات','الشبكة','النقل','الجلسة','العرض','التطبيق'],[source('osi','ITU-T X.200، 1994، بنية الطبقات السبعة')],['easy','medium','hard'],list(range(1,8)), 'تبدأ السلسلة بالإشارة والوصلة، وتنتهي بالخدمة القريبة من التطبيق.')
corpus('spectrum','النطاقات السبعة للطيف الكهرومغناطيسي من الأطول موجة إلى الأقصر، مع فصل الموجات الميكروية عن بقية الراديو',['الراديو','الموجات الميكروية','تحت الحمراء','الضوء المرئي','فوق البنفسجية','الأشعة السينية','أشعة غاما'],[source('spectrum')],['easy','medium','hard'],None, 'زيادة التردد والطاقة تقابل قصر الطول الموجي في الفراغ.')
corpus('taxonomy','مراتب التصنيف الثماني من الأعم إلى الأخص، دون تحت النوع',['النطاق','المملكة','الشعبة','الطائفة','الرتبة','الفصيلة','الجنس','النوع'],[source('biology','Classification Levels')],['easy','medium','hard'],None,'الاسم العلمي الثنائي يستخدم آخر مرتبتين من السلسلة.')
corpus('dog_taxonomy','تصنيف الكلب المعروض في Figure 20.5 من النطاق إلى النوع، دون تحت النوع',['Eukarya','Animalia','Chordata','Mammalia','Carnivora','Canidae','Canis','lupus'],[source('biology','Figure 20.5')],['hard','legendary'],None,'آخر خانتين تمثلان جنس الكلب ونوعه؛ الأولى هي النطاق.')
corpus('shuttles','المكوكات الأمريكية الخمسة بحسب بداية رحلاتها المدارية، مع استبعاد إنتربرايز الذي لم ينفذ رحلة مدارية',['كولومبيا','تشالنجر','ديسكفري','أتلانتس','إنديفور'],[source('shuttles','Starting with Columbia and continuing with Challenger, Discovery, Atlantis and Endeavour')],['easy','medium','hard'],None,'البداية تعود إلى STS-1؛ النموذج الذي خضع لاختبارات جوية فقط مستبعد.')
for key,(title,names) in BOOKS.items():
    corpus('book_'+key,f'ترتيب الفهرس الأصلي لكتاب «{title}» في النسخة المحددة من غوتنبرغ؛ العناوين العربية ترجمة وصفية',names,[source(key,'Contents')],['medium','hard','legendary'],list(range(1,len(names)+1)), 'اتبع ترتيب القصص أو الفصول في الكتاب المحدد، لا زمن الأحداث داخل الحكاية.')
for title,names in GEO.items():
    corpus('geo_'+title,f'{title} من الأقدم إلى الأحدث وفق مخطط ICS إصدار ديسمبر 2024',names.split('|'),[source('stratigraphy','International Chronostratigraphic Chart، 2024/12')],['hard','legendary'],None,'قسّم الزمن إلى الحقب أو الأعمار المذكورة فقط؛ لا تخلط رتبتين جيولوجيتين.')
corpus('royals','أسماء الحكام في فهرس الأسرة الملكية من 1066 إلى 1952 بترتيب بداية أول فترة حكم، كما يسردها الفهرس؛ تُحسب فترتا الحكم المعادتان مرة واحدة',[x[0] for x in ROYALS],[source('royal')],['medium','hard','legendary'],[x[1] for x in ROYALS],'انتبه إلى رقم الاسم الملكي؛ تكرر الاسم عبر القرون لا يعني أنه الشخص نفسه.')
for cat,ar in CAT_AR.items():
    rows=sorted([x for x in NOBEL if x['category']['en']==cat],key=lambda x:int(x['awardYear']))
    # Sequence items include the complete group of laureates for an awarded year.
    for lo,hi in [(1901,1930),(1931,1960),(1961,1990),(1991,2024)]:
        rr=[x for x in rows if lo<=int(x['awardYear'])<=hi]
        if len(rr)<3:continue
        names=[' و'.join(laureate_name(a) for a in x['laureates']) for x in rr]
        # Distinguish repeated recipients without showing the year that answers a comparison.
        if len(set(names))<len(names):
            seen_names=Counter()
            original_counts=Counter(names)
            nn=[]
            for n in names:
                seen_names[n]+=1
                nn.append(n+f' (تكريم رقم {seen_names[n]} داخل هذا النطاق)' if original_counts[n]>1 else n)
            names=nn
        corpus(f'nobel_{cat}_{lo}',f'الفائزون بجائزة {"بنك السويد في العلوم الاقتصادية في ذكرى ألفرد نوبل" if cat=="Economic Sciences" else "نوبل في "+ar} بزيادة سنة الجائزة بين {lo} و{hi}، مع حذف السنوات التي لم تمنح فيها الجائزة وذكر كل الفائزين بالسنة',names,[source('nobel','category/awardYear/laureates')],['hard','legendary'],[int(x['awardYear']) for x in rr], 'سنة الجائزة هي المعيار، حتى إن تم التسليم في سنة لاحقة؛ المجموعة المشتركة وحدة واحدة.')
    famous=[]
    for x in rows:
        if all(a.get('knownName',a.get('orgName',{})).get('en') in NAME_AR for a in x['laureates']):famous.append(x)
    if len(famous)>=6:
        # Exclude people with two prizes in the same field rather than display their years.
        winner_counts=Counter(a['id'] for x in rows for a in x['laureates'])
        famous=[x for x in famous if all(winner_counts[a['id']]==1 for a in x['laureates'])]
        nn=[' و'.join(laureate_name(a) for a in x['laureates']) for x in famous]
        if len(nn)>=6:
            corpus('famous_'+cat,f'الأسماء المختارة في جائزة {ar} بزيادة سنة الجائزة، لا سنة الولادة',nn,[source('nobel')],['easy','medium'],[int(x['awardYear']) for x in famous])

# Original ordered, non-arithmetic diagrams for elementary geometry and notation.
ALPHABET='ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ط ظ ع غ ف ق ك ل م ن ه و ي'.split()
corpus('arabic_letters','الحروف العربية الثمانية والعشرون بالترتيب الهجائي القياسي؛ الألف حرف واحد والهمزة ليست خانة مستقلة',ALPHABET,[source('arabic_chart','جدول الحروف U+0627–U+064A؛ الحروف الثمانية والعشرون المذكورة بعد استبعاد ة وى وصور الهمزة')],['easy','medium'],list(range(1,29)),'قارن الترتيب الهجائي لا ترتيب أبجد هوز.')
ABJAD='ا ب ج د ه و ز ح ط ي ك ل م ن س ع ف ص ق ر ش ت ث خ ذ ض ظ غ'.split()
# No abjad-only questions: a primary historical source would be needed for the convention.
MONTHS='يناير|فبراير|مارس|أبريل|مايو|يونيو|يوليو|أغسطس|سبتمبر|أكتوبر|نوفمبر|ديسمبر'.split('|')
HIJRI='محرم|صفر|ربيع الأول|ربيع الآخر|جمادى الأولى|جمادى الآخرة|رجب|شعبان|رمضان|شوال|ذو القعدة|ذو الحجة'.split('|')
corpus('months','الأشهر الميلادية في سنة تبدأ بيناير',MONTHS,[source('cldr_ar','calendar gregorian، month type=1…12، release-48')],['easy'],list(range(1,13)),'انتبه للأشهر التي تقع بين منتصف السنة ونهايتها.')
corpus('hijri','الأشهر الهجرية في سنة تبدأ بمحرم',HIJRI,[source('cldr_ar','calendar islamic، month type=1…12، release-48')],['easy','medium'],list(range(1,13)),'تسمية الشهر الأول أو الآخر في الزوج لا تحدد موقعه من السنة كلها.')

def visible_candidates(c,d,count):
    names=c['names']
    if c['key']=='quran':
        pool=list(range(94,114)) if d=='easy' else list(range(0,60)) if d=='medium' else list(range(30,94))
    elif c['key']=='elements':
        pool=list(range(0,20)) if d=='easy' else list(range(0,54)) if d=='medium' else list(range(20,86)) if d=='hard' else list(range(55,118))
    else:pool=list(range(len(names)))
    return sorted(RNG.sample(pool,min(count,len(pool))))

def first_last():
    seen=set()
    for d in DIFF:
        candidates=[c for c in CORP if d in c['difficulties'] and len(c['names'])>=3]
        # Each base corpus is capped per difficulty to keep the variety visible.
        uses=Counter()
        while sum(q['difficulty']==d for q in BANK['first_last'])<75:
            available=[c for c in candidates if uses[c['key']]< (9 if d=='easy' else 5)]
            assert available
            c=RNG.choice(available)
            count=3 if d=='easy' else 4 if d=='medium' else 5 if d=='hard' else 6
            idx=visible_candidates(c,d,count)
            if len(idx)<3:continue
            signature=(c['key'],tuple(idx))
            if signature in seen:continue
            seen.add(signature);uses[c['key']]+=1
            names=[c['names'][i] for i in idx]
            displayed=names[:];RNG.shuffle(displayed)
            if displayed==names:displayed=displayed[1:]+displayed[:1]
            answer=f'الأول: {names[0]}؛ الأخير: {names[-1]}'
            pair_options=[answer]
            for a,b in RNG.sample(list(permutations(names,2)),len(names)*(len(names)-1)):
                s=f'الأول: {a}؛ الأخير: {b}'
                if s not in pair_options:pair_options.append(s)
                if len(pair_options)==6:break
            scope='ضمن العناصر المعروضة فقط'
            text=RNG.choice([f'{scope}، حدّد الأول والأخير وفق القاعدة: {c["rule"]}.',f'أي عنصر يبدأ هذه المجموعة وأي عنصر ينهيها عندما نطبق {c["rule"]}؟ النطاق هو المعروض فقط.',f'أعطِ طرفي الترتيب للمجموعة المعروضة فقط: {c["rule"]}.'])
            ordered=' ← '.join(names)
            vals=c['values']
            evidence='؛ '.join(f'{c["names"][i]}: {vals[i]}' for i in idx) if vals else ordered
            add('first_last',d,text,answer,pair_options,c['hint'],f'بعد تطبيق القاعدة على المجموعة المعروضة يكون الترتيب: {ordered}. إذن {answer}. بيانات التحقق: {evidence}.',c['sources'],presentation('comparison',displayed),checks={'corpus':c['key'],'orderedIndices':idx,'displayIndices':[c['names'].index(x) for x in displayed]})

def complete_sequence():
    seen=set()
    for d in DIFF:
        # A private editorial selection is not a unique sequence rule.
        # Famous-name subsets work for displayed comparisons only; gaps use complete corpora.
        candidates=[c for c in CORP if d in c['difficulties'] and len(c['names'])>=6 and not c['key'].startswith('famous_')]
        uses=Counter();pos_counts=Counter()
        while sum(q['difficulty']==d for q in BANK['complete_sequence'])<75:
            c=RNG.choice([x for x in candidates if uses[x['key']]< (9 if d=='easy' else 5)])
            length=4 if d=='easy' else 5 if d=='medium' else 6 if d=='hard' else 7
            length=min(length,len(c['names']))
            if c['key']=='quran':
                limits=(94,114) if d=='easy' else (0,60) if d=='medium' else (30,94)
            elif c['key']=='elements':
                limits=(0,20) if d=='easy' else (0,54) if d=='medium' else (20,86) if d=='hard' else (55,118)
            else:limits=(0,len(c['names']))
            start=RNG.randrange(limits[0],limits[1]-length+1)
            mode=min(['before','inside','after'],key=lambda x:pos_counts[x])
            gap=0 if mode=='before' else length-1 if mode=='after' else RNG.randrange(1,length-1)
            target=start+gap
            sig=(c['key'],start,length,gap)
            if sig in seen:continue
            seen.add(sig);uses[c['key']]+=1;pos_counts[mode]+=1
            full=c['names'][start:start+length];answer=full[gap]
            visible=full[:];visible[gap]='؟'
            distractors=[x for x in c['names'] if x!=answer]
            # Same corpus alternatives are close in type and can never be accepted as the missing item.
            options=[answer]+RNG.sample(distractors,5)
            placement='الأولى' if mode=='before' else 'الأخيرة' if mode=='after' else 'الداخلية'
            text=f'أكمل الخانة {placement} في هذه السلسلة. القاعدة: {c["rule"]}. العناصر المعروضة متتابعة في هذا الترتيب المحدد دون قفز.'
            vals=c['values'];detail=''
            if vals:detail=' قيم مواضع أو قياسات التحقق: '+ '؛ '.join(f'{c["names"][i]}: {vals[i]}' for i in range(start,start+length))+'.'
            add('complete_sequence',d,text,answer,options,c['hint'],f'السلسلة الكاملة وفق القاعدة المعلنة: {" ← ".join(full)}. الخانة المطلوبة هي {answer}.{detail}',c['sources'],presentation('sequence',visible),checks={'corpus':c['key'],'start':start,'length':length,'gap':gap})

def fmt(v):
    if isinstance(v,str):return v
    if isinstance(v,int) or float(v).is_integer():return str(int(v))
    return format(Decimal(str(v)),'f').rstrip('0').rstrip('.')

NUM=[]
def numeric(key,d,topic,unit,rows,sources,note='',hint='راجع معنى الوحدة والخاصية؛ لا تخلط بين عدد العناصر وعدد الفئات.'):
    assert len(rows)>=6,(key,rows)
    assert len({Decimal(str(v)) for _,v in rows})==len(rows),(key,'ties',rows)
    NUM.append({'key':key,'d':d,'topic':topic,'unit':unit,'rows':rows,'sources':sources,'note':note,'hint':hint})

def get_surahs(indices,field):return [(QURAN[i-1]['name'],int(QURAN[i-1][field])) for i in indices]
def get_elements(indices):return [(ELEMENT_NAMES[i-1],i) for i in indices]

# Fifteen independent measurement themes per difficulty; each contributes the five specified modes.
numeric('easy_sura_length','easy','عدد آيات السور وفق العد الكوفي في مصحف حفص','آية',get_surahs([1,2,3,4,5,6,7,12],'ayas'),[source('quran')],hint='السور الطويلة ليست متساوية؛ البقرة أطولها في هذه المجموعة.')
numeric('easy_sura_position','easy','رقم السورة في ترتيب المصحف','رقم سورة',get_surahs([1,2,18,36,55,67,112,114],'index'),[source('quran')],hint='تذكر أول المصحف وخواتيمه وبعض السور المشهورة بينهما.')
numeric('easy_atomic','easy','العدد الذري للعناصر الشائعة','بروتون في نواة العنصر',get_elements([1,2,6,7,8,11,13,26]),[source('elements')],hint='العدد الذري يحدد العنصر، والكتلة الذرية قيمة أخرى.')
numeric('easy_atomic_metals','easy','العدد الذري لفلزات مألوفة','بروتون في النواة',get_elements([3,12,19,20,29,30,47,79]),[source('elements')])
numeric('easy_planet_distance','easy','متوسط البعد عن الشمس للكواكب الثمانية','مليون كم',list(zip(PLANETS,PVALUES['متوسط البعد عن الشمس'][1])),[source('planets')],'قيم تقريبية كما في جدول ناسا المحدث 18 مارس 2025.',hint='افصل الكواكب الداخلية عن العمالقة الخارجية قبل تقدير المسافة.')
numeric('easy_planet_diameter','easy','القطر الاستوائي للكواكب الثمانية','كم',list(zip(PLANETS,PVALUES['القطر الاستوائي'][1])),[source('planets')],'تقريب جدول ناسا المحدث 18 مارس 2025.',hint='المشتري وزحل أكبر بكثير من الكواكب الصخرية، وأورانوس أكبر قليلًا من نبتون.')
numeric('easy_planet_year','easy','فترة دورة الكواكب حول الشمس','يوم أرضي',list(zip(PLANETS,PVALUES['فترة المدار حول الشمس'][1])),[source('planets')],'تقريب جدول ناسا المحدث 18 مارس 2025.',hint='السنة تصبح أطول كلما ابتعد مدار الكوكب عن الشمس.')
numeric('easy_month','easy','موضع الشهر الميلادي في السنة التي تبدأ بيناير','رقم شهر',[(MONTHS[i-1],i) for i in [1,2,3,6,8,9,11,12]],[source('cldr_ar','calendar gregorian، release-48')],hint='اربط الشهر ببداية السنة أو منتصفها أو نهايتها.')
numeric('easy_hijri','easy','موضع الشهر الهجري في السنة التي تبدأ بمحرم','رقم شهر',[(HIJRI[i-1],i) for i in [1,2,3,6,8,9,11,12]],[source('cldr_ar','calendar islamic، release-48')],hint='تأتي الأشهر الثلاثة الأخيرة بعد رمضان.')
numeric('easy_letters','easy','موضع الحرف في الحروف العربية الثمانية والعشرين، دون خانة مستقلة للهمزة','رقم حرف',[(ALPHABET[i-1],i) for i in [1,2,3,6,12,16,23,28]],[source('arabic_chart','حروف الأبجدية الأساسية بزيادة نقطة الرمز بعد الاستثناءات المعلنة')],hint='استخدم الترتيب الهجائي؛ أبجد هوز ترتيب مختلف.')
numeric('easy_polygons','easy','عدد الأضلاع في المضلع المسمى، وفق تعريف الاسم','ضلع',[('مثلث',3),('رباعي',4),('خماسي',5),('سداسي',6),('ثماني',8),('عشاري',10)],[ORIGINAL],hint='الاسم يدل على عدد الأضلاع؛ طول الضلع لا يدخل في العدد.')
numeric('easy_diagonals','easy','عدد أقطار المضلع المحدب، مع عدم احتساب الأضلاع','قطر',[('مثلث',0),('رباعي',2),('خماسي',5),('سداسي',9),('سباعي',14),('ثماني',20)],[ORIGINAL],'التحقق: n(n−3)/2.',hint='كل رأس يتصل بأقطار إلى الرؤوس غير المجاورة، ثم يُقسم العد على اثنين.')
numeric('easy_seconds','easy','عدد الثواني في مدة محددة، مع اعتبار اليوم 24 ساعة','ثانية',[('دقيقة واحدة',60),('خمس دقائق',300),('ربع ساعة',900),('نصف ساعة',1800),('ساعة',3600),('يوم',86400)],[source('si','Table 8: min/h/d')],hint='ابدأ من 60 ثانية في الدقيقة، ثم انتقل من الدقائق إلى الساعات.')
numeric('easy_length_units','easy','عدد المترات في وحدة طول مترية أو بحرية محددة','متر',[('مليمتر',.001),('سنتيمتر',.01),('ديسيمتر',.1),('ديكامتر',10),('كيلومتر',1000),('ميل بحري',1852)],[source('si','Tables 7–8')],hint='بادئات الوحدات عشرية؛ الميل البحري له تعريف مستقل.')
numeric('easy_nobel_literature','easy','سنة جائزة نوبل في الأدب للأسماء المختارة','سنة ميلادية',[],[source('nobel')]) if False else None

def nobel_rows(cat, indices=None, famous=False, lo=1901,hi=2024):
    out=[]
    winner_counts=Counter(a['id'] for x in NOBEL if x['category']['en']==cat for a in x['laureates'])
    for x in NOBEL:
        if x['category']['en']!=cat or not lo<=int(x['awardYear'])<=hi:continue
        if famous and not all(a.get('knownName',a.get('orgName',{})).get('en') in NAME_AR for a in x['laureates']):continue
        if len(x['laureates'])!=1:continue
        # A date-only mapping must not ambiguously refer to either of two awards.
        if winner_counts[x['laureates'][0]['id']]!=1:continue
        out.append((laureate_name(x['laureates'][0]),int(x['awardYear'])))
    out.sort(key=lambda x:x[1])
    return [out[i] for i in indices] if indices is not None else out

numeric('easy_nobel_literature','easy','سنة جائزة نوبل في الأدب لهؤلاء الأدباء','سنة ميلادية',nobel_rows('Literature',famous=True)[:8],[source('nobel')],hint='قارن أدباء مطلع القرن العشرين بأدباء منتصفه؛ سنة الجائزة تختلف عن سنة الولادة.')

# Medium: physical quantities, contextual numeric facts and geometry knowledge.
for key,prop in [('medium_density','الكثافة المتوسطة'),('medium_escape','سرعة الإفلات'),('medium_spin','مقدار فترة الدوران النجمي'),('medium_speed','متوسط السرعة المدارية')]:
    unit,vals=PVALUES[prop]
    numeric(key,'medium',prop+' للكواكب الثمانية',unit,list(zip(PLANETS,vals)),[source('planets')],'قيم تقريبية في جدول ناسا المحدث 18 مارس 2025؛ إشارة الدوران الرجعي لا تدخل في المقدار.',hint='الحجم والكثافة وفترة الدوران خواص مختلفة؛ ثبّت الخاصية أولًا.')
numeric('medium_sura_length','medium','عدد آيات هذه السور، بالعد الكوفي في مصحف حفص','آية',get_surahs([10,11,14,16,19,20,24,26],'ayas'),[source('quran')],hint='تشابه طول الأسماء لا يدل على طول السورة؛ قارن السور نفسها.')
numeric('medium_sura_position','medium','أرقام هذه السور في ترتيب المصحف','رقم سورة',get_surahs([8,9,10,13,15,17,21,25],'index'),[source('quran')],hint='موضع السورة في المصحف لا يتبع ترتيب نزولها.')
numeric('medium_atomic_transition','medium','الأعداد الذرية لفلزات من الصف الانتقالي الأول','بروتون في النواة',get_elements([21,22,23,24,25,27,28,30]),[source('elements')],hint='تتجاور هذه العناصر في الدورة الرابعة، بعد الكالسيوم.')
numeric('medium_atomic_nonmetals','medium','الأعداد الذرية لهذه العناصر اللافلزية أو أشباه الفلزات','بروتون في النواة',get_elements([5,14,15,16,17,32,33,34]),[source('elements')])
numeric('medium_prefix_exp','medium','أسّ العدد 10 في عامل بادئة SI؛ المطلوب الأسّ نفسه لا العامل','أسّ صحيح',[('ديسي',-1),('سنتي',-2),('ملي',-3),('ميكرو',-6),('نانو',-9),('كيلو',3),('ميغا',6),('غيغا',9)],[source('si','Table 7')],hint='المضاعفات أسس موجبة والأجزاء أسس سالبة.')
numeric('medium_area_units','medium','عدد الأمتار المربعة في وحدة مساحة محددة','م²',[('مليمتر مربع',.000001),('سنتيمتر مربع',.0001),('ديسيمتر مربع',.01),('آر',100),('هكتار',10000),('كيلومتر مربع',1000000)],[source('si','Table 8؛ تربيع عوامل بادئات Table 7')],hint='عند تحويل المساحة يُربّع عامل تحويل الطول.')
numeric('medium_angle_sum','medium','مجموع الزوايا الداخلية لمضلع محدب مسطح','درجة',[('مثلث',180),('رباعي',360),('خماسي',540),('سداسي',720),('ثماني',1080),('عشاري',1440)],[ORIGINAL],'إثبات أصلي: تقسيم المضلع إلى n−2 مثلثًا.',hint='يمكن تقسيم المضلع من رأس واحد إلى مثلثات دون تداخل.')
numeric('medium_pairs','medium','عدد المباريات في دوري من دور واحد يلعب فيه كل فريق مع كل آخر مرة واحدة','مباراة',[('3 فرق',3),('4 فرق',6),('5 فرق',10),('6 فرق',15),('8 فرق',28),('10 فرق',45)],[ORIGINAL],'التحقق: عدد الأزواج غير المرتبة n(n−1)/2.',hint='احسب كل مواجهة بين فريقين مرة واحدة فقط.')
numeric('medium_royal_years','medium','سنة بداية الحكم الأولى للأسماء الملكية المحددة في فهرس Royal.uk','سنة ميلادية',[(n,y) for n,y in ROYALS if n in ['هنري السابع','هنري الثامن','إليزابيث الأولى','جيمس الأول','فيكتوريا','إدوارد السابع','جورج الخامس','جورج السادس']],[source('royal')],hint='لا تخلط بين سنة الميلاد وسنة بداية الحكم، ولا بين ملكين يحملان الاسم نفسه.')
numeric('medium_nobel_physics','medium','سنة جائزة نوبل في الفيزياء لمنفردين مختارين','سنة ميلادية',nobel_rows('Physics',famous=True)[:8],[source('nobel')],hint='تقدم اكتشاف الأشعة السينية على نظرية الكم؛ استخدم سنة الجائزة لا التسليم.')
numeric('medium_nobel_chemistry','medium','سنة جائزة نوبل في الكيمياء لمنفردين مختارين','سنة ميلادية',nobel_rows('Chemistry',famous=True)[:8],[source('nobel')],hint='الجائزة المرتبطة باسم علم قد تكون في مجال مختلف عن تخصصه الأشهر.')

# Hard: close quantities and exact contextual records.
for key,prop in [('hard_mass','الكتلة'),('hard_solar_day','طول اليوم الشمسي'),('hard_perihelion','مسافة الحضيض الشمسي'),('hard_aphelion','مسافة الأوج الشمسي'),('hard_axial','ميل محور الدوران إلى المدار')]:
    unit,vals=PVALUES[prop]
    numeric(key,'hard',prop+' للكواكب الثمانية',unit,list(zip(PLANETS,vals)),[source('planets')],'قيم جدول ناسا المحدث 18 مارس 2025؛ استخدم الأرقام المدرجة ضمن تقريب الجدول.',hint='ميّز الحضيض عن الأوج والدوران النجمي عن اليوم الشمسي وفق الخاصية المطلوبة.')
numeric('hard_sura_length','hard','عدد آيات السور المحددة، بالعد الكوفي في مصحف حفص','آية',get_surahs([27,28,30,31,33,35,39,40],'ayas'),[source('quran')],hint='أعداد آيات سور الجزء الأوسط لا تُستنتج من مواضعها.')
numeric('hard_sura_position','hard','رقم هذه السور في ترتيب المصحف','رقم سورة',get_surahs([29,32,34,37,38,41,42,43],'index'),[source('quran')])
numeric('hard_atomic','hard','الأعداد الذرية للعناصر المحددة من الدورتين الخامسة والسادسة','بروتون في النواة',get_elements([41,42,43,44,45,46,48,50]),[source('elements')],hint='ابدأ بموقع الدورة والمجموعة، ثم ميّز العناصر المتجاورة.')
numeric('hard_atomic_heavy','hard','الأعداد الذرية لهذه الفلزات الثقيلة','بروتون في النواة',get_elements([72,73,74,75,76,77,78,80]),[source('elements')])
numeric('hard_prefix_exp','hard','أسّ العدد 10 في عوامل بادئات SI الكبيرة؛ المطلوب الأسّ','أسّ صحيح',[('ميغا',6),('غيغا',9),('تيرا',12),('بيتا',15),('إكسا',18),('زيتا',21),('يوتا',24),('رونا',27),('كويتا',30)],[source('si','Table 7، إصدار يتضمن قرار 2022')],hint='انتبه لبادئات التوسع المعتمد في 2022 ولقفزات الأسس بثلاثة.')
numeric('hard_nobel_literature','hard','سنة نوبل في الأدب للأسماء المحددة بين 1930 و1980','سنة ميلادية',nobel_rows('Literature',lo=1930,hi=1980)[2:10],[source('nobel')],hint='سنة الجائزة أدق من معرفة جيل الأديب؛ الجائزة المتأخرة لا تعني كتابًا متأخرًا.')
numeric('hard_nobel_peace','hard','سنة نوبل للسلام لمنفردين مختارين بين 1901 و1960','سنة ميلادية',nobel_rows('Peace',lo=1901,hi=1960)[:8],[source('nobel')])
numeric('hard_nobel_medicine','hard','سنة نوبل في الطب أو علم وظائف الأعضاء لمنفردين مختارين','سنة ميلادية',nobel_rows('Physiology or Medicine',lo=1901,hi=1930)[3:11],[source('nobel')])
numeric('hard_factorial','hard','عدد ترتيبات كتب مختلفة على رف خطي دون قيود','ترتيب',[('3 كتب',6),('4 كتب',24),('5 كتب',120),('6 كتب',720),('7 كتب',5040),('8 كتب',40320)],[ORIGINAL],'الإثبات: n!؛ في كل موضع يتناقص عدد الكتب المتاحة بواحد.',hint='اختيار الكتاب الأول ثم الثاني يضرب عدد الإمكانات، ولا يجمعها.')
numeric('hard_eu_entry','hard','سنة انضمام الدولة المختارة إلى الاتحاد الأوروبي أو سلفه الجماعة الاقتصادية الأوروبية كما يعرض موقع الاتحاد','سنة ميلادية',[('بلجيكا',1958),('الدنمارك',1973),('اليونان',1981),('النمسا',1995),('إستونيا',2004),('بلغاريا',2007),('كرواتيا',2013)],[source('eu')],hint='تأسيس الاتحاد الأوروبي باسمه الحالي لا يلغي احتساب أعضاء الجماعة السابقة في الجدول الرسمي.')

# Legendary: precise quantities and awards across adjacent years; no live rates or totals.
numeric('legendary_eccentricity','legendary','اللامركزية المدارية للكواكب الثمانية، وفق جدول ناسا','قيمة بلا وحدة',list(zip(PLANETS,PVALUES['اللامركزية المدارية'][1])),[source('planets')],'قيم تقريبية في الجدول المحدث 18 مارس 2025.',hint='اللامركزية صفر للدائرة المثالية؛ صغرها لا يدل على قرب الكوكب من الشمس.')
numeric('legendary_temperature','legendary','متوسط درجة حرارة الكوكب المدرجة في جدول ناسا، لا الحد الأقصى أو حرارة نواته','درجة مئوية',list(zip(PLANETS,PVALUES['متوسط درجة الحرارة في جدول ناسا'][1])),[source('planets')],'القيم المرجعية التقريبية في جدول 18 مارس 2025؛ للكواكب الغازية مستوى القياس معرف في ملاحظات الجدول.',hint='الجو الكثيف قد يجعل كوكبًا أبعد أشد حرارة؛ احتفظ بإشارة الأعداد السالبة.')
numeric('legendary_sura_length','legendary','عدد آيات سور محددة، بالعد الكوفي في مصحف حفص','آية',get_surahs([44,45,46,47,48,49,50,51],'ayas'),[source('quran')])
numeric('legendary_sura_position','legendary','أرقام السور المحددة في ترتيب المصحف','رقم سورة',get_surahs([52,54,56,57,58,60,63,66],'index'),[source('quran')])
numeric('legendary_lanthanides','legendary','الأعداد الذرية لعناصر من اللانثانيدات','بروتون في النواة',get_elements([58,59,60,61,62,64,65,66]),[source('elements')],hint='الكتلة ليست معيارًا؛ تذكر موضع اللانثانيدات بين اللانثانوم واللوتيتيوم.')
numeric('legendary_actinides','legendary','الأعداد الذرية لعناصر من الأكتينيدات','بروتون في النواة',get_elements([90,91,92,93,94,95,96,97]),[source('elements')])
numeric('legendary_synthetic','legendary','الأعداد الذرية للعناصر الاصطناعية المحددة','بروتون في النواة',get_elements([104,106,108,110,113,114,116,118]),[source('elements')])
numeric('legendary_small_prefix','legendary','أسّ العدد 10 لبادئات SI الخاصة بالأجزاء الدقيقة؛ المطلوب الأسّ','أسّ صحيح',[('نانو',-9),('بيكو',-12),('فيمتو',-15),('أتو',-18),('زيبتو',-21),('يوكتو',-24),('رونتو',-27),('كويكتو',-30)],[source('si','Table 7')],hint='كل خطوة في هذه المجموعة تنقص الأس ثلاث درجات؛ بادئات 2022 توسع الطرف الأصغر.')
numeric('legendary_constants_exponents','legendary','أسّ عشرة عند كتابة القيمة العددية لثابت SI المحدد بصيغة علمية معيارية: معامل من 1 إلى أقل من 10؛ تُستخدم الوحدة المذكورة مع كل ثابت','أسّ صحيح',[('تردد انتقال السيزيوم 133 (هرتز)',9),('سرعة الضوء في الفراغ (م/ث)',8),('ثابت بلانك (جول ثانية)',-34),('الشحنة الأولية (كولوم)',-19),('ثابت بولتزمان (جول/كلفن)',-23),('ثابت أفوغادرو (مول⁻¹)',23),('الفعالية الضوئية Kcd عند 540×10^12 هرتز (لومن/واط)',2)],[source('si','Table 1، constants defining SI')],hint='المطلوب أسّ الصيغة العلمية بعد تثبيت الوحدة؛ لا تقارن ثوابت مختلفة مباشرةً فيزيائيًا.')
for key,cat,lo,hi in [('legendary_physics','Physics',1930,1965),('legendary_chemistry','Chemistry',1940,1980),('legendary_literature','Literature',1981,2024),('legendary_medicine','Physiology or Medicine',1920,1970),('legendary_economics','Economic Sciences',1969,1995)]:
    rr=nobel_rows(cat,lo=lo,hi=hi)
    assert len(rr)>=6,(key,rr)
    numeric(key,'legendary',f'سنة جائزة {"بنك السويد في العلوم الاقتصادية في ذكرى ألفرد نوبل" if cat=="Economic Sciences" else "نوبل في "+CAT_AR[cat]} للأسماء المحددة','سنة ميلادية',rr[:8],[source('nobel')],hint='المعيار سنة الجائزة، حتى لو عُقد حفل تسليمها في سنة تالية.')
numeric('legendary_geo_boundaries','legendary','العمر العددي التقريبي لبداية الفترة الجيولوجية في مخطط ICS إصدار ديسمبر 2024؛ تُهمل حدود عدم اليقين هنا','مليون سنة قبل الحاضر',[('الرباعي',2.58),('النيوجين',23.04),('الباليوجين',66),('الطباشيري',143.1),('الجوراسي',201.4),('الترياسي',251.902),('البرمي',298.9),('الكمبري',538.8)],[source('stratigraphy')],'أعمار تقريبية مثبتة بإصدار 2024/12، وليست تعريفات حدود GSSP نفسها.',hint='كلما كانت بداية الفترة أقدم زاد العمر قبل الحاضر؛ انتبه للفارق بين العمر وترتيب الفترات.')

assert Counter(x['d'] for x in NUM)==Counter({d:15 for d in DIFF}),Counter(x['d'] for x in NUM)

def numeric_statement(g,row):
    name,value=row
    return f'{name}: {g["topic"]} = {fmt(value)} {g["unit"]}'

def numbers():
    for g in NUM:
        d=g['d'];rows=g['rows'];unit=g['unit'];topic=g['topic'];note=g['note']
        use=RNG.sample(rows,6)
        selected=use[2]
        # Owner is a knowledge-to-number association among actual same-topic alternatives.
        owner,value=selected
        answer=owner
        add('numbers',d,f'صاحب الرقم: أي عنصر يرتبط بالقيمة {fmt(value)} {unit} عند قياس {topic}؟ {note}',answer,[n for n,_ in use],g['hint'],f'{owner}: {fmt(value)} {unit}. القيم الصحيحة لهذه الخيارات: '+ '؛ '.join(f'{n}={fmt(v)} {unit}' for n,v in use)+'. '+note,g['sources'],subtype='number_owner',checks={'mode':'owner','referenceRows':use,'selected':selected})
        # One numeric error; all remaining statements are unmodified corpus values.
        factual=RNG.sample(rows,4 if d in ['easy','medium'] else 5)
        bad=RNG.randrange(len(factual));actual=factual[bad][1]
        numeric_values=[Decimal(str(v)) for _,v in rows]
        step=Decimal('1') if all(v==int(v) for v in numeric_values) else Decimal('0.1') if all(v*10==int(v*10) for v in numeric_values) else Decimal('0.001')
        wrong=Decimal(str(actual))+step*(3 if d=='easy' else 2 if d=='medium' else 1)
        shown=[numeric_statement(g,r) for r in factual]
        shown[bad]=numeric_statement(g,(factual[bad][0],wrong))
        answer=f'العبارة {bad+1}: {factual[bad][0]}؛ الصحيح {fmt(actual)} {unit}'
        opts=[answer]
        for i,(n,v) in enumerate(factual):
            if i!=bad:opts.append(f'العبارة {i+1}: {n}؛ الصحيح {fmt(Decimal(str(v))+step)} {unit}')
        for shift in [4,-2,6]:
            s=f'العبارة {bad+1}: {factual[bad][0]}؛ الصحيح {fmt(Decimal(str(actual))+step*shift)} {unit}'
            if s not in opts:opts.append(s)
            if len(opts)==6:break
        add('numbers',d,f'الرقم الخطأ: في العبارات المعروضة عن {topic} رقم واحد غير صحيح. حدّد العبارة وصحح الرقم. {note}',answer,opts,g['hint'],f'العبارة {bad+1} وحدها خاطئة: {fmt(wrong)} بدلًا من {fmt(actual)} {unit}. إثبات كل القيم الأصلية: '+ '؛ '.join(f'العبارة {i+1}: {n}={fmt(v)} {unit}' for i,(n,v) in enumerate(factual))+'. '+note,g['sources'],presentation('statements',shown),subtype='number_wrong',checks={'mode':'wrong','rows':factual,'badIndex':bad,'wrongValue':str(wrong),'actualValue':str(actual)})
        # Nearest: six close estimates for one contextual measured number, none equal to reference.
        chosen=rows[(NUM.index(g)+3)%len(rows)];name,reference=chosen
        ref=Decimal(str(reference))
        gran=Decimal('1') if ref==int(ref) else Decimal('0.1') if ref*10==int(ref*10) else Decimal('0.001')
        # Use readable estimates at a precision supported by the quoted reference.
        raw_scale=abs(ref)*Decimal('.003')
        scale=max(gran,Decimal(10)**raw_scale.adjusted()) if raw_scale else gran
        if topic.startswith('سنة') or unit.startswith('رقم') or unit in ['سنة ميلادية','أسّ صحيح','رقم شهر','رقم حرف','بروتون في النواة','بروتون في نواة العنصر','ضلع','قطر','آية','قيمة حرف']:
            scale=Decimal('1')
        deltas=[Decimal(x) for x in ([-5,-3,-2,1,4,6] if NUM.index(g)%2==0 else [-6,-4,-1,2,3,5])]
        nonnegative=unit not in ['درجة مئوية','أسّ صحيح']
        if nonnegative and ref+scale*min(deltas)<=0:
            deltas=[Decimal(x) for x in [1,2,3,4,5,6]]
        estimates=[ref+scale*x for x in deltas]
        distances=[abs(x-ref) for x in estimates]
        assert min(distances)>0 and distances.count(min(distances))==1
        correct=estimates[distances.index(min(distances))]
        opts=[fmt(x)+' '+unit for x in estimates];answer=fmt(correct)+' '+unit
        text=f'الأقرب للرقم: أي تقدير من التقديرات الستة أقرب إلى القيمة المرجعية لـ«{name}» في {topic}؟ الوحدة {unit}. {note}'
        add('numbers',d,text,answer,opts,'حدد رتبة المقدار أولًا، ثم قارن الفروق المطلقة؛ التقريب لأعلى أو لأسفل وحده لا يكفي.',f'المرجع هو {fmt(ref)} {unit}. فروق التقديرات عن المرجع: '+ '؛ '.join(f'{fmt(v)}: فرق {fmt(dist)} {unit}' for v,dist in zip(estimates,distances))+f'. أقل فرق منفرد هو {fmt(min(distances))}، لذلك الأقرب {answer}. '+note,g['sources'],presentation('comparison',[fmt(v)+' '+unit for v in estimates]),subtype='number_nearest',checks={'mode':'nearest','reference':str(ref),'estimates':[str(x) for x in estimates],'distances':[str(x) for x in distances]})
        # Matching full solution; right column shuffled and labels never reveal the pairing.
        chosen=RNG.sample(rows,3);names=[n for n,_ in chosen];values=[v for _,v in chosen]
        right=values[:];RNG.shuffle(right)
        if right==values:right=right[1:]+right[:1]
        def solution(pp):return '؛ '.join(f'{n} = {fmt(v)} {unit}' for n,v in zip(names,pp))
        answer=solution(values);opts=[solution(pp) for pp in permutations(values)]
        pres={'type':'matching','sections':[{'id':'left','title':'العناصر','items':[{'id':f'l{i+1}','text':n} for i,n in enumerate(names)]},{'id':'right','title':'الأرقام ('+unit+')','items':[{'id':f'r{i+1}','text':fmt(v)} for i,v in enumerate(right)]}]}
        add('numbers',d,f'ضع الرقم مكانه: اربط العناصر الثلاثة بالأرقام الثلاثة في موضوع {topic}. كل رقم يُستخدم مرة واحدة. {note}',answer,opts,g['hint'],answer+'. كل علاقة مأخوذة من الجدول المرجعي أو التعريف المعلن؛ تبديل رقمين يغير الحل. '+note,g['sources'],pres,subtype='number_matching',checks={'mode':'matching','rows':chosen})
        # Ordering full permutations: numerical values stay out of presentation.
        chosen=RNG.sample(rows,3 if d in ['easy','medium'] else 4)
        ordered=sorted(chosen,key=lambda x:Decimal(str(x[1])))
        names=[n for n,_ in ordered]
        answer=' ← '.join(names)
        allopts=[' ← '.join(pp) for pp in permutations(names)]
        opts=[answer]+RNG.sample([x for x in allopts if x!=answer],5)
        display=names[:];RNG.shuffle(display)
        add('numbers',d,f'المقارنة والترتيب: رتّب العناصر المعروضة من الأقل إلى الأعلى بحسب {topic} ({unit}). {note}',answer,opts,g['hint'],'التحقق العددي: '+ '؛ '.join(f'{n}={fmt(v)} {unit}' for n,v in ordered)+'. لذلك الترتيب '+answer+'. '+note,g['sources'],presentation('comparison',display),subtype='number_ordering',checks={'mode':'ordering','rows':chosen,'ordered':ordered})

# Truth blocks: five independent facts per topic, plus a specific false counterpart
# for each. Topic breadth is measured in the report; no field is promoted to reviewed.
FACTS=[]
def fact(topic,truth,false,sources,ds,hint,proof=''):
    assert truth!=false
    FACTS.append({'topic':topic,'truth':truth,'false':false,'sources':sources,'ds':ds,'hint':hint,'proof':proof})

def seed_facts():
    for e in ELEMENTS:
        z=e['z'];name=e['name'];sym=e['symbol'];other=SYMBOLS[z%118+1]
        ds=['easy','medium'] if z<=20 or z in [26,29,30,47,50,53,79,80,82] else ['medium','hard'] if z<=54 else ['hard','legendary']
        fact('الكيمياء: رموز العناصر',f'رمز {name} هو {sym}.',f'رمز {name} هو {other}.',[source('elements')],ds,'حالة الحرفين في الرمز مهمة، والاسم العربي لا يولّد الرمز دائمًا.')
        fact('الكيمياء: هوية العناصر',f'العدد الذري لـ{name} هو {z}.',f'العدد الذري لـ{name} هو {z+1}.',[source('elements')],ds,'العدد الذري عدد البروتونات، لا عدد النيوترونات أو العدد الكتلي.')
    for x in QURAN:
        i=int(x['index']);ayas=int(x['ayas']);name=x['name']
        ds=['easy','medium'] if i<=7 or i>=93 or i in [18,36,55,67] else ['medium','hard'] if i<=40 else ['hard','legendary']
        fact('القرآن: فهرس المصحف',f'سورة {name} تحمل الرقم {i} في ترتيب المصحف.',f'سورة {name} تحمل الرقم {i+1} في ترتيب المصحف.',[source('quran')],ds,'استخدم ترتيب المصحف، فترتيب النزول غير مطلوب.')
        fact('القرآن: عد الآيات',f'سورة {name} تضم {ayas} آية بالعد الكوفي في مصحف حفص.',f'سورة {name} تضم {ayas+1} آية بالعد الكوفي في مصحف حفص.',[source('quran')],ds,'ثبّت رواية المصحف ونظام العد؛ لا تستنتج عدد الآيات من رقم السورة.')
    for prop,(unit,vals) in PVALUES.items():
        for name,v in zip(PLANETS,vals):
            ds=['easy','medium'] if prop in ['القطر الاستوائي','فترة المدار حول الشمس','متوسط البعد عن الشمس'] else ['medium','hard','legendary']
            # Perturb a final digit for precise high-level false counterparts.
            step=Decimal('1') if Decimal(str(v))==int(v) else Decimal('0.1') if Decimal(str(v))*10==int(Decimal(str(v))*10) else Decimal('.001')
            fact('الفلك: '+prop,f'القيمة المدرجة لـ«{prop}» للكوكب {name} هي {fmt(v)} {unit} في جدول ناسا المحدث 18 مارس 2025.',f'القيمة المدرجة لـ«{prop}» للكوكب {name} هي {fmt(Decimal(str(v))+step*3)} {unit} في جدول ناسا المحدث 18 مارس 2025.',[source('planets')],ds,'انتبه للخاصية ووحدتها؛ اليوم الشمسي وفترة الدوران ليسا الشيء نفسه.')
    for key,(title,names) in BOOKS.items():
        for i,n in enumerate(names,1):
            fact('الأدب: فهرس '+title,f'«{n}» هو العنصر رقم {i} في فهرس «{title}» المشار إليه، بعد الاستثناءات المذكورة في العنوان.',f'«{n}» هو العنصر رقم {i+1} في فهرس «{title}» المشار إليه، بعد الاستثناءات المذكورة في العنوان.',[source(key,'Contents')],['medium','hard','legendary'],'راجع فهرس الطبعة المحددة؛ ترتيب النشر الخارجي ليس ترتيب الكتاب.')
    for cat in CAT_AR:
        for n,y in nobel_rows(cat):
            ar=CAT_AR[cat]
            known=n in NAME_AR.values()
            ds=['medium','hard'] if known else ['hard','legendary']
            title='جائزة بنك السويد في العلوم الاقتصادية في ذكرى ألفرد نوبل' if cat=='Economic Sciences' else 'نوبل في '+ar
            fact('تاريخ الجوائز: '+ar,f'حصل {n} على {title} لسنة {y}.',f'حصل {n} على {title} لسنة {y+1}.',[source('nobel')],ds,'سنة الجائزة تختلف أحيانًا عن سنة الحفل؛ المطلوب سنة الجائزة.')
    for n,y in ROYALS:
        fact('التاريخ: بدايات الحكم البريطاني',f'بدأت أول فترة حكم لـ{n} سنة {y} وفق فهرس الأسرة الملكية.',f'بدأت أول فترة حكم لـ{n} سنة {y+1} وفق فهرس الأسرة الملكية.',[source('royal')],['medium','hard','legendary'],'رقم الاسم الملكي جزء من هويته؛ المطلوب بدء الحكم الأول.')
    for n,s,e in PREFIXES:
        fact('القياس: بادئات SI',f'بادئة {n} رمزها {s} وعاملها 10^{e}.',f'بادئة {n} رمزها {s} وعاملها 10^{e+1}.',[source('si','Table 7')],['easy','medium'] if abs(e)<=9 else ['hard','legendary'],'بادئات SI قوى للعدد عشرة وليست قوى للعدد اثنين.')
    for g in NUM:
        if g['sources']==[ORIGINAL]:
            for row in g['rows']:
                n,v=row
                fact('الرياضيات والتعريفات: '+g['topic'],numeric_statement(g,row)+'.',numeric_statement(g,(n,Decimal(str(v))+1))+'.',g['sources'],[g['d']],g['hint'],g['note'] or 'الأسماء العددية للمضلعات تصرح بعدد أضلاعها.')
    literary=[
      ('alice','راوي «أليس في بلاد العجائب» يصف أليس بأنها تتبع أرنبًا أبيض في الفصل الأول.','تتبع أليس غرابًا أسود في الفصل الأول.','easy'),
      ('alice','الأرنب الأبيض يحمل ساعة في مشهد البداية.','الأرنب الأبيض يحمل بوصلة في مشهد البداية.','easy'),
      ('alice','تجلس أليس مع أختها عند بداية الرواية.','تجلس أليس مع ابنها عند بداية الرواية.','easy'),
      ('alice','الكتاب الذي تقرؤه أخت أليس لا يحتوي صورًا أو حوارًا في وصف البداية.','الكتاب الذي تقرؤه أخت أليس مليء بالصور في وصف البداية.','medium'),
      ('alice','الجرة التي تحمل كتابة مربى البرتقال فارغة عندما تتناولها أليس.','الجرة التي تحمل كتابة مربى البرتقال ممتلئة عندما تتناولها أليس.','medium'),
      ('looking_glass','بداية «عبر المرآة» تذكر قطيطة سوداء وأخرى بيضاء.','بداية «عبر المرآة» تذكر قطيطة حمراء وأخرى زرقاء.','easy'),
      ('looking_glass','اسم القطة الأم في بداية «عبر المرآة» هو دينا.','اسم القطة الأم في بداية «عبر المرآة» هو مولي.','medium'),
      ('oz','تعيش دوروثي في كانساس عند بداية «ساحر أوز العجيب».','تعيش دوروثي في فلوريدا عند بداية «ساحر أوز العجيب».','easy'),
      ('oz','عم دوروثي في «ساحر أوز العجيب» اسمه هنري.','عم دوروثي في «ساحر أوز العجيب» اسمه جون.','easy'),
      ('oz','عمة دوروثي في «ساحر أوز العجيب» تدعى إِم.','عمة دوروثي في «ساحر أوز العجيب» تدعى ماري.','easy'),
      ('oz','المأوى تحت بيت دوروثي مخصص للأعاصير في الفصل الأول.','المأوى تحت بيت دوروثي مخصص لتخزين السفن في الفصل الأول.','easy'),
      ('jungle','ماوكلي طفل بشري بين الذئاب في «كتاب الأدغال».','ماوكلي نمر بالغ بين الذئاب في «كتاب الأدغال».','easy'),
      ('jungle','شيري خان نمر في «كتاب الأدغال».','شيري خان دب في «كتاب الأدغال».','easy'),
      ('jungle','تاباكي ابن آوى في «إخوة ماوكلي».','تاباكي غزال في «إخوة ماوكلي».','medium'),
      ('jungle','تصف أم الذئاب شيري خان بأنه أعرج منذ ولادته.','تصف أم الذئاب شيري خان بأنه ولد بلا أسنان.','medium'),
      ('sherlock_adventures','راوي قصة «فضيحة في بوهيميا» هو الدكتور واتسون.','راوي قصة «فضيحة في بوهيميا» هو المفتش ليستراد.','easy'),
      ('sherlock_adventures','يشير هولمز في افتتاح «فضيحة في بوهيميا» إلى إيرين أدلر بأنها المرأة.','يشير هولمز في افتتاح «فضيحة في بوهيميا» إلى السيدة هدسون بأنها المرأة.','medium'),
      ('sherlock_return','تبدأ «البيت الخالي» بالإشارة إلى سنة 1894.','تبدأ «البيت الخالي» بالإشارة إلى سنة 1904.','hard'),
      ('sherlock_return','رونالد أدير في «البيت الخالي» هو الابن الثاني لإيرل ماينوث.','رونالد أدير في «البيت الخالي» هو الابن السابع لإيرل ماينوث.','legendary'),
    ]
    for key,t,f,d in literary:fact('الأدب: شخصيات ومشاهد',t,f,[source(key,'نص الفصل الأول')],[d,DIFF[min(3,DIFF.index(d)+1)]],'طابق الشخصية بالعمل والمشهد الأصلي، لا بالاقتباسات السينمائية.')
    broad=[
     ('الفلك: بنية النظام الشمسي','عطارد أقرب الكواكب الثمانية إلى الشمس.','نبتون أقرب الكواكب الثمانية إلى الشمس.','planet_sizes'),
     ('الفلك: بنية النظام الشمسي','المشتري أكبر الكواكب الثمانية قطرًا استوائيًا.','الأرض أكبر الكواكب الثمانية قطرًا استوائيًا.','planet_sizes'),
     ('الفلك: بنية النظام الشمسي','زحل يملك نظام حلقات.','زحل لا يملك أي نظام حلقات.','planets'),
     ('الفلك: بنية النظام الشمسي','المريخ يقع بين الأرض والمشتري في ترتيب الكواكب عن الشمس.','المريخ يقع بين زحل وأورانوس في ترتيب الكواكب عن الشمس.','planet_sizes'),
     ('الفلك: بنية النظام الشمسي','الزهرة هو الكوكب الثاني من الشمس.','الزهرة هو الكوكب السادس من الشمس.','planet_sizes'),
     ('الفلك: بنية النظام الشمسي','سيريس هو أقرب الكواكب القزمة الخمسة المذكورة في صفحة ناسا إلى الشمس.','إيريس هو أقرب الكواكب القزمة الخمسة المذكورة في صفحة ناسا إلى الشمس.','planet_sizes'),
     ('الفلك: بنية النظام الشمسي','بلوتو أكبر قليلًا من إيريس بالقطر في صفحة ناسا المؤرخة 22 أبريل 2025.','إيريس أكبر قليلًا من بلوتو بالقطر في صفحة ناسا المؤرخة 22 أبريل 2025.','planet_sizes'),
     ('تقنية الفضاء: برنامج المكوك','بدأت أول رحلة مدارية للمكوك في 12 أبريل 1981.','بدأت أول رحلة مدارية للمكوك في 12 أبريل 1971.','shuttles'),
     ('تقنية الفضاء: برنامج المكوك','المكوك الذي نفذ STS-1 هو كولومبيا.','المكوك الذي نفذ STS-1 هو إنديفور.','shuttles'),
     ('تقنية الفضاء: برنامج المكوك','أتلانتس نفذ المهمة الختامية STS-135.','ديسكفري نفذ المهمة الختامية STS-135.','shuttles'),
     ('تقنية الفضاء: برنامج المكوك','انتهت آخر مهمة للمكوك بهبوط 21 يوليو 2011.','انتهت آخر مهمة للمكوك بهبوط 21 يوليو 2001.','shuttles'),
     ('تقنية الفضاء: برنامج المكوك','بلغ عدد مهام برنامج المكوك المكتمل 135 مهمة.','بلغ عدد مهام برنامج المكوك المكتمل 153 مهمة.','shuttles'),
     ('تقنية الفضاء: برنامج المكوك','المهمة STS-6 كانت أول رحلة لتشالنجر.','المهمة STS-6 كانت أول رحلة لأتلانتس.','shuttles'),
     ('القياس: SI','الكيلو يشير إلى عامل 1000 في SI.','الكيلو يشير إلى عامل 1024 في SI.','si'),
     ('القياس: SI','رمز كيلو حرف k صغير.','رمز كيلو حرف K كبير.','si'),
     ('القياس: SI','يساوي الهكتار 10000 متر مربع.','يساوي الهكتار 1000 متر مربع.','si'),
     ('القياس: SI','يساوي اللتر ديسيمترًا مكعبًا.','يساوي اللتر سنتيمترًا مكعبًا.','si'),
     ('القياس: SI','يساوي الميل البحري 1852 مترًا.','يساوي الميل البحري 1609 مترًا.','si'),
     ('القياس: SI','يساوي الطن المتري 1000 كيلوغرام.','يساوي الطن المتري 100 كيلوغرام.','si'),
     ('القياس: SI','الميكرو والميغا بادئتان مختلفتان ورمزاهما µ وM.','الميكرو والميغا لهما الرمز M نفسه.','si'),
     ('الاتصالات: OSI','في OSI الطبقة الفيزيائية هي الأولى.','في OSI الطبقة الفيزيائية هي السابعة.','osi'),
     ('الاتصالات: OSI','في OSI طبقة النقل هي الرابعة.','في OSI طبقة النقل هي الثالثة.','osi'),
     ('الاتصالات: OSI','في OSI طبقة الشبكة هي الثالثة.','في OSI طبقة الشبكة هي الخامسة.','osi'),
     ('الاتصالات: OSI','في OSI طبقة التطبيق هي السابعة.','في OSI طبقة التطبيق هي السادسة.','osi'),
     ('الاتصالات: OSI','في OSI تقع طبقة العرض فوق طبقة الجلسة.','في OSI تقع طبقة العرض تحت الطبقة الفيزيائية.','osi'),
     ('الأحياء: مراتب التصنيف','الفصيلة أعم من الجنس في مراتب التصنيف المذكورة.','الجنس أعم من الفصيلة في مراتب التصنيف المذكورة.','biology'),
     ('الأحياء: مراتب التصنيف','الاسم العلمي الثنائي يجمع الجنس والنوع.','الاسم العلمي الثنائي يجمع المملكة والشعبة.','biology'),
     ('الأحياء: مراتب التصنيف','الرتبة تأتي بين الطائفة والفصيلة في التصنيف.','الرتبة تأتي بين الجنس والنوع في التصنيف.','biology'),
     ('الأحياء: مراتب التصنيف','Canidae اسم فصيلة الكلب في مثال OpenStax.','Canidae اسم نطاق الكلب في مثال OpenStax.','biology'),
     ('الأحياء: مراتب التصنيف','Mammalia اسم طائفة الكلب في مثال OpenStax.','Mammalia اسم جنس الكلب في مثال OpenStax.','biology'),
    ]
    for topic,t,f,s in broad:fact(topic,t,f,[source(s)],['easy','medium','hard'],'ثبّت نظام التصنيف أو الوحدة أو البرنامج المذكور؛ تشابه الأسماء لا يكفي.')
    for title,names in GEO.items():
        nn=names.split('|')
        for i in range(len(nn)-1):
            a,b=nn[i:i+2]
            fact('الجيولوجيا: '+title,f'في {title}، {a} أقدم من {b} وفق مخطط ديسمبر 2024.',f'في {title}، {a} أحدث من {b} وفق مخطط ديسمبر 2024.',[source('stratigraphy')],['hard','legendary'],'قارن زمنين من الرتبة نفسها؛ أقدم يعني أبعد عن الحاضر.')

def one_wrong():
    seed_facts()
    bytopic=defaultdict(list)
    for f in FACTS:bytopic[f['topic']].append(f)
    seen=set();usedbad=Counter();topicuse=Counter()
    for d in DIFF:
        count=4 if d in ['easy','medium'] else 5
        groups={t:[f for f in ff if d in f['ds']] for t,ff in bytopic.items()}
        groups={t:ff for t,ff in groups.items() if len(ff)>=count}
        while sum(q['difficulty']==d for q in BANK['one_wrong'])<75:
            # Spread themes, without using identical false statements twice.
            candidate=sorted(groups,key=lambda t:(topicuse[(d,t)],RNG.random()))
            t=candidate[0];pool=groups[t]
            ff=RNG.sample(pool,count)
            allowed=[i for i,f in enumerate(ff) if usedbad[f['false']]==0]
            if not allowed:
                # This topic is exhausted as a source of new errors at this level.
                del groups[t]
                assert groups
                continue
            bad=RNG.choice(allowed)
            sig=tuple(sorted(f['truth'] for f in ff))
            if sig in seen:continue
            seen.add(sig);usedbad[ff[bad]['false']]+=1;topicuse[(d,t)]+=1
            displayed=[f['truth'] if i!=bad else f['false'] for i,f in enumerate(ff)]
            answer=f'العبارة {bad+1} خاطئة؛ الصحيح: {ff[bad]["truth"]}'
            opts=[answer]
            for i,f in enumerate(ff):
                if i!=bad:opts.append(f'العبارة {i+1} خاطئة؛ الصحيح: {f["false"]}')
            # Complete distractors assert false corrections for another true statement.
            for i,f in enumerate(ff):
                if i!=bad:
                    opts.append(f'العبارة {i+1} خاطئة؛ التصحيح المقترح: {ff[bad]["truth"]}')
                    if len(opts)==6:break
            sources=list(dict.fromkeys(s for f in ff for s in f['sources']))
            evidence=' '.join(f'العبارة {i+1}: '+('خاطئة؛ '+f['truth'] if i==bad else 'صحيحة؛ '+f['truth'])+(' '+f['proof'] if f['proof'] else '') for i,f in enumerate(ff))
            add('one_wrong',d,f'خطأ واحد فقط في موضوع «{t}». العبارات المعروضة مستقلة في الحكم؛ حدّد العبارة الخاطئة وصححها.',answer,opts,ff[bad]['hint'],evidence,sources,presentation('statements',displayed),checks={'mode':'one_wrong','topic':t,'badIndex':bad,'truths':[f['truth'] for f in ff],'shown':displayed})

def save(cat):
    q=BANK[cat]
    obj={'schemaVersion':1,'categoryId':cat,'targetCount':300,'targetPerDifficulty':75,'status':'draft','questions':q}
    (BASE/(cat+'.json')).write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(cat, len(q),Counter(x['difficulty'] for x in q),flush=True)

def validate():
    allq=[q for cat in BANK.values() for q in cat]
    assert len(allq)==1200
    ids=[q['id'] for q in allq];assert len(set(ids))==len(ids)
    textkeys=[]
    for cat,qq in BANK.items():
        assert len(qq)==300 and Counter(q['difficulty'] for q in qq)==Counter({d:75 for d in DIFF})
        for q in qq:
            assert len(q['options'])==6 and [o['id'] for o in q['options']]==LETTERS
            assert len(set(o['text'] for o in q['options']))==6
            assert next(o['text'] for o in q['options'] if o['id']==q['correctOptionId'])==q['answer']
            assert all(q[k] for k in ['text','answer','hint','explanation','sources'])
            assert q['qualityStatus']=='unreviewed' and q['clues']==[]
            pp=q.get('presentation')
            if pp:
                ss=pp['sections'];assert 1<=len(ss)<=2
                its=[x for s in ss for x in s['items']]
                assert len({x['id'] for x in its})==len(its)
                for s in ss:assert 1<=len(s['items'])<=8
                for x in its:assert x['text'] and (not x.get('missing') or x['text']=='؟')
                if pp['type']=='statements':assert len(its) in [4,5]
                if pp['type']=='sequence':assert len([x for x in its if x.get('missing')])==1
                if pp['type']=='matching':assert len(ss)==2 and len(ss[0]['items'])==len(ss[1]['items'])
            textkeys.append(q['text']+'|'+json.dumps(q.get('presentation'),ensure_ascii=False,sort_keys=True))
    assert len(set(textkeys))==1200,Counter(textkeys).most_common(2)
    for d in DIFF:assert Counter(q['subtype'] for q in BANK['numbers'] if q['difficulty']==d)==Counter({s:15 for s in ['number_owner','number_wrong','number_nearest','number_matching','number_ordering']})
    # Independent enumeration verifies the authored mathematical tables.
    mathematical={g['key']:g for g in NUM if g['sources']==[ORIGINAL]}
    polygon_sides={'مثلث':3,'رباعي':4,'خماسي':5,'سداسي':6,'سباعي':7,'ثماني':8,'عشاري':10}
    for n,v in mathematical['easy_polygons']['rows']:assert polygon_sides[n]==v
    for n,v in mathematical['easy_diagonals']['rows']:
        k=polygon_sides[n]
        diagonals={tuple(sorted((a,b))) for a in range(k) for b in range(k) if a!=b and (a-b)%k not in [1,k-1]}
        assert len(diagonals)==v
    for n,v in mathematical['medium_angle_sum']['rows']:
        assert sum(180 for _ in range(1,polygon_sides[n]-1))==v
    for n,v in mathematical['medium_pairs']['rows']:
        k=int(n.split()[0]);assert len(list(combinations(range(k),2)))==v
    for n,v in mathematical['hard_factorial']['rows']:
        k=int(n.split()[0]);assert sum(1 for _ in permutations(range(k)))==v
    # The calendars are read directly from the released primary CLDR file.
    cldr=ET.parse(SRC/'cldr_ar.raw')
    for calendar,expected in [('gregorian',MONTHS),('islamic',HIJRI)]:
        actual=cldr.findall(f'./dates/calendars/calendar[@type="{calendar}"]/months/monthContext[@type="format"]/monthWidth[@type="wide"]/month')
        assert [(int(x.get('type')),x.text) for x in actual]==list(enumerate(expected,1))
    assert list(map(ord,ALPHABET))==sorted(map(ord,ALPHABET)) and len(ALPHABET)==28
    for v in VERIFY:
        if v.get('mode')=='nearest':
            r=Decimal(v['reference']);ss=[Decimal(x) for x in v['estimates']];dist=[abs(x-r) for x in ss]
            assert len(set(ss))==6 and dist.count(min(dist))==1 and min(dist)>0
        if v.get('mode')=='wrong':assert Decimal(v['wrongValue'])!=Decimal(v['actualValue'])
        if v.get('mode')=='one_wrong':assert sum(a!=b for a,b in zip(v['truths'],v['shown']))==1
        if v.get('mode')=='ordering':assert [Decimal(str(x[1])) for x in v['ordered']]==sorted(Decimal(str(x[1])) for x in v['rows'])
    (BASE/'ordered_numeric_checks.json').write_text(json.dumps(VERIFY,ensure_ascii=False,indent=2),encoding='utf-8')
    (BASE/'ordered_numeric_corpora.json').write_text(json.dumps({'orderedCorpora':CORP,'numericGroups':NUM},ensure_ascii=False,indent=2),encoding='utf-8')
    report={'count':1200,'categories':{},'sourceCorpora':len(CORP),'numericThemes':len(NUM),'truthFacts':len(FACTS),'qualityStatus':'all unreviewed','limitations':['فحص البنية والحساب لا يعادل مراجعة تحريرية مستقلة لجميع الأسئلة.','النصوص الأجنبية للأسماء أو الأعمار الجيولوجية تبقى كما في المصدر عند غياب تعريب شائع.','توجد مجموعات متعددة من corpus واحد؛ يلزم تدقيق التكرار المعنوي وصعوبة المجموعات قبل اعتماد reviewed.','الفهارس الأدبية هي للطبعات المرتبطة تحديدًا، وتستخدم ترجمة وصفية للعناوين.','تنزيل ينشر البيانات المصدرية للمصحف؛ هو مصدر نصي أولي للنسخة الرقمية، لا بحث أولي في علوم القرآن.']}
    for cat,qq in BANK.items():
        report['categories'][cat]={'count':len(qq),'difficulties':dict(Counter(q['difficulty'] for q in qq)),'correctOptions':dict(Counter(q['correctOptionId'] for q in qq)),'subtypes':dict(Counter(q.get('subtype') for q in qq)) if cat=='numbers' else None,'sourceDomains':dict(Counter(q['sources'][0].split('/')[2] if q['sources'][0].startswith('http') else 'original-proof' for q in qq))}
    (BASE/'ORDERED_NUMERIC_AUTHORING_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(report,ensure_ascii=False,indent=2))

if __name__=='__main__':
    first_last();save('first_last')
    complete_sequence();save('complete_sequence')
    numbers();save('numbers')
    one_wrong();save('one_wrong')
    validate()
