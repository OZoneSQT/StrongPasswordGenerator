Import-Module "$PSScriptRoot\src\StrongPwGenerator.Core.psm1" -Force
Start-EntropyAccumulator -IntervalSeconds 1
$o = New-StrongPasswordObject -Length 12 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true -UseEntropy
$o | ConvertTo-Json -Compress
Stop-EntropyAccumulator
