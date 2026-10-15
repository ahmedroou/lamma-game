"""Media transcription of individually selected sources; no editorial validator.

No fallback, no bank writes, no reviewed approvals. Every selected excerpt remains
pending a person who can actually listen to its final MP3.
"""
import json
import pathlib
import subprocess
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[3]
BASE = pathlib.Path(__file__).resolve().parent
FFMPEG = ROOT / 'tool/audio_pipeline/node_modules/ffmpeg-static/ffmpeg.exe'
SOURCES = BASE / 'sources'

# These are literal editorial decisions, not inferred selections or substitutions.
CUTS = [
    {'number': 51, 'title': 'File:Phrase de Neil Armstrong.oga', 'start': 0, 'end': 7.7,
     'speaker': 'نيل أرمسترونغ', 'transcript': "That's one small step for man, one giant leap for mankind.",
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Phrase_de_Neil_Armstrong.oga.en.srt',
     'license': 'Public domain — NASA recording (PD-USGov-NASA)',
     'licenseUrl': 'https://www.nasa.gov/nasa-brand-center/images-and-media/',
     'attribution': 'NASA / Neil Armstrong, Apollo 11, 21 July 1969 UTC. MP3 conversion; no voice imitation.',
     'explanation': 'صوت نيل أرمسترونغ عند خطوته الأولى على سطح القمر في مهمة أبوللو 11؛ التاريخ بتوقيت UTC هو 21 يوليو 1969.'},
    {'number': 52, 'title': 'File:Winston Churchill - Be Ye Men of Valour.ogg', 'start': 0.2, 'end': 9.6,
     'speaker': 'ونستون تشرشل', 'transcript': 'I speak to you for the first time as Prime Minister in a solemn hour for the life of our country, of our empire.',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Winston_Churchill_-_Be_Ye_Men_of_Valour.ogg.en.srt',
     'license': 'Public domain — expired Crown copyright, as documented on the file page',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:Winston_Churchill_-_Be_Ye_Men_of_Valour.ogg#Licensing',
     'attribution': 'Winston Churchill / BBC, Be Ye Men of Valour, 19 May 1940; Commons uploader TeleComNasSprVen. Excerpt and MP3 conversion.',
     'explanation': 'صوت ونستون تشرشل في بث Be Ye Men of Valour في 19 مايو 1940. هذا ليس تسجيل خطاب «سنقاتل على الشواطئ»؛ صُحح السياق الخاطئ السابق.'},
    {'number': 54, 'title': 'File:03 ALBERT EINSTEIN.ogg', 'start': 0.5, 'end': 11.7,
     'speaker': 'ألبرت أينشتاين', 'transcript': "Ladies and gentlemen, our age is proud of the progress it has made in man's intellectual development.",
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:03_ALBERT_EINSTEIN.ogg.en.srt',
     'license': 'CC BY-SA 3.0 Unported — excerpt distributed under the same license',
     'licenseUrl': 'https://creativecommons.org/licenses/by-sa/3.0/',
     'attribution': 'Radio Universidad Nacional de La Plata / Albert Einstein, 1943; permission ticket 2014041010009117. Excerpt and MP3 conversion; CC BY-SA 3.0.',
     'explanation': 'تسجيل حقيقي لألبرت أينشتاين من كلمة عام 1943 عن التطور الفكري والبحث عن المعرفة، من محفوظات Radio Universidad Nacional de La Plata. لا علاقة له بالكتاب المقروء بصوت Paul Adams ولا بشرح معادلة الكتلة والطاقة.'},
    {'number': 59, 'title': 'File:White House Millennium Lecture Series - -2 - Stephen Hawking30s.ogg', 'start': 0, 'end': 8.8,
     'speaker': 'ستيفن هوكينغ', 'transcript': 'Nearly all the visions of the future that we have been shown from H.G. Wells onwards have been essentially static.',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:White_House_Millennium_Lecture_Series_-_-2_-_Stephen_Hawking30s.ogg.en.srt',
     'license': 'Public domain — White House Television official recording; NARA 5860063',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:White_House_Millennium_Lecture_Series_-_-2_-_Stephen_Hawking30s.ogg#Licensing',
     'attribution': 'Courtesy; William J. Clinton Presidential Library. White House Television, Stephen Hawking lecture, 6 March 1998. Excerpt and MP3 conversion.',
     'explanation': 'ستيفن هوكينغ يتحدث بجهاز توليد الصوت في محاضرة البيت الأبيض «Imagination and Change» بتاريخ 6 مارس 1998. التسجيل أرشيف حقيقي لا استنساخًا جديدًا لصوته.'},
    {'number': 60, 'title': 'File:Roosevelt Infamy.ogg', 'start': 0, 'end': 14.2,
     'speaker': 'فرانكلين روزفلت', 'transcript': 'Yesterday, December 7, 1941 — a date which will live in infamy.',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Roosevelt_Infamy.ogg.en.srt',
     'license': 'Original recording public domain; W. Guy Finley derivative CC BY-SA 2.0; excerpt CC BY-SA 2.0',
     'licenseUrl': 'https://creativecommons.org/licenses/by-sa/2.0/',
     'attribution': 'Franklin D. Roosevelt; John G. Bradley recording / NARA 1436350; W. Guy Finley derivative. Excerpt and MP3 conversion under CC BY-SA 2.0.',
     'explanation': 'صوت فرانكلين روزفلت في مستهل خطاب 8 ديسمبر 1941 أمام الكونغرس، عن هجوم بيرل هاربر في اليوم السابق. استُبدل المصدر السابق الذي كان تسجيلاً مختلفًا بعنوان Americanism.'},
    {'number': 76, 'title': 'File:Florence Nightingale voice - 1576A 2nd Rendition Crop.ogg', 'start': 0, 'end': 9.9,
     'speaker': 'فلورنس نايتينجيل', 'transcript': 'When I am no longer even a memory, just a name.',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Florence_Nightingale_voice_-_1576A_2nd_Rendition_Crop.ogg.en.srt',
     'license': 'Public domain — 1890 published historical sound recording; PD-old-100-expired',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:Florence_Nightingale_voice_-_1576A_2nd_Rendition_Crop.ogg',
     'attribution': 'Florence Nightingale, wax-cylinder recording, 30 July 1890. Excerpt and MP3 conversion; final spoken name at 41 seconds excluded.',
     'explanation': 'صوت فلورنس نايتينجيل في تسجيل الأسطوانة الشمعية بتاريخ 30 يوليو 1890 لدعم قدامى محاربي بالاكلافا. المقتطف يتجنب توقيعها المنطوق في نهاية المصدر.'},
    {'number': 56, 'title': 'File:Jfk berlin address high.ogg', 'start': 550.65, 'end': 558,
     'speaker': 'جون كينيدي', 'transcript': 'As a free man, I take pride in the words: Ich bin ein Berliner!',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Jfk_berlin_address_high.ogg.en.srt',
     'license': 'Public domain — US federal government recording (PD-USGov)',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:Jfk_berlin_address_high.ogg#Licensing',
     'attribution': 'John F. Kennedy Presidential Library / John F. Kennedy, Berlin, 26 June 1963. Excerpt and MP3 conversion. Early crowd chanting his name excluded.',
     'explanation': 'صوت جون كينيدي في ختام خطاب برلين بتاريخ 26 يونيو 1963، متحدثًا بالإنجليزية والألمانية. هذا ليس خطاب تنصيبه عام 1961 ولا كلمة معاهدة الحظر الجزئي للتجارب النووية.'},
    {'number': 68, 'title': 'File:Nixon Resign.ogg', 'start': 0.8, 'end': 7.95,
     'speaker': 'ريتشارد نيكسون', 'transcript': 'Therefore I shall resign the presidency effective at noon tomorrow.',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Nixon_Resign.ogg.en.srt',
     'license': 'CC BY-SA 2.0 Generic — W. Guy Finley cleanup/section of original public-domain recording; excerpt CC BY-SA 2.0',
     'licenseUrl': 'https://creativecommons.org/licenses/by-sa/2.0/',
     'attribution': 'Richard Nixon / MSU Vincent Voice Library; cleanup and selection by W. Guy Finley. Excerpt and MP3 conversion under CC BY-SA 2.0.',
     'explanation': 'ريتشارد نيكسون يعلن مساء 8 أغسطس 1974 استقالته النافذة ظهر اليوم التالي. استُبدلت إحالته القديمة إلى إعلان انتخابي لعام 1960.'},
    {'number': 74, 'title': 'File:Tear down this wall.ogv', 'start': 710.3, 'end': 720,
     'speaker': 'رونالد ريغان', 'transcript': 'Mr. Gorbachev, tear down this wall!',
     'transcriptSource': 'https://commons.wikimedia.org/wiki/TimedText:Tear_down_this_wall.ogv.en.srt',
     'license': 'Public domain — official White House recording (PD-USGov)',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:Tear_down_this_wall.ogv#Licensing',
     'attribution': 'The White House / Ronald Reagan, Brandenburg Gate, Berlin, 12 June 1987. Audio excerpt and MP3 conversion.',
     'explanation': 'رونالد ريغان في نداء «اهدم هذا الجدار» عند بوابة براندنبورغ بتاريخ 12 يونيو 1987. استُبدل المصدر القديم الذي كان خطاب تنصيبه الأول عام 1981.'},
    {'number': 53, 'title': 'File:Martin Luther King, Jr. speaks about Barry Goldwater at a press conference at Amsterdam Airport Schiphol, August 1964 (audio from Polygoon).oga', 'start': 0, 'end': 12,
     'speaker': 'مارتن لوثر كينغ', 'transcript': '', 'transcriptSource': '',
     'license': 'CC BY-SA 3.0 Netherlands — excerpt under the same license',
     'licenseUrl': 'https://creativecommons.org/licenses/by-sa/3.0/nl/deed.en',
     'attribution': 'Polygoon Hollands Nieuws / Netherlands Institute for Sound and Vision, Open Images, Amsterdam Schiphol, 15 August 1964. Excerpt and MP3 conversion; CC BY-SA 3.0 NL.',
     'explanation': 'التسجيل الأرشيفي لمارتن لوثر كينغ في مؤتمر صحفي بمطار سخيبول بتاريخ 15 أغسطس 1964 عن باري غولدووتر؛ ليس خطاب «لدي حلم». التفريغ والاستماع النهائي لم يُنجزا.'},
    {'number': 55, 'title': 'File:Nelson Mandela voice.ogg', 'start': 0.5, 'end': 12.5,
     'speaker': 'نيلسون مانديلا', 'transcript': '', 'transcriptSource': '',
     'license': 'Public domain — official White House/Clinton Library recording (PD-USGov)',
     'licenseUrl': 'https://commons.wikimedia.org/wiki/File:Nelson_Mandela_voice.ogg#Licensing',
     'attribution': 'Courtesy; William J. Clinton Presidential Library. White House recording of Nelson Mandela state visit, 4 October 1994. Excerpt and MP3 conversion.',
     'explanation': 'مقتطف من الملف الأرشيفي لزيارة نيلسون مانديلا الرسمية للولايات المتحدة بتاريخ 4 أكتوبر 1994. يُسحب الادعاء السابق بأنه خطاب الإفراج عام 1990؛ بداية المقتطف وتفريغه ينتظران الاستماع.'},
    {'number': 69, 'title': "File:Prime Minister Margaret Thatcher's Joint Statement, 10th G7 summit.ogg", 'start': 62, 'end': 74,
     'speaker': 'مارغريت تاتشر', 'transcript': '', 'transcriptSource': '',
     'license': 'CC BY 3.0 Unported — Reagan Library release (also official US government recording)',
     'licenseUrl': 'https://creativecommons.org/licenses/by/3.0/',
     'attribution': 'Courtesy Ronald Reagan Presidential Library / White House Television Office, Guildhall G7 joint statement, 9 June 1984. Excerpt and MP3 conversion; CC BY 3.0.',
     'explanation': 'مصدر المقتطف كلمة مارغريت تاتشر المشتركة لقمة مجموعة السبع في غيلدهول بتاريخ 9 يونيو 1984. الصفحة تؤرخ بدء قراءتها عند 1:02. ليس خطاب «السيدة لن تتراجع» لعام 1980؛ التفريغ والاستماع قيد الانتظار.'},
    {'number': 86, 'title': 'File:10 PABLO PICASO.ogg', 'start': 0, 'end': 12,
     'speaker': 'بابلو بيكاسو', 'transcript': '', 'transcriptSource': '',
     'license': 'CC BY-SA 3.0 Unported — excerpt under the same license',
     'licenseUrl': 'https://creativecommons.org/licenses/by-sa/3.0/',
     'attribution': 'Radio Universidad Nacional de La Plata / Pablo Picasso; Commons collection permission ticket 2014041010009117. Excerpt and MP3 conversion; CC BY-SA 3.0.',
     'explanation': 'مصدر حقيقي موصوف بأنه صوت بابلو بيكاسو من مجموعة Radio Universidad Nacional de La Plata المرخصة. لا تُنسب هذه القصّة إلى إذاعة فرنسا أو سياق محدد قبل تفريغها؛ الاستماع وتحديد وجود مذيع في البداية قيد الانتظار.'},
]

