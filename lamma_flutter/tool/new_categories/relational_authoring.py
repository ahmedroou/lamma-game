"""Reproducible draft composition; no assets or Dart files are changed.

Facts are curated into mutually exclusive families within an explicitly named
frame. Compositions retain a review-needed status: executable validation is not
a substitute for checking Arabic wording, source coverage and game difficulty.
"""
from pathlib import Path
import itertools, json, random, collections, hashlib

OUT = Path(__file__).parent
R = random.Random(20261013)
groups = []

def add(domain, label, items, source, hint, minimum='easy'):
    groups.append(dict(domain=domain, label=label, items=items.split('|'), source=source, hint=hint, minimum=minimum))

M49='https://unstats.un.org/unsd/methodology/m49/overview/'
UNESCO='https://whc.unesco.org/en/list/'
CHEM='https://www.rsc.org/periodic-table'
PY='https://docs.python.org/3.14/library/index.html'
HTML='https://html.spec.whatwg.org/multipage/indices.html'
SI='https://www.bipm.org/en/publications/si-brochure'
GEO='تقسيمات M49 الجغرافية للأمم المتحدة؛ المطلوب مجموعات على أدق مستوى إقليمي مشترك، لا قارات عامة'
for label,items in [
 ('شمال إفريقيا','مصر|الجزائر|تونس|المغرب|ليبيا|السودان'),
 ('غرب إفريقيا','السنغال|غانا|نيجيريا|مالي|سيراليون|النيجر|بنين|توغو'),
 ('شرق إفريقيا','كينيا|إثيوبيا|أوغندا|تنزانيا|رواندا|بوروندي|جيبوتي|الصومال'),
 ('وسط إفريقيا','الكاميرون|الغابون|تشاد|غينيا الاستوائية|جمهورية الكونغو|أنغولا'),
 ('جنوب إفريقيا','بوتسوانا|ناميبيا|ليسوتو|إسواتيني|جنوب إفريقيا'),
 ('غرب آسيا','السعودية|الأردن|لبنان|عمان|الكويت|قطر|البحرين|الإمارات'),
 ('وسط آسيا','كازاخستان|أوزبكستان|قرغيزستان|طاجيكستان|تركمانستان'),
 ('جنوب آسيا','الهند|باكستان|بنغلادش|نيبال|بوتان|سريلانكا|أفغانستان|المالديف'),
 ('شرق آسيا','الصين|اليابان|منغوليا|كوريا الجنوبية|كوريا الشمالية'),
 ('جنوب شرق آسيا','تايلاند|فيتنام|كمبوديا|لاوس|ماليزيا|إندونيسيا|الفلبين|سنغافورة'),
 ('شمال أوروبا','السويد|النرويج|الدنمارك|فنلندا|آيسلندا|إيرلندا|إستونيا|لاتفيا'),
 ('غرب أوروبا','فرنسا|ألمانيا|بلجيكا|هولندا|النمسا|سويسرا|لوكسمبورغ|ليختنشتاين'),
 ('جنوب أوروبا','إيطاليا|إسبانيا|البرتغال|اليونان|كرواتيا|ألبانيا|مالطا|سلوفينيا'),
 ('شرق أوروبا','بولندا|أوكرانيا|رومانيا|بلغاريا|المجر|تشيكيا|سلوفاكيا|بيلاروس'),
 ('أمريكا الوسطى','المكسيك|غواتيمالا|هندوراس|السلفادور|نيكاراغوا|كوستاريكا|بنما|بليز'),
 ('أمريكا الجنوبية','البرازيل|الأرجنتين|تشيلي|بيرو|كولومبيا|الإكوادور|بوليفيا|أوروغواي'),
 ('الكاريبي','كوبا|جامايكا|هايتي|جمهورية الدومينيكان|باربادوس|غرينادا|سانت لوسيا|دومينيكا'),
 ('ميلانيزيا','فيجي|فانواتو|جزر سليمان|بابوا غينيا الجديدة|كاليدونيا الجديدة'),
 ('ميكرونيزيا','بالاو|ناورو|كيريباتي|جزر مارشال|ولايات ميكرونيزيا المتحدة'),
 ('بولينيزيا','ساموا|تونغا|توفالو|جزر كوك|نيوي|بولينيزيا الفرنسية'),
]: add(GEO,label,items,M49,'استبعد حجم الدولة ولغتها؛ التصنيف المطلوب إقليمي رسمي.')

