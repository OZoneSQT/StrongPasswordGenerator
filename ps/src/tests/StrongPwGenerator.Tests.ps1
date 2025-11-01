$modulePath = Join-Path $PSScriptRoot '..\StrongPwGenerator.Core.psm1'
$generatorPath = Join-Path $PSScriptRoot '..\StrongPwGenerator.ps1'
Import-Module $modulePath -Force

Describe 'New-StrongPassword' {
    It 'returns a password of the requested length' {
        $result = New-StrongPassword -Length 40
        $result.Password.Length | Should Be 40
        $result.Combinations | Should BeGreaterThan 0
    }

    It 'ensures numeric-only generation when only numbers are enabled' {
        $result = New-StrongPassword -Length 24 -IncludeLatin:$false -IncludeNumbers:$true -IncludeSigns:$false -IncludeNordic:$false -IncludeCyrillic:$false -IncludeGreek:$false -IncludeArmenian:$false -IncludeHangul:$false -IncludeArabic:$false -IncludeGeorgian:$false -IncludeEthiopian:$false -IncludeThaana:$false -IncludeHanzi:$false
    $result.Password | Should Match '^[0-9]+$'
    }

    It 'returns an error response when no character sets are selected' {
        $result = New-StrongPassword -Length 16 -IncludeLatin:$false -IncludeNumbers:$false -IncludeSigns:$false -IncludeNordic:$false -IncludeCyrillic:$false -IncludeGreek:$false -IncludeArmenian:$false -IncludeHangul:$false -IncludeArabic:$false -IncludeGeorgian:$false -IncludeEthiopian:$false -IncludeThaana:$false -IncludeHanzi:$false
    $result.Password | Should Be 'Error: Please select at least one character set'
    $result.Combinations | Should Be 0
    }

    It 'throws when length is less than 1' {
    { New-StrongPassword -Length 0 } | Should Throw 'Length must be greater than 0.'
    }
}

Describe 'Test-CharInString' {
    It 'detects characters contained in a set' {
    Test-CharInString -TestString 'ABC' -CharSet 'XYZABC' | Should Be $true
    }

    It 'returns false when characters are absent' {
    Test-CharInString -TestString '123' -CharSet 'ABC' | Should Be $false
    }
}

Describe 'StrongPwGenerator.ps1 headless mode' {
    It 'returns a secure string when invoked with parameters' {
        $scriptPath = $generatorPath
        $characterSets = @{ IncludeLatin = $true; IncludeNumbers = $true; IncludeSigns = $true }

        $result = & $scriptPath -PwLength 16 -CharacterCheckBoxes $characterSets

        $result.GetType().FullName | Should Be 'System.Security.SecureString'

        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($result)
        try {
            $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($bstr)
            $plain.Length | Should Be 16
        }
        finally {
            if ($bstr -ne [System.IntPtr]::Zero) {
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            }
        }
    }
}
