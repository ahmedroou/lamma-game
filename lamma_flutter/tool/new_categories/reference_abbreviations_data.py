from author_reference_categories import *
import re
T=json.loads((OUT/'reference_sources/abbreviation_tables.json').read_text(encoding='utf-8'))
TABLES={k:{r[0]:r[1].split(';')[0].split(' [')[0].rstrip('.') for r in rows if len(r)>1 and r[0]} for k,rows in T.items()}
SOURCES={'medical':'https://medlineplus.gov/appendixb.html','nasa':'https://www.nasa.gov/reference/appendix-b-vol-2/','un':'https://www.un.org/dgacm/en/content/editorial-manual/abbreviations','internet':'https://www.rfc-editor.org/rfc/rfc4949'}
SELECTIONS={
'easy':{
'medical':'''BMI|الكتلة والطول BP|العلامات الحيوية CPR|إجراء إسعافي RBC|مكونات الدم WBC|مكونات المناعة ICU|قسم مستشفى MRI|التصوير الطبي HIV|علم الفيروسات AIDS|علم المناعة ADHD|السلوك والانتباه OCD|الصحة النفسية ENT|تخصص طبي CNS|الجهاز العصبي TB|العدوى التنفسية IV|طريق إعطاء دواء IM|طريق إعطاء دواء ECG, EKG|فحص كهربائي EEG|فحص كهربائي CBC|تحليل مخبري DX|تحديد المرض''',
'nasa':'''NASA|مؤسسة استكشاف ISS|الرحلات المدارية GPS|تحديد الموقع LED|الإضاءة GUI|التفاعل مع حاسوب DNA|الوراثة AC|الدارات الكهربائية DC|الدارات الكهربائية UV|نوع إشعاع IR|نوع إشعاع RF|الاتصالات AR|تقنية عرض B/W|طريقة عرض ETA|تقدير زمني N/A|تعبئة نموذج''',
'un':'''WHO|الصحة العالمية UNESCO|التعليم والثقافة UNICEF|حقوق الأطفال IMF|التعاون المالي WTO|التجارة العالمية NATO|التحالفات العسكرية OPEC|تعاون الدول النفطية FAO|الغذاء والزراعة UNDP|التنمية UNHCR|النزوح واللجوء UNRWA|الإغاثة الفلسطينية WFP|المساعدات الغذائية IAEA|الاستخدام السلمي للطاقة UN-Women|المساواة ASEAN|تكتل آسيوي NGO|نوع مؤسسة GDP|حسابات اقتصاد GNP|حسابات اقتصاد VAT|الضرائب ICRC|الإغاثة الإنسانية INTERPOL|التعاون الشرطي LAS|تكتل إقليمي عربي PDF|ملفات رقمية RNA|جزيء حيوي ICT|التقنية والاتصال''',
},
'medium':{
'medical':'''ACL|إصابة رياضية AFIB|اضطراب نظم القلب ALS|مرض عصبي COPD|مرض تنفسي CRP|مؤشر التهاب CSF|سائل حيوي CXR|تصوير الصدر DVT|تخثر دموي ECHO|الموجات فوق الصوتية EMG|وظيفة عضلات GERD|اضطراب هضمي HDL|دهون الدم LDL|دهون الدم HPV|علم الفيروسات HRT|العلاج الهرموني HTN|الدورة الدموية IBS|اضطراب هضمي IUD|جهاز طبي LFT|تحليل أعضاء MI|حدث قلبي MMR|لقاح متعدد MS|مرض عصبي NSAID|فئة دوائية TSH|تحليل هرموني UTI|نوع عدوى''',
'nasa':'''ASCII|ترميز الحروف ANSI|هيئة معايير ISO|هيئة معايير IEEE|هيئة هندسية IEC|هيئة معايير LEO|مدار فضائي EVA|حركة رائد فضاء IVA|حركة رائد فضاء HUD|طريقة عرض HEPA|ترشيح الهواء PPE|معدات سلامة SDS|توثيق السلامة VOC|جودة الهواء RH|حالة الهواء RMS|حساب قياسي''',
'un':'''UNEP|البيئة UNFPA|السكان UNIDO|الصناعة UNODC|الجريمة والمخدرات UN-Habitat|التجمعات السكنية ILO|العمل IMO|النقل البحري ICAO|النقل الجوي ITU|الاتصالات UPU|البريد WIPO|حقوق الابتكار WMO|الطقس IOM|الهجرة OECD|التعاون الاقتصادي OIC|التعاون الإسلامي OSCE|الأمن الأوروبي UNCTAD|التجارة والتنمية FDI|الاستثمار CPI|مؤشر أسعار EEZ|النطاق البحري''',
},
'hard':{
'medical':'''ABG|قياس التنفس ACE|إنزيم إنزيم ALP|تحليل إنزيم ALT|تحليل الكبد AST|تحليل الكبد AMD|مرض عيني AVM|تشوه وعائي BPH|حالة غدية BUN|تحليل الكلى CABG|جراحة قلب CAD|مرض قلبي CHD|مرض خلقي CHF|فشل عضو CMV|علم الفيروسات CPK|تحليل إنزيم CRF|حالة كلوية CVA|حدث عصبي DTP|لقاح متعدد ESR|قياس الالتهاب GFR|وظيفة الكلى HCT|مكونات الدم HGB|بروتين دموي IBD|أمراض الأمعاء ICD|جهاز نظم قلبي MRSA|مقاومة المضادات''',
'nasa':'''ALARA|تقليل التعرض CFU|القياس الميكروبي CRI|جودة الإضاءة CCT|خصائص مصدر ضوء COTS|شراء مكونات جاهزة FOD|سلامة الطيران ECLSS|حياة الطاقم EMU|تجهيز رائد فضاء GCR|إشعاع فضائي GSE|معدات تشغيل أرضية HCD|تصميم منتج HITL|أسلوب محاكاة MET|وقت الرحلة SPE|نشاط شمسي STS|نظام نقل فضائي''',
'un':'''ADB|تمويل التنمية AfDB|تمويل التنمية EBRD|تمويل إعمار IBRD|تمويل التنمية IDA|تمويل التنمية IFC|الاستثمار الخاص IsDB|تمويل التنمية IFAD|تمويل الزراعة APEC|تعاون المحيط الهادئ CARICOM|تكتل كاريبي COMESA|تكتل إفريقي ECOWAS|تكتل إفريقي EFTA|التجارة الأوروبية ECLAC|لجنة اقتصادية ESCWA|لجنة اقتصادية ESCAP|لجنة اقتصادية OHCHR|حقوق الإنسان OPCW|الرقابة على أسلحة UNOPS|خدمات مشروعات UNV|العمل التطوعي''',
},
'legendary':{
'medical':'''CA-125|مؤشر مخبري ERCP|تصوير قنوات داخلية ESRD|مرحلة مرض FSH|هرمون تناسلي HAV|علم الفيروسات HBV|علم الفيروسات HCV|علم الفيروسات NG|طريق أنبوب IVP|تصوير المسالك PET|تصوير وظيفي PFT|اختبار تنفسي PID|التهاب موضعي PMS|أعراض دورية PPD|اختبار مناعي PSA|مؤشر غدي PT|قياس تخثر PTH|هرمون غدي PTT|قياس تخثر PUD|اضطراب هضمي PVC|نظم القلب RA|اضطراب مناعي RSV|علم الفيروسات SLE|مرض مناعي TIA|حدث عصبي TIBC|تحليل الحديد''',
'nasa':'''ASHRAE|جمعية هندسية ASA|جمعية علمية COSPAR|تعاون بحث فضائي DCS|تأثير تغير الضغط DRI|علم التغذية EER|علم التغذية HSI|هندسة النظم البشرية IPR|حقوق ابتكار LEA|مراحل رحلة LOC|مخاطر الطاقم LOM|مخاطر المهمة MPE|سلامة التعرض PEL|حدود تعرض SPL|قياس صوت TWA|متوسط تعرض''',
'un':'''UNCITRAL|القانون التجاري UNITAR|التدريب والبحث UNIDIR|بحث نزع السلاح UNICRI|البحث الجنائي UNRISD|بحث التنمية الاجتماعية PAHO|منظمة صحية إقليمية WCO|العمل الجمركي GEF|تمويل البيئة ODA|تمويل التنمية TRIPS|حقوق مرتبطة بالتجارة''',
}}

