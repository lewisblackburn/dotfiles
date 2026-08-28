<#
.SYNOPSIS
    Install WSL2 and the Linux distribution the dotfiles are provisioned into.
#>
[CmdletBinding()]
param(
    [string] $Distro = 'FedoraLinux-42',
    [switch] $DryRun,
    [switch] $Yes
)

$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Common.ps1')

Write-Header 'WSL2' $Distro

# Build 19041 is the floor for WSL2 and for `wsl --install` existing at all.
$build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
if ($build -lt 19041) {
    Write-Err "Windows build $build is too old for WSL2 (need 19041+). Update Windows first."
    exit 1
}
Write-Ok "Windows build $build supports WSL2"

# ---- the WSL feature itself -----------------------------------------------
$wslPresent = $null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)
if (-not $wslPresent) {
    Write-Info 'WSL is not installed'
    if (-not (Test-Administrator)) {
        Write-Err 'installing WSL needs an elevated shell - re-run this from "Run as administrator"'
        exit 1
    }
    Invoke-Step -DryRun:$DryRun -Description 'wsl --install --no-distribution' -Action {
        wsl.exe --install --no-distribution
    }
    Write-Warn 'a reboot is usually required before WSL works - reboot, then re-run this script'
} else {
    Write-Ok 'WSL present'
    Invoke-Step -DryRun:$DryRun -Description 'wsl --update' -Action {
        wsl.exe --update | Out-Null
    }
}

# WSL1 guests can't run systemd, which the Fedora profile's podman setup needs.
Invoke-Step -DryRun:$DryRun -Description 'defaulting new distros to WSL2' -Action {
    wsl.exe --set-default-version 2 | Out-Null
}

# ---- the distribution -----------------------------------------------------
if ($DryRun) {
    Write-Host "    would install the '$Distro' distribution if missing" -ForegroundColor Yellow
    return
}

if (Test-WslDistro -Name $Distro) {
    Write-Ok "$Distro already installed"
} else {
    Write-Info "available distributions:"
    (wsl.exe --list --online) -replace "`0", '' | Select-Object -Skip 3 | ForEach-Object {
        if ($_.Trim()) { Write-Host "      $_" }
    }
    if (-not (Confirm-Step "Install $Distro?" -AssumeYes:$Yes)) {
        Write-Info 'skipped'
        return
    }
    # --no-launch so the install doesn't block on the interactive first-user
    # prompt; the guest script creates the user itself.
    wsl.exe --install $Distro --no-launch
    Write-Ok "$Distro installed"
}

# systemd is off by default in some images; the Fedora profile enables the
# rootless podman socket, which is a systemd user unit.
Write-Info 'ensuring systemd is enabled in the guest'
$wslConf = @'
[boot]
systemd=true
'@
wsl.exe -d $Distro -u root -- bash -c "grep -q '^systemd=true' /etc/wsl.conf 2>/dev/null || printf '%s\n' '$wslConf' >> /etc/wsl.conf"
wsl.exe --terminate $Distro | Out-Null
Write-Ok 'systemd enabled (distro restarted)'
