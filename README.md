
# StrongPasswordGenerator

A cross-platform strong password generator implemented in JavaScript (web) and PowerShell (CLI + GUI).

- `root/` contains the browser-based generator (`root/index.html`, `root/pw.js`) and Node-friendly unit tests.
- `ps/` contains the PowerShell module and GUI (`ps/src/StrongPwGenerator.Core.psm1`, `ps/src/StrongPwGenerator.ps1`, `ps/src/StrongPwGenerator.xaml`) plus Pester tests.


Note
----

- This password generator is intended for creating passwords to be stored in a password manager, not to be memorized.
- If a generated password is rejected by a site, adjust the selected character classes and/or the length to meet that site's requirements. Some sites only accept Latin letters and numbers and enforce length limits (often 8–20 characters); when that is the case, choose settings that conform to those constraints.
- Prefer meeting the site's policy rather than weakening entropy unnecessarily. If you must use a restricted character set, consider increasing the allowed length (within the site's limits) to compensate for reduced character-set entropy.
- Avoid logging or sharing plaintext passwords; always store generated passwords securely in your password manager.


Quick summary
--------------

- Cryptographically secure RNG used across implementations.
- Built-in Unicode ranges (emoji, symbols, dingbats, etc.) sampled per-character to avoid large in-memory pools.
- Desktop UI removed the custom-unicode textbox and exposes checkboxes for range options.
- Web generator exports a pure `buildPassword(opts)` function and guarantees minimum character-class counts when those sets are selected.
Setup
-----

Windows (recommended helper): run the included `setup.ps1` from an elevated PowerShell prompt to install Node (if missing), `npm` dependencies, and the Pester module for PowerShell tests.

- To run interactively:

```powershell
.\setup.ps1
```

- Non-interactive (script will proceed on checksum warnings):

```powershell
.\setup.ps1 -NonInteractive
```
.\setup.ps1
```

 - Non-interactive (script will proceed on checksum warnings):

```powershell
.\setup.ps1 -NonInteractive
```

Notes about the installer behavior:

- The installer detects system architecture and will download the appropriate Node LTS MSI (`x64` or `arm64`) when winget is not available.
- The script attempts to verify the MSI with the official `SHASUMS256.txt`. If verification fails you'll be prompted to continue unless `-NonInteractive` is supplied.
- If automated install fails you can use `choco install nodejs-lts -y` or manually install Node from https://nodejs.org/.

Usage
-----

- Web UI: open `root/index.html` in a browser and use the controls.
- PowerShell (headless): dot-source `ps/src/StrongPwGenerator.ps1` and call the CLI functions, for example:

```powershell
. .\ps\src\StrongPwGenerator.ps1
New-StrongPassword -Length 20 -IncludeAllUnicode:$true
```

CLI PowerShell integration
--------------------------

The Node CLI now offers a few PowerShell-friendly options:

- `--ps-run` / `--pwsh` / `--secure`: invoke PowerShell under the hood to call the module's `New-StrongPasswordObject` and return JSON output. This is useful when you want PowerShell-native objects (the JSON will include `Password` and a `SecurePassword` object which contains metadata like length).
- `--json`: returns JSON with convenience fields including a `PowerShellCreateSecureStringFromBase64` snippet which reconstructs a `SecureString` without embedding plaintext directly on the command-line.

PowerShell SecureString reconstruction examples
----------------------------------------------

If you use `--json`, the CLI returns two convenient snippets:

- `PowerShellCreateSecureString`: a short `ConvertTo-SecureString -String "..." -AsPlainText -Force` form (convenient but contains plaintext in the command string).
- `PowerShellCreateSecureStringFromBase64`: a safer snippet that encodes the UTF-16LE password as base64 and reconstructs a `SecureString` by decoding and appending characters; this avoids having the plaintext appear directly on the command-line in many shells.

Example: reconstruct `SecureString` from the `--json` base64 field (recommended):

```powershell
# Run CLI and parse JSON
$j = node .\bin\strongpw.js --json | ConvertFrom-Json
# Use the provided base64 snippet (safer than embedding plaintext)
$b64 = $j.PasswordUtf16Base64
$bytes = [System.Convert]::FromBase64String($b64)
$plain = [System.Text.Encoding]::Unicode.GetString($bytes)
$ss = New-Object System.Security.SecureString
foreach ($c in $plain.ToCharArray()) { $ss.AppendChar($c) }
$ss.MakeReadOnly()
# $ss is a SecureString you can use in PowerShell
```

Alternatively, the CLI also emits `PowerShellCreateSecureStringFromBase64` which contains an inline snippet you can paste (it performs the same decoding and SecureString construction).

Security note: avoid logging, saving, or pasting the plaintext password in CI logs or shared shells. When automating, prefer returning an already-constructed `SecureString` from `--ps-run` (Windows runner) or dot-sourcing `bin/strongpw.ps1` and using `Start-StrongPw -AsVariable`.

PowerShell helper (dot-source)
------------------------------

If you prefer to get an actual `SecureString` object in your current PowerShell session, dot-source the provided helper and call it:

```powershell
. .\bin\strongpw.ps1      # dot-source the helper (must be run from repo root)
Start-StrongPw -Length 16 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true -AsVariable
# After running with -AsVariable, the variable $Global:StrongPasswordSecure will contain a SecureString.
```

Note: the dot-sourced helper sets a global variable named `StrongPasswordSecure` when you pass `-AsVariable` so the SecureString is available in your session. This is intentionally explicit; if you need a different variable name you can modify the helper script.

Testing
-------

- JS tests (Node required):

```powershell
npm ci
npm test
```

- PowerShell/Pester tests (Windows):

```powershell
.\ps\RunTests.cmd
```

If you'd like to run a single Pester test file directly (Windows):

```powershell
Import-Module .\ps\src\StrongPwGenerator.Core.psm1 -Force
Invoke-Pester -Script .\ps\tests\ExcludeBuhid.Tests.ps1 -PassThru
```

CI
--

GitHub Actions workflow runs JS tests on Windows and Ubuntu and runs Pester on Windows. Badge:

![CI](https://github.com/OZoneSQT/StrongPasswordGenerator/actions/workflows/ci.yml/badge.svg)

Logging
-------

Runtime errors and test-runner output should be collected by your tooling. The project follows a lightweight CSV structured logging recommendation for runtime errors where appropriate. A suggested CSV format:

 - columns: `Timestamp,Level,Component,Message,Context`
 - example row:

```csv
2025-11-28T12:34:56Z,ERROR,Generator,"Failed to sample codepoint","range=Emoji;requested=5;attempt=3"
```

Security considerations
-----------------------

- Cryptographic RNG is used; do not replace with insecure PRNGs.
- Avoid logging secrets or generated passwords in plaintext. If you must log, redact or hash values.
- When enabling `All Unicode`/emoji generation be aware some characters are visually confusable; avoid using such passwords in systems with poor Unicode handling.
- Installer downloads are verified against `SHASUMS256.txt` where possible; please verify manually in high-security environments.

Entropy accumulator (opt-in)
----------------------------

- Purpose: an optional, opt-in entropy accumulator is implemented in the PowerShell module as a lightweight Fortuna-inspired helper. It periodically collects non-sensitive system metrics, hashes them (SHA-256) and stores fixed-size chunks. When enabled the module XOR-mixes these chunks into RNG output in a best-effort way. This is intended as an optional additional entropy source for environments where you explicitly want to augment OS entropy.
- How to enable (PowerShell):

```powershell
Import-Module .\ps\src\StrongPwGenerator.Core.psm1 -Force
# start background collection (30s interval, keep up to 8 chunks)
Start-EntropyAccumulator -IntervalSeconds 30 -MaxChunks 8

