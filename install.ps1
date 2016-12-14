$encoding = 'utf8'
if (!(Test-Path $PROFILE)) {
    New-Item $PROFILE -Force -ItemType File -ErrorAction Stop
}
else {
    $sr = [System.IO.StreamReader]::new($PROFILE, [System.Text.Encoding]::ASCII, $true)
    $sr.Peek() > $null
    $enc = $sr.CurrentEncoding
    $sr.Close() > $null
    switch -Regex ($enc.HeaderName) {
        'utf-16BE' { $encoding = "bigendianunicode"; break }
        'utf-(\d.*)' {
            if ($matches[1] -eq 16) { $encoding = "unicode"; break }
            $encoding = "utf$($matches[1])"
            break
        }
        'ascii' { $encoding = "ascii"; break }
    }
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
Copy-Item -Path $thisPath -Destination $modulesDir -Recurse -Force

$profileContents = Get-Content $PROFILE
$profileApp = ''

if (!(Select-String -InputObject $profileContents -Pattern 'Set-PsPrompt' -Quiet -SimpleMatch)) {
    $profileApp += [System.Environment]::NewLine
    $profileApp += 'Set-PsPrompt'
}

if ($profileApp -ne '') {
    Out-File -InputObject $profileApp -FilePath $PROFILE -Append -Encoding $encoding
}

Write-Host "`nPsPrompt has been installed.  Restart your console (recommended) or run &(`$profile)."