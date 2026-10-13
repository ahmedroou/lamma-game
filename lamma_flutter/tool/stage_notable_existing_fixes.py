import json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def q(identifier,difficulty,text,answer,hint,explanation,options,source):
 return dict(id=identifier,categoryId='notable_figures',difficulty=difficulty,text=text,answer=answer,acceptedAnswers=[],hint=hint,clues=[],explanation=explanation,options=[dict(id=chr(65+i),text=s)for i,s in enumerate(options)],correctOptionId=chr(65+options.index(answer)),sources=source,qualityStatus='reviewed')
out=[q('notable_figures-medium-0189','medium','من عزل الستربتوميسين سنة 1943 أثناء عمله ضمن مشروع سلمان واكسمان لدراسة ميكروبات التربة؟','ألبرت شاتز','كان باحثاً ضمن فريق روتجرز، ويختلف اسمه عن اسم مدير المشروع الذي نال نوبل لاحقاً.','تنص مؤسسة نوبل على أن زميل واكسمان، ألبرت شاتز، عزل الستربتوميسين سنة 1943؛ أشرف واكسمان على برنامج البحث ونال الجائزة في 1952.',['سلمان واكسمان','ألكسندر فليمنغ','ألبرت شاتز','غيرهارد دوماك','هوارد فلوري','إرنست تشين'],['https://www.nobelprize.org/prizes/medicine/1952/waksman/facts/ — فقرة Work المقروءة تميز عزل شاتز عن إشراف واكسمان.']),
q('notable_figures-hard-0008','hard','من الفلكي المصري صاحب «الزيج الحاكمي الكبير»، الذي فصل أرصاده عن أرصاد من سبقه ووصف اقترانات كوكبية وخسوفات قمرية بدقة؟','ابن يونس المصري','حظي بدعم الخليفتين الفاطميين العزيز والحاكم، وأهدى عمله إلى الثاني.','جمع ابن يونس الأرصاد مع نسبتها لأصحابها في الزيج. لا يوجد دليل يثبت استعماله الرقاص لقياس الزمن؛ أزيلت النسبة الخاطئة من السؤال القديم.',['محمد البتاني','أبو الريحان البيروني','ابن يونس المصري','أبو الوفاء البوزجاني','أبو سهل القوهي','أبو محمود الخجندي'],['https://mathshistory.st-andrews.ac.uk/Biographies/Yunus/ — وصف الزيج والأرصاد وبيان عدم ثبوت نسبة الرقاص.'])]
out[0]['acceptedAnswers']=['Albert Schatz','ألبرت شاتس','البرت شاتز']
out[1]['acceptedAnswers']=['ابن يونس','Ibn Yunus']
p=ROOT/'tool/staging/notable_existing_fixes.json';p.write_text(json.dumps(dict(categoryId='notable_figures',questions=out),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
print('FIXES',len(out),hashlib.sha256(p.read_bytes()).hexdigest())
