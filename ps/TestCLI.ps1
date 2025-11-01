# Call the StrongPwGenerator script and capture the result
$result = & "$PSScriptRoot/src/StrongPwGenerator.ps1" -PwLength 16 -CharacterCheckBoxes @{ IncludeLatin = $true; IncludeNumbers = $true; IncludeSigns = $true }

# Check if the result is a SecureString
if ($result -is [System.Security.SecureString]) {
    Write-Host "Result is a SecureString" -ForegroundColor Green
} else {
    Write-Host "Result is NOT a SecureString. Type: $($result.GetType().FullName)" -ForegroundColor Yellow
}

# Display the result (if it's a regular string)
if ($result -is [string]) {
    Write-Host "Generated password: $result"
}
