"""Prepare the 88 individually selected BBC source candidates outside app assets.

No question mutation, no approval, no substitute audio on failed download.
"""
import datetime,hashlib,json,pathlib,re,subprocess,sys,time,urllib.request,urllib.error
from research_voice_sources import ROOT,OUT,plain

FFMPEG=ROOT/'tool/audio_pipeline/node_modules/ffmpeg-static/ffmpeg.exe'
PREP=ROOT/'design_sources/character_voice_repair/prepared-bbc-20261015'
PREP.mkdir(exist_ok=True)
pages=list({p['title']:p for file in ['commons-candidates.json','bbc-candidates.json']
    for p in json.loads((OUT/file).read_text(encoding='utf-8'))}.values())
selected=[]
cut_file=OUT/'cut_overrides.json'
overrides=json.loads(cut_file.read_text(encoding='utf-8')) if cut_file.exists() else {}
for index,line in enumerate((OUT/'selected_bbc_speakers.tsv').read_text(encoding='utf-8').splitlines(),1):
    prefix,speaker,hint=line.split('\t')
    matches=[p for p in pages if p['title'].startswith('File:'+prefix)]
    if not matches: matches=[p for p in pages if prefix.casefold() in p['title'].casefold()]
    if len(matches)!=1: raise ValueError(f'{prefix}: expected one source, got {[p["title"] for p in matches]}')
    page=matches[0]; info=page['imageinfo'][0]; meta=info['extmetadata']
    license=plain(meta.get('LicenseShortName',{}).get('value'))
    if license!='CC BY 3.0': raise ValueError(f'Unreviewed license {speaker}: {license}')
    description=plain(meta.get('ImageDescription',{}).get('value'))
    if not description:
        description='Source title: '+page['title']+'; source categories: '+plain(meta.get('Categories',{}).get('value'))
    selected.append(dict(candidate=index,speaker=speaker,hint=hint,sourceTitle=page['title'],
        sourcePageId=page['pageid'],sourceUrl=info['descriptionurl'],sourceMediaUrl=info['url'],
        originalSha1=info['sha1'],sourceDurationMs=round(info['duration']*1000),
        sourceDescription=description,license=license,
        licenseUrl=meta['LicenseUrl']['value'],attribution='BBC; '+page['title'][5:]+'. Excerpt, mono conversion and loudness normalization by Lamma; CC BY 3.0. No endorsement.',
        sourceStartMs=2000,sourceEndMs=min(round(info['duration']*1000),16000),
        recordingId='commons-'+str(page['pageid']),reviewStatus='sourceVerified',listeningStatus='pending'))
    if str(index) in overrides:
        selected[-1].update({k:v for k,v in overrides[str(index)].items() if k in ['sourceStartMs','sourceEndMs']})

(OUT/'selected-bbc-manifest.json').write_text(json.dumps(selected,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

def prepare(row):
    number=row['candidate']; source=PREP/f'candidate-{number:03}.flac'; output=PREP/f'candidate-{number:03}.mp3'
    try:
        if not source.exists() or hashlib.sha1(source.read_bytes()).hexdigest()!=row['originalSha1']:
            for attempt in range(3):
                try:
                    req=urllib.request.Request(row['sourceMediaUrl'],headers={'User-Agent':'LammaVoiceResearch/1.0'})
                    with urllib.request.urlopen(req,timeout=120) as response,source.with_suffix('.part').open('wb') as file:
                        while block:=response.read(128*1024): file.write(block)
                    source.with_suffix('.part').replace(source)
                    break
                except urllib.error.HTTPError as error:
                    if error.code!=429 or attempt==2: raise
                    wait=max(15,float(error.headers.get('Retry-After','30')))
                    (OUT/'download-cooldown.json').write_text(json.dumps({'reason':'HTTP 429 Retry-After from source',
                        'notBeforeEpoch':time.time()+wait})+'\n')
                    print(f'Source cooldown for candidate {number:03}: {wait:.0f} seconds; no substitute used.',flush=True)
                    while wait>0:
                        duration=min(wait,10);time.sleep(duration);wait-=duration
            if hashlib.sha1(source.read_bytes()).hexdigest()!=row['originalSha1']: raise ValueError('Source bytes differ from Commons SHA1')
        cut_path=PREP/f'candidate-{number:03}.cut.json'
        expected_cut=[row['sourceStartMs'],row['sourceEndMs']]
        previous_cut=json.loads(cut_path.read_text()) if cut_path.exists() else [2000,min(row['sourceDurationMs'],16000)]
        if not output.exists() or expected_cut!=previous_cut:
            subprocess.run([str(FFMPEG),'-nostdin','-v','error','-y','-ss',str(row['sourceStartMs']/1000),'-i',str(source),
                '-t',str((row['sourceEndMs']-row['sourceStartMs'])/1000),'-vn','-ac','1','-ar','24000','-b:a','48k',
                '-af','loudnorm=I=-16:TP=-1.5:LRA=11','-map_metadata','-1',str(output)],check=True,capture_output=True)
        cut_path.write_text(json.dumps(expected_cut)+'\n')
        print(f'Prepared {number:03}',flush=True)
        return {**row,'preparedPath':output.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(output.read_bytes()).hexdigest()}
    except Exception as error:
        print(f'FAILED {number:03}: {error}',flush=True)
        return {**row,'error':str(error),'reviewStatus':'unverified'}

if __name__=='__main__':
    if '--manifest-only' in sys.argv:
        print('Source manifest prepared for',len(selected),'individual candidates; no media downloaded.')
        sys.exit(0)
    cooldown=OUT/'download-cooldown.json'
    if cooldown.exists():
        wait=max(0,json.loads(cooldown.read_text())['notBeforeEpoch']-time.time())
        if wait: print('Respecting source cooldown for',round(wait),'seconds.',flush=True)
        while wait>0:
            time.sleep(min(wait,10));wait=max(0,json.loads(cooldown.read_text())['notBeforeEpoch']-time.time())
    results=[]
    for row in selected:
        existed=(PREP/f'candidate-{row["candidate"]:03}.mp3').exists()
        result=prepare(row)
        results.append(result)
        (OUT/'prepared-bbc-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        if not existed: time.sleep(15)
    print('Prepared',sum('error' not in r for r in results),'of',len(results),'; no questions approved.',flush=True)
