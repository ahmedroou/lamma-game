"""Bounded artifact audit of abbreviation options; does not certify semantic truth."""
import json,re
from pathlib import Path
BASE=Path(__file__).parent
ARTIFACT=re.compile(r'(chap\.,|art\.,|para\.,|sect\.,|vol\.,|No\.,|KG \(|Knight of the Order|Queen.s Counsel|King.s Counsel|millimetre centimetre|millilitre centilitre|milligram gram|ampere kiloampere|British thermal unit kilowatt|square centimetre square|byte kilobyte|cubic centimetre cubic|B\.C\.\s*\(|arrivalEngineering|gramgravity|Volt volume|kilothermal conductivity)',re.I)
UNITS={v.casefold() for v in ['ampere','candela','Celsius','calorie','centimeter','decibel','Fahrenheit','foot, feet','gigahertz','gramgravity (gravity equals 9.8 m/s2)','Hertz','hour','inch','Joule','Kelvin','kilocalorie','kilogram','kilohertz','kilojoule','kilometer','kilopascal','liter','megaohm','milliampere','milligram','milliliter','millimeter','millimeter of mercury','nanometer','ounce','Pascal','pound','second','Volt volume','watt','micrometer','meter','cubic meter','millisecond','fluid ounce','microgram','micropascal','radians per second squared','volt(s) per meter','watt(s) per meter squared']}
def findings(qs):
 result=[]
 for q in qs:
  for o in q['options']:
   s=o['text']
   reason=None
   if not isinstance(s,str) or not s.strip():reason='empty_option'
   elif ARTIFACT.search(s):reason='concatenated_table_or_document_formatting_row'
   elif s.strip().casefold() in UNITS and q['answer'].strip().casefold() not in UNITS:reason='unrelated_unit_in_nonunit_expansion_question'
   if reason:result.append({'id':q['id'],'optionId':o['id'],'text':s,'reason':reason})
 return result
if __name__=='__main__':
 qs=json.loads((BASE/'abbreviations.json').read_text(encoding='utf-8'))['questions'];result=findings(qs)
 report={'questionsScanned':len(qs),'optionsScanned':sum(len(q['options']) for q in qs),'findings':result,'limits':'Detects confirmed table artifacts and isolated units; does not certify that all remaining distractors are semantically close or factually wrong.'}
 (BASE/'reference_abbreviation_artifact_audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(report,ensure_ascii=True));assert not result,result
