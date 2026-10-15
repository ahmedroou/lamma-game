'use strict';

// Media preparation only: no substitute speakers and no editorial approval.
// Usage: node tool/audio_pipeline/prepare_verified_sources.cjs source.json
const fs = require('node:fs');
const path = require('node:path');
const https = require('node:https');
const { execFileSync, spawnSync } = require('node:child_process');
const ffmpeg = require('ffmpeg-static');
const root = path.resolve(__dirname, '../..');

function download(url, destination, depth = 0) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    if (parsed.protocol !== 'https:' || depth > 5) {
      reject(new Error('A direct HTTPS media URL is required.'));
      return;
    }
    const request = https.get(parsed, {
      headers: { 'User-Agent': 'LammaAudioPreparation/2.0' },
    }, (response) => {
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        response.resume();
        resolve(download(new URL(response.headers.location, parsed).href, destination, depth + 1));
        return;
      }
      if (response.statusCode !== 200) {
        response.resume();
        reject(new Error(`Media request failed: HTTP ${response.statusCode}`));
        return;
      }
      const output = fs.createWriteStream(destination, { flags: 'wx' });
      response.on('error', reject);
      output.on('error', reject);
      output.on('finish', () => output.close(resolve));
      response.pipe(output);
    });
    request.setTimeout(60000, () => request.destroy(new Error('Media download timed out.')));
    request.on('error', reject);
  });
}

function readDuration(file) {
  // FFmpeg duration is written to stderr even on success, never assume 7 sec.
  const result = spawnSync(ffmpeg, ['-hide_banner', '-i', file, '-f', 'null', '-'], {
    encoding: 'utf8', windowsHide: true,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error('Converted media could not be decoded.');
  const match = /Duration:\s*(\d+):(\d+):(\d+(?:\.\d+)?)/.exec(result.stderr);
  if (!match) throw new Error('Actual duration unavailable.');
  return Math.round((Number(match[1]) * 3600 + Number(match[2]) * 60 + Number(match[3])) * 1000);
}

async function prepare(record, folder, questions) {
  const question = questions.find((item) => item.id === record.questionId);
  if (!question || record.speaker !== question.answer || !record.recordingId ||
      !record.sourceUrl || !record.sourceMediaUrl || !record.licenseUrl ||
      !record.license || !record.attribution || !record.transcript ||
      typeof record.sourceVerifiedBy !== 'string' || !record.sourceVerifiedBy.trim() ||
      !Number.isInteger(record.sourceStartMs) || !Number.isInteger(record.sourceEndMs) ||
      record.sourceStartMs < 0 || record.sourceEndMs <= record.sourceStartMs ||
      !/^assets\/question_audio\/voice-\d{3}\.mp3$/.test(record.assetPath)) {
    throw new Error('Missing source provenance, mismatched speaker or invalid cut; nothing substituted.');
  }
  const name = path.basename(record.assetPath);
  const source = path.join(folder, `${name}.source`);
  const output = path.join(folder, name);
  await download(record.sourceMediaUrl, source);
  execFileSync(ffmpeg, [
    '-nostdin', '-y', '-ss', String(record.sourceStartMs / 1000),
    '-i', source, '-t', String((record.sourceEndMs - record.sourceStartMs) / 1000),
    '-vn', '-ac', '1', '-ar', '24000', '-b:a', '48k',
    '-af', 'loudnorm=I=-16:TP=-1.5:LRA=11', '-map_metadata', '-1', output,
  ], { windowsHide: true, stdio: 'pipe' });
  const durationMs = readDuration(output);
  // Prepared clips remain outside shipped assets until individually listened to.
  return { ...record, durationMs,
    preparedPath: path.relative(root, output).replaceAll('\\', '/'),
    reviewStatus: 'sourceVerified', listeningStatus: 'pending' };
}

async function main() {
  if (process.argv.length !== 3) {
    throw new Error('Supply a researched manifest. No default/fallback recording exists.');
  }
  const manifest = JSON.parse(fs.readFileSync(path.resolve(process.argv[2]), 'utf8'));
  if (!Array.isArray(manifest.recordings)) throw new Error('Expected a recordings array.');
  const bank = JSON.parse(fs.readFileSync(path.join(root, 'assets/questions/character_voice.json'), 'utf8'));
  const parent = path.join(root, 'design_sources/character_voice_repair');
  fs.mkdirSync(parent, { recursive: true });
  const folder = fs.mkdtempSync(path.join(parent, 'prepared-'));
  const results = [];
  let failed = false;
  for (const record of manifest.recordings) {
    try { results.push(await prepare(record, folder, bank.questions)); }
    catch (error) {
      failed = true;
      results.push({ questionId: record.questionId, speaker: record.speaker,
        reviewStatus: 'unverified', error: error.message });
      console.error(`${record.questionId}: ${error.message}`);
    }
  }
  fs.writeFileSync(path.join(folder, 'preparation-results.json'), JSON.stringify({
    status: 'pendingIndividualListening', recordings: results,
  }, null, 2) + '\n');
  console.log('Prepared sources saved outside the app; no question was approved or replaced.');
  if (failed) process.exitCode = 1;
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
