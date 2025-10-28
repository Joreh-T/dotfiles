local M = {}

local nvim_config = require("lazy.core.config")
------------------------ OS Info ------------------------
function M.is_windows()
    return SYSTEM_NAME == "windows_nt"
end

function M.is_linux()
    return SYSTEM_NAME == "linux"
end

function M.is_macos()
    return SYSTEM_NAME == "darwin"
end

------------------------ End Of OS Info ------------------------

----------------------- NVIM version Check --------------------
-- 0.10.4
-- │  │ └── patch version
-- │  └────── minor version
-- └───────── major version
-- Greater than or Equal
function M.is_nvim_ge(major, minor, patch)
    local v = vim.version()
    -- vim.notify(("Checking if Neovim >= %d.%d%s (current: %d.%d.%d)"):format(
    --   major, minor, patch and ("." .. patch) or "", v.major, v.minor, v.patch
    -- ), vim.log.levels.DEBUG)

    if v.major > major then
        return true
    elseif v.major < major then
        return false
    end

    if v.minor > minor then
        return true
    elseif v.minor < minor then
        return false
    end

    if patch == nil then
        return true
    end

    return v.patch >= patch
end

function M.is_nvim_le(major, minor, patch)
    local v = vim.version()
    -- vim.notify(("Checking if Neovim <= %d.%d%s (current: %d.%d.%d)"):format(
    --   major, minor, patch and ("." .. patch) or "", v.major, v.minor, v.patch
    -- ), vim.log.levels.DEBUG)

    if v.major < major then
        return true
    elseif v.major > major then
        return false
    end

    if v.minor < minor then
        return true
    elseif v.minor > minor then
        return false
    end

    if patch == nil then
        return true
    end

    return v.patch <= patch
end

-------------------- End Of NVIM version Check ------------------

-- Global table to store cursor positions
local cursor_positions = {}

-- Record the current window, cursor position, and input mode
local function record_cursor_position()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local pos = vim.api.nvim_win_get_cursor(win)
    local mode = vim.api.nvim_get_mode().mode
    cursor_positions = {
        win = win,
        buf = buf,
        pos = pos,
        mode = mode,
    }
end

-- Restore the cursor to the recorded window, position, and input mode
local function restore_cursor_position(ft)
    if cursor_positions.win and vim.api.nvim_win_is_valid(cursor_positions.win) then
        vim.api.nvim_set_current_win(cursor_positions.win)
        vim.api.nvim_win_set_cursor(cursor_positions.win, cursor_positions.pos)

        -- Restore input mode
        local current_mode = vim.api.nvim_get_mode().mode
        if current_mode ~= cursor_positions.mode then
            if cursor_positions.mode == "n" then
                vim.api.nvim_command("stopinsert")
            elseif cursor_positions.mode == "i" then
                vim.api.nvim_command("startinsert")
            end
        end
    else
        vim.notify("No valid recorded cursor position to restore", vim.log.levels.WARN)
    end
end

-- Avoid abnormal terminal height when an outline buffer exists in the current window.
function M.open_terminal_rezise_height()
    -- Save current window list for comparison
    local prev_wins = vim.api.nvim_list_wins()

    local has_outline = false
    for _, win in ipairs(prev_wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype:match("Outline") then
            has_outline = true
            break
        end
    end

    Snacks.terminal()

    -- Handle window size adjustment asynchronously
    vim.schedule(function()
        if has_outline then
            -- Get newly created terminal window
            local new_wins = vim.api.nvim_list_wins()
            local term_win = nil
            for _, win in ipairs(new_wins) do
                if not vim.tbl_contains(prev_wins, win) then
                    term_win = win
                    break
                end
            end

            local ui_height = vim.api.nvim_list_uis()[1].height

            if term_win then
                -- Switch to terminal window for operations
                vim.api.nvim_set_current_win(term_win)
                -- Calculate and set height (minimum 5 lines)
                local new_height = math.max(5, math.floor(ui_height * 0.21))
                vim.api.nvim_win_set_height(term_win, new_height)
                -- Lock window height (optional)
                -- vim.wo[term_win].winfixheight = true
            end
        end
    end)
    -- Avoid inability to automatically enter t mode when there's an avante window
    if M.has_target_ft_window("^Avante", true) and vim.fn.mode() ~= "t" and M.has_target_ft_window("snacks_terminal") then
        vim.defer_fn(function()
            vim.cmd("startinsert")
        end, 100)
    end
end

function M.focus_largest_window()
    local max_area = 0
    local target_win = nil

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local config = vim.api.nvim_win_get_config(win)
        if not config.relative or config.relative == "" then
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)
            local area = width * height
            if area > max_area then
                max_area = area
                target_win = win
            end
        end
    end

    if target_win then
        vim.api.nvim_set_current_win(target_win)
    end
