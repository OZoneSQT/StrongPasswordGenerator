const assert = require('assert')
const path = require('path')
const pw = require(path.join('..','pw.js'))

function containsBuhid(str) {
  for (const ch of [...str]) {
    const cp = ch.codePointAt(0)
    if (cp >= 0x1740 && cp <= 0x175F) return true
  }
  return false
}

// Test: when sampling wide Unicode ranges or emoji, Buhid block must be excluded
;(function run() {
  const opts = { length: 24, include: {}, includeAllUnicode: true }
  const res = pw.buildPassword(opts)
  const pass = res.Password
  console.log('Generated (all-unicode) password:', pass)
  // count Unicode code points (handle surrogate pairs)
  const codePoints = [...pass].length
  assert.strictEqual(codePoints, opts.length, 'Password length (in code points) must match')
  assert.ok(!containsBuhid(pass), 'Password must not contain Buhid block characters (U+1740..U+175F)')

  // Also test that no placeholder ? remains and password is printable
  assert.ok(!pass.includes('?'), 'Password must not contain fallback placeholders')

  console.log('Buhid exclusion test passed')
})()
