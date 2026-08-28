<#
.SYNOPSIS
    Clone the dotfiles inside the WSL guest and run the normal Unix installer.

.DESCRIPTION
    Everything after this point is the same Linux path a native Fedora machine
    takes — install/linux plus install/shared. The only difference is --no-gui:
    a WSL guest has no desktop, so GUI apps and fonts belong on the host (see
    Install-HostTools.ps1) rather than in the guest.
#>
[CmdletBinding()]
param(
    [string] $Distro = 'FedoraLinux-42',
    [string] $Repo   = 'https://github.com/lewisblackburn/dotfiles.git',
    [switch] $DryRun,
    [switch] $Yes
)

$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Common.ps1')

Write-Header 'Guest install' "$Distro - install/linux + install/shared"

if ($DryRun) {
    Write-Host "    would clone $Repo into ~/dotfiles inside $Distro" -ForegroundColor Yellow
    Write-Host "    would run: ./install.sh --no-gui" -ForegroundColor Yellow
    return
}

if (-not (Test-WslDistro -Name $Distro)) {
    Write-Err "$Distro is not installed - run Install-Wsl.ps1 first"
    exit 1
}

# A distro installed with --no-launch has no user account yet. Creating one is
# interactive and personal, so hand it back rather than guessing a username.
$user = (wsl.exe -d $Distro -- whoami) -replace "`0", ''
if ($user.Trim() -eq 'root') {
    Write-Warn "$Distro has no non-root user yet."
    Write-Info  "Create one, then re-run this script:"
    Write-Info  "  wsl -d $Distro -u root -- bash -c 'useradd -m -G wheel -s /bin/bash <you> && passwd <you>'"
    Write-Info  "  wsl -d $Distro -u root -- bash -c 'printf \"[user]\ndefault=<you>\n\" >> /etc/wsl.conf'"
    Write-Info  "  wsl --terminate $Distro"
    exit 1
}
Write-Ok "guest user: $($user.Trim())"

$flags = '--no-gui'
if ($Yes) { $flags = "$flags --yes" }

# git has to exist before the repo can be cloned; everything else the installer
# handles itself.
$script = @"
set -e
command -v git >/dev/null || sudo dnf install -y git
if [ -d "\$HOME/dotfiles/.git" ]; then
  git -C "\$HOME/dotfiles" pull --ff-only || true
else
  git clone $Repo "\$HOME/dotfiles"
fi
cd "\$HOME/dotfiles"
./install.sh $flags
"@

Write-Info "running the installer inside $Distro (this takes a while)"
wsl.exe -d $Distro -- bash -lc $script
Write-Ok 'guest install finished'
