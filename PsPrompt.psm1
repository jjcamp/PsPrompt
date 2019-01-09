<#

.SYNOPSIS
    Agnoster-like prompt theme.
    URL: https://github.com/jjcamp/PsPrompt
    Read README.md for more information.
#>

$PsPrompt = New-Module -AsCustomObject {
    <#
    .SYNOPSIS
        Configuration object for PsPrompt
    #>
    [System.ConsoleColor]$PWDBackgroundColor = [ConsoleColor]::Blue
    [System.ConsoleColor]$PWDForegroundColor = $host.UI.RawUI.BackgroundColor
    [System.ConsoleColor]$GitBackgroundColor = [ConsoleColor]::Green
    [System.ConsoleColor]$GitForegroundColor = $host.UI.RawUI.BackgroundColor
    [System.ConsoleColor]$GitDirtyBackgroundColor = [ConsoleColor]::Yellow
    [System.ConsoleColor]$GitDirtyForegroundColor = $host.UI.RawUI.BackgroundColor

    [bool]$UseUTF = $true
    [char[]]$SeparatorCharacter = @(0xE0B0, '>')
    #[char[]]$FailCharacter = @(0x2718, 'x')
    [char[]]$GitBranchCharacter = @(0xE0A0)
    [char[]]$GitDetachedCharacter = @(0x27A6)
    [char[]]$GitDirtyCharacter = @(0xB1, 0xF1)

    [bool]$CompressPWD = $true
    [int]$CompressPWDLength = 8
    [string]$CompressPWDMore = '~'

    Export-ModuleMember -Variable *
}
$PsPrompt.PsTypeNames.Insert(0, 'PsPromptConfiguration')

function Set-PsPrompt {
    <#
    .SYNOPSIS
        Themes the Powershell prompt
    .DESCRIPTION
        Uses the exported configuration object $PsPrompt to decorate the Powershell prompt in various ways.
    .PARAMETER NoUTF
        Disables the use of UTF characters, using fallbacks if available.
        Shortcut for $PsPrompt.UseUTF = $false
    .PARAMETER NoCompression
        Disables path compression.
        Shortcut for $PsPrompt.CompressPWD = $false
    .EXAMPLE
        Set-PsPrompt
        Themes the prompt using the configuration in $PsPrompt
    .EXAMPLE
        Set-PsPrompt -NoUTF -NoCompression
        Themes the prompt using the configuration in $PsPrompt, setting $PsPrompt.UseUTF to $false and $PsPrompt.CompressPWD to $false
    #>
    [CmdletBinding()]
    param (
        [switch]$NoUTF,
        [switch]$NoCompression
    )

    if ($NoUTF) {
        $PsPrompt.UseUTF = $false;
    }
    if ($NoCompression) {
        $PsPrompt.CompressPWD = $false;
    }

    Set-Content function:Prompt (get-content function:Write-Prompt)
}

function Write-Prompt {
    Write-PWD
    $prevBg = $PsPrompt.PWDBackgroundColor
    $gitBg = Write-Git
    if ($gitBg) {
        $prevBg = $gitBg
    }
    Write-Separator $prevBg $host.UI.RawUI.BackgroundColor

    return ' '
}

function Write-PWD {
    $path = Compress-Path (Get-Location).Path
    Write-Colored " $($path) " $PsPrompt.PWDBackgroundColor $PsPrompt.PWDForegroundColor
}

function Write-Git {
    $poshGit = Get-Module -Name posh-git
    if (-not $poshGit) {
        return $null
    }
    $status = Get-GitStatus
    if (-not $status) {
        return $null
    }
    $dirty = $false
    $fg = $PsPrompt.GitForegroundColor
    $bg = $PsPrompt.GitBackgroundColor
    if ($status.HasWorking -or $status.HasUntracked -or $status.HasIndex) {
        $dirty = $true
        $fg = $PsPrompt.GitDirtyForegroundColor
        $bg = $PsPrompt.GitDirtyBackgroundColor
    }
    Write-Separator $PsPrompt.PWDBackgroundColor $bg
    $gitStatusCharacter = $PsPrompt.GitBranchCharacter
    if ($status.Branch -match '^\(.*\)$') {
        $gitStatusCharacter = $PsPrompt.GitDetachedCharacter
    }
    if ($PsPrompt.UseUTF -or $gitStatusCharacter[1]) {
        Write-Colored " " $bg $fg
    }
    Write-Special $gitStatusCharacter $bg $fg
    Write-Colored " $($status.Branch)" $bg $fg
    if ($dirty) {
        Write-Special $PsPrompt.GitDirtyCharacter $bg $fg
    }
    Write-Colored " " $bg $fg
    return $bg
}

function Write-Separator {
    param(
        [Parameter(Mandatory=$true)][System.ConsoleColor]$FromBackground,
        [Parameter(Mandatory=$true)][System.ConsoleColor]$ToBackground
    )

    Write-Special $PsPrompt.SeparatorCharacter $ToBackground $FromBackground
}

function Write-Special {
    param(
        [char[]]$SpecialCharacter,
        [System.ConsoleColor]$BackgroundColor,
        [System.ConsoleColor]$ForegroundColor
    )

    if ($PsPrompt.UseUTF -and $SpecialCharacter[0]) {
        Write-Colored $SpecialCharacter[0] $BackgroundColor $ForegroundColor
    }
    elseif ($SpecialCharacter[1]) {
        Write-Colored $SpecialCharacter[1] $BackgroundColor $ForegroundColor
    }
}

function Write-Colored {
    param(
        [Parameter(Mandatory=$true)][Object]$Object,
        [System.ConsoleColor]$BackgroundColor,
        [System.ConsoleColor]$ForegroundColor = $host.UI.RawUI.BackgroundColor,
        [switch]$NewLine = $false
    )

    $forward = @{}
    $forward['Object'] = $Object
    $forward['ForegroundColor'] = $ForegroundColor
    $forward['BackgroundColor'] = $BackgroundColor
    if (-not $NewLine) { $forward['NoNewLine'] = $true }

    Write-Host @forward
}

function Compress-Path([string]$path) {
    if(-not $PsPrompt.CompressPWD) {
        return $path
    }
    $parent = Split-Path $path -Parent
    if ($parent -eq '') {
        return $path # Root directory
    }
    $leaf = Split-Path $path -Leaf
    $result = Compress-PathPart $parent
    return Join-Path $result $leaf
}

function Compress-PathPart([string]$path) {
    $parent = Split-Path $path -Parent
    if ($parent -eq '') {
        return Split-Path $path -Qualifier
    }
    $result = Compress-PathPart $parent
    $leaf = Split-Path $path -Leaf
    if ($leaf.Length -gt $PsPrompt.CompressPWDLength) {
        $moreString = $PsPrompt.CompressPWDMore
        $len = $PsPrompt.CompressPWDLength - $moreString.Length
        return Join-Path $result (($leaf[0..($len - 1)] -join '') + $moreString)
    }
    else {
        return Join-Path $result $leaf
    }
}

Export-ModuleMember -Variable PsPrompt
Export-ModuleMember Set-PsPrompt