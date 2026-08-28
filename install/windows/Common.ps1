# Shared helpers for the Windows scripts — the PowerShell counterpart of
# lib/common.sh. Dot-sourced, never run directly.

function Write-Header {
    param([string] $Title, [string] $Subtitle)
    Write-Host ''
    Write-Host "==> $Title" -ForegroundColor Blue
    if ($Subtitle) { Write-Host "    $Subtitle" -ForegroundColor DarkGray }
}
function Write-Info { param([string] $Message) Write-Host "    $Message" }
function Write-Ok   { param([string] $Message) Write-Host "    [ok] $Message"   -ForegroundColor Green }
function Write-Warn { param([string] $Message) Write-Host "    [!]  $Message"   -ForegroundColor Yellow }
function Write-Err  { param([string] $Message) Write-Host "    [x]  $Message"   -ForegroundColor Red }

# Ask a yes/no question. Honours -Yes via the caller's $Yes switch.
function Confirm-Step {
    param([string] $Question, [switch] $AssumeYes, [switch] $DefaultNo)
    if ($AssumeYes) { return $true }
    $suffix = if ($DefaultNo) { '[y/N]' } else { '[Y/n]' }
    $answer = Read-Host "?  $Question $suffix"
    if ([string]::IsNullOrWhiteSpace($answer)) { return -not $DefaultNo }
    return $answer -match '^[Yy]'
}

# Run a command, or print it under -DryRun. The PowerShell equivalent of run().
function Invoke-Step {
    param(
        [Parameter(Mandatory)] [string]   $Description,
        [Parameter(Mandatory)] [scriptblock] $Action,
        [switch] $DryRun
    )
    if ($DryRun) { Write-Host "    would $Description" -ForegroundColor Yellow; return }
    Write-Info $Description
    & $Action
}

function Test-Administrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# True when the named WSL distribution is already installed.
# `wsl --list` emits UTF-16 with NUL bytes, which breaks naive matching — strip
# them before comparing or every check comes back false.
function Test-WslDistro {
    param([Parameter(Mandatory)] [string] $Name)
    $installed = (wsl.exe --list --quiet) -replace "`0", ''
    return ($installed -split "`r?`n" | ForEach-Object { $_.Trim() }) -contains $Name
}
