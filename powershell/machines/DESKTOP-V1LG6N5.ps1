# machines\DESKTOP-V1LG6N5.ps1 — HongRiu desktop machine config

# ---------------------------------------------------------------------------
# Neovim / Neovide
# ---------------------------------------------------------------------------
Set-Alias -Name nvim -Value "D:\devSoftware\Neovim\bin\vim.exe"

function vide { neovide --neovim-bin "vim.exe" @args }

$env:EDITOR = "vim"
# ---------------------------------------------------------------------------
# Claude Code profile switcher
# ---------------------------------------------------------------------------
function Invoke-ClaudeWithProfile {
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$ProfileName,
        [Parameter(ValueFromRemainingArguments = $true)]
        $RemainingArgs
    )

    $ConfigMapping = @{
        "glm" = "$env:USERPROFILE\.claude\model_settings\glm\settings.json"
        "ds"  = "$env:USERPROFILE\.claude\model_settings\deepseek\settings.json"
    }

    if ($ConfigMapping.ContainsKey($ProfileName)) {
        $SettingsPath = $ConfigMapping[$ProfileName]
        & claude --settings $SettingsPath @RemainingArgs
    } else {
        if ($null -ne $ProfileName) {
            & claude $ProfileName @RemainingArgs
        } else {
            & claude
        }
    }
}

Set-Alias -Name ccc -Value Invoke-ClaudeWithProfile

# ---------------------------------------------------------------------------
# ODrive Python environment
# ---------------------------------------------------------------------------
function TupPyEnv {
    param (
        [string]$Version = "3.9.1"
    )

    Write-Host "Setting pyenv python to $Version..." -ForegroundColor Cyan
    $env:PYENV_VERSION = $Version

    $realPythonPath = "D:\devSoftware\odrive_python\Python39"
    if ([string]::IsNullOrWhiteSpace($realPythonPath)) {
        Write-Host "Error: Cannot find Python $Version." -ForegroundColor Red
        Write-Host "Please check if it is installed via 'pyenv install $Version'." -ForegroundColor Yellow
        Remove-Item Env:\PYENV_VERSION -ErrorAction SilentlyContinue
        return
    }

    $realPythonDir = Split-Path $realPythonPath

    if ($env:Path -notmatch [regex]::Escape($realPythonDir)) {
        $env:Path = "$realPythonDir;" + $env:Path
        Write-Host "Success! Python path temporarily elevated:" -ForegroundColor Green
        Write-Host "   $realPythonDir" -ForegroundColor White
        Write-Host "-> You can now run 'make'." -ForegroundColor Yellow
    } else {
        Write-Host "Environment already set for Python $Version. Just run 'make'." -ForegroundColor DarkCyan
    }
}

function odrivetool {
    & "D:\devSoftware\odrive_python\Python39\python.exe" "D:\devSoftware\odrive_python\Python39\Scripts\odrivetool" $args
}
