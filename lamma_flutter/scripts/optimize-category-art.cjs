// Run with Node and sharp installed, or set SHARP_MODULE to its local module path.
// Originals are intentionally outside Flutter's bundled assets.
const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require(process.env.SHARP_MODULE || 'sharp');

async function main() {
  const root = path.resolve(__dirname, '..');
  const source = path.join(root, 'design_sources/category_art');
  const destination = path.join(root, 'assets/category_art');
  const names = (await fs.readdir(source)).filter(name => name.endsWith('.png')).sort();
  if (names.length !== 14) throw new Error('Expected all 14 category originals.');
  await fs.mkdir(destination, { recursive: true });
  const files = [];
  for (const name of names) {
    const input = path.join(source, name);
    const output = path.join(destination, name.replace(/\.png$/, '.webp'));
    await sharp(input)
      .resize(512, 512, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 85, effort: 6 })
      .toFile(output);
    const metadata = await sharp(output).metadata();
    if (metadata.format !== 'webp' || metadata.width !== 512 || metadata.height !== 512) {
      throw new Error(`Unexpected output: ${name}`);
    }
    files.push({ name, originalBytes: (await fs.stat(input)).size,
      webpBytes: (await fs.stat(output)).size, width: metadata.width, height: metadata.height });
  }
  const originalBytes = files.reduce((sum, item) => sum + item.originalBytes, 0);
  const webpBytes = files.reduce((sum, item) => sum + item.webpBytes, 0);
  const report = { size: 512, quality: 85, sharpVersion: sharp.versions.sharp,
    originalBytes, webpBytes, reductionPercent: +(100 * (1 - webpBytes / originalBytes)).toFixed(2), files };
  await fs.writeFile(path.join(source, 'optimization-report.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report, null, 2));
}
main().catch(error => { console.error(error); process.exitCode = 1; });