HER='مواقع التراث العالمي لليونسكو؛ الرابط المطلوب دولة الإدراج الوطنية لكل موقع، مع استبعاد المواقع العابرة للحدود'
for label,items in [
 ('السعودية','الحجر (مدائن صالح)|حي الطريف في الدرعية|جدة التاريخية|واحة الأحساء|الفن الصخري في حائل|منطقة حمى الثقافية'),
 ('مصر','طيبة القديمة وجبانتها|القاهرة التاريخية|أبو مينا|ممفيس وجبانتها من الجيزة إلى دهشور|آثار النوبة من أبو سمبل إلى فيلة|وادي الحيتان'),
 ('الأردن','البتراء|قصير عمرة|أم الرصاص|منطقة وادي رم المحمية|المغطس|السلط'),
 ('لبنان','بعلبك|جبيل|صور|عنجر|وادي قاديشا وغابة أرز الرب|معرض رشيد كرامي الدولي'),
 ('العراق','الحضر|آشور (قلعة الشرقاط)|مدينة سامراء الأثرية|أهوار جنوب العراق ومدنه الأثرية|قلعة أربيل|بابل'),
 ('المغرب','مدينة فاس العتيقة|مدينة مراكش العتيقة|قصر آيت بن حدو|وليلي|مدينة مكناس التاريخية|مدينة تطوان العتيقة'),
 ('الجزائر','تيمقاد|تيبازة|جميلة|قلعة بني حماد|وادي مزاب|قصبة الجزائر'),
 ('تونس','قرطاج الأثرية|مدرج الجم|مدينة تونس العتيقة|القيروان|دقة|كركوان ومقبرتها'),
 ('ليبيا','قورينا الأثرية|لبدة الكبرى الأثرية|صبراتة الأثرية|تدرارت أكاكوس|مدينة غدامس القديمة'),
 ('تركيا','أفروديسياس|طروادة الأثرية|أفسس|غوبكلي تبه|المناطق التاريخية في إسطنبول|حاتوشا'),
 ('إيران','تخت جمشيد|باسارغاد|ميدان الإمام في أصفهان|تشوغا زنبيل|مدينة يزد التاريخية|الحديقة الفارسية'),
 ('الهند','تاج محل|حصن أغرا|كهوف أجانتا|كهوف إلورا|فاتح بور سيكري|مجموعة آثار هامبي'),
 ('الصين','سور الصين العظيم|ضريح الإمبراطور تشين الأول|كهوف موغاو|حدائق سوجو الكلاسيكية|مدينة بينغ ياو القديمة|معبد السماء'),
 ('اليابان','قلعة هيميجي|نصب كيوتو القديمة|نصب نارا القديمة|نصب السلام في هيروشيما|ضريح إيتسوكوشيما|مناجم إيوامي غينزان للفضة'),
 ('كوريا الجنوبية','قصر تشانغدوكغونغ|قلعة هواسونغ|ضريح جونغميو|المناطق التاريخية في غيونغجو|قرى هاهوي ويانغدونغ|مناطق بيكجي التاريخية'),
 ('إندونيسيا','مجمع معابد بوروبودور|مجمع معابد برامبانان|حديقة كومودو الوطنية|حديقة أوجونغ كولون الوطنية|موقع سانغيران للإنسان القديم|التراث الغابي الاستوائي في سومطرة'),
 ('فيتنام','مجمع آثار هيو|مدينة هوي آن القديمة|معبد مي سون|قلعة هو الملكية|مجمع ترانغ آن الطبيعي|القطاع المركزي لقلعة ثانغ لونغ'),
 ('كمبوديا','أنغكور|معبد برياه فيهير|منطقة معابد سامبور بري كوك|كوه كير'),
 ('أستراليا','الحاجز المرجاني العظيم|حديقة كاكادو الوطنية|دار أوبرا سيدني|خليج القرش|برية تسمانيا|حديقة أولورو كاتا تجوتا'),
 ('المكسيك','تشيتشن إيتزا|تيوتيهواكان|بالينكي|أوشمال|مدينة إل تاجين|دار واستوديو لويس باراغان'),
 ('بيرو','ماتشو بيتشو|مدينة كوسكو|خطوط ورسوم نازكا وبالبا|المركز التاريخي في ليما|موقع تشافين الأثري|مدينة كارال سوبي المقدسة'),
 ('البرازيل','برازيليا|بلدة أورو بريتو التاريخية|المركز التاريخي في أوليندا|المركز التاريخي في سلفادور باهيا|حديقة إيغواسو الوطنية|حديقة سيرا دا كابيفارا الوطنية'),
 ('الأرجنتين','كهف الأيدي ريو بينتوراس|حديقة لوس غلاسياريس الوطنية|حديقة إيغوازو الوطنية|شبه جزيرة فالديس|وادي كيبرادا دي هوماهواكا|حي ومرابع اليسوعيين في قرطبة'),
 ('تشيلي','حديقة رابا نوي الوطنية|كنائس تشيلوي|الحي التاريخي لميناء فالبارايسو|أعمال الملح الصخري في هامبرستون وسانتا لورا|مدينة سيويل التعدينية'),
 ('فرنسا','قصر وحديقة فرساي|جبل سان ميشيل وخليجه|قصر وحديقة فونتينبلو|كاتدرائية شارتر|مدينة كاركاسون المحصنة|جسر بون دو غار'),
 ('إيطاليا','المركز التاريخي في فلورنسا|ساحة الدومو في بيزا|البندقية وبحيرتها|المركز التاريخي في سان جيمينيانو|المركز التاريخي في سيينا|المناطق الأثرية في بومبي وهركولانيوم'),
 ('إسبانيا','قصر الحمراء وحدائق العريف وحي البيازين|المركز التاريخي في قرطبة|مدينة طليطلة التاريخية|مدينة شقوبية القديمة وقناتها|مدينة أفيلا القديمة وكنائسها خارج الأسوار|آثار ميريدا الأثرية'),
 ('اليونان','أكروبوليس أثينا|موقع دلفي الأثري|موقع أولمبيا الأثري|مدينة رودس الوسيطة|ميتيورا|موقع إبيداوروس'),
 ('ألمانيا','كاتدرائية آخن|كاتدرائية كولونيا|كاتدرائية شباير|دير ماولبرون|مدينة بامبرغ|موقع ميسيل الأحفوري'),
 ('المملكة المتحدة','ستونهنج وآفبري|برج لندن|قصر وستمنستر ودير وستمنستر|مدينة باث|كاتدرائية دورهام وقلعتها|الجسر الحديدي وواديه'),
 ('البرتغال','دير جيرونيموس وبرج بيليم|المركز التاريخي في بورتو|المشهد الثقافي في سينترا|دير باتالها|دير المسيح في تومار|جامعة كويمبرا'),
 ('كينيا','حدائق بحيرة توركانا الوطنية|حديقة جبل كينيا وغابته الطبيعية|بلدة لامو القديمة|غابات كايا ميجيكيندا المقدسة|حصن يسوع في مومباسا|موقع ثيمليتش أوهينغا الأثري'),
]: add(HER,label,items,UNESCO,'قارن دولة الموقع؛ لا تعتمد على كونه معبدًا أو قلعة أو محمية فقط.','medium')

