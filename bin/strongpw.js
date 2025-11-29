#!/usr/bin/env node
'use strict';
const path = require('path');
const child = require('child_process');
const fs = require('fs');

function parseArgs(argv) {
    const args = { flags: {}, opts: {} };
    for (let i = 2; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--plain') { args.flags.plain = true; continue; }
        if (a === '--json') { args.flags.json = true; continue; }
        if (a === '--ps') { args.flags.ps = true; continue; }
        if (a === '--ps-run' || a === '--pwsh' || a === '--secure') { args.flags.psrun = true; continue; }
        if (a.startsWith('--length=')) { args.opts.length = parseInt(a.split('=')[1],10); continue; }
        if (a.startsWith('--include-')) {
            const name = a.slice('--include-'.length).replace(/-/g,'');
            args.opts.include = args.opts.include || {};
            if (name === 'allunicode') { args.opts.includeAllUnicode = true; continue; }
            args.opts.include[name] = true;
            continue;
        }
        if (a.startsWith('--exclude-range=')) {
            args.opts.excludeRanges = args.opts.excludeRanges || [];
            const val = a.split('=')[1];
            // support start:end, allow 0x hex
            const parts = val.split(':');
            const parseIntFlexible = (s) => { if (!s) return NaN; if (s.startsWith('0x')||s.startsWith('0X')) return parseInt(s,16); return parseInt(s,10); };
            const s = parseIntFlexible(parts[0]);
            const e = parseIntFlexible(parts[1]);
            if (!Number.isFinite(s) || !Number.isFinite(e)) { continue; }
            args.opts.excludeRanges.push([s,e]);
            continue;
        }
        if (a === '--help' || a === '-h') { args.flags.help = true; }
    }
    return args;
}

function usage() {
    console.log('Usage: strongpw [--length=N] [--include-latin] [--include-numbers] [--include-signs] [--include-emoji] [--include-symbols] [--include-dingbats] [--include-allunicode] [--plain|--json|--ps|--ps-run]');
}

function toPowerShellSecureStringCommand(pwText) {
    const escaped = pwText.replace(/"/g,'\\"');
    return `ConvertTo-SecureString -String "${escaped}" -AsPlainText -Force`;
}

function toPowerShellSecureStringFromBase64(pwText) {
    const b64 = Buffer.from(pwText, 'utf16le').toString('base64');
    return `$b = [System.Convert]::FromBase64String('${b64}'); $s = [System.Text.Encoding]::Unicode.GetString($b); $ss = New-Object System.Security.SecureString; foreach ($c in $s.ToCharArray()) { $ss.AppendChar($c) }; $ss.MakeReadOnly(); $ss`;
}

function runPowerShellNewStrongPassword(opts) {
    const includes = opts.include || {};
    const psParts = [];
    psParts.push(`Import-Module "${path.join(process.cwd(),'ps','src','StrongPwGenerator.Core.psm1')}" -Force`);
    const callParts = [];
    callParts.push('New-StrongPasswordObject');
    callParts.push(`-Length ${opts.length || 32}`);
    const map = { latin: 'IncludeLatin', numbers: 'IncludeNumbers', signs: 'IncludeSigns', emoji: 'IncludeEmoji', symbols: 'IncludeSymbols', dingbats: 'IncludeDingbats', includeAllUnicode: 'IncludeAllUnicode' };
    for (const k of Object.keys(map)) {
        if (k === 'includeAllUnicode') {
            if (opts.includeAllUnicode) callParts.push(`-IncludeAllUnicode`);
            continue;
        }
        if (includes && includes[k]) callParts.push(`-${map[k]} $true`);
    }
    // map exclude ranges if provided
    if (opts.excludeRanges && Array.isArray(opts.excludeRanges)) {
        for (const r of opts.excludeRanges) {
            if (!r || r.length < 2) continue;
            // ensure integers
            const s = Number(r[0]);
            const e = Number(r[1]);
            if (!Number.isFinite(s) || !Number.isFinite(e)) continue;
            callParts.push(`-ExcludeRanges @{ Start = ${s}; End = ${e} }`);
        }
    }
    psParts.push(`$o = ${callParts.join(' ')}`);
    psParts.push('$o | ConvertTo-Json -Compress');
    const psCmd = psParts.join('; ');

    const candidates = process.platform === 'win32' ? ['powershell.exe','pwsh'] : ['pwsh','powershell'];
    for (const exe of candidates) {
        try {
            const out = child.execFileSync(exe, ['-NoProfile','-Command',psCmd], { encoding: 'utf8', timeout: 20000 });
            return out.toString();
        } catch (e) {
            // try next
        }
    }
    throw new Error('No PowerShell executable found (tried pwsh and powershell).');
}

function main() {
    const args = parseArgs(process.argv);
    if (args.flags.help) { usage(); process.exit(0); }

    const opts = {
        length: args.opts.length || 32,
        include: args.opts.include || { latin: true, numbers: true, signs: true },
        includeAllUnicode: !!args.opts.includeAllUnicode,
        includeEmoji: !!(args.opts.include && args.opts.include.emoji),
        includeSymbols: !!(args.opts.include && args.opts.include.symbols),
        includeDingbats: !!(args.opts.include && args.opts.include.dingbats)
    };

    if (args.flags.psrun) {
        try {
            const out = runPowerShellNewStrongPassword(opts);
            console.log(out.trim());
            return;
        } catch (e) {
            console.error('PowerShell invocation failed:', e.message);
            process.exit(2);
        }
    }

    let res;
    try {
        const pw = require(path.join('..','root','pw.js'));
        if (!pw || typeof pw.buildPassword !== 'function') throw new Error('Invalid JS generator export');
        res = pw.buildPassword(opts);
    } catch (e) {
        console.error('JS generator failed to run:', e.message);
        console.error('You can use --ps-run to invoke the PowerShell generator instead, or run Node with a platform crypto provider.');
        process.exit(2);
    }

    const out = {
        Password: res.Password,
        Combinations: res.Combinations,
        PowerShellCreateSecureString: toPowerShellSecureStringCommand(res.Password),
        PowerShellCreateSecureStringFromBase64: toPowerShellSecureStringFromBase64(res.Password),
        PasswordUtf16Base64: Buffer.from(res.Password, 'utf16le').toString('base64')
    };

    if (args.flags.plain) {
        console.log(res.Password);
        return;
    }
    if (args.flags.ps) {
        console.log(out.PowerShellCreateSecureString);
        return;
    }
    if (args.flags.json) {
        console.log(JSON.stringify(out));
        return;
    }

    console.log(JSON.stringify(out, null, 2));
}

main();
