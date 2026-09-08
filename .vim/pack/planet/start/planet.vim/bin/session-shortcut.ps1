param([Parameter(Mandatory=$true)][string]$RequestFile)
$ErrorActionPreference = 'Stop'
$request = Get-Content -LiteralPath $RequestFile -Raw | ConvertFrom-Json
function Quote-Argument([string]$Value) {
    # Windows CommandLineToArgvW quoting, including backslashes before quotes.
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($request.path)
$shortcut.TargetPath = $request.argv[0]
$shortcut.Arguments = (($request.argv | Select-Object -Skip 1 | ForEach-Object { Quote-Argument $_ }) -join ' ')
$shortcut.WorkingDirectory = $request.cwd
$shortcut.Description = 'Open this PlanetVim session'
$shortcut.Save()
Remove-Item -LiteralPath $RequestFile
