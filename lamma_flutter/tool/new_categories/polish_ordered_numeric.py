"""Polish the saved draft in place, retaining IDs and subtype quotas.
Run after author_ordered_numeric.py; no production assets are touched.
"""
from pathlib import Path
from collections import Counter
import json,re,random,sys
sys.path.insert(0,str(Path(__file__).parent))
import author_ordered_numeric as author

BASE=Path(__file__).parent
RNG=random.Random(411130)
CATS=['first_last','complete_sequence','numbers','one_wrong']
DOCS={c:json.loads((BASE/(c+'.json')).read_text(encoding='utf-8')) for c in CATS}
CHECKS=json.loads((BASE/'ordered_numeric_checks.json').read_text(encoding='utf-8'))
CHECKMAP={x['id']:x for x in CHECKS}
CORP={x['key']:x for x in author.CORP}
DIFF=author.DIFF
CHANGES=[]

# Conventional Arabic forms or straightforward personal-name transliterations.
# These are names, not invented translations of their meanings.
AR={
 'Albert Szent-Györgyi':'ألبرت سنت جيورجي','Albrecht Kossel':'ألبرشت كوسل','Alphonse Laveran':'ألفونس لافيران',
 'Allvar Gullstrand':'ألفار غولستراند','Alexis Carrel':'ألكسيس كاريل','Charles Richet':'شارل ريشيه',
 'Arthur Henderson':'آرثر هندرسون','August Krogh':'أوغست كروغ','Willem Einthoven':'فيلم أينتهوفن',
 'Karl Landsteiner':'كارل لاندشتاينر','Thomas H. Morgan':'توماس هانت مورغان','Camilo José Cela':'كاميلو خوسيه ثيلا',
 'Carl Spitteler':'كارل شبيتلر','Carlos Saavedra Lamas':'كارلوس سافيدرا لاماس','Claude Simon':'كلود سيمون',
 'Daniel Bovet':'دانيال بوفيه','Franco Modigliani':'فرانكو موديلياني','Frans Eemil Sillanpää':'فرانس إيميل سيلانبا',
 'Frederick Soddy':'فريدريك سودي','George de Hevesy':'جورج دي هيفيشي','Giosuè Carducci':'جوزويه كاردوتشي',
 'Günter Blobel':'غونتر بلوبل','Herbert Simon':'هربرت سايمون','Isidor Isaac Rabi':'إيزيدور إسحاق رابي',
 'Ivan Bunin':'إيفان بونين','Pearl Buck':'بيرل باك','Johannes V. Jensen':'يوهانس فيلهلم ينسن',
 'Johannes Fibiger':'يوهانس فيبيغر','Lawrence R. Klein':'لورنس كلاين','Maurice Maeterlinck':'موريس ميترلينك',
 'Patrick Modiano':'باتريك موديانو','Paul Müller':'باول مولر','Permanent International Peace Bureau':'المكتب الدولي الدائم للسلام',
 'René Cassin':'رينيه كاسان','Richard H. Thaler':'ريتشارد ثالر','Roger Martin du Gard':'روجيه مارتان دو غار',
 'Stanley B. Prusiner':'ستانلي بروسينر','The Svedberg':'تيودور سفيدبرغ','Vincent du Vigneaud':'فنسنت دو فينيو',
 'Walther Nernst':'فالتر نرنست','Wilhelm Wien':'فيلهلم فين','Wole Soyinka':'وولي سوينكا',
 'Yasunari Kawabata':'ياسوناري كاواباتا','Yoshinori Ohsumi':'يوشينوري أوسومي',
 'Gustaf Dalén':'غوستاف دالين','Heike Kamerlingh Onnes':'هايكه كامرلينغ أونيس','Max von Laue':'ماكس فون لاوه',
 'William Bragg':'وليام براغ','Lawrence Bragg':'لورنس براغ','Charles Glover Barkla':'تشارلز غلوفر باركلا',
 'Friedrich von Hayek':'فريدريش فون هايك','Gunnar Myrdal':'غونار ميردال','Wassily Leontief':'فاسيلي ليونتيف',
 'Robert M. Solow':'روبرت سولو','James Tobin':'جيمس توبن','Theodore W. Schultz':'ثيودور شولتز','Sir Arthur Lewis':'آرثر لويس',
 'Anatole France':'أناتول فرانس','André Gide':'أندريه جيد','Boris Pasternak':'بوريس باسترناك','Bertrand Russell':'برتراند راسل',
 'John Galsworthy':'جون غالزورثي','Luigi Pirandello':'لويجي بيرانديللو','Eugene O\'Neill':'يوجين أونيل',
 'Frédéric Mistral':'فريدريك ميسترال','José Echegaray':'خوسيه إتشيغاراي','Paul Heyse':'باول هايزه',
 'Romain Rolland':'رومان رولان','Grazia Deledda':'غراتسيا ديليدا','Knut Hamsun':'كنوت هامسون',
 'William Butler Yeats':'وليام بتلر ييتس','Henri Bergson':'هنري برغسون','Gerhart Hauptmann':'غيرهارت هاوبتمان',
 'Henryk Sienkiewicz':'هنريك سينكيفيتش','Bjornstjerne Bjornson':'بيورنستيارنه بيورنسون','Bjørnstjerne Bjørnson':'بيورنستيارنه بيورنسون',
 'Jacinto Benavente':'خاثينتو بينافينتي','Verner von Heidenstam':'فيرنر فون هايدنستام','Karl Gjellerup':'كارل غيلروب',
 'Henrik Pontoppidan':'هنريك بونتوبيدان','Sir William Ramsay':'وليام رامزي','Albert A. Michelson':'ألبرت ميكلسون',
 'Sir Chandrasekhara Venkata Raman':'تشاندراسيخارا فنكاتا رامان','Hendrik A. Lorentz':'هندريك لورنتس','Pieter Zeeman':'بيتر زيمان',
 'Johannes Diderik van der Waals':'يوهانس ديديريك فان دير فالس','Lord Rayleigh':'اللورد رايلي','Philipp Lenard':'فيليب لينارد',
 'Gabriel Lippmann':'غابرييل ليبمان','Charles Edouard Guillaume':'شارل إدوار غيوم','Johannes Stark':'يوهانس شتارك',
 'Paul A.M. Dirac':'بول ديراك','Otto Stern':'أوتو شتيرن','Wolfgang Pauli':'فولفغانغ باولي','Max Born':'ماكس بورن',
 'Emil von Behring':'إميل فون بهرنغ','Ronald Ross':'رونالد روس','Niels Ryberg Finsen':'نيلز ريبرغ فينسن',
 'Theodor Kocher':'تيودور كوخر','Otto Warburg':'أوتو فاربورغ','Earl W. Sutherland, Jr.':'إيرل سذرلاند الابن',
 'Artturi Virtanen':'أرتوري فيرتانن','Adolf Windaus':'أدولف فينداوس','Adolf Butenandt':'أدولف بوتناندت',
 'Wilhelm Ostwald':'فيلهلم أوستفالد','Otto Wallach':'أوتو فالاخ','Henri Moissan':'هنري مواسان','Eduard Buchner':'إدوارد بوخنر',
 'Alfred Werner':'ألفرد فيرنر','Theodore W. Richards':'ثيودور ريتشاردز','Richard Willstätter':'ريتشارد فيلشتاتر',
 'Fritz Pregl':'فريتز بريغل','Francis W. Aston':'فرانسيس أستون','Victor Grignard':'فيكتور غرينيارد','Paul Sabatier':'باول ساباتييه',
 'Doctors Without Borders':'أطباء بلا حدود','International Labour Organization':'منظمة العمل الدولية',
 'United Nations Children\'s Fund':'منظمة الأمم المتحدة للطفولة (اليونيسف)','International Atomic Energy Agency':'الوكالة الدولية للطاقة الذرية',
 'United Nations Peacekeeping Forces':'قوات حفظ السلام التابعة للأمم المتحدة','Amnesty International':'منظمة العفو الدولية',
 'Grameen Bank':'بنك غرامين','National Dialogue Quartet':'الرباعي الراعي للحوار الوطني التونسي',
 'Office of the United Nations High Commissioner for Refugees':'مفوضية الأمم المتحدة السامية لشؤون اللاجئين',
 'The 14th Dalai Lama':'الدالاي لاما الرابع عشر','Mohamed ElBaradei':'محمد البرادعي','Tawakkol Karman':'توكل كرمان',
 'Mikhail Gorbachev':'ميخائيل غورباتشوف','Fridtjof Nansen':'فريتيوف نانسن','Dag Hammarskjöld':'داغ همرشولد',
 'Willy Brandt':'فيلي برانت','Lech Wałęsa':'ليخ فاونسا','Shirin Ebadi':'شيرين عبادي','Elie Wiesel':'إيلي فيزل',
 'Aung San Suu Kyi':'أونغ سان سو تشي','Oscar Arias Sánchez':'أوسكار آرياس سانشيز','Martti Ahtisaari':'مارتي أهتيساري',
 'Herta Müller':'هيرتا مولر','Günter Grass':'غونتر غراس','Heinrich Böll':'هاينريش بول','Saul Bellow':'سول بيلو',
 'Isaac Bashevis Singer':'إسحاق باشفيس سنغر','Octavio Paz':'أوكتافيو باث','José Saramago':'جوزيه ساراماغو',
 'Mario Vargas Llosa':'ماريو فارغاس يوسا','Alice Munro':'أليس مونرو','Nadine Gordimer':'نادين غورديمر',
 'Dario Fo':'داريو فو','Harold Pinter':'هارولد بنتر','Patrick Modiano':'باتريك موديانو','Olga Tokarczuk':'أولغا توكارتشوك',
 'Gao Xingjian':'غاو شينغجيان','Mo Yan':'مو يان','Jon Fosse':'يون فوسه','Svetlana Alexievich':'سفيتلانا أليكسييفيتش',
 'Elias Canetti':'إلياس كانيتي','Gabriela Mistral':'غابرييلا ميسترال','William Golding':'وليام غولدنغ',
 'Imre Kertész':'إيمري كيرتيس','Czesław Miłosz':'تشيسواف ميووش','Jaroslav Seifert':'ياروسلاف سايفرت',
}
AR.update(author.NAME_AR)

