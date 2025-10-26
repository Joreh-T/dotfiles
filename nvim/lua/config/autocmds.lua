-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local utils = require("config.utils")

local function newGroup(name)
    return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- Disable spelling check.
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Set expandtab = false when opening Makefile
vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("makefile-tabs"),
    pattern = { "make", "mk" },
    callback = function()
        -- only affect the current buffer
        vim.bo.expandtab = false
        vim.bo.shiftwidth = 4
        vim.bo.softtabstop = 0
    end,
})

-- Treat "*.jsp" files as HTML files.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = newGroup("jsp-as-html"),
    pattern = { "*.jsp" },
    callback = function()
        vim.bo.filetype = "html"
    end,
})

------------------ Neo-tree ------------------

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "VimResume" }, {
    group = newGroup("neo tree auto refresh"),
    pattern = "*",
    callback = utils.refresh_neo_tree_if_git,
    desc = "Auto refresh neo-tree when git status changed",
})

------------------End Of Neo-tree ------------------

------------------ Avante------------------
vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("avante custom highlights with sonokai"),
    pattern = "Avante",
    callback = function()
        if vim.g.colors_name ~= "sonokai" then
            return
        end

        vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { link = "Normal" })
        vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })

        local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).bg or 0)
        vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { bg = normal_bg })
        vim.api.nvim_set_hl(0, "AvanteReversedThirdTitle", { fg = "#353b45", bg = normal_bg })
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = newGroup("avante-auto-toggle"),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype

        if utils.is_avante_monitor_ft(ft) then
            vim.schedule(function()
                utils.debounce_toggle_avante(ft)
            end)
        end
    end,
})
------------------ End Of Avante------------------

------------------ Neovide ------------------
vim.api.nvim_create_autocmd("ModeChanged", {
    group = newGroup("neovide-cursor-effects"),
    pattern = "*",
    callback = function()
        if vim.g.neovide then
            if vim.fn.mode() == "i" then
                vim.g.neovide_cursor_animation_length = 0.0
                vim.g.neovide_cursor_vfx_mode = "" -- Disable particle effects
                vim.g.neovide_cursor_trail_size = 0 -- Trail length
            else
                vim.g.neovide_cursor_animation_length = 0.15 -- Cursor movement animation speed
                vim.g.neovide_cursor_vfx_mode = "pixiedust" -- Particle effect mode
                vim.g.neovide_cursor_trail_size = 0.2 -- Trail length
            end
        end
    end,
})

------------------ End Of Neovide ------------------

------------------ Outline ------------------
vim.api.nvim_create_autocmd({ "WinEnter", "VimResume" }, {
    group = newGroup("compatible with avante & outline"),
    pattern = "*",
    callback = function(args)
        if vim.bo.filetype == "Outline" and utils.has_avante_window() then
            -- vim.schedule(function()
            --     vim.cmd("normal! 0")
            -- end)
            vim.defer_fn(function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>0", true, false, true), "n", true)
            end, 350)
        end
    end,
})
------------------ End Of Outline ------------------
------------------ Welcome Buffer ------------------
-- vim.api.nvim_create_autocmd("VimEnter", {
--     pattern = "*",
--     desc = "Joreh's Welcome Buffer",
--     once = true,
--     callback = function()
--         if not utils.has_yazi then
--             vim.defer_fn(function()
--                 utils.focus_largest_window()
--                 utils.set_welcome_buffer(2)
--                 if utils.is_plugin_loaded("neo-tree.nvim") then
--                     vim.cmd("Neotree")
--                 end
--             end, 100) -- make sure buffer-2 has been created
--         else
--             utils.set_welcome_buffer()
--         end
--     end,
-- })
local welcome_del_flag = 0
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = newGroup("welcome-tips"),
    pattern = "*",
    desc = "Joreh's Welcome Buffer",
    callback = function(args)
        if vim.fn.argc() ~= 1 then
            vim.api.nvim_del_autocmd(args.id)
            return
        end

        local stats = vim.uv.fs_stat(vim.fn.argv(0))
        if not stats or stats.type ~= "directory" then
            vim.api.nvim_del_autocmd(args.id)
            return
        end

        local no_name_buf_id_neo_tree = 2
        if not utils.has_yazi() and no_name_buf_id_neo_tree == args.buf then
            vim.defer_fn(function()
                utils.focus_largest_window()
                utils.set_welcome_buffer(no_name_buf_id_neo_tree)
                if utils.is_plugin_loaded("neo-tree.nvim") then
                    vim.cmd("Neotree")
                end
                vim.api.nvim_del_autocmd(args.id)
            end, 100)
        elseif utils.has_yazi() then
            utils.set_welcome_buffer(args.buf)
            if 0 == welcome_del_flag then
                welcome_del_flag = 1
                -- The ID of the empty buffer that is last displayed in the window cannot be determined.
                -- To display the prompt interface in all empty buffers, delay the deletion of this autocmd
                vim.defer_fn(function()
                    vim.api.nvim_del_autocmd(args.id)
                end, 5000)
            end
        end
    end,
})
--------------- End of Welcome Buffer --------------

