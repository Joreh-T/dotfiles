-- Get the Os Name in lowercase
_G.SYSTEM_NAME = (vim.loop.os_uname().sysname):lower()
_G.MASON_BIN_PATH = vim.fn.stdpath("data") .. "/mason/bin" -- Can't work in Windows

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local icons = require("lazyvim.config").icons


local is_windows_terminal = vim.fn.getenv("WT_SESSION") ~= vim.NIL -- Windows Terminal
local is_wezterm = vim.fn.getenv("WEZTERM_PANE") ~= vim.NIL -- WezTerm

if vim.g.neovide then
    icons.diagnostics.Error = ""
    icons.diagnostics.Warn = ""
    icons.diagnostics.Info = ""
    icons.diagnostics.Hint = "󰌵"
else
    icons.diagnostics.Error = "😡"
    icons.diagnostics.Warn = "😟"
    icons.diagnostics.Info = "🙂"
    icons.diagnostics.Hint = "🤔"
end

-- vim.lsp.enable({'clangd'})

local utils = require("config.utils")
if utils.is_windows() then
    vim.defer_fn(function()
        local shada_dir = vim.fn.stdpath("data") .. "/shada/"
        local tmp_files = vim.fn.glob(shada_dir .. "main.shada.tmp.*", true, true)
        for _, file in ipairs(tmp_files) do
            vim.fn.delete(file)
        end
    end, 5000)
end

