<#
.SYNOPSIS
    Bootstrap this machine on Windows.

.DESCRIPTION
    Windows is provisioned as WSL2: this script installs WSL2 and a Fedora
    guest, sets up the pieces that have to live on the Windows *host*, and then
    runs the normal Unix installer inside the guest.

    The host half is not optional decoration. WSL has no terminal of its own, so
    the Nerd Fonts and Windows Terminal settings that make the starship prompt
    and nvim's devicons render must be installed on Windows itself — without
    them the prompt is a row of broken boxes no matter what the guest has.

.PARAMETER Distro
    WSL distribution to install. Defaults to FedoraLinux-42, matching
    install/linux/distros/fedora.sh.

.PARAMETER SkipHostTools
    Don't touch fonts or Windows Terminal settings on the host.

.PARAMETER SkipGuest
    Set up WSL and the host only; don't run the installer inside the guest.

.PARAMETER DryRun
    Print what would happen and change nothing.

.PARAMETER Yes
    Assume yes to every prompt, here and inside the guest.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -Distro Ubuntu-24.04 -Yes
    .\install.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [string] $Distro = 'FedoraLinux-42',
    [switch] $SkipHostTools,
    [switch] $SkipGuest,
    [switch] $DryRun,
    [switch] $Yes
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $here 'install\windows\Common.ps1')

Write-Header 'Dotfiles bootstrap (Windows)' "WSL2 · $Distro"
if ($DryRun) { Write-Warn 'dry run - nothing will be changed' }

# ---- 1. WSL2 + the distro -------------------------------------------------
& (Join-Path $here 'install\windows\Install-Wsl.ps1') `
    -Distro $Distro -DryRun:$DryRun -Yes:$Yes

# ---- 2. Host-side tools ---------------------------------------------------
if ($SkipHostTools) {
    Write-Info 'skipping host tools (-SkipHostTools)'
} else {
    & (Join-Path $here 'install\windows\Install-HostTools.ps1') `
        -DryRun:$DryRun -Yes:$Yes
}

# ---- 3. The real install, inside the guest --------------------------------
if ($SkipGuest) {
    Write-Info 'skipping the guest install (-SkipGuest)'
} else {
    & (Join-Path $here 'install\windows\Install-Guest.ps1') `
        -Distro $Distro -DryRun:$DryRun -Yes:$Yes
}

Write-Header 'Done' 'Open Windows Terminal and pick the WSL profile.'