--------------- Auto update config --------------
vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
    group = newGroup("auto-update-dotfiles"),
    pattern = "*",
    desc = "Auto update config from git repo once a day",
    callback = function(args)
        -- local config_path = vim.fn.stdpath("config")
        local config_path = vim.fn.expand("$HOME/dotfiles")
        -- Use vim.fs.joinpath for cross-platform compatibility
        local today_file = vim.fs.joinpath(config_path, ".last_update")
        local today = os.date("%Y-%m-%d")

        local last_pull_date = ""
        if vim.fn.filereadable(today_file) == 1 then
            local content = vim.fn.readfile(today_file)
            last_pull_date = content[1] or ""
        end

        -- Only check for updates once a day
        if last_pull_date == today then
            return
        end

        local stdout_lines = {}
        local stderr_lines = {}

        -- vim.fn.jobstart({ "git", "-C", config_path, "pull", "--ff-only" }, {
        vim.fn.jobstart({ "git", "-C", config_path, "pull", "--autostash", "--rebase" }, {
            on_stdout = function(_, data)
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stdout_lines, line)
                    end
                end
            end,
            on_stderr = function(_, data)
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stderr_lines, line)
                    end
                end
            end,
            on_exit = function(_, code)
                if code ~= 0 then
                    local msg = "Dotfiles updated failed, err：" .. code
                    if #stderr_lines > 0 then
                        local err_lines = {}
                        for i = 1, math.min(3, #stderr_lines) do
                            table.insert(err_lines, stderr_lines[i])
                        end
                        msg = msg .. "\n" .. table.concat(err_lines, "\n")
                    end
                    vim.notify(msg, vim.log.levels.ERROR, { title = "Dotfiles" })
                    return
                end

                -- Success, so write the date to the file
                vim.fn.writefile({ today }, today_file)

                local output_str = table.concat(stdout_lines, "\n")

                -- Check if there was an actual update by checking the git pull output
                -- for English and Chinese messages.
                if not output_str:match("Already up to date") and not output_str:match("已经是最新的") then
                    vim.notify("Dotfiles updated successfully", vim.log.levels.INFO, { title = "Dotfiles" })
                end
            end,
        })

        -- Delete the autocmd so it doesn't run again in this session
        if args and args.id then
            vim.api.nvim_del_autocmd(args.id)
        end
    end,
})

-- vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
--     group = newGroup("auto-update-config"),
--     pattern = "*",
--     desc = "Auto update chezmoi config once a day (pull + apply)",
--     callback = function(args)
--         if vim.fn.executable("chezmoi") == 0 then
--             vim.notify("chezmoi not found in PATH", vim.log.levels.WARN, { title = "Chezmoi Update Dotfiles" })
--             return
--         end
--
--         local config_path = vim.fn.stdpath("config")
--         local today_file = vim.fs.joinpath(config_path, ".last_chezmoi_update")
--         local today = os.date("%Y-%m-%d")
--
--         local last_update_date = ""
--         if vim.fn.filereadable(today_file) == 1 then
--             local content = vim.fn.readfile(today_file)
--             last_update_date = content[1] or ""
--         end
--
--         if last_update_date == today then
--             return
--         end
--
--         local function run_apply()
--             vim.fn.jobstart({ "chezmoi", "apply", "--no-tty" }, {
--                 env = { CHEZMOI_NO_TTY = "1" },
--                 on_exit = function(_, code)
--                     if code == 0 then
--                         vim.fn.writefile({ today }, today_file)
--                         vim.notify("Chezmoi apply completed.", vim.log.levels.INFO, { title = "Chezmoi Update Dotfiles" })
--                     else
--                         vim.notify("Chezmoi apply failed with code " .. code, vim.log.levels.ERROR, { title = "Chezmoi Update Dotfiles" })
--                     end
--                 end,
--             })
--         end
--
--         vim.fn.jobstart({ "chezmoi", "git", "pull", "--", "--autostash", "--rebase" }, {
--             env = { CHEZMOI_NO_TTY = "1" },
--             stdout_buffered = true,
--             stderr_buffered = true,
--
--             on_exit = function(_, code)
--                 if code == 0 then
--                     vim.notify("Chezmoi pull succeeded, applying changes...", vim.log.levels.INFO, { title = "Chezmoi Update Dotfiles" })
--                     run_apply()
--                 else
--                     vim.notify("Chezmoi pull failed with code " .. code, vim.log.levels.ERROR, { title = "Chezmoi Update Dotfiles" })
--                 end
--             end,
--         })
--
--         if args and args.id then
--             vim.api.nvim_del_autocmd(args.id)
--         end
--     end,
-- })

