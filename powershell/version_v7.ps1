# version_v7.ps1 — PowerShell 7+ advanced features

# ---------------------------------------------------------------------------
# PSReadLine — predictive IntelliSense (v7+)
# ---------------------------------------------------------------------------
if ($null -ne (Get-Module PSReadLine)) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -Colors @{ InlinePrediction = '#7f8c8d' }
}

# ---------------------------------------------------------------------------
# Enhanced completions
# ---------------------------------------------------------------------------
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Ctrl+Space to show argument completions
Set-PSReadLineKeyHandler -Chord Ctrl+Spacebar -Function PossibleCompletions
