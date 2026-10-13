"""Recheck cached-source excerpts and independent problem proofs after triage.

Reads all raw records, including diagram variants quarantined by product policy.
Source-text equality is not a review of interpretation, clues or distractors.
"""
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re

from audit_question_quality import normalize_option
from verify_reasoning_questions import check

ROOT = Path(__file__).resolve().parents[1]


def normalized_excerpt(text):
    text = normalize_option(text).replace("ٱ", "ا").replace("\ufeff", "")
    return re.sub(r"\s+", " ", re.sub(r"[^\w\s]", " ", text)).strip()


def completed_quote(question):
    quote = re.search("«(.*?)»", question["text"])
    if quote is None:
        return None
    body = quote[1]
    # Unbracketed leading ellipsis omits surrounding context in the new bank;
    # only the bracketed hole requests the answer in those records.
    if "[…]" in body:
        body = body.replace("[…]", question["answer"]).replace("…", "")
    else:
        body = body.replace("…", question["answer"]).replace("...", question["answer"])
    return normalized_excerpt(body)


def verify(root=ROOT):
    banks = {path.stem: json.loads(path.read_text(encoding="utf-8-sig"))
             for path in (root / "assets/questions").glob("*.json")}
    by_id = {question["id"]: question for bank in banks.values() for question in bank["questions"]}
    failures, proof_counts = [], Counter()
    proofs = json.loads((root / "tool/reasoning_proofs.json").read_text(encoding="utf-8"))
    for proof in proofs:
        question = by_id.get(proof["id"])
        if question is None:
            continue
        # Old physical-network proofs were superseded by authored mechanism
        # questions at the same IDs, so they do not verify the new content.
        if proof["engine"] == "physical_network" and "شبكة" not in question["text"]:
            continue
        try:
            check(proof, question)
            proof_counts[proof["engine"]] += 1
        except Exception as error:
            failures.append(dict(id=question["id"], check="independent_problem_proof", detail=str(error)))
    quran_path = root / "tool/religion_quran_simple_source.json"
    quran = json.loads(quran_path.read_text(encoding="utf-8"))
    verses = {(surah["number"], ayah["numberInSurah"]): ayah["text"]
              for surah in quran["data"]["surahs"] for ayah in surah["ayahs"]}
    verse_matches = 0
    for question in banks["complete_verse"]["questions"]:
        refs = [re.search(r"https://quran.com/(\d+)/(\d+)", source)
                for source in question["sources"]]
        refs = [ref for ref in refs if ref]
        quote = completed_quote(question)
        reference = tuple(int(number) for number in refs[0].groups()) if refs else None
        if not quote or reference not in verses or quote not in normalized_excerpt(verses[reference]):
            failures.append(dict(id=question["id"], check="cached_quran_completion", reference=reference))
        else:
            verse_matches += 1
    bukhari_path = root / "tool/religion_bukhari_source.json"
    bukhari = json.loads(bukhari_path.read_text(encoding="utf-8"))
    hadiths = {int(hadith["hadithnumber"]): hadith["text"] for hadith in bukhari["hadiths"]}
    hadith_matches, hadith_skipped = 0, []
    for question in banks["complete_hadith"]["questions"]:
        refs = [re.search(r"https://sunnah.com/bukhari:(\d+)", source)
                for source in question["sources"]]
        refs = [ref for ref in refs if ref]
        if not refs:
            hadith_skipped.append(question["id"])
            continue
        reference, quote = int(refs[0][1]), completed_quote(question)
        if not quote or reference not in hadiths or quote not in normalized_excerpt(hadiths[reference]):
            failures.append(dict(id=question["id"], check="cached_bukhari_completion", reference=reference))
        else:
            hadith_matches += 1
    paths = [quran_path, bukhari_path, root / "tool/reasoning_proofs.json"]
    return dict(schemaVersion=1, generatedAt=datetime.now(timezone.utc).isoformat(),
                independentProblemChecks=sum(proof_counts.values()), proofCounts=dict(proof_counts),
                cachedQuranCompletionMatches=verse_matches,
                cachedBukhariCompletionMatches=hadith_matches,
                hadithQuestionsOutsideCachedCheck=hadith_skipped,
                cachedInputSha256={str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths},
                bankInputSha256={str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in (root / "assets/questions").glob("*.json")},
                failures=failures,
                scope="Independent declared-problem checks and exact completed excerpts in cached source texts. Includes raw quarantined map variants. Does not authenticate every source, verify interpretation, all distractors, difficulty or all 12600 facts; 793 hadiths are outside the cached Bukhari check.")


if __name__ == "__main__":
    result = verify()
    (ROOT / "QUESTION_TRIAGE_EVIDENCE.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: result[key] for key in ("independentProblemChecks", "proofCounts", "cachedQuranCompletionMatches", "cachedBukhariCompletionMatches", "failures")}, ensure_ascii=False))
    raise SystemExit(1 if result["failures"] else 0)
