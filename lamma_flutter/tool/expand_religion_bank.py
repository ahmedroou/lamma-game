"""Compile the hand-authored religion expansion; preserves existing question IDs."""
import json, re, unicodedata, sys
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
def plain(value):
    value = ''.join(c for c in value if not unicodedata.combining(c) and c not in '\u200f\u200eـ')
    return re.sub(r'\s+', ' ', value).strip()

def options(answer, distractors, offset):
    assert len(distractors) == 5
    values = list(distractors)
    index = offset % 6
    values.insert(index, answer)
    assert len({plain(v) for v in values}) == 6, values
    return [dict(id=chr(65+i), text=v) for i,v in enumerate(values)], chr(65+index)

def save(category, new):
    p = ROOT / 'assets/questions' / (category+'.json')
    bank = json.loads(p.read_text(encoding='utf8'))
    bank['questions'] = [q for q in bank['questions'] if int(q['id'].rsplit('-',1)[-1]) <= 200]
    assert len(new) == 100, (category, len(new))
    assert Counter(q['difficulty'] for q in new) == dict.fromkeys(['easy','medium','hard','legendary'],25)
    existing = {plain(q['text']) for q in bank['questions']}
    assert not existing.intersection(plain(q['text']) for q in new)
    if '--staging' in sys.argv:
        folder=ROOT/'tool/staging';folder.mkdir(exist_ok=True)
        (folder/(category+'_expansion_100.json')).write_text(json.dumps(dict(categoryId=category,questions=new),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
        print(category,'STAGED',len(new))
        return
    bank['questions'].extend(new)
    bank['targetCount'] = 900
    bank['targetPerDifficulty'] = 225
    bank['status'] = 'draft'
    p.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print(category, len(bank['questions']), Counter(q['difficulty'] for q in bank['questions']))

def fields(category, ordinal, text, answer, hint, explanation, sources, wrong):
    difficulty = ['easy','medium','hard','legendary'][ordinal//25]
    answer=plain(answer)
    choices, correct = options(answer,[plain(v) for v in wrong],ordinal)
    return dict(id=f'{category}-{difficulty}-{201+ordinal%25:04d}',categoryId=category,
                difficulty=difficulty,text=text,answer=answer,acceptedAnswers=[],
                hint=hint,clues=[],explanation=explanation,sources=sources,options=choices,
                correctOptionId=correct,qualityStatus='reviewed')

def verses():
    source = json.loads((ROOT/'tool/religion_quran_simple_source.json').read_text(encoding='utf8'))['data']['surahs']
    old = json.loads((ROOT/'assets/questions/complete_verse.json').read_text(encoding='utf8'))['questions']
    used = {re.search(r'quran.com/(\d+)/(\d+)', ' '.join(q['sources'])).groups() for q in old if int(q['id'].rsplit('-',1)[-1])<=200}
    new=[]
    for i,line in enumerate((ROOT/'tool/religion_verse_expansion.tsv').read_text(encoding='utf8').splitlines()):
        ref, answer, hint, wrong = line.split('|')
        s,a = map(int,ref.split(':'))
        assert (str(s),str(a)) not in used, ref
        surah=source[s-1]
        raw=surah['ayahs'][a-1]['text']
        words=[w for w in raw.split() if not re.fullmatch(r'[۞ۖۗۘۙۚۛۜ۩]+',w)]
        normalized=[plain(w).replace('ٰ','') for w in words]
        match=[]
        for j in range(len(words)):
            for k in range(j+1,len(words)+1):
                if ' '.join(normalized[j:k]) == answer: match.append((j,k))
        assert len(match)==1,(ref,answer,plain(raw))
        j,k=match[0]
        exact=' '.join(words[j:k])
        before=' '.join(words[max(0,j-13):j]); after=' '.join(words[k:min(len(words),k+7)])
        excerpt=('… ' if j>13 else '')+before+' […]'+(' '+after if after else '')+(' …' if k+7<len(words) else '')
        text=f'أكمل العبارة مكان الفراغ كما وردت في سورة {plain(surah["name"]).replace("سورة ","")}، الآية {a}: «{excerpt.strip()}»'
        explanation=f'المقطع الصحيح: «{exact}». موضعه سورة {plain(surah["name"])}, الآية {a}، برواية حفص. السؤال يطلب النص القرآني حرفياً؛ صيغ الخيارات الأخرى مشتتات تعليمية وليست قراءات بديلة لهذا الموضع. {hint}'
        new.append(fields('complete_verse',i,text,exact,hint,explanation,[f'https://quran.com/{s}/{a}', f'https://api.alquran.cloud/v1/ayah/{s}:{a}/quran-simple'],wrong.split(';')))
    save('complete_verse',new)

def hadiths():
    data=json.loads((ROOT/'tool/religion_bukhari_source.json').read_text(encoding='utf8'))
    source={int(q['hadithnumber']):q for q in data['hadiths']}
    old=json.loads((ROOT/'assets/questions/complete_hadith.json').read_text(encoding='utf8'))['questions']
    used=set()
    for q in old:
        if int(q['id'].rsplit('-',1)[-1])>200:continue
        for s in q['sources']:
            m=re.search(r'bukhari[/:](\d+)',s)
            if m:used.add(int(m[1]))
    new=[]
    for i,line in enumerate((ROOT/'tool/religion_hadith_expansion.tsv').read_text(encoding='utf8').splitlines()):
        number,answer,narrator,hint,wrong=line.split('|')
        number=int(number); assert number not in used,number
        q=source[number]
        # Keep only quoted matn. Strip display punctuation for exact token matching.
        quotes=[plain(s) for s in q['text'].split('"')[1::2]]
        cleaned=lambda s:re.sub(r'[،,.؛{}()«»؟:]', '',plain(s))
        matches=[]
        for quote in quotes:
            words=quote.split(); norm=[cleaned(w) for w in words]
            wanted=cleaned(answer)
            for j in range(len(words)):
                for k in range(j+1,len(words)+1):
                    if ' '.join(norm[j:k])==wanted: matches.append((words,j,k))
        assert matches,(number,answer,quotes)
        words,j,k=matches[0]
        # The rendered blank is explicitly bounded by its surrounding text.
        before=' '.join(words[max(0,j-13):j]);after=' '.join(words[k:min(len(words),k+8)])
        excerpt=('… ' if j>13 else '')+before+' […]'+(' '+after if after else '')+(' …' if k+8<len(words) else '')
        bookid=str(q['reference']['book'])
        book={'1':'كتاب بدء الوحي','2':'كتاب الإيمان','3':'كتاب العلم','4':'كتاب الوضوء','5':'كتاب الغسل','6':'كتاب الحيض','7':'كتاب التيمم','8':'كتاب الصلاة','9':'كتاب مواقيت الصلاة','10':'كتاب الأذان'}.get(bookid,data['metadata']['sections'].get(bookid,''))
        text=f'أكمل العبارة مكان الفراغ في الرواية المحددة من صحيح البخاري ({number}): «{excerpt.strip()}»'
        honorific='رضي الله عنها' if narrator in ['عائشة','أم سلمة','أم عطية'] else ('رضي الله عنهما' if narrator in ['أسماء بنت أبي بكر','عبد الله بن عمر','عبد الله بن عمرو','عبد الله بن عباس','جابر بن عبد الله'] else 'رضي الله عنه')
        explanation=f'النص المطلوب في هذه الرواية: «{plain(answer)}». رواه {narrator} {honorific}؛ صحيح البخاري، {book}، حديث {number} (صحيح). السؤال يطلب لفظ الرواية المحددة؛ المشتتات صيغ تعليمية وليست روايات أخرى منسوبة للنبي ﷺ. {hint}'
        sources=[f'https://sunnah.com/bukhari:{number}',f'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari/{number}.json',f'صحيح البخاري، حديث {number}، رواية {narrator}، درجة الحديث: صحيح.']
        new.append(fields('complete_hadith',i,text,answer,hint,explanation,sources,wrong.split(';')))
    save('complete_hadith',new)

HISTORY_SOURCES={
 'calligraphy':'https://www.metmuseum.org/essays/calligraphy-in-islamic-art',
 'geometric':'https://www.metmuseum.org/essays/geometric-patterns-in-islamic-art',
 'vegetal':'https://www.metmuseum.org/essays/vegetal-patterns-in-islamic-art',
 'tiraz':'https://www.metmuseum.org/essays/tiraz-inscribed-textiles-from-the-early-islamic-period',
 'abbasid':'https://www.metmuseum.org/essays/the-art-of-the-abbasid-period-750-1258',
 'fatimid':'https://www.metmuseum.org/essays/the-art-of-the-fatimid-period-909-1171',
 'mamluk':'https://www.metmuseum.org/essays/the-art-of-the-mamluk-period-1250-1517',
 'ottoman':'https://www.metmuseum.org/essays/the-art-of-the-ottomans-before-1600',
 'safavid':'https://www.metmuseum.org/essays/the-art-of-the-safavids-before-1600',
 'ilkhanid':'https://www.metmuseum.org/essays/the-art-of-the-book-in-the-ilkhanid-period',
 'samarra':'https://whc.unesco.org/en/list/276/', 'khiva':'https://whc.unesco.org/en/list/543/',
 'bukhara':'https://whc.unesco.org/en/list/602/', 'samarkand':'https://whc.unesco.org/en/list/603/',
 'kairouan':'https://whc.unesco.org/en/list/499/', 'jeddah':'https://whc.unesco.org/en/list/1361/',
 'zabid':'https://whc.unesco.org/en/list/611/', 'sanaa':'https://whc.unesco.org/en/list/385/',
 'shibam':'https://whc.unesco.org/en/list/192/', 'tim':'https://whc.unesco.org/en/list/119/',
 'djenné':'https://whc.unesco.org/en/list/116/', 'urgench':'https://whc.unesco.org/en/list/1199/',
 'merv':'https://whc.unesco.org/en/list/886/'
}
def history():
    new=[]
    for i,line in enumerate((ROOT/'tool/religion_history_expansion.tsv').read_text(encoding='utf8').splitlines()):
        key,text,answer,hint,explanation,wrong=line.split('|')
        new.append(fields('islamic_history',i,text,answer,hint,explanation,[HISTORY_SOURCES[key]],wrong.split(';')))
    save('islamic_history',new)

if __name__=='__main__':
    import sys
    sys.stdout.reconfigure(encoding='utf8')
    verses()
    hadiths()
    history()