end

function M.close_terminal_and_focus_largest()
    -- Close current window
    vim.cmd("close")
    -- Snacks.terminal(nil, { cwd = LazyVim.root() })

    -- Find the window with the largest area among remaining windows
    M.focus_largest_window()
end

function M.has_target_ft_window(filetype_patterns, use_pattern_regex)
    use_pattern_regex = use_pattern_regex or false

    -- Check if the input is a table; if not, wrap it into a table.
    local patterns_to_check = {}
    if type(filetype_patterns) == "table" then
        patterns_to_check = filetype_patterns
    elseif type(filetype_patterns) == "string" then
        patterns_to_check = { filetype_patterns }
    else
        return false
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype or ""

        if ft ~= "" then
            for _, pattern in ipairs(patterns_to_check) do
                if use_pattern_regex then
                    if ft:match(pattern) then
                        return true
                    end
                else
                    if ft == pattern then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function M.is_current_window_ft(filetype_pattern, use_pattern_regex)
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local ft = vim.bo[current_buf].filetype or ""

    if ft == "" then
        return false
    end

    if use_pattern_regex then
        return ft:match(filetype_pattern) ~= nil
    else
        return ft == filetype_pattern
    end
end

------------------------ Avante ------------------------
-- Check if there's a window with filetype starting with Avante
function M.has_avante_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype:match("^Avante") then
            return true
        end
    end
    return false
end

-- Define list of filetypes to monitor (supports partial matching)
local avante_monitor_ft = {
    "terminal$", -- Match filetypes ending with "terminal"
    "Outline$",
    -- "neo-tree"
}

-- Check if filetype matches target list (supports partial matching)
function M.is_avante_monitor_ft(ft)
    for _, pattern in ipairs(avante_monitor_ft) do
        if ft:match(pattern) then
            return true
        end
    end
    return false
end

-- Safe debounce function (supports Neovim 0.5+)
M.debounce_toggle_avante = (function()
    local cooldown = false -- Add cooldown status flag
    local timer = nil
    return function(ft)
        -- Return directly if in cooldown state
        if cooldown then
            print("[Avante] In cooldown, skip toggle")
            return
        end

        -- Execute operation immediately
        record_cursor_position()
        if M.has_avante_window() then
            vim.cmd("AvanteToggle")
            vim.cmd("AvanteToggle")
            restore_cursor_position(ft)
            -- focus_largest_window()
            -- vim.defer_fn(function()
            --   vim.cmd("stopinsert")
            -- end, 320)
        end

        -- Start cooldown timer
        cooldown = true
        timer = vim.loop.new_timer()
        if not timer then
            vim.notify("Failed to create avanteCheck timer", vim.log.levels.ERROR)
            return
        end

        timer:start(
            200, -- Cooldown time 200ms
            0,
            vim.schedule_wrap(function()
                -- Safely release resources
                pcall(function()
                    timer:close()
                end)
                timer = nil
                cooldown = false -- Release cooldown state
                -- print("[Avante] Cooldown ended")
            end)
        )
    end
end)()
------------------------ End Of Avante ------------------------

