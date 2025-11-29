Import-Module (Join-Path $PSScriptRoot '..\src\StrongPwGenerator.Core.psm1') -Force

Describe 'Exclude Buhid block' {
    It 'does not produce characters in U+1740..U+175F and preserves length' {
        $o = New-StrongPasswordObject -Length 20 -IncludeAllUnicode:$true
        $pw = $o.Password
        # Count Unicode code points (handles surrogate pairs)
        $cpCount = 0
        for ($i = 0; $i -lt $pw.Length;) {
            $cp = [System.Char]::ConvertToUtf32($pw, $i)
            $cpCount++
            if ($cp -gt 0xFFFF) { $i += 2 } else { $i += 1 }
        }
        $cpCount | Should -Be 20

        $found = $false
        for ($i = 0; $i -lt $pw.Length; $i++) {
            $cp = [System.Char]::ConvertToUtf32($pw, $i)
            if ($cp -ge 0x1740 -and $cp -le 0x175F) { $found = $true; break }
        }
        $found | Should -BeFalse -Because 'Buhid block characters must be excluded'
    }
}
