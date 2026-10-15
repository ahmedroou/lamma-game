"""Locally transcribe actual prepared clips for editorial inspection; never approve."""
import argparse,datetime,hashlib,json,os,pathlib,sys,time,types,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0,str(pathlib.Path.home()/'.cache/lamma-audio-review/packages'))
os.environ['HF_HUB_DISABLE_XET']='1'
# Use FFmpeg's explicit mono waveform input. PyAV's native codec import hangs
# in this Windows runtime; no PyAV decoding path is used or emulated here.
av_unavailable=types.ModuleType('av')
def reject_pyav(name):
    raise RuntimeError('Use the FFmpeg waveform decoder in this research runner, not PyAV.')
av_unavailable.__getattr__=reject_pyav
sys.modules['av']=av_unavailable
import numpy as np
from faster_whisper import WhisperModel

OUT=ROOT/'design_sources/character_voice_repair/research-20261015'
PREP=ROOT/'design_sources/character_voice_repair/prepared-bbc-20261015'
parser=argparse.ArgumentParser()
parser.add_argument('--model',default='tiny.en')
parser.add_argument('--once',action='store_true')
args=parser.parse_args()
RESULT=OUT/('machine-transcripts.jsonl' if args.model=='tiny.en' else f'machine-transcripts-{args.model}.jsonl')
print('Loading transcription model '+args.model,flush=True)
model=WhisperModel(args.model,device='cpu',compute_type='int8',cpu_threads=4,
                  download_root=str(pathlib.Path.home()/'.cache/lamma-audio-review/models'))
done=set()
if RESULT.exists():
    done={json.loads(line)['sha256'] for line in RESULT.read_text(encoding='utf-8').splitlines()}

def transcribe(path):
    if time.time()-path.stat().st_mtime<3: return
    digest=hashlib.sha256(path.read_bytes()).hexdigest()
    if digest in done: return
    pcm=subprocess.run([str(ROOT/'tool/audio_pipeline/node_modules/ffmpeg-static/ffmpeg.exe'),
        '-nostdin','-v','error','-i',str(path),'-f','f32le','-ac','1','-ar','16000','pipe:1'],
        check=True,capture_output=True).stdout
    waveform=np.frombuffer(pcm,dtype=np.float32)
    segments,info=model.transcribe(waveform,language='en',beam_size=5,word_timestamps=True,
                                  condition_on_previous_text=False,vad_filter=False)
    segments=list(segments)
    row=dict(file=path.relative_to(ROOT).as_posix(),sha256=digest,model='Systran/faster-whisper-'+args.model,
        method='local-speech-recognition-not-human-listening',language=info.language,durationSeconds=info.duration,
        transcript=' '.join(s.text.strip() for s in segments),
        segments=[dict(start=s.start,end=s.end,text=s.text,avgLogprob=s.avg_logprob,noSpeechProb=s.no_speech_prob,
          words=[dict(start=w.start,end=w.end,text=w.word,probability=w.probability) for w in s.words or []]) for s in segments],
        transcribedAt=datetime.datetime.now(datetime.timezone.utc).isoformat())
    with RESULT.open('a',encoding='utf-8') as stream: stream.write(json.dumps(row,ensure_ascii=False)+'\n')
    done.add(digest)
    print(path.name+': '+row['transcript'],flush=True)

deadline=time.monotonic()+1800
while time.monotonic()<deadline:
    files=sorted(PREP.glob('*.mp3'))+sorted((ROOT/'assets/question_audio').glob('*.mp3'))
    for path in files:
        try: transcribe(path)
        except Exception as error: print(path.name+': transcription failed: '+str(error),flush=True)
    if args.once or len(list(PREP.glob('*.mp3')))>=88 and len(done)>=100: break
    time.sleep(10)
print('Transcription preparation stopped; no clip was approved.',flush=True)
