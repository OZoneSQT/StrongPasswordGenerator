Describe 'Entropy accumulator and New-StrongPasswordObject' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\src\StrongPwGenerator.Core.psm1'
        Import-Module $modulePath -Force -ErrorAction Stop
    }

    It 'can start and stop the entropy accumulator and generate SecureString+plaintext' {
        # Start with a short interval so test runs fast
        Start-EntropyAccumulator -IntervalSeconds 1 -MaxChunks 4

        try {
            $obj = New-StrongPasswordObject -Length 12 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true -UseEntropy
            $obj | Should -Not -BeNullOrEmpty
            $obj.Password.Length | Should -Be 12
            # SecurePassword should be a SecureString object
            $obj.SecurePassword | Should -BeOfType System.Security.SecureString
        } finally {
            Stop-EntropyAccumulator
        }
    }
}
