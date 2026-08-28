# Minimal PowerShell profile for the Windows host.
#
# Copy or link to $PROFILE:
#   New-Item -ItemType SymbolicLink -Path $PROFILE -Target <repo>\install\windows\profile.ps1
#
# Deliberately thin. The real environment lives in WSL — this only makes getting
# there quick, since Windows is a host for the guest rather than a dev machine
# in its own right.

$DotfilesDistro = 'FedoraLinux-42'

# Drop into the guest, in the equivalent directory where one exists.
function dev {
    param([string] $Path)
    if ($Path) { wsl.exe -d $DotfilesDistro -- bash -lc "cd '$Path' && exec `$SHELL -l" }
    else       { wsl.exe -d $DotfilesDistro -- bash -lc 'cd ~ && exec $SHELL -l' }
}

# Run a single command in the guest without leaving PowerShell.
function wsr { wsl.exe -d $DotfilesDistro -- bash -lc ($args -join ' ') }

# The dotfiles helper, from the host.
function dot { wsl.exe -d $DotfilesDistro -- bash -lc "~/dotfiles/bin/dot $($args -join ' ')" }

Set-Alias vi  nvim  -ErrorAction SilentlyContinue
Set-Alias vim nvim  -ErrorAction SilentlyContinue

# PSReadLine: history search on the arrow keys, matching the zsh setup.
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}