CHEMD='الكيمياء: أعمدة الجدول الدوري وفق الترقيم IUPAC؛ الرابط رقم المجموعة لا حالة العنصر الفيزيائية'
for label,items in [
 ('المجموعة 1 من الجدول الدوري','ليثيوم|صوديوم|بوتاسيوم|روبيديوم|سيزيوم|فرانسيوم'),
 ('المجموعة 2 من الجدول الدوري','بيريليوم|مغنيسيوم|كالسيوم|سترونشيوم|باريوم|راديوم'),
 ('المجموعة 13 من الجدول الدوري','بورون|ألومنيوم|غاليوم|إنديوم|ثاليوم|نيهونيوم'),
 ('المجموعة 14 من الجدول الدوري','كربون|سيليكون|جرمانيوم|قصدير|رصاص|فليروفيوم'),
 ('المجموعة 15 من الجدول الدوري','نيتروجين|فوسفور|زرنيخ|أنتيمون|بزموت|موسكوفيوم'),
 ('المجموعة 16 من الجدول الدوري','أكسجين|كبريت|سيلينيوم|تيلوريوم|بولونيوم|ليفرموريوم'),
 ('المجموعة 17 من الجدول الدوري','فلور|كلور|بروم|يود|أستاتين|تينيسين'),
 ('المجموعة 18 من الجدول الدوري','هيليوم|نيون|أرغون|كريبتون|زينون|رادون'),
]: add(CHEMD,label,items,CHEM,'ابحث عن عمود مشترك، وقد يجمع العمود حالات فيزيائية مختلفة.','hard')

