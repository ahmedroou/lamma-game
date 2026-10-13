from reference_abbreviations_data import *
AR_SOURCE='https://www.un.org/ar/about-us/un-system'
arabic='''UNDP|برنامج الأمم المتحدة الإنمائي
UNEP|برنامج الأمم المتحدة للبيئة
UNFPA|صندوق الأمم المتحدة للسكان
UN-Habitat|برنامج الأمم المتحدة للمستوطنات البشرية
UNICEF|منظمة الأمم المتحدة للطفولة
WFP|برنامج الأغذية العالمي
FAO|منظمة الأغذية والزراعة للأمم المتحدة
ICAO|منظمة الطيران المدني الدولي
IFAD|الصندوق الدولي للتنمية الزراعية
ILO|منظمة العمل الدولية
IMF|صندوق النقد الدولي
IMO|المنظمة البحرية الدولية
ITU|الاتحاد الدولي للاتصالات
UNESCO|منظمة الأمم المتحدة للتربية والعلم والثقافة
UNIDO|منظمة الأمم المتحدة للتنمية الصناعية
UPU|الاتحاد البريدي العالمي
WHO|منظمة الصحة العالمية
WIPO|المنظمة العالمية للملكية الفكرية
WMO|المنظمة العالمية للأرصاد الجوية
IBRD|البنك الدولي للإنشاء والتعمير
IDA|المؤسسة الدولية للتنمية
IFC|مؤسسة التمويل الدولية
UNHCR|المفوضية السامية للأمم المتحدة لشؤون اللاجئين
UNIDIR|معهد الأمم المتحدة لبحوث نزع السلاح
UNITAR|معهد الأمم المتحدة للتدريب والبحث
UNOPS|مكتب الأمم المتحدة لخدمات المشاريع
UNRWA|وكالة الأمم المتحدة لإغاثة وتشغيل اللاجئين الفلسطينيين في الشرق الأدنى
UN-Women|هيئة الأمم المتحدة للمرأة
IAEA|الوكالة الدولية للطاقة الذرية
WTO|منظمة التجارة العالمية
IOM|المنظمة الدولية للهجرة
UNODC|مكتب الأمم المتحدة المعني بالمخدرات والجريمة'''
AR=dict(r.split('|') for r in arabic.splitlines())
def revise_options(q,answers):
 assert len(set(answers))==6 and q['answer'] in answers
 RNG.shuffle(answers);q['options']=[{'id':chr(65+i),'text':v} for i,v in enumerate(answers)];q['correctOptionId']=next(o['id'] for o in q['options'] if o['text']==q['answer'])
for item in BOOKS['abbreviations']:
 found=next((key for key in AR if 'للاختصار '+key+'؟' in item['text']),None)
 if found:
  previous=item['answer'];item['answer']=AR[found];item['acceptedAnswers']=[previous]
  item['text']=f'في المنظمات الدولية، ما الاسم العربي الكامل للجهة المعروفة بالاختصار {found}؟'
  item['explanation']=f'الاسم العربي الرسمي هو «{AR[found]}»، ويقابله في المصدر الإنجليزي {previous}.'
  item['sources'].append(AR_SOURCE if found!='UNODC' else 'https://www.unodc.org/res/strategy/full-strategy_html/full-strategy_AR.pdf')
  candidates=sorted([v for v in AR.values() if v!=item['answer']],key=lambda v:(len(set(v.split())&set(item['answer'].split())),-abs(len(v)-len(item['answer']))),reverse=True)
  revise_options(item,[item['answer']]+candidates[:5])

agencies=[
('easy','واس','وكالة الأنباء السعودية','أحد أجهزة الأخبار الرسمية في الجزيرة العربية.','https://cc.spa.gov.sa/ar/aboutUs'),
('easy','وام','وكالة أنباء الإمارات','وكالة رسمية من دولة اتحادية في الخليج.','https://wns.wam.ae/public/contract-ar.html'),
('medium','قنا','وكالة الأنباء القطرية','مؤسسة إعلامية من دولة خليجية.','https://qna.org.qa/ar-QA/Pages/about-us'),
('medium','كونا','وكالة الأنباء الكويتية','وكالة خليجية تتخذ العاصمة مقرًا.','https://www.kuna.net.kw/ArticlePrintPage.aspx?id=1609544&language=ar'),
('hard','بترا','وكالة الأنباء الأردنية','اسمها المختصر يذكّر بمدينة أثرية.','https://petra.gov.jo/ar'),
('hard','وفا','وكالة الأنباء والمعلومات الفلسطينية','يتضمن الاسم الكامل قطاع معلومات إلى جانب الأخبار.','https://info.wafa.ps/Home/AboutUs'),
('legendary','سانا','الوكالة العربية السورية للأنباء','تستخدم حروف الاسم الإنجليزي في تسمية عربية شائعة.','https://sana.sy/contact/'),
('legendary','أ ش أ','وكالة أنباء الشرق الأوسط','الحروف تختصر كلمات من اسم منطقة جغرافية.','https://mena.org.eg/ar/section/WebArPolitics/2492'),
]
remove=['B/W','N/A','RMS','PPE','GCR','FOD','ASHRAE','MPE']
BOOKS['abbreviations']=[v for v in BOOKS['abbreviations'] if not any('للاختصار '+short+'؟' in v['text'] and 'ناس' in v['text'] for short in remove)]
for diff,short,answer,hint,source in agencies:add('abbreviations',diff,f'في أسماء وكالات الأنباء العربية، إلى أي وكالة يشير الاسم المختصر «{short}»؟',answer,hint,f'تعرّف الوكالة نفسها بهذا الاسم الكامل: {answer}.',[source],[r[2] for r in agencies])

