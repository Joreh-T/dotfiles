# Clear-Host

#--------------------------------------------------------------------
# Neovide
#--------------------------------------------------------------------
function vide { neovide  @args }
function videw { neovide --wsl }

# ---------------------------------------------------------------------------
# claude code custom
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

    # Match custom parameters
    if ($ConfigMapping.ContainsKey($ProfileName)) {
        $SettingsPath = $ConfigMapping[$ProfileName]
        # Explicitly specify the configuration file and concatenate subsequent parameters
        & claude --settings $SettingsPath @RemainingArgs
    } else {
        # Don't have custom parameters, Passing all parameters
        if ($null -ne $ProfileName) {
            & claude $ProfileName @RemainingArgs
        } else {
            & claude
        }
    }
}

Set-Alias -Name ccc -Value Invoke-ClaudeWithProfile


# ---------------------------------------------------------------------------
New-Alias rttEnv rtt_cmd.cmd

function cdws {
    Set-Location -Path "D:\WorkSpaces"
}

function msys2 {
    & "D:\MySoftwares\MSYS2\zsh.cmd" -defterm -mingw64 -no-start -here
}

function forbidnet {
    & "D:\dev_softwares\forbid_net.bat"
}
