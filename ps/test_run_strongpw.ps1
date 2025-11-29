. (Join-Path $PSScriptRoot '..\bin\strongpw.ps1')
$r = Start-StrongPw -Length 12 -IncludeLatin $true -IncludeNumbers $true -IncludeSigns $true
$r | ConvertTo-Json -Compress