COM='منتجات وخدمات شركات التقنية؛ الرابط الجهة المطورة الأصلية للمنتج، وفق الأدلة الرسمية المقروءة'
for label,items,source in [
 ('Apple','iPhone|iPad|MacBook|Apple Watch|AirPods|Safari','https://www.apple.com/iphone/'),
 ('Microsoft','Word|Excel|PowerPoint|Outlook|OneDrive|Teams|OneNote|SharePoint','https://www.microsoft.com/en-us/microsoft-365/products-apps-services'),
 ('Google','Gmail|Google Drive|Google Meet|Google Docs|Google Sheets|Google Slides|Google Forms|Google Keep','https://workspace.google.com/'),
 ('Adobe','Photoshop|Illustrator|InDesign|Acrobat|Lightroom|After Effects|Premiere|Audition','https://www.adobe.com/products/catalog.html'),
]: add(COM,label,items,source,'بعض الأدوات تؤدي وظيفة متشابهة؛ افصلها بحسب الجهة التي طورتها.')

PYD='مكتبة Python 3.14 القياسية: صنّف أسماء الوحدات بحسب أقسام الفهرس الرسمي، لا بحسب إمكان استخدامها في أكثر من مهمة'
for label,items in [
 ('خدمات معالجة النصوص','string|re|difflib|textwrap|unicodedata|stringprep'),
 ('أنواع البيانات','datetime|zoneinfo|calendar|collections|heapq|bisect|array|weakref'),
 ('الوحدات العددية والرياضية','numbers|math|cmath|decimal|fractions|random|statistics'),
 ('البرمجة الوظيفية','itertools|functools|operator'),
 ('الوصول إلى نظام الملفات','pathlib|stat|filecmp|tempfile|glob|fnmatch|shutil'),
 ('استمرارية البيانات','pickle|copyreg|shelve|marshal|dbm|sqlite3'),
 ('ضغط البيانات وأرشفتها','zlib|gzip|bz2|lzma|zipfile|tarfile'),
 ('تنسيقات الملفات','csv|configparser|tomllib|plistlib'),
 ('خدمات أنظمة التشغيل العامة','os|io|time|logging|platform|errno|ctypes'),
 ('مكتبات واجهة سطر الأوامر','argparse|optparse|getpass|fileinput|curses|cmd'),
 ('التنفيذ المتزامن','threading|multiprocessing|concurrent.futures|subprocess|sched|queue|contextvars'),
 ('الشبكات والاتصال بين العمليات','asyncio|socket|ssl|select|selectors|signal|mmap'),
 ('معالجة بيانات الإنترنت','email|json|mailbox|mimetypes|base64|binascii|quopri'),
 ('معالجة ترميز النصوص المهيكلة','html|html.parser|html.entities|xml.etree.ElementTree|xml.dom|xml.sax'),
 ('أدوات التطوير','typing|pydoc|doctest|unittest|unittest.mock|test'),
 ('خدمات وقت تشغيل Python','sys|sysconfig|builtins|__main__|warnings|dataclasses|contextlib|abc'),
 ('استيراد الوحدات','zipimport|pkgutil|modulefinder|runpy|importlib'),
 ('خدمات لغوية','ast|symtable|token|keyword|tokenize|tabnanny|py_compile|compileall'),
]: add(PYD,label,items,PY,'الرابط هو موضع الوحدة في فهرس المكتبة؛ ميّز أسماء الوحدات عن أسماء دوالها.','legendary')

