-- install lazypath
-- vim.fn.stdpath("data") <->  ~/.local/share
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- 'rtp' is the path Neovim uses to search for plugins, scripts, configuration files, and other resources. `vim.opt.rtp` is used to manipulate Neovim's runtimepath option, and the prepend method adds the specified path to the beginning of runtimepath. This ensures Neovim prioritizes loading plugins or configurations from the specified path.
vim.opt.rtp:prepend(lazypath)

local utils = require("config.utils")

local lazy_config = {
    spec = {
        -- add LazyVim and import LazyVim's plugins
        {
            "LazyVim/LazyVim",
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        },
        -- Import my custom plugins
        { import = "plugins" },
    },

    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    install = { colorscheme = { "sonokai", "one_monokai", "tokyonight", "habamax" } }, --HINT_N: The first theme loads at launch
    checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- notify on update
    }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                -- "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}

if utils.is_windows() then
    lazy_config.rocks = {
        enabled = true,
        hererocks = false,
    }
end

require("lazy").setup(lazy_config)
