# Root directory of dotfiles
$DotfilesDir = "$HOME\dotfiles"

# Mapping: source -> destination
$Links = @{
    "$DotfilesDir\nvim"       = "$HOME\AppData\Local\nvim"
    "$DotfilesDir\yazi"       = "$HOME\AppData\Local\yazi"
    "$DotfilesDir\vim\.vimrc" = "$HOME\.vimrc"
    "$DotfilesDir\wezterm"    = "$HOME\.config\wezterm"
}

Write-Host "Creating symlinks..."

foreach ($src in $Links.Keys) {
    $dst = $Links[$src]

    if (Test-Path $dst) {
        # Write-Host "Removing existing file/directory at $dst"
        # Write-Host " "
        Remove-Item -Path $dst -Recurse -Force
    }

    # Create parent directory if needed
    $parent = Split-Path $dst
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    # Create symbolic link
    New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
    Write-Host "Created symlink: $dst -> $src"
    # Write-Host " "
}

Write-Host "All symlinks created."

# Check if yazi is installed
if (Get-Command "ya" -ErrorAction SilentlyContinue) {
    Write-Host "yazi detected, upgrading packages..."
    ya pkg upgrade
} else {
    Write-Host "yazi not installed, skipping package upgrade."
}

Write-Host "=== All tasks completed successfully ==="

