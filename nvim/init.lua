-- Get the Os Name in lowercase
local uv = vim.uv or vim.loop

_G.SYSTEM_NAME = (uv.os_uname().sysname):lower()
-- _G.MASON_BIN_PATH = vim.fn.stdpath("data") .. "/mason/bin" -- Can't work in Windows

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

local utils = require("config.utils")

local win = detect_windows_version()

-- if vim.g.neovide or  (win and win.is_win10) then
if (win and win.is_win10) or utils.is_linux() then
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

-- GUI-launched nvim (e.g. Neovide opened from a desktop entry) doesn't inherit the
-- login shell's $PATH, so shell-managed tools like node (via fnm/nvm) aren't found.
-- Only when a shell-installed tool is missing, merge the login shell's PATH in before
-- plugins load. The spawned login shell re-sources ~/.zshrc (starting fnm/nvm/etc.);
-- its session dirs persist while nvim runs, so the captured paths stay valid.
-- Windows uses a different mechanism (PATH via environment), so it's skipped here.
if not utils.is_windows() and vim.fn.executable("node") ~= 1 then
    local shell = vim.fn.executable("zsh") == 1 and "zsh" or "bash"
    local res = vim.fn.system(shell .. " -lic 'echo $PATH' 2>/dev/null")
    if res ~= "" then
        local shell_path = vim.trim(res)
        local seen = {}
        for p in (vim.env.PATH or ""):gmatch("[^:]+") do
            seen[p] = true
        end
        local parts = {}
        for entry in shell_path:gmatch("[^:]+") do
            if not seen[entry] then
                table.insert(parts, entry)
                seen[entry] = true
            end
        end
        if #parts > 0 then
            vim.env.PATH = table.concat(parts, ":") .. ":" .. (vim.env.PATH or "")
        end
    end
end

if utils.is_windows() then
    vim.defer_fn(function()
        local shada_dir = vim.fn.stdpath("data") .. "/shada/"
        local tmp_files = vim.fn.glob(shada_dir .. "main.shada.tmp.*", true, true)
        for _, file in ipairs(tmp_files) do
            vim.fn.delete(file)
        end
    end, 5000)
end

utils.setup_force_english_input()