------------------------ Neo-tree ------------------------
-- local neotree_refresh_timer = nil
-- local neotree_refresh_interval = 2000 --ms
local is_refresh_neotree_need = false
local last_neotree_refresh_time = 0

local function is_git_repo_cached()
    if M.has_target_ft_window("snacks_dashboard") then
        vim.g.is_git_repo_cache = nil
        return false
    end
    if vim.g.is_git_repo_cache ~= nil then
        return vim.g.is_git_repo_cache
    end

    -- Build cross-platform command
    local command
    if M.is_windows() then
        -- Explicitly call CMD in Windows and be compatible with PowerShell environment
        command = 'cmd /c "git rev-parse --is-inside-work-tree 2>nul"'
        -- vim.notify("windows env")
    else
        -- Linux/Mac use standard silent mode
        command = "git rev-parse --is-inside-work-tree 2>/dev/null"
        -- vim.notify("linux env")
    end

    local handle = io.popen(command)
    if not handle then
        vim.g.is_git_repo_cache = false
        return false
    end

    local result = handle:read("*a")
    handle:close()

    -- Tail whitespace trimming
    local trimmed = result:gsub("%s+", "")
    -- vim.notify("git rev-parse output: '" .. trimmed .. "'", vim.log.levels.INFO)
    vim.g.is_git_repo_cache = trimmed == "true"

    -- vim.notify(string.format("final result %s", trimmed), vim.log.levels.INFO)
    return vim.g.is_git_repo_cache
end

local function has_neotree_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neo-tree" then
            -- vim.notify("have neo-tree", vim.log.levels.INFO)
            return true
        end
    end
    -- vim.notify("have not neo-tree", vim.log.levels.WARN)
    return false
end

function M.refresh_neo_tree_if_git()
    -- Check Git repository status
    if not is_git_repo_cached() then
        return
    end

    -- Check if refresh is needed (Diffview related conditions)
    if M.has_target_ft_window("DiffviewFiles") or M.has_target_ft_window("DiffviewFileHistory") then
        is_refresh_neotree_need = true
        -- vim.notify("need refresh neo-tree", vim.log.levels.INFO)
    end

    local now = vim.loop.now()
    if last_neotree_refresh_time and (now - last_neotree_refresh_time > 2000) then
        is_refresh_neotree_need = true
    end

    if
        M.is_current_window_ft("neo-tree")
        or M.is_current_window_ft("Outline")
        or M.is_current_window_ft("grug-far")
        or M.has_target_ft_window("snacks_dashboard")
    then
        is_refresh_neotree_need = false
    end

    if not has_neotree_window() or not is_refresh_neotree_need then
        is_refresh_neotree_need = false
        return
    end

    -- Debounce logic: record last refresh time in ms
    now = vim.loop.now()
    if last_neotree_refresh_time and (now - last_neotree_refresh_time < 2000) then
        -- vim.notify("refresh interval too short", vim.log.levels.INFO)
        return
    end
    last_neotree_refresh_time = now

    -- Execute one-time refresh
    vim.defer_fn(function()
        -- check again before actual refresh due to refresh is delayed
        if
            M.is_current_window_ft("neo-tree")
            or M.is_current_window_ft("Outline")
            or M.is_current_window_ft("grug-far")
            or M.has_target_ft_window("snacks_dashboard")
        then
            is_refresh_neotree_need = false
            return
        end

        -- if has_neotree_window() then
        require("neo-tree.sources.manager").refresh("filesystem")
        is_refresh_neotree_need = false
        -- vim.notify("Refreshed neo-tree once (with delay)", vim.log.levels.INFO)
        -- end
    end, 1000)
end
------------------------ End Of Neo-tree ------------------------

