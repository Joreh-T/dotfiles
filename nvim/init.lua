-- Get the Os Name in lowercase
local uv = vim.uv or vim.loop

_G.SYSTEM_NAME = (uv.os_uname().sysname):lower()
_G.MASON_BIN_PATH = vim.fn.stdpath("data") .. "/mason/bin" -- Can't work in Windows

local function detect_windows_version()
    if vim.fn.has("win32") ~= 1 then return nil end

    local uname = uv.os_uname()
    if uname.sysname ~= "Windows_NT" then return nil end

    -- The format is usually as follows: "10.0.19045" or "10.0.22631"
    local _, _, build = uname.release:match("(%d+)%.(%d+)%.(%d+)")
    build = tonumber(build)
    if not build then return nil end

    local version_name = build >= 22000 and "Win11" or "Win10"

    return {
        build       = build,
        name        = version_name,
        raw_release = uname.release,
        is_win10    = build < 22000
    }
end


-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local icons = require("lazyvim.config").icons

-- local is_windows_terminal = vim.fn.getenv("WT_SESSION") ~= vim.NIL -- Windows Terminal
-- local is_wezterm = vim.fn.getenv("WEZTERM_PANE") ~= vim.NIL -- WezTerm

local win = detect_windows_version()

-- if vim.g.neovide or  (win and win.is_win10) then
if win and win.is_win10 then
    icons.diagnostics.Error = " "
    icons.diagnostics.Warn = " "
    icons.diagnostics.Info = " "
    icons.diagnostics.Hint = "󰌵 "
else
    icons.diagnostics.Error = "😡"
    icons.diagnostics.Warn = "😟"
    icons.diagnostics.Info = "🙂"
    icons.diagnostics.Hint = "🤔"
end

-- vim.lsp.enable({'clangd'})

local lsp_log_path = vim.fn.stdpath("state") .. "/lsp.log"
if vim.fn.filereadable(lsp_log_path) == 1 then
    os.remove(lsp_log_path)
    -- vim.notify("Removed LSP log file: " .. log_path, vim.log.levels.INFO)
else
    -- vim.notify("LSP log file does not exist: " .. log_path, vim.log.levels.INFO)
end

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
