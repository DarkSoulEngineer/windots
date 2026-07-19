$cavaPath = "$env:LOCALAPPDATA\cava\cava.exe"
$configPath = "$env:USERPROFILE\.config\cava\config"
$barDataPath = "$env:USERPROFILE\.glzr\zebar\bar-data.json"

if (!(Test-Path $cavaPath)) {
    Write-Error "cava not found at $cavaPath"
    exit 1
}

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $cavaPath
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.CreateNoWindow = $true

try {
    $proc = [System.Diagnostics.Process]::Start($psi)
    while (!$proc.HasExited) {
        $line = $proc.StandardOutput.ReadLine()
        if ($null -eq $line) { break }

        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0) { continue }

        $parts = $trimmed -split '\s+'
        $bars = New-Object System.Collections.ArrayList
        foreach ($p in $parts) {
            $val = 0
            if ([int]::TryParse($p, [ref]$val)) {
                [void]$bars.Add([math]::Min(1000, [math]::Max(0, $val)))
            }
        }

        if ($bars.Count -gt 0) {
            $json = '[' + ($bars -join ',') + ']'
            [System.IO.File]::WriteAllText($barDataPath, $json)
        }
    }
} catch {
    Write-Error "cava failed: $_"
}
