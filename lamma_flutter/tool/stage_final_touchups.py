"""Final, explicitly authored repairs. Never writes production banks."""
import hashlib
import json
from itertools import product
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
STAGE=ROOT/'tool/staging'

def save(path,value):
    path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

def identity(identifier,answer,clues,hint,explanation,wrong,source,aliases=()):
    values=[*wrong[:2],answer,*wrong[2:]]
    return dict(id=identifier,categoryId='who_am_i',difficulty='hard',text='من أنا؟',
        answer=answer,acceptedAnswers=list(aliases),clues=clues,hint=hint,explanation=explanation,
        sources=[source],options=[dict(id=chr(65+i),text=v) for i,v in enumerate(values)],
        correctOptionId='C',qualityStatus='reviewed')

def main():
    fixes=[
        identity('who_am_i-hard-0069','ماري بوتنام جاكوبي',[
            'طبيبة وُلدت في لندن سنة 1842 لأبوين أمريكيين، ثم نشأت في نيويورك.',
            'دافعت عن تعليم النساء الطبي مع الرجال، وأنشأت في نيويورك جمعية لتطوير تعليمهن الطبي سنة 1872.',
            'فاز بحثي عن الراحة أثناء الحيض بجائزة بويلستون في هارفارد سنة 1876؛ دعمته بجداول وقياسات للنبض.'
        ],'ميّز بين طبيبة كتبت بحثًا تجريبيًا ومن عُرفت بأسبقية التخرج وحدها.',
        'تربط سيرة المكتبة الوطنية للطب بين الميلاد في لندن والجمعية التعليمية والبحث الحائز جائزة بويلستون؛ وهي قرائن لماري بوتنام جاكوبي.',
        ['إليزابيث بلاكويل','إميلي بلاكويل','ريبيكا كول','ماري إدواردز ووكر','سوزان لا فليش بيكوت'],
        'https://www.nlm.nih.gov/exhibition/changing-the-face-of-medicine/physicians/biography_mary_jacobi.html?id=item-163',
        ['Mary Putnam Jacobi','ماري كورينا بوتنام جاكوبي']),
        identity('who_am_i-hard-0085','جزيرة ماكواري',[
            'جزيرة نائية في المحيط الجنوبي تؤوي تجمعات كبيرة من البطاريق والفقمات.',
            'أقع نحو 1500 كيلومتر جنوب شرق تسمانيا، تقريبًا بين أستراليا والقارة القطبية الجنوبية.',
            'أنا الجزء الظاهر من حيد بحري عند التقاء صفائح؛ تنكشف فوق البحر فيّ صخور من القشرة المحيطية والوشاح العلوي.'
        ],'الموقع وتكوين الصخور معًا يميزانني عن جزر جنوبية تشتهر بالبطاريق فقط.',
        'تحدد اليونسكو موقع ماكواري جنوب شرق تسمانيا، وتوثق انكشاف القشرة المحيطية والوشاح مع مستعمرات البطاريق والفقمات.',
        ['جزيرة هيرد','جزيرة كيرغولين','جزيرة كامبل','جزيرة أوكلاند','جزيرة جورجيا الجنوبية'],
        'https://whc.unesco.org/en/list/629/', ['ماكواري','ماكّواري','Macquarie Island']),
        identity('who_am_i-hard-0082','وادي الحيتان',[
            'موقع أحفوري يحتفظ بسجل انتقال مجموعة من الثدييات من العيش على اليابسة إلى الحياة البحرية.',
            'تضم أحافيري هياكل لحيتان قديمة من الأركيوسيتات، وبعضها يحتفظ بآثار أطراف خلفية.',
            'أقع في الصحراء الغربية المصرية، داخل نطاق محمية وادي الريان، وأُدرجت في التراث العالمي سنة 2005.'
        ],'ابحث عن موقع مصري يجمع الصحراء ببقايا ثدييات بحرية.',
        'توثق اليونسكو أحافير الحيتان القديمة في هذا الموقع المصري، ضمن محمية وادي الريان، وتاريخ إدراجه سنة 2005.',
        ['حفريات جوغنز','حفريات ميستاكِن بوينت','موقع حفريات ريفرسلي','حفرة ميسيل','حديقة إشيغوالاستو'],
        'https://whc.unesco.org/en/list/1186/', ['Wadi Al-Hitan']),
        identity('who_am_i-hard-0050','ضريح خواجة أحمد يسوي',[
            'مبنى ديني ضخم من الآجر يمثل مرحلة مبكرة مؤثرة من العمارة التيمورية.',
            'أمر تيمور ببنائي بين 1389 و1405، وبقي بعضي غير مكتمل بعد وفاته.',
            'أقع في مدينة تركستان، التي عُرفت باسم ياسي، في كازاخستان؛ وأُنشئت لتخليد شيخ صوفي من القرن الثاني عشر.'
        ],'اجمع بين مدينة ياسي والدولة الحالية، ولا تفترض أن كل مبنى تيموري يقع في سمرقند.',
        'تثبت اليونسكو زمن البناء بأمر تيمور، وتوقفه سنة 1405، والموقع في تركستان بكازاخستان؛ وهذه قرائن ضريح أحمد يسوي.',
        ['ضريح غور أمير','مجمع شاه زنده','ضريح إسماعيل الساماني','ضريح السلطان سنجر','ضريح أولجايتو'],
        'https://whc.unesco.org/en/list/1103/', ['ضريح أحمد يسوي','Mausoleum of Khoja Ahmed Yasawi']),
        identity('who_am_i-hard-0049','ريبيكا لي كرامبلر',[
            'طبيبة أمريكية عملت بعد الحرب الأهلية على رعاية محرَّرين من العبودية في ريتشموند.',
            'نشرت سنة 1883 كتابًا في الإرشادات الطبية للنساء والأطفال، مستندة إلى خبرتي في الممارسة.',
            'بتخرجي سنة 1864 من كلية نيو إنغلاند الطبية النسائية أصبحت أول أمريكية من أصل إفريقي تحصل على شهادة الطب MD.'
        ],'ميّز أسبقية سنة 1864 عن طبيبة أخرى من أصل إفريقي تخرجت سنة 1867.',
        'توثق المكتبة الوطنية للطب تخرج كرامبلر سنة 1864، ورعاية المحرَّرين في ريتشموند، وكتابها الطبي المنشور سنة 1883.',
        ['ريبيكا كول','ماري إليزا ماهوني','سوزان لا فليش بيكوت','إليزابيث بلاكويل','ماري بوتنام جاكوبي'],
        'https://www.nlm.nih.gov/exhibition/changing-the-face-of-medicine/physicians/biography_rebecca_crumpler.html',
        ['Rebecca Lee Crumpler','ريبيكا كرامبلر'])
    ]
    save(STAGE/'who_existing_fixes.json',fixes)

    riddles=json.loads((STAGE/'riddles.json').read_text(encoding='utf-8'))
    q=next(q for q in riddles['questions'] if q['id']=='riddles-easy-0219')
    solution=[10*a+b for a,b in product(range(1,10),repeat=2) if a+b==7 and a*b==12 and a%2==1]
    assert solution==[34]
    q.update(text='قفل رمزه عدد من رقمين غير صفريين. مجموع الرقمين 7 وحاصل ضربهما 12، ورقم العشرات فردي. ما الرمز؟',
        answer='34',acceptedAnswers=[],hint='حل شرطَي المجموع والضرب أولًا، ثم استخدم شرط العشرات لاختيار الترتيب.',
        explanation='الرقمان هما 3 و4 لأن مجموعهما 7 وحاصل ضربهما 12. شرط العشرات الفردية يستبعد 43 ويترك 34 وحده.',
        sources=['لغز أصلي؛ فحص جميع أزواج الرقمين من 1 إلى 9 يترك الرمز 34 وحده عند تطبيق الشروط الثلاثة.'],
        options=[dict(id=chr(65+i),text=v) for i,v in enumerate(['25','43','52','61','34','16'])],
        correctOptionId='E',qualityStatus='reviewed')
    save(STAGE/'riddles.json',riddles)
    proofs=json.loads((ROOT/'tool/reasoning_proofs.json').read_text(encoding='utf-8'))
    proof=next(p for p in proofs if p['id']==q['id'])
    proof.clear()
    proof.update(id=q['id'],engine='two_digit_lock',digitSum=7,digitProduct=12,oddTens=True,solution=34)
    save(ROOT/'tool/reasoning_proofs.json',proofs)

    science=json.loads((STAGE/'how_it_works.json').read_text(encoding='utf-8'))
    q=next(q for q in science['questions'] if q['id']=='how_it_works-legendary-0201')
    q.update(text='توجد شحنة موجبة معزولة داخل تجويف مغلق في موصل متعادل، ولا تلامس الجدار. في الاتزان الكهروستاتيكي، كيف يصبح مجموع الشحنة على السطح الداخلي للتجويف؟',
        answer='سالبًا ومساويًا في المقدار للشحنة الداخلية',
        hint='طبق قانون غاوس على سطح داخل مادة الموصل يحيط بالتجويف.',
        explanation='المجال داخل مادة الموصل صفر في الاتزان، لذا فالتدفق عبر سطح غاوسي داخلها صفر. يلزم أن تلغي الشحنة المستحثة على السطح الداخلي الشحنة المعزولة: محصلتها سالبة وبالمقدار نفسه، وتظهر شحنة موجبة مقابلة على السطح الخارجي للموصل المتعادل.',
        options=[dict(id=chr(65+i),text=v) for i,v in enumerate([
            'صفرًا لأن الشحنة الداخلية لا تلامس الجدار',
            'موجبًا ومساويًا في المقدار للشحنة الداخلية',
            'سالبًا ونصف مقدار الشحنة الداخلية دائمًا',
            'سالبًا ومساويًا في المقدار للشحنة الداخلية',
            'موجبًا وضعف مقدار الشحنة الداخلية دائمًا',
            'متغيرًا بحسب موقع الشحنة دون قيمة إجمالية ثابتة'])],correctOptionId='D',acceptedAnswers=[])
    save(STAGE/'how_it_works.json',science)

    manifest=json.loads((STAGE/'science_puzzles_manifest.json').read_text(encoding='utf-8'))
    for category in ('how_it_works','riddles'):
        manifest[category]['sha256']=hashlib.sha256((STAGE/f'{category}.json').read_bytes()).hexdigest()
    save(STAGE/'science_puzzles_manifest.json',manifest)
    print('Staged five identity replacements, one verified riddle replacement and precise cavity question.')

if __name__=='__main__':main()