function M.get_global_row_scaled(factor)
    local total_rows = vim.o.lines

    if factor == nil then
        return total_rows
    end

    if type(factor) ~= "number" then
        vim.notify("Input arg not a number", vim.log.levels.ERROR)
        return total_rows
    end

    if factor <= 0 then
        vim.notify("Input factor must be greater than 0", vim.log.levels.ERROR)
        return total_rows
    end

    local result = math.floor(total_rows * factor + 0.5)
    return math.max(1, result)
end

function M.get_global_col_scaled(factor)
    local total_cols = vim.api.nvim_win_get_width(0)

    if factor == nil then
        return total_cols
    end

    if type(factor) ~= "number" or factor <= 0 then
        return total_cols
    end

    if factor <= 0 then
        vim.notify("Input factor must be greater than 0", vim.log.levels.ERROR)
        return total_cols
    end

    local result = math.floor(total_cols * factor + 0.5)
    return math.max(1, result)
end

function M.get_focused_window_row_scaled(factor)
    local total_rows = vim.api.nvim_win_get_height(0)

    if factor == nil then
        return total_rows
    end

    if type(factor) ~= "number" then
        vim.notify("Input arg not a number", vim.log.levels.ERROR)
        return total_rows
    end

    if factor <= 0 then
        vim.notify("Input factor must be greater than 0", vim.log.levels.ERROR)
        return total_rows
    end

    local result = math.floor(total_rows * factor + 0.5)
    return math.max(1, result)
end

function M.get_focused_window_col_scaled(factor)
    local total_cols = vim.o.columns

    if factor == nil then
        return total_cols
    end

    if type(factor) ~= "number" or factor <= 0 then
        return total_cols
    end

    if factor <= 0 then
        vim.notify("Input factor must be greater than 0", vim.log.levels.ERROR)
        return total_cols
    end

    local result = math.floor(total_cols * factor + 0.5)
    return math.max(1, result)
end

function M.set_welcome_buffer(buf)
    local ver = vim.version()
    local version = string.format("%s.%s.%s", ver.major, ver.minor, ver.patch)
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local date = os.date("%Y-%m-%d %H:%M")
    buf = buf or vim.api.nvim_get_current_buf()

    local buf_info = {
        filetype = vim.bo[buf].filetype,
        buftype = vim.bo[buf].buftype,
        filename = vim.api.nvim_buf_get_name(buf),
    }

    if buf_info.filetype ~= "" or buf_info.buftype ~= "" or (buf_info.filename and buf_info.filename:match("lsp.log")) then
        return
    end

    -- Store original window options
    local original_wo = {
        list = vim.wo.list,
        number = vim.wo.number,
        relativenumber = vim.wo.relativenumber,
    }

    -- General information (centered)
    local info_lines = {
        string.format("✨  Welcome to Joreh's Neovim! 🧮 Enjoy your fresh thinking! 🚀"),
        "",
        string.format("✌️Nvim V%s", version),
        "",
        string.format("📍Working dir: %s", cwd),
        "",
        string.format("📅 %s", date),
        "",
        "",
    }

    -- Shortcut information (left-aligned to first line start)
    local shortcut_lines = {
        "  Quick Start 👇:",
        "    📂 <Space>e     ➡️   Open File Explorer",
        "    🔎 <Space>ff    ➡️   Find File",
        "    🔄 <Space>qs    ➡️   Restore The Last Session",
        "    ❌ <Space>qq    ➡️   Exit Neovim",
    }

    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)

    -- Calculate padding for first line
    local first_line = info_lines[1]
    local first_pad = math.floor((win_width - vim.fn.strdisplaywidth(first_line)) / 2)

    -- Center general information
    for i, line in ipairs(info_lines) do
        if line ~= "" then
            local pad = math.floor((win_width - vim.fn.strdisplaywidth(line)) / 2)
            info_lines[i] = string.rep(" ", pad) .. line
        end
    end

    -- Left-align shortcut information to first line start position
    for i, line in ipairs(shortcut_lines) do
        shortcut_lines[i] = string.rep(" ", first_pad) .. line
    end

    -- Combine both sets of information
    local message = vim.list_extend(info_lines, shortcut_lines)

    -- Add top padding for vertical centering
    local top_padding = math.floor((win_height - #message) / 2)
    for _ = 1, top_padding do
        table.insert(message, 1, "")
    end

    -- Write to buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, message)

    -- Set buffer/window options
    vim.bo[buf].modified = false -- Do not mark as modified
    vim.bo[buf].buftype = "nofile" -- Non-file buffer
    vim.bo[buf].filetype = "welcome" -- Set filetype to welcome
    vim.bo[buf].bufhidden = "wipe" -- Auto delete when closing window
    vim.bo[buf].swapfile = false -- Do not generate swapfile
    vim.bo[buf].modifiable = false -- Not modifiable
    vim.bo[buf].readonly = true -- Read-only
    vim.wo.list = false -- Do not display invisible characters
    vim.wo.number = false -- Turn off line numbers
    vim.wo.relativenumber = false -- Turn off relative line numbers

    -- Create an autocommand to restore window options when the buffer is wiped
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        once = true,
        callback = function()
            -- The window that was displaying the welcome buffer is likely the current one.
            -- We need to check if it's still valid before restoring options.
            local current_win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_is_valid(current_win) then
                vim.wo.list = original_wo.list
                vim.wo.number = original_wo.number
                vim.wo.relativenumber = original_wo.relativenumber
            end
        end,
    })
