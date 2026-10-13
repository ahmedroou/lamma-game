import reference_abbreviations_data as d,re,json
txt=re.sub(r'\s+',' ',(d.OUT/'reference_sources/rfc4949.txt').read_text())
out=[]
for row in d.TECH.strip().splitlines():
 diff,short,answer,hint=row.split('|')
 p=txt.lower().find(answer.lower())
 if p<0:
  p=txt.find('$ '+short+' ')
  if p<0:p=txt.find('$ '+short+' (')
  excerpt=txt[p:p+300] if p>=0 else 'NOT FOUND'
 else:excerpt=txt[max(0,p-25):p+len(answer)+85]
 print(short+': '+excerpt)
 out.append({'acronym':short,'answer':answer,'excerpt':excerpt})
(d.OUT/'reference_sources/tech_verification.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
