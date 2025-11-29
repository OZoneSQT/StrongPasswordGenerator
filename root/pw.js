"use strict";
// Canonical secure implementation inlined into `pw.js`.
// Export: `buildPassword(opts)` -> { Password: string, Combinations: number }
String.prototype.replaceAt = function(index, replacement) {
	if (index >= this.length) return this.valueOf();
	return this.substring(0, index) + replacement + this.substring(index + 1);
};

String.prototype.shuffle = function() {
	var a = Array.from(this);
	for (var i = a.length - 1; i > 0; i--) {
		var j = secureRandomInt(i + 1);
		var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
	}
	return a.join("");
};

// Cross-platform secure RNG helpers
const isNodeEnv = (typeof process !== 'undefined' && process.versions && process.versions.node);
let nodeCrypto = null;
if (isNodeEnv) {
	try { nodeCrypto = require('crypto'); } catch (e) { nodeCrypto = null; }
}

function randomUint32() {
	if (isNodeEnv && nodeCrypto) {
		return nodeCrypto.randomBytes(4).readUInt32BE(0);
	}
	if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
		var arr = new Uint32Array(1); crypto.getRandomValues(arr); return arr[0];
	}
	throw new Error('No cryptographically-secure RNG available in this environment');
}

function secureRandomInt(maxExclusive) {
	if (!maxExclusive || maxExclusive <= 0) return 0;
	const maxUint = 0x100000000;
	const upper = Math.floor(maxUint / maxExclusive) * maxExclusive;
	let v;
	do { v = randomUint32(); } while (v >= upper);
	return v % maxExclusive;
}

function secureRandomInRange(minInclusive, maxExclusive) {
	return minInclusive + secureRandomInt(maxExclusive - minInclusive);
}

