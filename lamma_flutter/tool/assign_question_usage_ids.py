"""Assign stable, globally unique 128-bit random decimal IDs, without re-keying edits.

Run from the Flutter project: python tool/assign_question_usage_ids.py
Use --check for a read-only verification. Existing IDs are never regenerated.
The registry retains removed question IDs so their numbers cannot be reused.
"""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import secrets
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def valid_number(value):
    return isinstance(value, str) and value.isascii() and value.isdecimal() and not value.startswith('0') and 0 < int(value) < 2 ** 128

def atomic_write(path: Path, data: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix='.usage-', suffix='.tmp', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp_name, path)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)

def assign(root: Path = ROOT, check: bool = False, random_bits=secrets.randbits):
    registry_path = root / 'tool' / 'question_usage_ids.json'
    registry_bytes = registry_path.read_bytes() if registry_path.exists() else None
    registry = json.loads(registry_bytes.decode('utf-8-sig')) if registry_bytes else {'version': 1, 'ids': {}}
    if registry.get('version') != 1 or not isinstance(registry.get('ids'), dict):
        raise ValueError('Invalid usage ID registry; refusing to replace it')
    mapping = registry['ids']
    owners = {}
    for qid, number in mapping.items():
        if not isinstance(qid, str) or not valid_number(number) or number in owners:
            raise ValueError('Invalid or duplicate registered usage ID')
        owners[number] = qid
    inputs = []
    seen_ids = set()
    added = 0
    count = 0
    for path in sorted((root / 'assets' / 'questions').glob('*.json')):
        raw = path.read_bytes()
        document = json.loads(raw.decode('utf-8-sig'))
        changed = False
        for q in document['questions']:
            qid = q['id']
            if qid in seen_ids:
                raise ValueError(f'Duplicate question ID: {qid}')
            seen_ids.add(qid)
            current = q.get('usageId')
            previous = mapping.get(qid)
            if current is not None:
                if not valid_number(current) or (current in owners and owners[current] != qid):
                    raise ValueError(f'Invalid or duplicated usageId: {qid}')
                if previous is not None and previous != current:
                    raise ValueError(f'usageId changed for {qid}; preserve device history')
                mapping[qid] = current
                owners[current] = qid
            else:
                if check:
                    raise ValueError(f'Missing usageId: {qid}')
                number = previous
                attempts = 0
                while number is None:
                    attempts += 1
                    candidate = str(random_bits(128))
                    if valid_number(candidate) and candidate not in owners:
                        number = candidate
                    if attempts > 1000:
                        raise ValueError('Random source failed to produce a unique ID')
                q['usageId'] = number
                mapping[qid] = number
                owners[number] = qid
                changed = True
                added += 1
            count += 1
        inputs.append((path, raw, document, changed))
    if not inputs:
        raise ValueError('No question banks found')
    if not check:
        # Persist reservations first: a partial run recovers the same IDs.
        if registry_path.exists() and registry_path.read_bytes() != registry_bytes:
            raise RuntimeError('Concurrent registry edit; rerun on the latest files')
        encoded = (json.dumps(registry, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
        if encoded != registry_bytes:
            atomic_write(registry_path, encoded)
        for path, original, document, changed in inputs:
            if changed:
                if path.read_bytes() != original:
                    raise RuntimeError(f'Concurrent bank edit: {path}; rerun without losing reserved IDs')
                atomic_write(path, (json.dumps(document, ensure_ascii=False, indent=2) + '\n').encode('utf-8'))
    return {'questions': count, 'assigned': added, 'registered': len(mapping), 'check': check}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    options = parser.parse_args()
    print(json.dumps(assign(check=options.check)))
