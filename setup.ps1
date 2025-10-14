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

    # Backup existing target
    if (Test-Path $dst) {
        Write-Host "Backing up existing $dst -> $dst.bak"
        Rename-Item $dst "$dst.bak"
    }

    # Create parent directory if needed
    $parent = Split-Path $dst
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    # Create symbolic link
    New-Item -ItemType SymbolicLink -Path $dst -Target $src
    Write-Host "Created symlink: $dst -> $src"
}

Write-Host "Symlinks created."

# Check if yazi is installed
if (Get-Command "ya" -ErrorAction SilentlyContinue) {
    Write-Host "yazi detected, upgrading packages..."
    ya pkg upgrade
} else {
    Write-Host "yazi not installed, skipping package upgrade."
}

Write-Host "Done!"

