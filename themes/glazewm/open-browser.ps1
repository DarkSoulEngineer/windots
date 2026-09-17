# Opens the system's default web browser to a blank page.
# - Firefox family (Firefox/Waterfox): about:home
# - Chromium family (Chrome/Edge/Brave/...): about:blank
# Falls back to a search page if the default browser cannot be determined.

function Get-DefaultBrowserHandler {
  $progId = (Get-ItemProperty `
    'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' `
    -ErrorAction SilentlyContinue).ProgId

  if (-not $progId) { return $null }

  return (Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\$progId\shell\open\command" `
    -ErrorAction SilentlyContinue).'(default)'
}

function Open-DefaultBrowser {
  $handler = Get-DefaultBrowserHandler
  if (-not $handler) { return $false }

  # The handler string looks like:
  # "C:\Program Files\Waterfox\waterfox.exe" -osint -url "%1"
  $exe = ($handler -split '"')[1]
  if (-not $exe -or -not (Test-Path -LiteralPath $exe)) { return $false }

  if ($handler -match 'firefox|waterfox') {
    $url = 'about:home'
  } else {
    $url = 'about:blank'
  }

  & $exe $url
  return $true
}

try {
  if (-not (Open-DefaultBrowser)) {
    Start-Process 'https://www.google.com'
  }
} catch {
  Start-Process 'https://www.google.com'
}