# Generate and receive both plaintext and SecureString (accumulator used only for this call if -UseEntropy is provided)
$o = New-StrongPasswordObject -Length 16 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true -UseEntropy
$o.Password
$o.SecurePassword

# Stop collector when done
Stop-EntropyAccumulator
```

- Important security notes:
	- The system CSPRNG (OS-provided) remains the primary entropy source; the accumulator is strictly opt-in and only XOR-mixes hashed accumulator bytes into RNG output. It does not replace or weaken the OS CSPRNG by design, but it is experimental.
	- Only enable the accumulator if you understand the security implications. XOR-mixing can provide additional entropy if the accumulator collects unpredictable data, but it cannot recover from a compromised or broken OS RNG. For higher-assurance scenarios prefer OS-supported entropy/reseeding primitives or reviewed entropy reseeding strategies (HMAC-DRBG, HKDF-based mixing).
	- The accumulator implementation and mixing strategy are intentionally simple. If you prefer a stronger mixing/reseed method (HMAC-based reseed or integrated CSPRNG reseed), I can implement that as an alternative opt-in mode.
	- The accumulator is written to be compatible with PowerShell 5.1+ (uses Monitor for locking and safe event handling).

Behavior notes
-------------

- Minimum guarantees: when the generator is asked to include Latin letters, numbers, or signs, it will ensure at least 2 uppercase Latin letters, 2 lowercase Latin letters, 3 digits, and 2 sign characters are present in the output (when those sets are selected).
- Best-effort for short lengths: if the sum of the guaranteed minimums is larger than the requested `Length`, the generator performs "best-effort" placement (it will replace characters to include as many required characters as possible). It will not crash in this case.
- UI validation: the WPF UI will show a warning dialog if the selected length is too small to satisfy the minimums and offers to (a) increase the length automatically to the minimum required, (b) proceed with best-effort placement, or (c) cancel generation.
- Headless/CLI behavior: when run in headless/CLI mode the generator logs a warning to inform you that the minimums exceed the requested length and proceeds with best-effort placement.

Contributing / Development
--------------------------

- Run `npm test` to run the pure-JS unit test for the web generator.
- Run `.\ps\RunTests.cmd` to run the PowerShell Pester suite on Windows.

If Node is not installed, install the LTS from https://nodejs.org/ or use `nvm-windows`.

Implementation details & API
---------------------------

- **Canonical JS API**: require `root/pw.js` and call `buildPassword(opts)`.
	- `opts` (object):
		- `length` (int) — password length (default 32)
		- `include` (object) — boolean flags: `latin`, `numbers`, `signs`, and other scripts
		- `includeAllUnicode` (bool) — sample from wide Unicode ranges
		- `includeEmoji`, `includeSymbols`, `includeDingbats` (bool) — include those ranges
	- returns `{ Password: string, Combinations: number }`

- **Security note**: `buildPassword` uses the platform CSPRNG (`crypto.randomBytes` on Node, `crypto.getRandomValues` in browsers). An optional entropy-accumulator (Fortuna-inspired) can be added as an opt-in feature; by default the system CSPRNG is preferred.

Example (Node):

```javascript
const pw = require('./root/pw.js');
const res = pw.buildPassword({ length: 16, include: { latin: true, numbers: true, signs: true } });
console.log(res.Password);
```

Exclude Unicode ranges
----------------------

You can provide an `excludeRanges` option to the JS API or `-ExcludeRanges` to the PowerShell functions to blacklist Unicode blocks. Each range is a start/end pair (inclusive). Example (JS):

```javascript
// exclude Buhid explicitly (U+1740..U+175F)
const res = pw.buildPassword({
	length: 16,
	include: { latin: true, numbers: true, signs: true },
	excludeRanges: [ [0x1740, 0x175F] ]
});
```

PowerShell example (explicit hashtables):

```powershell
Import-Module .\ps\src\StrongPwGenerator.Core.psm1 -Force
$ex = @(@{ Start = 0x1740; End = 0x175F })
$o = New-StrongPasswordObject -Length 16 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true -ExcludeRanges $ex
$o.Password
```


CLI usage
---------

The Node CLI accepts a repeatable `--exclude-range=start:end` flag (decimal or `0x` hex). Each invocation appends a range to the list of excluded codepoints. Examples:

```powershell
# Exclude Buhid (hex)
node .\bin\strongpw.js --length=16 --include-latin --include-numbers --include-signs --exclude-range=0x1740:0x175F --plain

