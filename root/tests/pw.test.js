const assert = require('assert')
const path = require('path')
// Use canonical implementation
const pw = require(path.join('..','pw.js'))

function countMatches(str, re) {
    const m = str.match(re)
    return m ? m.length : 0
}

// test parameters
const opts = {
    length: 16,
    include: { latin: true, numbers: true, signs: true },
    includeAllUnicode: false,
    includeEmoji: false,
    includeSymbols: false,
    includeDingbats: false
}

const latinUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const latinLower = "abcdefghijklmnopqrstuvwxyz"
const numbers = "0123456789"
const signs = "/|()1{}[]?-_+~!I;:,^.$@%&*"

const res = pw.buildPassword(opts)
const pass = res.Password

console.log('Generated password:', pass)
assert.strictEqual(pass.length, opts.length, 'Password length must match')

const upperCount = countMatches(pass, /[A-Z]/g)
const lowerCount = countMatches(pass, /[a-z]/g)
const numberCount = countMatches(pass, /[0-9]/g)
let signCount = 0
for (let i = 0; i < pass.length; i++) {
    if (signs.indexOf(pass.charAt(i)) !== -1) signCount++
}

assert.ok(upperCount >= 2, `Expected at least 2 uppercase, got ${upperCount}`)
assert.ok(lowerCount >= 2, `Expected at least 2 lowercase, got ${lowerCount}`)
assert.ok(numberCount >= 3, `Expected at least 3 numbers, got ${numberCount}`)
assert.ok(signCount >= 2, `Expected at least 2 signs, got ${signCount}`)

console.log('All assertions passed')