def replace(s):
    if not isinstance(s,str):return s
    for en,ar in sorted(AR.items(),key=lambda kv:-len(kv[0])):s=s.replace(en,ar)
    s=re.sub(r'(-?\d+(?:\.\d+)?)\s+10\^24 كغ',r'\1 ×10²⁴ كغ',s)
    return s.replace('لـال','لل').replace('لـإ','لإ').replace('لـع','لع').replace('لـن','لن')

def walk(value):
    if isinstance(value,str):return replace(value)
    if isinstance(value,list):return [walk(x) for x in value]
    if isinstance(value,dict):return {k:walk(v) if k not in ['id','categoryId','correctOptionId','subtype','qualityStatus','sources','acceptedAnswers'] else v for k,v in value.items()}
    return value

def short_rule(c):
    rule=c['rule']
    rule=rule.replace('العناصر بزيادة العدد الذري','العناصر بحسب زيادة العدد الذري')
    rule=rule.replace('بزيادة سنة الجائزة','بحسب سنة الجائزة')
    rule=rule.replace('ترتيب الفهرس الأصلي لكتاب','ترتيب فهرس كتاب')
    rule=rule.replace(' في النسخة المحددة من غوتنبرغ؛ العناوين العربية ترجمة وصفية','؛ الطبعة محددة في المصدر')
    rule=rule.replace('بحسب جدول ناسا المحدث في 18 مارس 2025','وفق جدول ناسا، 18 مارس 2025')
    rule=rule.replace('الفائزون بجائزة بنك السويد في العلوم الاقتصادية في ذكرى ألفرد نوبل','الفائزون بجائزة بنك السويد للاقتصاد في ذكرى نوبل')
    rule=rule.replace('، مع حذف السنوات التي لم تمنح فيها الجائزة وذكر كل الفائزين بالسنة','؛ السنوات التي لم تُمنح فيها الجائزة مستبعدة، والفائزون المشتركون مجموعة واحدة')
    rule=rule.replace('، بما فيها الفئة f في موضعها من زيادة العدد الذري','؛ تشمل عناصر الفئة f بحسب العدد الذري')
    return rule

