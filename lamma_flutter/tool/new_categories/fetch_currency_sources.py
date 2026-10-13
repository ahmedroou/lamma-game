from fetch_reference_sources import fetch,BASE
import concurrent.futures,json
URLS=[
'https://www.snb.ch/en/the-snb/mandates-goals/cash/series-9',
'https://www.riksbank.se/en-gb/payments--cash/notes--coins/notes/design-of-the-banknotes/',
'https://www.norges-bank.no/en/topics/notes-and-coins/legal-tender-notes-coins/',
'https://www.norges-bank.no/en/topics/notes-and-coins/withdrawn-notes-coins/banknote-series-VII/',
'https://www.norges-bank.no/en/topics/notes-and-coins/withdrawn-notes-coins/Banknote-series-VI/',
'https://www.qcb.gov.qa/en/Pages/HistoryOfBanknotes.aspx',
'https://sama.gov.sa/ar-sa/Currency/Pages/SixthIssue.aspx',
'https://www.bankofengland.co.uk/banknotes/5-pound-note',
'https://www.bankofengland.co.uk/banknotes/polymer-10-pound-note',
'https://www.bankofengland.co.uk/banknotes/polymer-20-pound-note',
'https://www.bankofengland.co.uk/banknotes/polymer-50-pound-note',
'https://www.uscurrency.gov/denominations/1',
'https://www.uscurrency.gov/denominations/2',
'https://www.uscurrency.gov/denominations/5',
'https://www.uscurrency.gov/denominations/10',
'https://www.uscurrency.gov/denominations/20',
'https://www.uscurrency.gov/denominations/50',
'https://www.uscurrency.gov/denominations/100',
]
if __name__=='__main__':
 with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:results=list(ex.map(fetch,URLS))
 (BASE/'currency_manifest.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
 for item in results:
  print(item)
  if 'file' in item and any(x in item['url'] for x in ['riksbank','sama','qcb','norges']):
   txt=(BASE/item['file']).read_text(encoding='utf-8')
   print(txt[-12000:])