# Exclude multiple ranges (decimal)
node .\bin\strongpw.js --length=16 --include-allunicode --exclude-range=5952:5983 --exclude-range=8192:8303 --json
```

Notes on `--json` and SecureString reconstruction:

- Use `--json` to get structured output including `PasswordUtf16Base64` (recommended) and `PowerShellCreateSecureStringFromBase64` (inline snippet). The `PasswordUtf16Base64` field contains the UTF-16LE bytes of the password, base64-encoded.
- Recommended reconstruction (safer than embedding plaintext on the command line):

```powershell
# Run CLI and parse JSON
$j = node .\bin\strongpw.js --json | ConvertFrom-Json
$b64 = $j.PasswordUtf16Base64
$bytes = [System.Convert]::FromBase64String($b64)
$plain = [System.Text.Encoding]::Unicode.GetString($bytes)
$ss = New-Object System.Security.SecureString
foreach ($c in $plain.ToCharArray()) { $ss.AppendChar($c) }
$ss.MakeReadOnly()
# $ss is a SecureString you can use in PowerShell
```


Notes and guidance
------------------

- The generator always prefers platform CSPRNGs; exclusions only filter which Unicode code points are considered printable for selection.
- The repository excludes the Buhid block (U+1740..U+175F) by default to avoid glyphs that some fonts or terminals render as confusing characters (e.g., `᝱`). Use `excludeRanges` to add further exclusions.
- `excludeRanges` works with either arrays in JS (`[ [start,end], ... ]`) or an array of hashtables in PowerShell (`@(@{ Start = n; End = m })`). The CLI flag `--exclude-range` builds the appropriate list for you.
- `signs` has been updated to avoid characters that can break the use of the password, such as `[`, `/`, `"`, `´`, and other problematic punctuation.
- Range endpoints are inclusive.
- When excluding ranges, the generator will retry sampling and, if necessary, substitute safe characters from the selected base pools so the requested password length is preserved.

Security note: avoid blacklisting too broadly; removing large ranges may reduce the available entropy. Prefer targeted exclusions for scripts/blocks that cause rendering problems in your environment.

Example (browser): include `root/pw.js` in the page and call `buildPassword` from event handlers or the console.