SPACE='أقمار طبيعية في المجموعة الشمسية: الرابط الكوكب أو الكوكب القزم الذي يدور حوله القمر'
for label,items,source in [
 ('أقمار المشتري','آيو|أوروبا|غانيميد|كاليستو','https://science.nasa.gov/jupiter/jupiter-moons/'),
 ('أقمار زحل','تيتان|إنسيلادوس|ميماس|تيثيس|ديون|ريا|هايبريون|إيابيتوس','https://science.nasa.gov/saturn/moons/'),
 ('أقمار أورانوس','تيتانيا|أوبيرون|أرييل|أومبرييل|ميراندا|باك','https://science.nasa.gov/uranus/moons/'),
 ('أقمار نبتون','تريتون|نيريد|بروتيوس|لاريسا|ديسبينا|غالاتيا','https://science.nasa.gov/neptune/moons/'),
 ('أقمار بلوتو','شارون|نيكس|هيدرا|كيربيروس|ستيكس','https://science.nasa.gov/dwarf-planets/pluto/moons/'),
]: add(SPACE,label,items,source,'الأسماء قد تكون أسطورية؛ المطلوب الجسم المركزي الذي تدور حوله.','hard')

SIF='النظام الدولي للوحدات SI: ميّز وضع الوحدة في بنية النظام، لا الكمية التي يمكن قياسها وحدها'
add(SIF,'وحدات SI الأساسية','متر|كيلوغرام|ثانية|أمبير|كلفن|مول|كانديلا',SI,'افصل الوحدات التي يقوم عليها النظام عن الوحدات المركبة المسماة.')
add(SIF,'وحدات SI المشتقة ذات أسماء خاصة','نيوتن|باسكال|جول|واط|كولوم|فولت|أوم|سيمنز|فاراد|ويبر|تسلا|هنري|هرتز|بيكريل|غراي|سيفرت|لومن|لوكس|كاتال',SI,'قد يكون للوحدة اسم خاص ومع ذلك تُكتب بدلالة الوحدات الأساسية.','medium')

WEB='HTML: العناصر بحسب دورها المحدد في مواصفة WHATWG؛ الرابط بنية العنصر ووظيفته لا مظهره الافتراضي'
for label,items in [
 ('بنية الجداول','table|caption|colgroup|col|thead|tbody|tfoot|tr|td|th'),
 ('عناصر العناوين ذات مستويات','h1|h2|h3|h4|h5|h6'),
 ('عناصر البيانات الوصفية في الرأس','base|link|meta|style|title'),
]: add(WEB,label,items,HTML,'راجع علاقة الوسم ببنية المستند، لا طريقة عرضه في المتصفح.','hard')