TECH='''
easy|URL|Uniform Resource Locator|عنوان مورد على الشبكة
easy|HTTP|Hypertext Transfer Protocol|نقل صفحات الويب
easy|FTP|File Transfer Protocol|نقل ملفات
easy|TCP|Transmission Control Protocol|نقل موثوق بين المضيفين
easy|IP|Internet Protocol|عنونة وتوجيه الحزم
easy|DNS|Domain Name System|الأسماء والعناوين
easy|LAN|Local Area Network|نطاق شبكة محدود
easy|WAN|Wide Area Network|نطاق شبكة واسع
easy|VPN|Virtual Private Network|اتصال عبر شبكة مشتركة
easy|PIN|Personal Identification Number|سر قصير لإثبات الهوية
easy|DoS|Denial of Service|تعطيل إتاحة خدمة
easy|WWW|World Wide Web|موارد مترابطة بروابط
easy|ISP|Internet Service Provider|الاشتراك بالشبكة
easy|USB|Universal Serial Bus|وصلة أجهزة
easy|MAC|Message Authentication Code|سلامة رسالة وأصالتها؛ ليس عنوان بطاقة الشبكة
medium|UDP|User Datagram Protocol|نقل رزم بلا ضمان تسليم
medium|SMTP|Simple Mail Transfer Protocol|إرسال البريد
medium|IMAP|Internet Message Access Protocol|الوصول إلى بريد محفوظ بالخادم
medium|SNMP|Simple Network Management Protocol|إدارة أجهزة الشبكة
medium|TLS|Transport Layer Security|حماية الاتصال
medium|SSL|Secure Sockets Layer|الاسم السابق لعائلة حماية اتصال
medium|SSH|Secure Shell|دخول آمن عن بعد
medium|HTML|Hypertext Markup Language|توصيف صفحة
medium|XML|Extensible Markup Language|بنية بيانات نصية
medium|AES|Advanced Encryption Standard|تشفير متماثل
medium|DES|Data Encryption Standard|تشفير متماثل قديم
medium|RSA|Rivest-Shamir-Adleman|أسماء مبتكري نظام تشفير
medium|SHA|Secure Hash Algorithm|بصمة بيانات
medium|PKI|Public-Key Infrastructure|شهادات ومفاتيح
medium|IDS|Intrusion Detection System|مراقبة نشاط مشبوه
hard|ACL|Access Control List|تفويض وصول؛ ليس رباط الركبة
hard|CA|Certification Authority|إصدار شهادات رقمية؛ ليس الكالسيوم
hard|CRL|Certificate Revocation List|شهادات لم تعد صالحة
hard|OCSP|Online Certificate Status Protocol|الاستعلام عن حالة شهادة
hard|DHCP|Dynamic Host Configuration Protocol|ضبط مضيف تلقائيًا
hard|ICMP|Internet Control Message Protocol|رسائل تحكم للشبكة
hard|ARP|Address Resolution Protocol|ربط عنوان شبكي بعنوان وصلة
hard|NAT|Network Address Translation|تغيير عناوين مرور الشبكة
hard|NTP|Network Time Protocol|مزامنة الوقت
hard|PPP|Point-to-Point Protocol|وصلة بين نقطتين
hard|CHAP|Challenge Handshake Authentication Protocol|استيثاق بتحد واستجابة
hard|PAP|Password Authentication Protocol|استيثاق بكلمة مرور
hard|SASL|Simple Authentication and Security Layer|طبقة استيثاق في التطبيقات
hard|S/MIME|Secure/Multipurpose Internet Mail Extensions|حماية رسائل البريد
hard|PGP|Pretty Good Privacy|برنامج حماية بريد وملفات
legendary|HMAC|Keyed-Hash Message Authentication Code|توثيق باستخدام دالة تجزئة ومفتاح
legendary|CBC|Cipher Block Chaining|نمط تشغيل شيفرة كتلية؛ ليس تحليل تعداد الدم
legendary|ECB|Electronic Codebook|نمط تشغيل شيفرة كتلية؛ ليس البنك المركزي
legendary|CFB|Cipher Feedback|نمط تغذية راجعة للتشفير
legendary|OFB|Output Feedback|نمط تغذية راجعة لخرج الشيفرة
legendary|CTR|Counter|نمط تشغيل يعتمد عدّادًا
legendary|IV|Initialization Vector|مدخل ابتدائي للتشفير؛ ليس حقنًا وريديًا
legendary|KDC|Key Distribution Center|توزيع مفاتيح جلسات
legendary|TGS|Ticket-Granting Service|خدمة إصدار تذاكر في Kerberos
legendary|ESP|Encapsulating Security Payload|حماية حمل حزم IPsec
legendary|AH|Authentication Header|رأس بروتوكول في IPsec
legendary|IKE|Internet Key Exchange|تفاوض مفاتيح في IPsec
legendary|ISAKMP|Internet Security Association and Key Management Protocol|تأسيس ارتباطات أمنية
legendary|SPI|Security Parameters Index|تحديد ارتباط أمني
legendary|SA|Security Association|ترتيب معلمات حماية اتصال
legendary|SSO|Single Sign-On|دخول واحد لخدمات متعددة
legendary|RBAC|Role-Based Access Control|صلاحيات حسب وظيفة المستخدم
legendary|DAC|Discretionary Access Control|سياسة وصول يتحكم بها المالك
legendary|MAC|Mandatory Access Control|سياسة وصول إلزامية؛ ليس رمز توثيق الرسالة
legendary|DSS|Digital Signature Standard|معيار توقيع رقمي
legendary|DSA|Digital Signature Algorithm|خوارزمية توقيع رقمي
legendary|FIPS|Federal Information Processing Standards|معايير معالجة معلومات أمريكية
legendary|ASN.1|Abstract Syntax Notation One|توصيف تركيب بيانات
legendary|BER|Basic Encoding Rules|قواعد ترميز بيانات ASN.1
legendary|DER|Distinguished Encoding Rules|قواعد ترميز محددة لبيانات ASN.1
'''

