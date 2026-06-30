# init.ps1 — PowerShell configuration router
# dot-source this from your $PROFILE:
#   . "$HOME\dotfiles\powershell\init.ps1"

# manually set '-Verbose' to get verbose output: . "$HOME\dotfiles\powershell\init.ps1" -Verbose

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Verbose "[pwsh:init] loading from $ScriptDir" -Verbose:$false

# ---------------------------------------------------------------------------
# 1. Core — always loaded (all versions, all machines)
# ---------------------------------------------------------------------------
$Core = Join-Path $ScriptDir "core.ps1"
if (Test-Path $Core) {
    . $Core
    Write-Verbose "[pwsh:init] loaded core.ps1" -Verbose:$false
}

# ---------------------------------------------------------------------------
# 2. Version-specific — loaded by PowerShell major version
# ---------------------------------------------------------------------------
$VersionFile = if ($PSVersionTable.PSVersion.Major -ge 7) {
    Join-Path $ScriptDir "version_v7.ps1"
} else {
    Join-Path $ScriptDir "version_v5.ps1"
}
if (Test-Path $VersionFile) {
    . $VersionFile
    Write-Verbose "[pwsh:init] loaded $(Split-Path $VersionFile -Leaf)" -Verbose:$false
}

# ---------------------------------------------------------------------------
# 3. Machine-specific — loaded by COMPUTERNAME
# ---------------------------------------------------------------------------
$MachineFile = Join-Path $ScriptDir "machines\$env:COMPUTERNAME.ps1"
if (Test-Path $MachineFile) {
    . $MachineFile
    Write-Verbose "[pwsh:init] loaded machines\$env:COMPUTERNAME.ps1" -Verbose:$false
} else {
    Write-Verbose "[pwsh:init] no machine config found for $env:COMPUTERNAME (expected: $MachineFile)" -Verbose:$false
}