end

function M.has_yazi()
    return vim.fn.executable("yazi") == 1
end

function M.is_plugin_loaded(name)
    local plugin = nvim_config.plugins[name]
    return plugin and plugin._.loaded or false
end

function M.get_glibc_version()
    local output = vim.fn.system("/lib/x86_64-linux-gnu/libc.so.6 2>/dev/null")
    local version = output:match("release version ([%d%.]+)")
    if version then
        return version
    end

    output = vim.fn.system("/usr/bin/ldd --version 2>/dev/null")
    version = output:match("(%d+%.%d+)")
    if version then
        return version
    end

    return "unknown"
end

function M.show_glibc_version()
    local version = M.get_glibc_version()
    vim.notify("GLIBC version: " .. version, vim.log.levels.INFO)
end

function M.is_glibc_less_than(target_version)
    local current = M.get_glibc_version()
    if current == "unknown" then
        return false
    end

    local function split(ver)
        local t = {}
        for num in ver:gmatch("(%d+)") do
            table.insert(t, tonumber(num))
        end
        return t
    end

    local c = split(current)
    local t = split(target_version)

    for i = 1, math.max(#c, #t) do
        local cv = c[i] or 0
        local tv = t[i] or 0
        if cv < tv then
            return true
        end
        if cv > tv then
            return false
        end
    end
    return false
end

function M.is_glibc_larger_than(target_version)
    local current = M.get_glibc_version()
    if current == "unknown" then
        return false
    end

    local function split(ver)
        local t = {}
        for num in ver:gmatch("(%d+)") do
            table.insert(t, tonumber(num))
        end
        return t
    end

    local c = split(current)
    local t = split(target_version)

    for i = 1, math.max(#c, #t) do
        local cv = c[i] or 0
        local tv = t[i] or 0
        if cv > tv then
            return true
        end
        if cv < tv then
            return false
        end
    end
    return false
end

local diffview_open = false
local diffviewFileHistory_open = false

function M.set_diffview_open(state)
    diffview_open = state
end

function M.set_diffviewFileHistory_open(state)
    diffviewFileHistory_open = state
end

function M.toggle_diffview()
    if diffview_open then
        vim.cmd("DiffviewClose")
        diffview_open = false
    else
        vim.cmd("DiffviewOpen")
    end
end

function M.toggle_history_view()
    if diffviewFileHistory_open then
        vim.cmd("DiffviewClose")
        diffviewFileHistory_open = false
    else
        vim.cmd("DiffviewFileHistory")
    end
end

local restore_session_win_count = -1
function M.set_restore_session_win_count(count)
    restore_session_win_count = count
end

function M.get_restore_session_win_count()
    return restore_session_win_count
end

function M.get_projects()
    local session_path = vim.fn.stdpath("data") .. "/sessions/"
    local session_files = vim.fn.glob(session_path .. "*.vim", true, true)

    if vim.tbl_isempty(session_files) then
        return {}
    end

    local files_with_stats = {}
    for _, file in ipairs(session_files) do
        local stat = vim.loop.fs_stat(file)
        if stat then
            table.insert(files_with_stats, { path = file, mtime = stat.mtime.sec })
        end
    end

    -- sort by mtime descending
    table.sort(files_with_stats, function(a, b)
        return a.mtime > b.mtime
    end)

    local projects = {}
    for _, file_info in ipairs(files_with_stats) do
        local session_file = file_info.path
        local project_path = vim.fn.fnamemodify(session_file, ":t:r")

        if M.is_windows() then
            project_path = project_path:gsub("%%", ":\\", 1)
            project_path = project_path:gsub("%%", "\\")
        else
            project_path = project_path:gsub("%%", "/")
            if project_path:sub(1, 1) ~= "/" then
                project_path = "/" .. project_path
            end
        end

        -- Check the path validity and prevent adding the same item repeatedly.
        if not project_path:match("\\\\") and vim.fn.isdirectory(project_path) == 1 then
            if not vim.tbl_contains(projects, project_path) then
                table.insert(projects, project_path)
            end
        end
    end

    local projects_count = #projects
    if 0 == projects_count then
        return nil
    end
    return projects
end

---------------------------- Custom Commands ----------------------------
vim.api.nvim_create_user_command("BufferInfo", function(opts)
    local buf = vim.api.nvim_get_current_buf()
    local lines = {}
    local function add(title, tbl)
        table.insert(lines, "### " .. title .. " ###")
        for k, v in pairs(tbl) do
            table.insert(lines, string.format("%-20s = %s", k, vim.inspect(v)))
        end
        table.insert(lines, "")
    end

    -- Simple info mode (:BufferInfo)
    local general = {
        id = buf,
        name = vim.api.nvim_buf_get_name(buf),
        filetype = vim.bo[buf].filetype,
        buftype = vim.bo[buf].buftype,
        modified = vim.bo[buf].modified,
        readonly = vim.bo[buf].readonly,
        modifiable = vim.bo[buf].modifiable,
        listed = vim.bo[buf].buflisted,
        loaded = vim.api.nvim_buf_is_loaded(buf),
        line_count = vim.api.nvim_buf_line_count(buf),
        encoding = vim.bo[buf].fileencoding,
        fileformat = vim.bo[buf].fileformat,
        swapfile = vim.bo[buf].swapfile,
    }

    add("General", general)

    if opts.bang then
        -- Verbose info mode (:BufferInfo!)
        local bufinfo = vim.fn.getbufinfo(buf)[1] or {}
        local ok, vars = pcall(vim.fn.getbufvar, buf, "")
        if not ok then
            vars = {}
        end

        local opts_tbl = {}
        for _, name in ipairs(vim.tbl_keys(vim.api.nvim_get_all_options_info())) do
            local ok_opt, val = pcall(vim.api.nvim_get_option_value, name, { buf = buf })
            if ok_opt then
                opts_tbl[name] = val
            end
        end

        add("BufInfo", bufinfo)
        add("Vars", vars)
        add("Options", opts_tbl)
    end

    -- Send to quickfix
    local qf_items = {}
    for i, line in ipairs(lines) do
        table.insert(qf_items, { lnum = i, text = line })
    end
    vim.fn.setqflist(qf_items, "r")
    vim.cmd("copen")
end, {
    bang = true, -- For: BufferInfo!
    desc = "Show current buffer information",
})

vim.api.nvim_create_user_command("WindowInfo", function(opts)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local lines = {}

    local function add(title, tbl)
        table.insert(lines, "### " .. title .. " ###")
        for k, v in pairs(tbl) do
            table.insert(lines, string.format("%-20s = %s", k, vim.inspect(v)))
        end
        table.insert(lines, "")
    end

    -- Simple info mode (:WindowInfo)
    local general = {
        id = win,
        buf = buf,
        winid = win,
        bufnr = buf,
        win_type = vim.fn.win_gettype(win),
        width = vim.api.nvim_win_get_width(win),
        height = vim.api.nvim_win_get_height(win),
        winbar = vim.wo[win].winbar,
        cursor = vim.api.nvim_win_get_cursor(win),
        topline = vim.fn.line("w0", win),
        botline = vim.fn.line("w$", win),
        relative = vim.api.nvim_win_get_config(win).relative,
        is_floating = vim.api.nvim_win_get_config(win).relative ~= "",
        is_valid = vim.api.nvim_win_is_valid(win),
    }
    add("General", general)

    if opts.bang then
        -- Verbose info mode (:WindowInfo!)
        local config = vim.api.nvim_win_get_config(win)
        local opts_tbl = {}
        for _, name in ipairs(vim.tbl_keys(vim.api.nvim_get_all_options_info())) do
            local ok_opt, val = pcall(vim.api.nvim_get_option_value, name, { win = win })
            if ok_opt then
                opts_tbl[name] = val
            end
        end
        add("WindowConfig", config)
        add("WindowOptions", opts_tbl)
    end

    local qf_items = {}
    for i, line in ipairs(lines) do
        table.insert(qf_items, { lnum = i, text = line })
    end
    vim.fn.setqflist(qf_items, "r")
    vim.cmd("copen")
end, {
    bang = true, -- For :WindowInfo!
    desc = "Show current window information",
})

vim.api.nvim_create_user_command("BufferHighlights", function(opts)
    local show_color = opts.bang -- Show verbose info with colors and styles if '!' is used
    local groups = vim.fn.getcompletion("@lsp", "highlight")
    local result = {}

    -- Parse hl.link recursively
    local function resolve_hl(name, depth)
        depth = depth or 0
        if depth > 5 then
            return name
        end -- Avoid infinite loop
        local hl = vim.api.nvim_get_hl(0, { name = name, link = true })
        if hl.link then
            return resolve_hl(hl.link, depth + 1)
        end
        return name, hl
    end

    for _, g in ipairs(groups) do
        local resolved_name, hl = resolve_hl(g)
        hl = hl or {}

        local styles = {}
        for _, style in ipairs({ "bold", "italic", "underline", "strikethrough" }) do
            if hl[style] then
                table.insert(styles, style)
            end
        end
        local style_str = #styles > 0 and table.concat(styles, ",") or "-"

        local line = ""
        if show_color then
            local fg = hl.fg and string.format("#%06x", hl.fg) or "-"
            local bg = hl.bg and string.format("#%06x", hl.bg) or "-"
            local sp = hl.sp and string.format("#%06x", hl.sp) or "-"
            line = string.format("%-40s → %-25s  fg=%-9s bg=%-9s sp=%-9s style=%s", g, resolved_name, fg, bg, sp, style_str)
        else
            line = string.format("%-40s → %s", g, resolved_name)
        end
        table.insert(result, line)
    end

    if #result == 0 then
        vim.notify("No @lsp.* highlight groups found", vim.log.levels.INFO)
        return
    end

    vim.fn.setqflist({}, "r", { title = "LSP/Treesitter Highlight Links", lines = result })
    vim.cmd("copen")
end, {
    bang = true,
    desc = "Display current LSP/Treesitter highlight links in Neovim (with ! shows colors and styles)",
})

return M
