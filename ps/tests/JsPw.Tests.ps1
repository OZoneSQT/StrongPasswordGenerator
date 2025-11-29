Describe 'JavaScript password generator integration' {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        It 'Node.js not installed - skip JS tests' -Skip 'Node not available on PATH' { }
    }
    else {
        It 'Node pw.test.js should exit 0' {
            $scriptPath = Join-Path $PSScriptRoot '..\..\root\tests\pw.test.js'
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $node.Path
            $psi.Arguments = "`"$scriptPath`""
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($psi)
            $p.WaitForExit()
            $out = $p.StandardOutput.ReadToEnd()
            $err = $p.StandardError.ReadToEnd()
            if ($out) { Write-Host $out }
            if ($err) { Write-Host $err }
            $p.ExitCode | Should -Be 0
        }
    }
}
