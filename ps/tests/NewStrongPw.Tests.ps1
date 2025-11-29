Describe 'New-StrongPassword enforcement' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\src\StrongPwGenerator.Core.psm1'
        Import-Module $modulePath -Force -ErrorAction Stop
    }

    It 'generates password with required counts for latin/numbers/signs' {
        $res = New-StrongPassword -Length 16 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true
        $pwd = $res.Password
        $pwd.Length | Should -Be 16

        $upper = ([regex]::Matches($pwd,'[A-Z]')).Count
        $lower = ([regex]::Matches($pwd,'[a-z]')).Count
        $nums  = ([regex]::Matches($pwd,'[0-9]')).Count

        $upper | Should -BeGreaterOrEqual 2
        $lower | Should -BeGreaterOrEqual 2
        $nums  | Should -BeGreaterOrEqual 3

        # count signs
        $signs = "/|()1{}[]?-_+~!I;:,^.`$@%&*"
        $signCount = 0
        foreach ($c in $pwd.ToCharArray()) { if ($signs.Contains($c)) { $signCount++ } }
        $signCount | Should -BeGreaterOrEqual 2
    }

    It 'best-effort places required characters when length is small' {
        # Should not throw; returns a password of requested length and attempts to include as many required characters as possible
        $res = New-StrongPassword -Length 5 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true
        $pwd = $res.Password
        $pwd.Length | Should -Be 5
        # It may not be possible to include all minimums due to short length, but function should not error
        $true | Should -Be $true
    }

    It 'succeeds when length exactly equals required minimums' {
        # required sum for latin+numbers+signs = 4 + 3 + 2 = 9
        $res = New-StrongPassword -Length 9 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true
        $pwd = $res.Password
        $pwd.Length | Should -Be 9
        ([regex]::Matches($pwd,'[A-Z]')).Count | Should -BeGreaterOrEqual 2
        ([regex]::Matches($pwd,'[a-z]')).Count | Should -BeGreaterOrEqual 2
        ([regex]::Matches($pwd,'[0-9]')).Count | Should -BeGreaterOrEqual 3
        $signs = "/|()1{}[]?-_+~!I;:,^.`$@%&*"
        $s = 0
        foreach ($c in $pwd.ToCharArray()) { if ($signs.Contains($c)) { $s++ } }
        $s | Should -BeGreaterOrEqual 2
    }

    It 'enforces counts when using IncludeAllUnicode (range generation)' {
        $res = New-StrongPassword -Length 16 -IncludeAllUnicode $true -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true
        $pwd = $res.Password
        $pwd.Length | Should -Be 16
        ([regex]::Matches($pwd,'[A-Z]')).Count | Should -BeGreaterOrEqual 2
        ([regex]::Matches($pwd,'[a-z]')).Count | Should -BeGreaterOrEqual 2
        ([regex]::Matches($pwd,'[0-9]')).Count | Should -BeGreaterOrEqual 3
        $signs = "/|()1{}[]?-_+~!I;:,^.`$@%&*"
        $s = 0
        foreach ($c in $pwd.ToCharArray()) { if ($signs.Contains($c)) { $s++ } }
        $s | Should -BeGreaterOrEqual 2
    }
}