LIT='الأعمال الأدبية المنشورة: الرابط المؤلف الأصلي الذي تنسب إليه فهارس النصوص هذه الأعمال، لا المترجم أو الممثل'
for label,items,authorid in [
 ('تشارلز ديكنز','قصة مدينتين|آمال عظيمة|أوليفر تويست|ديفيد كوبرفيلد|البيت الكئيب|أوقات عصيبة|ترنيمة عيد الميلاد|أوراق بيكويك',37),
 ('جين أوستن','كبرياء وتحامل|العقل والعاطفة|إيما|الإقناع|دير نورثانغر|مانسفيلد بارك',68),
 ('ويليام شكسبير','هاملت|ماكبث|عطيل|الملك لير|العاصفة|حلم ليلة صيف|تاجر البندقية|يوليوس قيصر',65),
 ('جول فيرن','حول العالم في ثمانين يومًا|عشرون ألف فرسخ تحت البحر|رحلة إلى مركز الأرض|الجزيرة الغامضة|من الأرض إلى القمر|خمسة أسابيع في منطاد',60),
 ('مارك توين','مغامرات توم سوير|مغامرات هكلبيري فن|الأمير والفقير|الحياة على المسيسيبي|يانكي من كونيتيكت في بلاط الملك آرثر|الأبرياء في الخارج',53),
 ('روبرت لويس ستيفنسون','جزيرة الكنز|الدكتور جيكل والسيد هايد|المخطوف|كاتريونا|حديقة أشعار الطفل|رحلات مع حمار في سيفين',35),
 ('آرثر كونان دويل','دراسة في اللون القرمزي|علامة الأربعة|كلب آل باسكرفيل|وادي الخوف|العالم المفقود|الحزام السام',69),
 ('ليو تولستوي','الحرب والسلام|آنا كارينينا|البعث|ما الفن؟|الطفولة|السيد والخادم',136),
 ('أوسكار وايلد','صورة دوريان غراي|أهمية أن تكون جادًا|الأمير السعيد|شبح كانترفيل|مروحة الليدي ويندرمير|زوج مثالي',111),
 ('برام ستوكر','دراكولا|ضيف دراكولا|جوهرة النجوم السبع|عرين الدودة البيضاء|لغز البحر|سيدة الكفن',190),
]: add(LIT,label,items,f'https://www.gutenberg.org/ebooks/author/{authorid}','ميّز صاحب النص الأصلي عن بلد الأحداث وشخصيات الرواية.','medium')

def ordered_unique(items): return list(dict.fromkeys(items))
def question(cat,diff,num,text,answer,hint,explanation,sources,wrong,presentation=None):
    wrong=ordered_unique([x for x in wrong if x!=answer])
    assert len(wrong)>=5,(cat,diff,num,wrong)
    candidates=wrong[:5]
    pos=(num-1+['easy','medium','hard','legendary'].index(diff)*3)%6
    candidates.insert(pos,answer)
    q=dict(id=f'{cat}-{diff}-{num:04d}',categoryId=cat,difficulty=diff,text=text,answer=answer,acceptedAnswers=[],hint=hint,clues=[],explanation=explanation,sources=ordered_unique(sources),options=[dict(id=chr(65+i),text=x) for i,x in enumerate(candidates)],correctOptionId=chr(65+pos),qualityStatus='unreviewed')
    if presentation:q['presentation']=presentation
    return q

def partition_text(left,right,labels):
    return f'{labels[0]}: '+ '، '.join(sorted(left))+'؛ '+f'{labels[1]}: '+'، '.join(sorted(right))