def owner(g,value):
    k=g['key'];v=author.fmt(value);note=g['note'];topic=g['topic'];unit=g['unit']
    if 'sura_length' in k: return f'أي سورة تضم {v} آية بالعد الكوفي في مصحف حفص؟'
    if 'sura_position' in k:return f'ما السورة التي تحمل الرقم {v} في ترتيب المصحف؟'
    if 'atomic' in k or k in ['legendary_lanthanides','legendary_actinides','legendary_synthetic']:return f'ما العنصر ذو العدد الذري {v}؟'
    if k=='easy_month':return f'ما الشهر رقم {v} في السنة الميلادية التي تبدأ بيناير؟'
    if k=='easy_hijri':return f'ما الشهر رقم {v} في السنة الهجرية التي تبدأ بمحرم؟'
    if k=='easy_letters':return f'ما الحرف رقم {v} في الترتيب الهجائي للحروف العربية الثمانية والعشرين، دون الهمزة؟'
    if k=='easy_polygons':return f'ما المضلع الذي له {v} أضلاع؟'
    if k=='easy_diagonals':return f'أي مضلع محدب له {v} أقطار، مع استبعاد الأضلاع؟'
    if k=='medium_angle_sum':return f'في أي مضلع محدب مسطح يبلغ مجموع الزوايا الداخلية {v} درجة؟'
    if k=='medium_pairs':return f'أي عدد من الفرق ينتج دوريًا من دور واحد فيه {v} مباراة، إذا تقابل كل فريقين مرة واحدة؟'
    if k=='hard_factorial':return f'أي عدد من الكتب المختلفة يعطي {v} ترتيبًا ممكنًا على رف خطي؟'
    if k=='easy_seconds':return f'أي مدة معروضة تساوي {v} ثانية؟ اليوم هنا 24 ساعة.'
    if k=='easy_length_units':return f'أي وحدة طول معروضة تساوي {v} مترًا؟'
    if k=='medium_area_units':return f'أي وحدة مساحة معروضة تساوي {v} متر مربع؟'
    if 'prefix_exp' in k or k=='legendary_small_prefix':return f'ما بادئة SI التي عاملها 10^{v}، وفق البادئات المعتمدة حتى قرار 2022؟'
    if 'nobel' in k or k in ['legendary_physics','legendary_chemistry','legendary_literature','legendary_medicine','legendary_economics']:
        award=re.sub(r'^سنة (?:جائزة )?','',topic)
        award=re.split(r' (?:لمنفردين|لهؤلاء|للأسماء)',award)[0]
        return f'من فاز بجائزة {award} لسنة {v}؟'
    if k=='medium_royal_years':return f'من الحكام المعروضين بدأ أول فترة حكمه سنة {v} وفق فهرس الأسرة الملكية البريطانية؟'
    if k=='hard_eu_entry':return f'أي دولة معروضة انضمت سنة {v} إلى الاتحاد الأوروبي أو سلفه الجماعة الاقتصادية الأوروبية؟'
    if k=='legendary_geo_boundaries':return f'بدأت أي فترة جيولوجية معروضة قبل نحو {v} مليون سنة، وفق مخطط ICS لديسمبر 2024، مع إهمال عدم اليقين؟'
    if k=='legendary_constants_exponents':return f'أي ثابت SI معروض أسُّ عشرة في صيغته العلمية المعيارية هو {v}، بالوحدة المذكورة مع اسمه؟'
    prop=topic.replace(' للكواكب الثمانية','').replace('، وفق جدول ناسا','')
    if k=='hard_mass':return f'كتلة أي كوكب تبلغ {v} ×10²⁴ كغ في جدول ناسا المحدث 18 مارس 2025، بحسب تقريب الجدول؟'
    if k=='legendary_eccentricity':return f'اللامركزية المدارية لأي كوكب تبلغ {v} في جدول ناسا المحدث 18 مارس 2025، بحسب تقريب الجدول؟'
    if k=='legendary_temperature':return f'متوسط حرارة أي كوكب مدرج بقيمة {v} درجة مئوية في جدول ناسا المحدث 18 مارس 2025؟ للكواكب الغازية يُستخدم مستوى القياس المحدد في الجدول.'
    physical={
      'easy_planet_distance':f'أي كوكب يبلغ متوسط بعده عن الشمس نحو {v} مليون كم؟',
      'easy_planet_diameter':f'أي كوكب يبلغ قطره الاستوائي نحو {v} كم؟',
      'easy_planet_year':f'أي كوكب تستغرق دورته حول الشمس نحو {v} يومًا أرضيًا؟',
      'medium_density':f'كثافة أي كوكب تبلغ نحو {v} كغ/م³؟',
      'medium_escape':f'سرعة الإفلات من أي كوكب تبلغ نحو {v} كم/ث؟',
      'medium_spin':f'أي كوكب يستغرق دورانه النجمي حول محوره نحو {v} ساعة، مع تجاهل إشارة الدوران الرجعي؟',
      'medium_speed':f'أي كوكب يبلغ متوسط سرعته المدارية نحو {v} كم/ث؟',
      'hard_solar_day':f'أي كوكب يبلغ طول يومه الشمسي نحو {v} ساعة؟',
      'hard_perihelion':f'أي كوكب تبلغ مسافة حضيضه الشمسي نحو {v} مليون كم؟',
      'hard_aphelion':f'أي كوكب تبلغ مسافة أوجه الشمسي نحو {v} مليون كم؟',
      'hard_axial':f'أي كوكب يميل محور دورانه إلى مداره بنحو {v} درجة؟',
    }
    return physical[k]+' القيم من جدول ناسا المحدث 18 مارس 2025، بحسب تقريب الجدول.'