function buildPassword(opts) {
	opts = opts || {};
	const excludeRanges = opts.excludeRanges || [];
	const length = Math.max(1, (opts.length || 32));
	const include = opts.include || {};
	const allUnicode = !!opts.includeAllUnicode;
	const emoji = !!opts.includeEmoji;
	const symbols = !!opts.includeSymbols;
	const dingbats = !!opts.includeDingbats;

	const latinLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	const numbers = "0123456789";
	const signs = "/|(){}[]?-_+~!;:,^.$@%&*";

	// Build base pool
	let base = "";
	if (include.latin) base += latinLetters;
	if (include.numbers) base += numbers + numbers + numbers; // bias numbers
	if (include.signs) base += signs + signs;
	if (!base) base = latinLetters + numbers + signs;

	// Printable check for Unicode sampling
	function isPrintable(cp) {
		if (cp >= 0x0000 && cp <= 0x001F) return false;
		if (cp >= 0x007F && cp <= 0x009F) return false;
		if (cp >= 0xD800 && cp <= 0xDFFF) return false; // surrogates
		if (cp >= 0xFDD0 && cp <= 0xFDEF) return false; // non-characters
		if ((cp & 0xFFFF) === 0xFFFE || (cp & 0xFFFF) === 0xFFFF) return false;
		if (cp >= 0xFE00 && cp <= 0xFE0F) return false; // variation selectors

		// Exclude Buhid block (U+1740..U+175F) which can render as glyphs like '᝱' in some fonts/terminals
		if (cp >= 0x1740 && cp <= 0x175F) return false;
		// Honor user-provided exclusion ranges (arrays of [start, end])
		for (let i = 0; i < excludeRanges.length; i++) {
			const ex = excludeRanges[i];
			if (!ex || ex.length < 2) continue;
			const s = Number(ex[0]);
			const e = Number(ex[1]);
			if (!Number.isFinite(s) || !Number.isFinite(e)) continue;
			if (cp >= s && cp <= e) return false;
		}
		return true;
	}

	const emojiRanges = [ [0x1F300,0x1F5FF], [0x1F600,0x1F64F], [0x1F900,0x1F9FF] ];
	const symbolRanges = [ [0x2600,0x26FF] ];
	const dingbatRanges = [ [0x2700,0x27BF] ];

	let combinedRanges = [];
	if (emoji) combinedRanges = combinedRanges.concat(emojiRanges);
	if (symbols) combinedRanges = combinedRanges.concat(symbolRanges);
	if (dingbats) combinedRanges = combinedRanges.concat(dingbatRanges);

	const useRangeSampling = combinedRanges.length > 0;

	// All-Unicode path
	if (allUnicode) {
		const ranges = [
			[0x0020,0x007E],[0x00A0,0x00FF],[0x0100,0x017F],[0x0180,0x024F],[0x0250,0x02AF],[0x02B0,0x02FF],[0x0300,0x036F],[0x0370,0x03FF],[0x0400,0x04FF],[0x0500,0x052F],[0x0530,0x058F],[0x0600,0x06FF],[0x0700,0x074F],[0x0780,0x07BF],[0x0900,0x097F],[0x0980,0x09FF],[0x0A00,0x0A7F],[0x0A80,0x0AFF],[0x0B00,0x0B7F],[0x0B80,0x0BFF],[0x0C00,0x0C7F],[0x0C80,0x0CFF],[0x0D00,0x0D7F],[0x0E00,0x0E7F],[0x0F00,0x0FFF],[0x1000,0x109F],[0x1100,0x11FF],[0x1200,0x137F],[0x13A0,0x13FF],[0x1400,0x167F],[0x1780,0x17FF],[0x1800,0x18AF],[0x1B00,0x1B7F],[0x1C00,0x1C4F],[0x1D00,0x1D7F],[0x1E00,0x1EFF],[0x1F00,0x1FFF],[0x1F600,0x1F64F],[0x2000,0x206F],[0x2100,0x214F],[0x2190,0x21FF],[0x2200,0x22FF],[0x2300,0x23FF],[0x2500,0x257F],[0x25A0,0x25FF],[0x2600,0x26FF],[0x2700,0x27BF],[0x2E80,0x2EFF],[0x3000,0x303F],[0x3040,0x309F],[0x30A0,0x30FF],[0x3130,0x318F],[0x3400,0x4DBF],[0x4E00,0x9FFF]
		];

		let result = "";
		for (let i = 0; i < length; i++) {
			let attempts = 0;
			let ch = '?';
			while (attempts < 50) {
				const r = ranges[secureRandomInt(ranges.length)];
				const cp = secureRandomInRange(r[0], r[1] + 1);
				if (isPrintable(cp)) { ch = String.fromCodePoint(cp); break; }
				attempts++;
			}
			result += ch;
		}

		return { Password: result.shuffle(), Combinations: Number.POSITIVE_INFINITY };
	}

	// Build initial result by sampling base and optionally ranges
	let result = "";
	if (useRangeSampling) {
		for (let i = 0; i < length; i++) {
			let pickBase = (base.length > 0) && (secureRandomInt(2) === 0);
			if (pickBase) {
				result += base.charAt(secureRandomInt(base.length));
			} else {
				let ch = '?';
				let attempts = 0;
				while (attempts < 50) {
					const r = combinedRanges[secureRandomInt(combinedRanges.length)];
					const cp = secureRandomInRange(r[0], r[1] + 1);
					if (isPrintable(cp)) { ch = String.fromCodePoint(cp); break; }
					attempts++;
				}
				if (ch === '?') {
					// Could not find a printable codepoint in ranges; use a safe base character to preserve length
					if (base.length > 0) {
						ch = base.charAt(secureRandomInt(base.length));
					} else {
						ch = latinLetters.charAt(secureRandomInt(latinLetters.length));
					}
				}
				result += ch;
			}
		}
	} else {
		// base-only sampling with mild anti-repetition
		let last = null;
		for (let i = 0; i < length; i++) {
			let ch = base.charAt(secureRandomInt(base.length));
			if (last === ch) ch = base.charAt(secureRandomInt(base.length));
			last = ch;
			result += ch;
		}
	}

	// Enforce minimum class counts (if included)
	const reqUpper = include.latin ? 2 : 0;
	const reqLower = include.latin ? 2 : 0;
	const reqNumbers = include.numbers ? 3 : 0;
	const reqSigns = include.signs ? 2 : 0;

	function randIndex(len) { return (len && len > 0) ? secureRandomInt(len) : 0; }
	function setAtIndices(s, indices, chars) {
		let arr = Array.from(s);
		for (let i = 0; i < indices.length && i < chars.length; i++) {
			arr[indices[i]] = chars[i];
		}
		return arr.join("");
	}
	function uniqueIndices(count) {
		const n = Math.max(0, Math.floor(length));
		const set = new Set();
		let tries = 0;
		while (set.size < Math.min(count, n) && tries < count * 20) {
			set.add(secureRandomInt(n)); tries++;
		}
		return Array.from(set);
	}

	function pickNFrom(str, n) {
		const out = [];
		for (let i = 0; i < n; i++) out.push(str.charAt(randIndex(str.length)));
		return out;
	}

	let toPlace = [];
	if (reqUpper > 0) toPlace = toPlace.concat(pickNFrom(latinLetters.substring(0,26), reqUpper));
	if (reqLower > 0) toPlace = toPlace.concat(pickNFrom(latinLetters.substring(26), reqLower));
	if (reqNumbers > 0) toPlace = toPlace.concat(pickNFrom(numbers, reqNumbers));
	if (reqSigns > 0) toPlace = toPlace.concat(pickNFrom(signs, reqSigns));

	if (toPlace.length > length) toPlace = toPlace.slice(0, length);

	let indices = uniqueIndices(toPlace.length);
	while (indices.length < toPlace.length) indices.push(secureRandomInt(length));
	result = setAtIndices(result, indices, toPlace);

	// Final secure shuffle to spread required characters
	result = result.shuffle();

	return { Password: result, Combinations: Math.pow((base.length || 1), length) };
}

if (typeof module !== 'undefined' && module.exports) module.exports = { buildPassword };
