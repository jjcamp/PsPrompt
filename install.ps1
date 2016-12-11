if (!(Test-Path $PROFILE)) {
    New-Item $PROFILE -Force -ItemType File -ErrorAction Stop
}
$modulesDirFound = $env:PsModulePath -match '^(.*?);' 
if (!($modulesDirFound)) {
    throw "Could not find local modules directory"
}

$modulesDir = $matches[1]
if (!(Test-Path $modulesDir)) {
    New-Item $modulesDir -Force -ItemType Directory -ErrorAction Stop
}
$thisPath = Split-Path $MyInvocation.MyCommand.Path -Parent
Copy-Item -Path $thisPath -Destination $modulesDir -Recurse

$profileContents = Get-Content $PROFILE
$profileApp = ''

if (!(Select-String -InputObject $profileContents -Pattern 'Set-PsPrompt' -Quiet -SimpleMatch)) {
    $profileApp = 'Import-Module -Name PsPrompt'
    $profileApp += [System.Environment]::NewLine
    $profileApp += 'Set-PsPrompt' 
    $profileChanged = $true
}

if ($profileApp -ne '') {
    Out-File -InputObject $profileApp -FilePath $PROFILE -Append
}

Write-Host "`nPsPrompt has been installed.  Restart your console (recommended) or run &(`$profile)."