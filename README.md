# StrongPasswordGenerator

A simple but strong password generator.
- ```root-folder``` contains a version coded in JavaScript on an HTML page that makes use of multiple alphabets and other characters.
- ```ps-folder``` contains a version coded in PowerShell, both a CLI and a GUI version that makes use of multiple alphabets and other characters.
- The PowerShell UI now includes an option to supply your own Unicode characters (emoji, symbols, additional scripts) for password generation.
 - The PowerShell UI now includes an option to use the complete set of Unicode blocks (All Unicode). This selects printable Unicode codepoints from many blocks instead of requiring pasted characters.

Usage notes:
- PowerShell headless: dot-source `ps/src/StrongPwGenerator.ps1` and pass `-IncludeAllUnicode` or use `-CharacterCheckBoxes @{ allunicode = $true }`.
- The web UI (`root/index.html`) also exposes an "All Unicode blocks" checkbox; the web generator picks random printable code points from representative ranges.

Security/performance:
- "All Unicode" mode can include many scripts and symbols and may produce characters that are hard to type. When enabled the generator selects printable codepoints directly (no giant in-memory pool) to avoid excessive memory.
- Control and non-printable codepoints are excluded.

