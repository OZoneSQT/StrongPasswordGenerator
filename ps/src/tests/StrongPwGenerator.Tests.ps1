if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\StrongPwGenerator.Core.psm1'
$modulePath = [string](Resolve-Path -LiteralPath $modulePath)
$generatorPath = Join-Path -Path $PSScriptRoot -ChildPath '..\StrongPwGenerator.ps1'
$generatorPath = [string](Resolve-Path -LiteralPath $generatorPath)
Import-Module $modulePath -Force

Describe 'New-StrongPassword' {
    It 'returns a password of the requested length' {
        $result = New-StrongPassword -Length 40
        $result.Password.Length | Should -Be 40
        $result.Combinations | Should -BeGreaterThan 0
    }

    It 'ensures numeric-only generation when only numbers are enabled' {
        $result = New-StrongPassword -Length 24 -IncludeLatin:$false -IncludeNumbers:$true -IncludeSigns:$false -IncludeNordic:$false -IncludeCyrillic:$false -IncludeGreek:$false -IncludeArmenian:$false -IncludeHangul:$false -IncludeArabic:$false -IncludeGeorgian:$false -IncludeEthiopian:$false -IncludeThaana:$false -IncludeHanzi:$false
        $result.Password | Should -Match '^[0-9]+$'
    }

    It 'supports custom Unicode characters' {
        $customChars = [string]::Concat([char]0x03A9, [char]0x0416, [char]0x6F22)
        $result = New-StrongPassword -Length 18 -IncludeLatin:$false -IncludeNumbers:$false -IncludeSigns:$false -IncludeNordic:$false -IncludeCyrillic:$false -IncludeGreek:$false -IncludeArmenian:$false -IncludeHangul:$false -IncludeArabic:$false -IncludeGeorgian:$false -IncludeEthiopian:$false -IncludeThaana:$false -IncludeHanzi:$false -IncludeCustom:$true -CustomCharacters $customChars

        $result.Password.Length | Should -Be 18
        foreach ($ch in $result.Password.ToCharArray()) {
            $customChars.Contains($ch) | Should -BeTrue
        }
    }

    It 'throws when custom Unicode flag is set without characters' {
        { New-StrongPassword -Length 16 -IncludeLatin:$false -IncludeNumbers:$false -IncludeSigns:$false -IncludeCustom:$true -CustomCharacters '' } | Should -Throw 'CustomCharacters must contain at least one character when IncludeCustom is enabled.'
    }

    It 'returns an error response when no character sets are selected' {
        $result = New-StrongPassword -Length 16 -IncludeLatin:$false -IncludeNumbers:$false -IncludeSigns:$false -IncludeNordic:$false -IncludeCyrillic:$false -IncludeGreek:$false -IncludeArmenian:$false -IncludeHangul:$false -IncludeArabic:$false -IncludeGeorgian:$false -IncludeEthiopian:$false -IncludeThaana:$false -IncludeHanzi:$false
        $result.Password | Should -Be 'Error: Please select at least one character set'
        $result.Combinations | Should -Be 0
    }

    It 'throws when length is less than 1' {
        { New-StrongPassword -Length 0 } | Should -Throw 'Length must be greater than 0.'
    }
}

Describe 'Test-CharInString' {
    It 'detects characters contained in a set' {
        Test-CharInString -TestString 'ABC' -CharSet 'XYZABC' | Should -BeTrue
    }

    It 'returns false when characters are absent' {
        Test-CharInString -TestString '123' -CharSet 'ABC' | Should -BeFalse
    }
}

Describe 'StrongPwGenerator.ps1 headless mode' {
    BeforeAll {
        $gp = Join-Path -Path $PSScriptRoot -ChildPath '..\StrongPwGenerator.ps1'
        $gp = [string](Resolve-Path -LiteralPath $gp)
        Set-Variable -Name 'generatorPath' -Value $gp -Scope Script
        $generatorPath.GetType().FullName | Should -Be 'System.String'
        Test-Path $generatorPath | Should -BeTrue
    }

    It 'returns a secure string when invoked with parameters' {
        $characterSets = @{ IncludeLatin = $true; IncludeNumbers = $true; IncludeSigns = $true }


        $result = . $generatorPath -PwLength 16 -CharacterCheckBoxes $characterSets

        $result.GetType().FullName | Should -Be 'System.Security.SecureString'

        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($result)
        try {
            $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($bstr)
            $plain.Length | Should -Be 16
        }
        finally {
            if ($bstr -ne [System.IntPtr]::Zero) {
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            }
        }
    }

    It 'returns plain text details when custom Unicode characters are supplied' {
        $customChars = [string]::Concat([char]0x2620, [char]0x03A9, [char]0x6F22)
        $characterSets = @{
            IncludeLatin = $false
            IncludeNumbers = $false
            IncludeSigns = $false
            IncludeCustom = $true
            CustomUnicodeCharacters = $customChars
        }

        $result = . $generatorPath -PwLength 14 -CharacterCheckBoxes $characterSets -PlainText

        $result.Password.Length | Should -Be 14
        foreach ($ch in $result.Password.ToCharArray()) {
            $customChars.Contains($ch) | Should -BeTrue
        }
        $result.Combinations | Should -BeGreaterThan 0
    }
}