def load_pages():
    pages = {}
    for filename in ['original-claimed-file-pages.json', 'builder-claimed-file-pages.json', 'replacement-candidates-01.json', 'replacement-candidates-02.json', 'replacement-candidates-03.json']:
        data = json.loads((SOURCES / filename).read_text(encoding='utf8'))
        pages.update({x['title']: x for x in data['query']['pages'].values()})
    return pages

def main():
    pages = load_pages()
    raw = SOURCES / 'raw'
    raw.mkdir(exist_ok=True)
    results = []
    for cut in CUTS:
        info = pages[cut['title']]['imageinfo'][0]
        number = cut['number']
        original = raw / (f'source-{number:03}' + pathlib.Path(cut['title']).suffix)
        if not original.exists():
            req = urllib.request.Request(info['url'], headers={'User-Agent': 'LammaEditorialRepair/1.0'})
            try:
                with urllib.request.urlopen(req, timeout=90) as response:
                    original.write_bytes(response.read())
            except Exception as exc:
                print(f'Source voice-{number:03} not prepared: {exc}; no fallback.', flush=True)
                continue
        output = ROOT / f'assets/question_audio/voice-{number:03}.mp3'
        subprocess.run([str(FFMPEG), '-hide_banner', '-loglevel', 'error', '-y', '-ss', str(cut['start']),
                        '-i', str(original), '-t', str(cut['end']-cut['start']), '-vn', '-map_metadata', '-1',
                        '-ac', '1', '-ar', '24000', '-b:a', '48k', str(output)], check=True)
        decoded = subprocess.run([str(FFMPEG), '-hide_banner', '-loglevel', 'error', '-i', str(output),
                                  '-f', 's16le', '-acodec', 'pcm_s16le', '-ac', '1', '-ar', '24000', '-'],
                                 check=True, capture_output=True).stdout
        duration = round(len(decoded) / 2 / 24000 * 1000)
        result = dict(cut, directUrl=info['url'], sourceUrl=info['descriptionurl'],
                      durationMs=duration, sourceStartMs=round(cut['start']*1000), sourceEndMs=round(cut['end']*1000),
                      assetPath=f'assets/question_audio/voice-{number:03}.mp3',
                      reviewStatus='sourceVerified' if cut['transcript'] else 'unverified', listeningStatus='pending-model-does-not-support-audio-input')
        results.append(result)
        (BASE / 'source_verified_cuts.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf8')
        print(f'Prepared genuine source voice-{number:03}; decoded duration {duration} ms; listening pending.', flush=True)

if __name__ == '__main__':
    main()
