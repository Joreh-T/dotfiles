# version_v5.ps1 — PowerShell 5.1 compatibility layer

# ---------------------------------------------------------------------------
# Shim missing pwsh 7+ features
# ---------------------------------------------------------------------------

# pwsh 7+ has built-in && / || pipeline chaining — unavailable in v5.
# Use ; instead and check $LASTEXITCODE / $? manually in scripts.

# pwsh 7+ has ternary operator: $cond ? $true : $false
# In v5, use: if ($cond) { $trueResult } else { $falseResult }

# ---------------------------------------------------------------------------
# PSReadLine — compatible keybindings (v1.x safe)
# ---------------------------------------------------------------------------
if ($null -ne (Get-Module PSReadLine)) {
    # Basic searching — no PredictionSource in v1.x
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory
}
