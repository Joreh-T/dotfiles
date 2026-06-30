# core.ps1 — common PowerShell config for ALL Windows machines and ALL versions

# ---------------------------------------------------------------------------
# Prompt — oh-my-posh
# ---------------------------------------------------------------------------
oh-my-posh init pwsh --config spaceship | Invoke-Expression

# ---------------------------------------------------------------------------
# UTF-8 everywhere
# ---------------------------------------------------------------------------
$env:LESSCHARSET = "utf-8"
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ---------------------------------------------------------------------------
# PSReadLine — basics (works on both v5 and v7)
# ---------------------------------------------------------------------------
if ($null -ne (Get-Module -ListAvailable PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -ViModeIndicator Cursor

    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd

    # Ctrl+d exits shell (like bash)
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

    # Smart word delimiters
    Set-PSReadLineOption -WordDelimiters ';:,.[]{}()!^&*=+-~|"<>?/@'

    # History
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates
}
# ---------------------------------------------------------------------------
# Enhanced ls / dir (usable on both versions)
# ---------------------------------------------------------------------------
function which { Get-Command @args | Select-Object -ExpandProperty Source }