--------------- End of auto update config --------------

vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("change-leetcode-question-window-highlight"),
    pattern = "leetcode.nvim",
    callback = function(args)
        -- Defer the function call to the next Neovim event loop
        -- This ensures that this autocmd executes after the plugin has completed all its synchronous setup
        vim.api.nvim_set_hl(0, "LeetCodeDescription", { link = "bg0" })
        vim.defer_fn(function()
            local win_id = vim.fn.bufwinid(args.buf)

            if win_id and win_id ~= -1 and vim.api.nvim_win_is_valid(win_id) and false == vim.bo[args.buf].modified then
                vim.diagnostic.config({ virtual_text = false })
                vim.api.nvim_set_option_value("winhighlight", "Normal:LeetCodeDescription,FloatBorder:FloatBorder", { win = win_id })
                -- vim.bo[args.buf].filetype = "markdown"
                -- vim.bo[args.buf].bufhidden = "wipe" -- Auto delete when closing window
            end
        end, 0) -- Delay of 0 ms means "Place this task at the end of the main task(Wait for the plugin configuration to take effect first)."
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("disable-auto-comment-when-newline"),
    pattern = { "*" },
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("close dap-float with q"),
    pattern = "dap-float",
    desc = "Add 'q' to close dap-float windows",
    callback = function(args)
        vim.keymap.set("n", "q", "<Cmd>close<CR>", {
            buffer = args.buf, -- only bind to the buffer that triggered the event
            silent = true,
            noremap = true,
            desc = "Close DAP float window",
        })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = newGroup("set git diff view state"),
    pattern = { "DiffviewFiles", "DiffviewFileHistory" },
    callback = function(args)
        if "DiffviewFiles" == vim.bo[args.buf].filetype then
            utils.set_diffview_open(true)
        elseif "DiffviewFileHistory" == vim.bo[args.buf].filetype then
            utils.set_diffviewFileHistory_open(true)
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "Outline",
    group = newGroup("outline custom highlights with sonokai"),
    callback = function()
        if vim.g.colors_name ~= "sonokai" then
            return
        end

        vim.api.nvim_set_hl(0, "OutlineBackground", { fg = "#cfcfcf", bg = "#24272e" })
        -- vim.api.nvim_set_hl(0, "OutlineBackground", {link = "InlayHints"})
        vim.wo.winhl = "Normal:OutlineBackground"
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = newGroup("setup-notUse-buffer"),
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local is_swapfile = vim.bo[args.buf].swapfile
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })
        local count = #bufs

        -- vim.notify("buf count: " .. count .. ", filetype: " .. filetype, vim.log.levels.DEBUG, { title = "Welcome Buffer Cleanup" })
        local is_ignored_ft = { "welcome", "yazi", "dashboard" }

        if "" == filetype or "" == bufname or not is_swapfile then
            return
        end

        for _, t in ipairs(is_ignored_ft) do
            if filetype:match(t) then
                return
            end
        end

        if count > 2 then
            return
        end

        local buf = vim.api.nvim_create_buf(true, false)
        local message = {
            "This buffer cannot be used.",
        }
        -- vim.api.nvim_buf_set_name(buf, "notUse")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, message)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "hide"
        vim.bo[buf].swapfile = false
        vim.bo[buf].modifiable = false
        vim.bo[buf].modified = false
        vim.bo[buf].filetype = "notUse"
        vim.bo[buf].readonly = true
        vim.api.nvim_del_autocmd(args.id)
    end,
})
