-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

---------------------------------------------------------------------
-- Set PowerShell as the default shell when Neovim starts on Windows
local os = vim.loop.os_uname().sysname

if os == "Windows_NT" then
    vim.o.shell = "powershell"
end

vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { space = "·", tab = ">-", eol = "↲" }
vim.opt.tabstop = 4 -- Set tab width to 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4 -- Set auto-indent width to 4
vim.opt.copyindent = true
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = true
-- vim.opt.autoindent = true
vim.opt.conceallevel = 0 -- Show hidden characters
vim.opt.clipboard = "unnamedplus" -- Use system clipboard instead of nvim clipboard
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.number = true
vim.opt.jumpoptions = "stack"
vim.opt.nrformats = "bin,hex,octal,alpha" -- Enable binary, hexadecimal, octal, and alphabetical number formats
vim.opt.fileencodings = { "utf-8", "gbk", "gb2312",  "utf-16le", "big5", "euc-jp", "euc-kr", "latin1" }

---------------------------------------------------------------------
if not os == "Windows_NT" then
    vim.g.python3_host_prog = "/usr/bin/python3"
else
    vim.g.python3_host_prog = "python3"
end

-- Reduce timeoutlen in terminal mode to avoid HJKL stuttering
-- vim.cmd [[
--   autocmd TermOpen * setlocal ttimeoutlen=10
-- ]]

vim.g.autoformat = false
vim.o.wrap = true

vim.g.snacks_animate = false -- Temporarily disable animation, which causes cursor anomalies in Visual mode when selecting downward
---------------------------------------------------------------------
---
vim.o.virtualedit = "onemore" -- Set virtualedit, cursor won't default to line end when moving up/down
vim.o.undofile = true -- Save all change history of files
vim.o.scrolloff = 7 -- Ensure n lines of space above and below cursor
-- vim.diagnostic.config({
--     virtual_lines = true, -- Show diagnostics in virtual lines
-- })
-- vim.opt.winborder = 'rounded'

--
-- if vim.fn.has("wsl") == 1 then
--     vim.g.clipboard = {
--         name = "winclp",
--         copy = {
--             ["+"] = "clip.exe",
--             ["*"] = "clip.exe"
--         },
--         paste = {
--             ["+"] = "powershell.exe -command 'Get-Clipboard'",
--             ["*"] = "powershell.exe -command 'Get-Clipboard'"
--         },
--         cache_enabled = false,
--     }
-- end
-- Cross-system copy-paste for WSL
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = false,
    }
end

if vim.g.neovide then
    -- Function to parse and compare versions
    local function is_version_leq(target_version)
        local version_str = vim.fn.system("neovide --version")
        local version = version_str:match("Neovide (%d+%.%d+%.%d+)")
        if not version then
            return false
        end

        local target_major, target_minor, target_patch = target_version:match("(%d+)%.(%d+)%.(%d+)")
        local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")

        if not (major and minor and patch) then
            return false
        end

        -- Compare versions numerically
        if tonumber(major) < tonumber(target_major) then
            return true
        elseif tonumber(major) == tonumber(target_major) then
            if tonumber(minor) < tonumber(target_minor) then
                return true
            elseif tonumber(minor) == tonumber(target_minor) then
                return tonumber(patch) <= tonumber(target_patch)
            end
        end
        return false
    end

    if is_version_leq("0.15.0") then
        vim.g.neovide_transparency = 0.99
    else
        vim.g.neovide_opacity = 0.98
    end

    vim.g.neovide_title_background_color = "#2a2f38"
    -- string.format(
    --   "%x",
    -- vim.api.nvim_get_hl(0, {id=vim.api.nvim_get_hl_id_by_name("Normal")}).bg)
    --
    vim.o.guifont = "JetBrainsMono Nerd Font:h13.5"
    -- vim.o.guifont = "Cascadia Code:h12:style=Regular,Segoe UI Emoji:h12"
    vim.g.neovide_ligatures = true -- Enable ligature effects

    vim.g.neovide_hide_mouse_when_typing = true
    -- vim.g.neovide_refresh_rate = 60

    -- Cursor Animation
    vim.g.neovide_cursor_animation_length = 0.1 -- Cursor movement animation speed
    vim.g.neovide_cursor_trail_size = 0.15 -- Trail length
    vim.g.neovide_cursor_antialiasing = true -- Anti-aliasing
    -- ""：Disable particles
    -- "railgun"：Beam effect
    -- "torpedo"：Trail particles
    -- "pixiedust"：Sparkle particles
    -- "sonicboom"：Shockwave effect
    -- "ripple"：Ripple effect
    -- "wireframe"：Wireframe effect
    vim.g.neovide_cursor_vfx_mode = "pixiedust" -- Particle effect mode

    -- Scroll Animation
    vim.g.neovide_scroll_animation_length = 0.3 -- Scroll animation duration (seconds)
    vim.g.neovide_scroll_animation_far = 1.5 -- Magnify animation for long-distance scrolling

    -- Window Effects
    vim.g.neovide_floating_blur = 10 -- Floating window blur intensity
    vim.g.neovide_floating_opacity = 0.8 -- Opacity
    vim.g.neovide_floating_z_height = 10 -- Float height

    vim.g.neovide_window_blurred = true
end
