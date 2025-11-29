const child = require('child_process')
const assert = require('assert')

function run() {
  try {
    const path = require('path')
    const script = path.join(__dirname, '..', '..', 'bin', 'strongpw.js')
    const out = child.execFileSync(process.execPath, [script,'--ps-run','--length=16','--include-latin','--include-numbers','--include-signs'], { encoding: 'utf8', timeout: 15000 })
    const txt = out.toString().trim()
    let obj = null
    try { obj = JSON.parse(txt) } catch (e) {
      console.error('Output was not valid JSON from --ps-run:', txt)
      process.exit(2)
    }
    if (!obj.Password) { console.error('JSON missing Password field'); process.exit(3) }
    if (!obj.SecurePassword) { console.error('JSON missing SecurePassword field'); process.exit(4) }
    console.log('CLI --ps-run produced JSON with Password and SecurePassword')
    process.exit(0)
  } catch (e) {
    const em = (e && e.message) ? e.message : String(e)
    if (em && (em.indexOf('No PowerShell executable') !== -1 || em.indexOf('ENOENT') !== -1 || em.indexOf('spawn') !== -1)) {
      console.log('PowerShell not available on this runner; skipping --ps-run test')
      process.exit(0)
    }
    console.error('CLI --ps-run test failed:', em)
    process.exit(5)
  }
}

run()