def split_record(diff,num,g1,g2,seen):
    n=4 if diff in ('hard','legendary') and min(len(g1['items']),len(g2['items']))>=4 else 3
    for _ in range(200):
        left=R.sample(g1['items'],n); right=R.sample(g2['items'],n)
        signature=tuple(sorted(left+right))
        if signature not in seen:break
    else: return None
    seen.add(signature)
    labels=[g1['label'],g2['label']]
    answer=partition_text(left,right,labels)
    wrong=[]
    for i,j in itertools.product(range(n),range(n)):
        a=left.copy();b=right.copy();a[i],b[j]=b[j],a[i]
        wrong.append(partition_text(a,b,labels))
    R.shuffle(wrong)
    elements=left+right;R.shuffle(elements)
    pres=dict(type='grouping',sections=[dict(id='items',title='',items=[dict(id=f'g{i+1}',text=t) for i,t in enumerate(elements)])])
    text=f'قسّم العناصر المعروضة إلى مجموعتين متساويتين، ثم سمّ الرابط الخاص بكل مجموعة. السياق: {g1["domain"]}.'
    explain=f'المجموعة الأولى ({g1["label"]}): '+ '، '.join(left)+f'. المجموعة الثانية ({g2["label"]}): '+ '، '.join(right)+'. في إطار التصنيف المحدد في السؤال، كل عنصر يتبع مجموعة واحدة؛ مبادلة عنصرين بين المجموعتين تخالف ذلك التصنيف.'
    return question('split_groups',diff,num,text,answer,g1['hint'],explain,[g1['source'],g2['source']],wrong,pres)

def match_record(diff,num,selected,seen):
    left=[R.choice(g['items']) for g in selected]
    key=tuple(sorted(left))
    if key in seen:return None
    seen.add(key)
    right=[g['label'] for g in selected]
    # Three pairs have exactly six bijections, so every stored choice is complete.
    answer='؛ '.join(f'{a} ← {b}' for a,b in zip(left,right))
    wrong=['؛ '.join(f'{a} ← {b}' for a,b in zip(left,p)) for p in itertools.permutations(right) if list(p)!=right]
    order=R.choice([[1,2,0],[2,0,1]])
    mode=(num-1)%4
    missing_count=0 if mode==0 else 1 if mode==1 else 2 if mode==2 else 3
    # Empty slots are fungible: request reconstruction of the unordered pairs,
    # never demand a hidden label at an arbitrary blank position.
    missing=set(R.sample(range(3),missing_count))
    ri=[dict(id=f'r{i+1}',text='؟',missing=True) if i in missing else dict(id=f'r{i+1}',text=right[k]) for i,k in enumerate(order)]
    pres=dict(type='matching',sections=[dict(id='left',title='العناصر',items=[dict(id=f'l{i+1}',text=t) for i,t in enumerate(left)]),dict(id='right',title='الروابط',items=ri)])
    text='أعد بناء الأزواج الثلاثة كاملة: صِل كل عنصر برابطه المحدد.'
    if missing_count:text+=' كل «؟» تمثل رابطًا محذوفًا؛ استنتج أسماء الروابط الناقصة من العناصر، ويكفي ذكر الأزواج دون ترتيب الخانات الفارغة.'
    text+=' السياق: '+selected[0]['domain']+'.'
    explain='الحل: '+answer+'. '+ ' '.join(f'{a} يتبع {g["label"]} وفق مرجع هذا التصنيف.' for a,g in zip(left,selected))+' كل تبديل آخر بين الروابط الثلاثة يضع عنصرًا واحدًا على الأقل تحت رابط مختلف.'
    return question('pair_up',diff,num,text,answer,selected[0]['hint'],explain,[g['source'] for g in selected],wrong,pres)