def remake(q,text,answer,opts,hint,exp,sources,pres):
    correct=q['correctOptionId'];other=[x for x in opts if x!=answer];RNG.shuffle(other)
    q.update(text=text,answer=answer,acceptedAnswers=[],hint=hint,explanation=exp,sources=sources,presentation=pres,qualityStatus='unreviewed')
    q['options']=[{'id':l,'text':answer if l==correct else other.pop()} for l in author.LETTERS]
    assert len(q['options'])==6 and len(set(o['text'] for o in q['options']))==6

def cultural_swaps():
    # Six first/last comparisons and six sequence gaps, all from the existing Quran/CLDR corpora.
    first=[q for q in DOCS['first_last']['questions'] if q['difficulty']=='easy' and CHECKMAP[q['id']]['corpus'] in ['osi','elements','planet_فترة المدار حول الشمس','planet_القطر الاستوائي','sun_order']][:6]
    selections=[([1,2,18],'quran'),([36,55,67],'quran'),([94,95,96],'quran'),([99,103,112],'quran'),([109,110,114],'quran'),([3,6,11],'months')]
    for q,(indices,key) in zip(first,selections):
        c=CORP[key];names=[c['names'][i-1] for i in indices];shown=names[::-1]
        ans=f'الأول: {names[0]}؛ الأخير: {names[-1]}'
        opts=[f'الأول: {a}؛ الأخير: {b}' for a,b in author.permutations(names,2)]
        remake(q,f'ضمن المعروض فقط، ما الأول وما الأخير بحسب {short_rule(c)}؟',ans,opts,c['hint'],'الترتيب الصحيح: '+' ← '.join(names)+'. '+ans+'.',c['sources'],author.presentation('comparison',shown))
        CHECKMAP[q['id']].update(corpus=key,orderedIndices=[i-1 for i in indices],displayIndices=[i-1 for i in indices[::-1]])
        CHANGES.append({'id':q['id'],'change':'science → cultural first/last'})
    seq=[q for q in DOCS['complete_sequence']['questions'] if q['difficulty']=='easy' and CHECKMAP[q['id']]['corpus'] in ['osi','elements','planet_فترة المدار حول الشمس','planet_القطر الاستوائي','sun_order']][:6]
    # Familiar consecutive groups with before/inside/after placements preserved.
    starts=[108,100,94,1,17,52]
    for q,start in zip(seq,starts):
        v=CHECKMAP[q['id']];gap=v['gap'];c=CORP['quran'];full=c['names'][start:start+4];ans=full[gap];shown=full[:];shown[gap]='؟'
        other=[n for n in c['names'] if n!=ans];opts=[ans]+RNG.sample(other,5)
        remake(q,'أكمل السورة الناقصة. السور متتابعة بحسب ترتيب المصحف، لا ترتيب النزول.',ans,opts,'تذكر السورة السابقة أو التالية في ترتيب المصحف.','السلسلة الكاملة: '+' ← '.join(full)+'.',c['sources'],author.presentation('sequence',shown))
        v.update(corpus='quran',start=start,length=4)
        CHANGES.append({'id':q['id'],'change':'science → cultural sequence'})
    # Twelve culturally familiar error blocks: independent character/work and calendar facts.
    true=[
      ('في بداية «ساحر أوز العجيب»، تعيش دوروثي في كانساس.','في بداية «ساحر أوز العجيب»، تعيش دوروثي في ألاسكا.','oz'),
      ('عم دوروثي في «ساحر أوز العجيب» يدعى هنري.','عم دوروثي في «ساحر أوز العجيب» يدعى وليام.','oz'),
      ('عمة دوروثي في «ساحر أوز العجيب» تدعى إِم.','عمة دوروثي في «ساحر أوز العجيب» تدعى أليس.','oz'),
      ('تتبع أليس أرنبًا أبيض في افتتاح «أليس في بلاد العجائب».','تتبع أليس قطة سوداء في افتتاح «أليس في بلاد العجائب».','alice'),
      ('الأرنب الأبيض يحمل ساعة في افتتاح «أليس في بلاد العجائب».','الأرنب الأبيض يحمل منظارًا في افتتاح «أليس في بلاد العجائب».','alice'),
      ('تجلس أليس مع أختها عند بداية «أليس في بلاد العجائب».','تجلس أليس مع جدها عند بداية «أليس في بلاد العجائب».','alice'),
      ('شيري خان نمر في «كتاب الأدغال».','شيري خان ذئب في «كتاب الأدغال».','jungle'),
      ('ماوكلي طفل بشري في «كتاب الأدغال».','ماوكلي دب صغير في «كتاب الأدغال».','jungle'),
      ('تاباكي ابن آوى في «إخوة ماوكلي».','تاباكي فهد في «إخوة ماوكلي».','jungle'),
      ('يناير هو الشهر الأول في السنة الميلادية.','يناير هو الشهر الثاني في السنة الميلادية.','cldr_ar'),
      ('رمضان هو الشهر التاسع في السنة الهجرية.','رمضان هو الشهر الثامن في السنة الهجرية.','cldr_ar'),
      ('ذو الحجة هو الشهر الثاني عشر في السنة الهجرية.','ذو الحجة هو الشهر الحادي عشر في السنة الهجرية.','cldr_ar'),
    ]
    qset=[q for q in DOCS['one_wrong']['questions'] if q['difficulty']=='easy' and q['text'].find('الفلك:')>=0][:12]
    for j,q in enumerate(qset):
        select=[j]+RNG.sample([i for i in range(12) if i!=j],3);RNG.shuffle(select);bad=select.index(j)
        ff=[true[i] for i in select];shown=[x[1] if i==bad else x[0] for i,x in enumerate(ff)]
        ans=f'العبارة {bad+1} خاطئة؛ الصحيح: {ff[bad][0]}'
        opts=[ans]+[f'العبارة {i+1} خاطئة؛ الصحيح: {x[1]}' for i,x in enumerate(ff) if i!=bad]
        for i,x in enumerate(ff):
            if i!=bad:opts.append(f'العبارة {i+1} خاطئة؛ التصحيح المقترح: {ff[bad][0]}')
            if len(opts)==6:break
        exp=' '.join(f'العبارة {i+1}: '+('خاطئة؛ الصحيح ' if i==bad else 'صحيحة؛ ')+x[0] for i,x in enumerate(ff))
        ss=list(dict.fromkeys(author.source(x[2]) for x in ff))
        remake(q,'خطأ واحد فقط: أي عبارة عن القصص المشهورة والتقويم تحتاج إلى تصحيح؟',ans,opts,'اربط الشخصيات بكتابها الأصلي، والأشهر بالتقويم المحدد.',exp,ss,author.presentation('statements',shown))
        CHECKMAP[q['id']].update(topic='ثقافة: شخصيات وتقويم',badIndex=bad,truths=[x[0] for x in ff],shown=shown)
        CHANGES.append({'id':q['id'],'change':'science → culture error block'})

