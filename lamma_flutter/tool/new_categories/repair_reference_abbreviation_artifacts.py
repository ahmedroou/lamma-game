"""Explicit option-only repair of confirmed malformed sets, preserving all answers."""
from pathlib import Path
import json,copy,hashlib
from audit_reference_abbreviation_options import findings,BASE
SETS={
'abbreviations-easy-0031':['Radio Flux','Radiation Frequency','Radio Feedback','Reference Frequency','Resonance Factor'],
'abbreviations-easy-0048':['Association of Southeast Asian Networks','Association of Southeast Asian Nonprofits','Alliance of Southeast Asian Nations','Association of Southern European and Asian Nations','Asian Society for Economic and Agricultural Negotiations'],
'abbreviations-easy-0050':['Gross Domestic Profit','Gross Direct Product','Gross Debt Position','General Domestic Product','Gross Development Product'],
'abbreviations-easy-0051':['Gross National Profit','Gross Net Product','General National Product','Gross National Price','Gross Nominal Product'],
'abbreviations-easy-0052':['Value Allocation Tax','Variable Added Tax','Value Added Tariff','Value Assessment Tax','Volume Added Tax'],
'abbreviations-easy-0056':['Protected Document Format','Programmable Data Format','Portable Digital File','Public Document Format','Portable Document Framework'],
'abbreviations-easy-0057':['Reduced Nucleic Acid','Reactive Nucleic Acid','Regulatory Nucleic Acid','Recombinant Nucleic Acid','Ribosomal Nucleic Acid'],
'abbreviations-medium-0027':['American National Safety Institute','American National Science Institute','Advanced National Standards Institute','American Network Standards Institute','American National Standards Inspection'],
'abbreviations-medium-0028':['International Standards Organization','International Safety Organization','International Systems Organization','Integrated Standards Organization','International Statistics Office'],
'abbreviations-medium-0036':['Safety Design Standard','Security Data Sheet','Safety Disclosure Statement','Safety Data Summary','Standard Data Sheet'],
'abbreviations-medium-0037':['Volatile Oxidizing Compound','Variable Organic Concentration','Volatile Organic Concentration','Vapor Organic Composition','Vacuum Operated Catalyst'],
'abbreviations-medium-0053':['Organization of Islamic Commerce','Organization of International Cooperation','Organization of Islamic Culture','Organization of Intercontinental Cooperation','Office of Islamic Cooperation'],
'abbreviations-medium-0056':['Foreign Domestic Investment','Financial Direct Investment','Foreign Debt Insurance','Foreign Development Income','Federal Direct Investment'],
'abbreviations-medium-0057':['Cost Price Index','Consumer Profit Index','Consumption Price Indicator','Consumer Production Index','Capital Price Index'],
'abbreviations-medium-0058':['Extended Economic Zone','Exclusive Environmental Zone','External Economic Zone','European Economic Zone','Exclusive Export Zone'],
'abbreviations-hard-0028':['Color Reflection Index','Chromatic Response Index','Color Resolution Index','Color Radiation Index','Contrast Rendering Index'],
'abbreviations-hard-0032':['Extravehicular Monitoring Unit','Environmental Mobility Unit','Emergency Maneuvering Unit','External Maintenance Unit','Extravehicular Management Unit'],
'abbreviations-hard-0033':['Ground Safety Equipment','Ground Survey Equipment','Geographic Support Equipment','Guidance Signal Electronics','Ground Systems Engineering'],
'abbreviations-hard-0034':['Human Controlled Design','Human Cognitive Development','Hardware Centered Design','Human Computer Development','Human Context Description'],
'abbreviations-hard-0035':['Hardware-in-the-loop','Human Input Through Logic','Human Interface Testing Layer','Hardware Integration Test Loop','Human Inside Test Laboratory'],
'abbreviations-hard-0051':['European Fair Trade Association','European Financial Trade Authority','European Free Transport Association','European Federal Trade Alliance','European Foreign Trade Agency'],
'abbreviations-legendary-0033':['Launch Exploration Abort','Launch Entry Arrival','Lunar Entry Abort','Launch Exit Abort','Launch Entry Ascent'],
'abbreviations-legendary-0046':['Global Environment Federation','Global Energy Facility','Global Economic Facility','Global Environmental Foundation','Global Environment Forum'],
'abbreviations-legendary-0048':['trade-related intellectual property standards','trade-related industrial property services','trade-related international patent standards','trade-related investment protection standards','trade-regulated intellectual property systems'],
}
SETS.update({
'abbreviations-medium-0029':['Institute of Electrical and Energy Engineers','International Institute of Electrical Engineers','Institute of Electronics and Environmental Engineers','Institute of Electrical Equipment Engineering','Institution of Electrical and Electronic Education'],
'abbreviations-hard-0036':['Mission Estimated Time','Mission Entry Time','Mission Event Time','Mission End Time','Mission Encounter Time'],
'abbreviations-legendary-0026':['American Society of Astronomy','Acoustic Standards Association','American Sound Association','Aeronautical Safety Association','Acoustical Science Academy'],
'abbreviations-legendary-0034':['Loss of Communication','Loss of Control','Loss of Cooling','Loss of Cargo','Loss of Command'],
})
if __name__=='__main__':
 p=BASE/'abbreviations.json';d=json.loads(p.read_text(encoding='utf-8'));before=copy.deepcopy(d)
 initial=findings(d['questions']);badids={r['id'] for r in initial}
 assert badids<=SETS.keys(),badids-SETS.keys()
 changes=[]
 for q in d['questions']:
  if q['id'] not in SETS:continue
  wrong=SETS[q['id']];assert len(wrong)==5 and len(set(wrong+[q['answer']]))==6
  iterator=iter(wrong)
  for o in q['options']:
   if o['id']==q['correctOptionId']:assert o['text']==q['answer']
   else:o['text']=next(iterator)
  changes.append({'id':q['id'],'answer':q['answer'],'correctOptionId':q['correctOptionId'],'distractors':wrong})
 assert len(changes)==28
 for old,new in zip(before['questions'],d['questions']):
  if old['id'] not in SETS:assert old==new
  else:
   check=copy.deepcopy(new);check['options']=old['options'];assert check==old
 assert not findings(d['questions'])
 p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 prior=BASE/'reference_abbreviation_artifact_cleanup.json'
 prior_findings=json.loads(prior.read_text(encoding='utf-8')).get('initialArtifactFindings',[]) if prior.exists() else []
 merged={json.dumps(r,sort_keys=True):r for r in prior_findings+initial}
 report={'affectedQuestions':len(changes),'scope':'All five distractors replaced in28 confirmed malformed option sets. Original exact answers, their positions and all source fields preserved. Formal-name prompts subsequently clarify ISO and affected proper institutions; NASA acronym contexts name the source standard. No reviewed status granted.','initialArtifactFindings':list(merged.values()),'changes':changes,'sha256After':hashlib.sha256(p.read_bytes()).hexdigest()}
 (BASE/'reference_abbreviation_artifact_cleanup.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print(json.dumps({'affectedQuestions':len(changes),'ids':[c['id'] for c in changes],'sha256After':report['sha256After']},ensure_ascii=True))