def relationship_record(diff,num,g,pair,alternatives):
    a,b=pair
    answer=f'كلاهما ضمن «{g["label"]}» في التصنيف المحدد'
    wrong=[f'كلاهما ضمن «{h["label"]}» في التصنيف المحدد' for h in alternatives]
    # Domain-specific distractors remain propositions of the same precision.
    if len(wrong)<5:
        extra={COM:['Sony','Nintendo','Samsung','IBM','Oracle'],SPACE:['أقمار المريخ','أقمار الأرض','أقمار إيريس'],SIF:['وحدات خارج SI مقبولة للاستخدام معه','وحدات زاوية غير دولية','وحدات كتلة عرفية','وحدات طول بحرية','وحدات معلومات رقمية'],WEB:['عناصر روابط تشعبية','عناصر بيانات وصفية في الرأس','عناصر تضمين وسائط متعددة','عناصر نماذج تقبل الإدخال','عناصر قوائم وتعريفات']}[g['domain']]
        wrong += [f'كلاهما ضمن «{x}» في التصنيف المحدد' for x in extra]
    text=f'ما الرابط التصنيفي الدقيق بين «{a}» و«{b}»؟ السياق: {g["domain"]}.'
    explain=f'{a} و{b} يندرجان في {g["label"]} بحسب المرجع المذكور. المطلوب هذا التصنيف المحدد؛ الصفات العامة أو الاستخدامات الجانبية لا تغير جواب هذا الإطار.'
    return question('relationship',diff,num,text,answer,g['hint'],explain,[g['source']],wrong)

def save(cat,questions):
    path=OUT/f'{cat}.json'
    doc=dict(schemaVersion=1,categoryId=cat,targetCount=300,targetPerDifficulty=75,status='draft',questions=questions)
    path.write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

def build():
    by_domain=collections.defaultdict(list)
    for g in groups:by_domain[g['domain']].append(g)
    assignments={
      'easy':[GEO,COM,SIF,LIT],
      'medium':[HER,GEO,COM,SIF,LIT],
      'hard':[CHEMD,SPACE,HER,WEB,LIT],
      'legendary':[PYD,CHEMD,SPACE,HER,LIT],
    }
    # Global uniqueness guards avoid questions repeated through a reordering.
    split_seen=set();pair_seen=set();relation_seen=set();used_class_pairs=set()
    output={k:[] for k in ['split_groups','pair_up','relationship']}
    for diff,domains in assignments.items():
        pools=[]
        for d in domains:
            choices=list(itertools.combinations(by_domain[d],2));R.shuffle(choices);pools.append(choices)
        count=0
        while count<75:
            progress=False
            for pool in pools:
                while pool:
                    g1,g2=pool.pop()
                    classes=(g1['domain'],*sorted([g1['label'],g2['label']]))
                    if classes in used_class_pairs:continue
                    q=split_record(diff,count+1,g1,g2,split_seen)
                    if q:
                        used_class_pairs.add(classes);output['split_groups'].append(q);count+=1;progress=True;break
                if count==75:break
            if not progress:raise ValueError(('insufficient grouping pairs',diff,count))
        save('split_groups',output['split_groups'])
        count=0
        md=[d for d in domains if len(by_domain[d])>=3]
        while count<75:
            d=md[count%len(md)]
            selected=R.sample(by_domain[d],3)
            q=match_record(diff,count+1,selected,pair_seen)
            if q:output['pair_up'].append(q);count+=1
        save('pair_up',output['pair_up'])
        candidates=[]
        for d in domains:
            local=[]
            for g in by_domain[d]:
                for pair in itertools.combinations(g['items'],2):
                    if tuple(sorted(pair)) not in relation_seen:local.append((g,pair))
            R.shuffle(local);candidates.append(local)
        count=0
        while count<75:
            progress=False
            for pool in candidates:
                while pool:
                    g,pair=pool.pop();key=tuple(sorted(pair))
                    if key in relation_seen:continue
                    others=[h for h in by_domain[g['domain']] if h is not g]
                    R.shuffle(others)
                    q=relationship_record(diff,count+1,g,pair,others)
                    output['relationship'].append(q);relation_seen.add(key);count+=1;progress=True;break
                if count==75:break
            if not progress:raise ValueError(('insufficient relation pairs',diff,count))
        save('relationship',output['relationship'])
    (OUT/'relational_fact_pools.json').write_text(json.dumps(groups,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print({cat:len(qs) for cat,qs in output.items()})

if __name__=='__main__':build()
