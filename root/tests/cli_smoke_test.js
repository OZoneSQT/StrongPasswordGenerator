const child = require('child_process');
const assert = require('assert');

function run() {
  try {
    const out = child.execFileSync(process.execPath, ['./bin/strongpw.js','--length=16','--include-latin','--include-numbers','--include-signs','--plain'], { encoding: 'utf8', timeout: 5000 });
    const pw = out.toString().trim();
    console.log('CLI produced:', pw);
    if (pw.length !== 16) {
      console.error('Unexpected password length from CLI:', pw.length);
      process.exit(2);
    }
    // Basic character class assertions
    const upper = (pw.match(/[A-Z]/g) || []).length;
    const lower = (pw.match(/[a-z]/g) || []).length;
    const nums = (pw.match(/[0-9]/g) || []).length;
    if (upper < 2 || lower < 2 || nums < 3) {
      console.error('CLI password did not meet minimum class counts');
      process.exit(3);
    }
    console.log('CLI smoke test passed');
    process.exit(0);
  } catch (e) {
    console.error('CLI smoke test failed:', e && e.message ? e.message : e);
    process.exit(4);
  }
}

run();
