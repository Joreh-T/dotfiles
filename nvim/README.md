# Neovim

[Neovim](https://neovim.io/) configurations based on [LazyVim💤](https://www.lazyvim.org/)

## Install Neovim

1. Download the appropriate Neovim. If Neovim was installed via a package manager, uninstall it first.
   ```bash
   sudo apt remove neovim
   ```

2. Download the appropriate version.
   ```bash
   wget https://github.com/neovim/neovim/releases/download/nvim-Vx.x.x.tar.gz
   ```

3. Move it to a preferred path.
   ```bash
   mv nvim-Vx.x.x.tar.gz ~/.local/bin
   ```

4. Extract it.
   ```bash
   tar xzvf nvim-linux64.tar.gz
   ```

5. Link to /usr/bin or another directory already in PATH.
   ```bash
   ln -s /customDirectory/nvim_Vx.x.x/bin/nvim nvim
   ```

## Requirements

- Neovim >= 0.11.2
- a Nerd Font

### Windows

- [git](https://git-scm.com/download/win)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
- [fd](https://github.com/sharkdp/fd#on-windows)
- [fzf](https://github.com/junegunn/fzf#windows)
- [curl](https://curl.se/windows/)
- [nvm-windows](https://github.com/coreybutler/nvm-windows)
- [node & npm](https://nodejs.org/en/download)
  > Installs node via nvm: `nvm install x.x.x`
- [python3](https://www.python.org/downloads/windows/)
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md)
  > `npm install -g tree-sitter-cli`
- [lazygit](https://github.com/jesseduffield/lazygit)
  > Optional.
- [Ghostscript](https://ghostscript.com/releases/gsdnld.html)
  > Optional. For PDF support.
- [tectonic](https://github.com/tectonic-typesetting/tectonic/releases)
  > Optional. For LaTeX support.
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)
  > Optional. For mermaid diagram support: `npm install -g @mermaid-js/mermaid-cli`
- [yazi](https://github.com/sxyazi/yazi/blob/main/README.md#installation)
  > Optional. If not installed, nvim will use neotree as the file explorer.

### Linux

- [git](https://git-scm.com/download/linux)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
- [fd](https://github.com/sharkdp/fd#on-ubuntu)
- [fzf](https://github.com/junegunn/fzf#using-linux-package-managers)
- curl
  > Usually pre-installed.
- [nvm](https://github.com/nvm-sh/nvm)
- [node & npm](https://nodejs.org/en/download/package-manager)
  > Installs node via nvm: `nvm install x.x.x`
- [python3](https://www.python.org/downloads/)
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md)
  > Not needed if glibc < 2.32. Install with: `npm install -g tree-sitter-cli`
- [lazygit](https://github.com/jesseduffield/lazygit)
  > Optional.
- [Ghostscript](https://ghostscript.com/releases/gsdnld.html)
  > Optional. For PDF support.
- [tectonic](https://tectonic-typesetting.github.io/en-US/install.html)
  > Optional. For LaTeX support.
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)
  > Optional. For mermaid diagram support: `npm install -g @mermaid-js/mermaid-cli`
- [yazi](https://github.com/sxyazi/yazi/blob/main/README.md#installation)
  > Optional. If not installed, nvim will use neotree as the file explorer.