def run():
    cultural_swaps()
    number_groups={g['key']:g for g in author.NUM}
    for i,q in enumerate(DOCS['numbers']['questions']):
        g=author.NUM[i//5];v=CHECKMAP[q['id']];mode=q['subtype']
        if mode=='number_owner':q['text']=owner(g,v['selected'][1])
        elif mode=='number_wrong':
            q['text']=f'أي عبارة تحتوي الرقم الخطأ؟ الموضوع: {g["topic"]}. {g["note"]}'
            rows=v['rows'];bad=v['badIndex'];wrong=v['wrongValue']
            q['presentation']=author.presentation('statements',[f'{n}: {wrong if j==bad else author.fmt(val)} {g["unit"]}' for j,(n,val) in enumerate(rows)])
        elif mode=='number_nearest':
            name=g['rows'][(list(author.NUM).index(g)+3)%len(g['rows'])][0]
            q['text']=f'أي تقدير معروض أقرب إلى قيمة «{name}» في {g["topic"]}؟ الوحدة: {g["unit"]}. {g["note"]}'
        elif mode=='number_matching':q['text']=f'طابق الأسماء بالأرقام: {g["topic"]}. استخدم كل رقم مرة واحدة. {g["note"]}'
        elif mode=='number_ordering':q['text']=f'رتّب المعروض تصاعديًا بحسب {g["topic"]} ({g["unit"]}). {g["note"]}'
        CHANGES.append({'id':q['id'],'change':'numeric phrasing'})
    for cat in ['first_last','complete_sequence']:
        for q in DOCS[cat]['questions']:
            if any(x['id']==q['id'] for x in CHANGES):continue
            v=CHECKMAP[q['id']];c=CORP[v['corpus']];rule=short_rule(c)
            if cat=='first_last':q['text']=f'ضمن المعروض فقط، ما الأول وما الأخير بحسب {rule}؟'
            else:
                placement='الأولى' if v['gap']==0 else 'الأخيرة' if v['gap']==v['length']-1 else 'الداخلية'
                q['text']=f'أكمل الخانة {placement}. القاعدة: {rule}. العناصر متتابعة دون قفز.'
            CHANGES.append({'id':q['id'],'change':'shorter ordering rule'})
    for cat,doc in DOCS.items():
        new=[]
        for q in doc['questions']:
            raw=q['answer'];translated=walk(q)
            if raw in AR:translated['acceptedAnswers']=list(dict.fromkeys(q.get('acceptedAnswers',[])+[raw]))
            # The English original is useful clarification for less common translated names.
            if cat=='complete_sequence' and raw in AR:
                translated['explanation']+=' الاسم في المصدر: '+raw+'.'
            translated['text']=re.sub(r'\s+',' ',translated['text']).strip()
            translated['answer']=re.sub(r'\s+',' ',translated['answer']).strip()
            for o in translated['options']:o['text']=re.sub(r'\s+',' ',o['text']).strip()
            assert next(o['text'] for o in translated['options'] if o['id']==translated['correctOptionId'])==translated['answer']
            assert len(set(o['text'] for o in translated['options']))==6
            new.append(translated)
        doc['questions']=new
        assert len(new)==300 and Counter(q['difficulty'] for q in new)==Counter({d:75 for d in DIFF})
        if cat=='numbers':
            for d in DIFF:assert Counter(q['subtype'] for q in new if q['difficulty']==d)==Counter({s:15 for s in ['number_owner','number_wrong','number_nearest','number_matching','number_ordering']})
        (BASE/(cat+'.json')).write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (BASE/'ordered_numeric_checks.json').write_text(json.dumps(CHECKS,ensure_ascii=False,indent=2),encoding='utf-8')
    (BASE/'ordered_numeric_final_polish.json').write_text(json.dumps({'changes':CHANGES,'nameMap':AR,'culturalReplacements':24,'count':1200},ensure_ascii=False,indent=2),encoding='utf-8')
    print('Polished 1200; cultural replacements 24; numeric subtypes and difficulty quotas preserved.')

if __name__=='__main__':run()