# Hand-crafted close expansions: same letters and comparable names/functions.
closer={
'NASA':['National Aeronautics and Space Administration','National Astronomy and Space Administration','National Aeronautics and Satellite Administration','National Aviation and Space Authority','National Aeronautics and Science Administration','National Astronomy and Satellite Authority'],
'ISS':['International Space Station','International Space Shuttle','Integrated Space Station','International Satellite System','Interplanetary Space Station','International Space Service'],
'GPS':['Global Positioning System','Global Planning System','Geographical Positioning Service','Global Navigation System','Ground Positioning System','Global Positioning Satellite'],
'LED':['light-emitting diodes','Light Energy Detectors','Low Emission Displays','Laser Emission Devices','Light Extraction Devices','Linear Electronic Diodes'],
'GUI':['graphical user interface','General User Interface','Graphical Utility Interface','Global User Interface','Graphical User Interaction','General Utility Interface'],
'AC':['alternating current','Automatic Current','Alternating Charge','Active Conductor','Average Current','Alternating Circuit'],
'DC':['direct current','Dynamic Current','Direct Charge','Distributed Current','Differential Current','Direct Circuit'],
'AR':['augmented reality','Artificial Reality','Assisted Rendering','Adaptive Reality','Augmented Rendering','Artificial Rendering'],
'ASCII':['American Standard Code for Information Interchange','American Standard Code for Internet Interchange','American Standard Coding for Information Integration','Advanced Standard Code for Information Interchange','American System Code for Information Interchange','American Standard Code for International Information'],
'BMI':['Body mass index','Body Metabolic Index','Body Muscle Index','Body Measurement Index','Basal Mass Index','Body Mass Indicator'],
'BP':['Blood pressure','Body Pressure','Blood Perfusion','Brain Pressure','Basal Pulse','Bronchial Pressure'],
'CPR':['Cardiopulmonary resuscitation','Cardiopulmonary Recovery','Cardiovascular Pressure Regulation','Cerebral Perfusion Response','Cardiac Pressure Restoration','Cardiopulmonary Rehabilitation'],
'MRI':['Magnetic resonance imaging','Magnetic Reflection Imaging','Molecular Resonance Imaging','Magnetic Radiation Inspection','Medical Resonance Imaging','Magnetic Resolution Imaging'],
'EEG':['Electroencephalogram','Electroenterogram','Electroencephalographic Gradient','Electroencephalic Graph','Electroevoked Graph','Electroendocrine Graph'],
'HTTP':['Hypertext Transfer Protocol','Hypertext Transport Protocol','High-speed Text Transfer Protocol','Hypertext Transmission Procedure','Hyperlink Transfer Protocol','Host Text Transfer Protocol'],
'FTP':['File Transfer Protocol','File Transport Protocol','Fast Transfer Protocol','File Transmission Procedure','File Tracking Protocol','Folder Transfer Protocol'],
'TCP':['Transmission Control Protocol','Transport Control Protocol','Transmission Connection Protocol','Transfer Control Procedure','Traffic Control Protocol','Transmission Communication Protocol'],
'DNS':['Domain Name System','Domain Naming Service','Data Name System','Dynamic Name Service','Domain Network Service','Distributed Name System'],
'VPN':['Virtual Private Network','Virtual Public Network','Verified Private Network','Virtual Protected Node','Variable Private Network','Virtual Packet Network'],
'TLS':['Transport Layer Security','Transmission Layer Security','Transport Link Security','Trusted Layer Service','Traffic Layer Security','Transport Login Service'],
'SMTP':['Simple Mail Transfer Protocol','Secure Mail Transfer Protocol','Simple Mail Transport Protocol','Standard Message Transfer Protocol','Simple Message Transmission Protocol','Secure Message Transport Protocol'],
'AES':['Advanced Encryption Standard','Advanced Encoding Standard','Asymmetric Encryption Standard','Advanced Encryption System','Authenticated Encryption Scheme','Automated Encryption Standard'],
'SHA':['Secure Hash Algorithm','Secure Header Authentication','Simple Hash Algorithm','Symmetric Hash Algorithm','Secure Hash Authentication','Standard Hash Algorithm'],
'RSA':['Rivest-Shamir-Adleman','Rivest-Shannon-Adleman','Rivest-Shamir-Anderson','Rabin-Shamir-Adleman','Rivest-Shamir-Aaronson','Rivest-Simmons-Adleman'],
}
for item in BOOKS['abbreviations']:
 key=next((k for k in closer if 'للاختصار '+k+'؟' in item['text']),None)
 if key and item['answer'] in closer[key]:revise_options(item,closer[key].copy())
 item['hint']=item['hint'].replace('إنزيم إنزيم','إنزيم منظم في الدورة الدموية')
counts=collections.Counter()
for item in BOOKS['abbreviations']:
 counts[item['difficulty']]+=1;item['id']=f"abbreviations-{item['difficulty']}-{counts[item['difficulty']]:04d}"
