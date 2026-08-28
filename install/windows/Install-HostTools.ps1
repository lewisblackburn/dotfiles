<#
.SYNOPSIS
    Set up the Windows host so a WSL guest is actually usable: Nerd Fonts and
    Windows Terminal.

.DESCRIPTION
    WSL has no terminal of its own - it renders inside a Windows terminal, using
    Windows fonts. So the starship prompt's glyphs and nvim's devicons depend on
    fonts installed here, on the host, not in the guest. This is the step that
    is easy to forget and produces "why is my prompt full of boxes".
#>
[CmdletBinding()]
param(
    [string[]] $Fonts = @('FiraCode', 'Hack'),
    [string]   $TerminalFont = 'FiraCode Nerd Font',
    [switch]   $DryRun,
    [switch]   $Yes
)

$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Common.ps1')

Write-Header 'Host tools' 'Nerd Fonts + Windows Terminal'

# ---- Nerd Fonts -----------------------------------------------------------
# Installed per-user, which needs no elevation: the files go under LOCALAPPDATA
# and each face is registered in HKCU so Windows Terminal can see it.
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$regPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$release = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download'

New-Item -ItemType Directory -Force -Path $fontDir | Out-Null

foreach ($font in $Fonts) {
    $already = Get-ChildItem $fontDir -Filter "$font*" -ErrorAction SilentlyContinue
    if ($already) { Write-Ok "$font Nerd Font present"; continue }

    if ($DryRun) { Write-Host "    would download and install $font Nerd Font" -ForegroundColor Yellow; continue }
    if (-not (Confirm-Step "Install the $font Nerd Font?" -AssumeYes:$Yes)) { continue }

    $zip     = Join-Path $env:TEMP "$font.zip"
    $extract = Join-Path $env:TEMP "$font-nf"
    try {
        Write-Info "downloading $font..."
        Invoke-WebRequest -Uri "$release/$font.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $extract -Force

        # Static TTFs only: the variable-weight files confuse Windows Terminal's
        # font picker, and the Windows Compatible variants duplicate the rest.
        Get-ChildItem $extract -Include '*.ttf', '*.otf' -Recurse |
            Where-Object { $_.Name -notmatch 'Windows Compatible' } |
            ForEach-Object {
                $dest = Join-Path $fontDir $_.Name
                Copy-Item $_.FullName $dest -Force
                $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
                New-ItemProperty -Path $regPath -Name "$name (TrueType)" `
                    -Value $dest -PropertyType String -Force | Out-Null
            }
        Write-Ok "$font Nerd Font installed"
    } catch {
        Write-Warn "$font Nerd Font failed: $($_.Exception.Message)"
    } finally {
        Remove-Item $zip, $extract -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---- Windows Terminal -----------------------------------------------------
# Patched in place rather than replaced from a tracked settings.json: that file
# also holds the machine's own profile GUIDs and any per-machine tweaks, so
# overwriting it would throw away more than it sets.
$settings = Join-Path $env:LOCALAPPDATA `
    'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

if (-not (Test-Path $settings)) {
    Write-Warn 'Windows Terminal settings.json not found - install Windows Terminal, launch it once, then re-run'
    return
}

if ($DryRun) {
    Write-Host "    would set the Windows Terminal default font to '$TerminalFont'" -ForegroundColor Yellow
    return
}
if (-not (Confirm-Step "Set the Windows Terminal default font to '$TerminalFont'?" -AssumeYes:$Yes)) { return }

$backup = "$settings.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item $settings $backup
Write-Info "backed up settings.json -> $(Split-Path -Leaf $backup)"

# -AsHashtable keeps the untouched keys intact on round-trip; the default
# PSCustomObject conversion mangles nested arrays on re-serialisation.
$json = Get-Content $settings -Raw | ConvertFrom-Json -AsHashtable

if (-not $json.profiles)          { $json.profiles = @{} }
if (-not $json.profiles.defaults) { $json.profiles.defaults = @{} }
$json.profiles.defaults.font = @{ face = $TerminalFont; size = 11 }

$json | ConvertTo-Json -Depth 32 | Set-Content $settings -Encoding utf8
Write-Ok "Windows Terminal default font set to $TerminalFont"