def author():
    for diff,groups in SELECTIONS.items():
      for name,selection in groups.items():
        pairs=[v.split('|') for v in selection.split()]
        # Arabic hints contain spaces, so split on known key followed by pipe instead.
        keys=re.findall(r'(?:^| )([A-Za-z0-9,&/-]+)\|',selection)
        starts=list(re.finditer(r'(?:^| )([A-Za-z0-9,&/-]+)\|',selection))
        rows=[]
        for i,m in enumerate(starts):
          key=m.group(1);hint=selection[m.end():starts[i+1].start() if i+1<len(starts) else len(selection)].strip()
          if key=='EKG':key='ECG, EKG'
          assert key in TABLES[name],(name,key)
          answer=TABLES[name][key]
          if key=='ETA':answer='Estimated Time of Arrival'
          rows.append((key,answer,hint))
        fullpool=[v for k,v in TABLES[name].items() if re.match(r'^[A-Za-z]',k) and len(v)<110 and 'See' not in v and 'OR' not in v]
        for short,answer,hint in rows:
          domain={'medical':'الاختصارات الطبية في قائمة MedlinePlus','nasa':'مصطلحات ناسا العلمية والهندسية','un':'الاقتصاد والمنظمات الدولية في دليل الأمم المتحدة'}[name]
          text=f'في {domain}، ما التوسّع الإنجليزي للاختصار {short}؟'
          words=set(answer.lower().split())
          pool=sorted(fullpool,key=lambda x:len(words&set(x.lower().split())),reverse=True)[:18]
          add('abbreviations',diff,text,answer,f'يرتبط السياق بـ{hint}؛ طابق الحروف الأولى مع المصطلح الكامل.',f'تسجل القائمة المرجعية {short} بمعنى {answer}. السياق هنا {hint}.',SOURCES[name],pool)
    techrows=[r.split('|') for r in TECH.strip().splitlines()]
    extras={'WAN':'https://www.itu.int/ITU-D/ict/publications/wtdr_99/material/glossary.html','USB':'https://www.usb.org/about','DHCP':'https://www.rfc-editor.org/rfc/rfc2131','ARP':'https://www.rfc-editor.org/rfc/rfc826','NAT':'https://www.rfc-editor.org/rfc/rfc2663','NTP':'https://www.rfc-editor.org/rfc/rfc5905','TGS':'https://www.rfc-editor.org/rfc/rfc4120','HMAC':'https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.198-1.pdf','CTR':'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf'}
    extras['WAN']='https://www.cisco.com/site/us/en/learn/topics/networking/what-is-a-wan-wide-area-network.html'
    for diff,short,answer,hint in techrows:
      allanswers=[r[2] for r in techrows]
      words=set(answer.lower().split())
      pool=sorted(allanswers,key=lambda x:len(words&set(x.lower().split())),reverse=True)[:18]
      add('abbreviations',diff,f'في الشبكات وأمن المعلومات، وفي سياق {hint.split("؛")[0]}، ما التوسّع الإنجليزي للاختصار {short}؟',answer,'انتبه إلى الوظيفة المحددة؛ للاختصار نفسه توسعات أخرى خارج هذا السياق.',f'{short} يختصر {answer} في هذا السياق. يُميّز معنى الحروف المجال المحدد في السؤال.',extras.get(short,SOURCES['internet']),pool)

author()
