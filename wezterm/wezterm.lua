local wezterm = require("wezterm")
local action = wezterm.action
local nerdfonts = wezterm.nerdfonts
local mux = wezterm.mux

local F = require("functions")
-- local W = require("workspaces")

--Weztern Built-in Nerdfont Icons:  https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html

local colors = {}
local config = {}
local custom = {}

-- Custom
custom = {
    -- color_scheme = {
    --     dark  = "Catppuccin Frappe",
    --     light = "Catppuccin Mocha",
    -- },
    hostname = {
        current = string.lower(wezterm.hostname()),
        work = "pc-xxxx",
    },
    timeout = {
        key = 3000,
        leader = 1200,
    },
    username = os.getenv("USER") or os.getenv("LOGNAME") or os.getenv("USERNAME"),
}

--------------------------------- Lauch ---------------------------------
config.default_prog = { "powershell.exe", "-NoLogo" }
config.automatically_reload_config = true

-- CLipboard
-- if os.getenv("XDG_SESSION_TYPE") == "wayland" then
--     custom.clipboard = { copy = "wl-copy -n" }
-- end
--
-- if os.getenv("XDG_SESSION_TYPE") == "x11" then
--     custom.clipboard = { copy = "xsel --clipboard" }
-- end

-- Launch commands
config.launch_menu = {
    {
        label = "󰨊 PoserShell",
        args = { "powershell.exe", "-NoLogo" },
    },
    {
        label = " WSL Default",
        args = { "wsl.exe", "~" },
    },
    {
        label = " SSH -> 100Ask",
        args = { "ssh", "root@192.168.5.9" },
    },
    -- {
    --     label = " SSH -> 512",
    --     args = { "ssh", "admin@192.168.225.1" },
    -- },
    {
        label = " Cmd",
        args = { "cmd.exe" },
    },
}

--------------------------------- Colorscheme ---------------------------------
-- config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = 'OneHalfDark'
config.color_scheme = "OneDark (base16)"
-- auto switch dark/light mode
-- config.color_scheme = F.scheme_for_appearance(
--     wezterm.gui.get_appearance(),
--     custom.color_scheme.dark,
--     custom.color_scheme.light
-- )
colors = wezterm.get_builtin_color_schemes()[config.color_scheme]

-- theme colors adjustments
-- colors.background = "#2D2F3A"

-- terminal colors
local color_inactive_pane_sep = colors.ansi[1]
local color_window_decorations = "#333333" -- used in Minimize, Maximize, Close button

if config.color_scheme == "OneDark (base16)" then
    color_inactive_pane_sep = colors.brights[1]
    color_window_decorations = "#333333"
elseif config.color_scheme == "Catppuccin Frappe" then
    color_inactive_pane_sep = colors.ansi[1]
    color_window_decorations = "#414559"
end

config.colors = {
    compose_cursor = colors.ansi[2],
    cursor_bg = colors.brights[8],
    cursor_border = colors.brights[8],
    split = colors.brights[1],
    tab_bar = {
        background = colors.background,
        active_tab = {
            bg_color = colors.background,
            fg_color = colors.foreground,
            italic = true,
        },
    },
    foreground = colors.brights[8],
    -- background = "#2d3139",
    visual_bell = colors.ansi[2],
    -- scrollbar_thumb = colors.brights[1],
}

--------------------------------- Font ---------------------------------
--- diable missing font glyph warnings
config.warn_about_missing_glyphs = false
config.font = wezterm.font_with_fallback({
    -- main font
    { family = "Maple Mono CN", weight = "Regular" },
    -- { family = "Maple Mono NF CN", weight = "Regular" },
    { family = "JetBrainsMono Nerd Font", weight = "Regular" },
    { family = "FiraCode Nerd Font Mono", weight = "Regular" },
    { family = "Segoe UI Emoji", weight = "Regular" },
    { family = "Noto Color Emoji", weight = "Regular" },
})
config.font_size = 14
if custom.hostname.current == "fresh" then
    -- config.line_height = 0.9
end

----------------------------- Commands Palette ---------------------------
config.command_palette_font_size = 15
config.command_palette_font = wezterm.font_with_fallback({
    -- main font
    -- { family = "Maple Mono CN", weight = "Regular" },
    -- { family = "Maple Mono NF CN", weight = "Regular" },
    { family = "JetBrainsMono Nerd Font", weight = "Regular" },
    { family = "FiraCode Nerd Font Mono", weight = "Regular" },
    { family = "Segoe UI Emoji", weight = "Regular" },
    { family = "Noto Color Emoji", weight = "Regular" },
})
config.command_palette_bg_color = "#35383d"
-- config.ommand_palette_fg_color = rgba(0.75, 0.75, 0.75, 1.0)

--------------------------------- Window ---------------------------------
config.bold_brightens_ansi_colors = true
config.initial_cols = 110
config.initial_rows = 30

config.text_background_opacity = 1
config.window_background_opacity = 0.9
-- config.win32_system_backdrop = "Acrylic"
-- config.win32_system_backdrop = 'Mica'
config.win32_system_backdrop = "Tabbed"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

local top_padding = ("fresh" == custom.hostname.current) and { config.font_size / 2 } or { config.font_size }

config.window_padding = {
    left = 0,
    right = 10,
    top = top_padding[1],
    bottom = 0,
}

-- Tab/Pane Viewing
-- active pane
config.foreground_text_hsb = {
    brightness = 0.99,
    saturation = 0.97,
    -- hue = 1.0,
}

-- inactive pane
config.inactive_pane_hsb = {
    brightness = 0.85,
    saturation = 0.94,
    -- hue = 1.0,
}

-- Bell
config.visual_bell = {
    fade_in_function = "Constant",
    fade_in_duration_ms = 0,
    fade_out_function = "Constant",
    fade_out_duration_ms = 300,
    target = "CursorColor",
}

-- Tab
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = true
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.tab_max_width = 30
config.use_fancy_tab_bar = false

--------------------------------- Graphics ---------------------------------
config.animation_fps = 1
-- When using a non-English keyboard to input a return(Enter), the following configuration will cause the terminal to freeze.
-- if custom.hostname.current == "fresh" then
-- config.animation_fps = 1
-- else
--     config.animation_fps = 23
--     -- config.cursor_blink_ease_in = "EaseIn"
--     -- config.cursor_blink_ease_out = "EaseOut"
--     config.front_end = "WebGpu"
--     config.max_fps = 75
--     config.webgpu_power_preference = "HighPerformance" -- HighPerformance or LowPower
-- end

--------------------------------- Keys ---------------------------------
-- IME
config.use_ime = true
-- Keys Mapping
config.disable_default_key_bindings = true
config.leader = { key = "Space", mods = "ALT", timeout_milliseconds = custom.timeout.leader }
config.keys = {
    {
        key = "Delete",
        mods = "NONE",
        -- clear viewport by injecting new lines and sending CTRL-L
        action = wezterm.action_callback(function(window, pane)
            -- scroll to bottom in case you aren't already
            window:perform_action(wezterm.action.ScrollToBottom, pane)
            -- get the current height of the viewport
            local height = pane:get_dimensions().viewport_rows
            -- build a string of new lines equal to the viewport height
            local blank_viewport = string.rep("\r\n", height)
            -- inject those new lines to push the viewport contents into the scrollback
            pane:inject_output(blank_viewport)
            -- send an escape sequence to clear the viewport (CTRL-L)
            pane:send_text("\x0c")
        end),
        -- true clear
        -- action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    },
    -- CTRL + W close current Tab
    { key = "w", mods = "ALT", action = action.CloseCurrentTab({ confirm = true }) },
    -- close current Tab
    { key = "q", mods = "ALT", action = action.CloseCurrentPane({ confirm = true }) },
    -- {
    --     key = "l",
    --     mods = "CTRL|SHIFT",
    --     action = action.Multiple({
    --         action.ClearScrollback("ScrollbackOnly"),
    --         action.EmitEvent("flash-terminal"),
    --     }),
    -- },
    { key = "t", mods = "ALT", action = action.SpawnTab("DefaultDomain") },
    -- copy/paste
    {
        key = "v",
        mods = "CTRL|SHIFT",
        action = action.Multiple({
            action.PasteFrom("PrimarySelection"),
            action.ClearSelection,
        }),
    },
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = action.Multiple({
            action.CopyTo("ClipboardAndPrimarySelection"),
            action.ClearSelection,
        }),
    },
    -- move pane to new window
    {
        key = "p",
        mods = "CTRL|ALT",
        action = wezterm.action_callback(function(win, pane)
            local tab, window = pane:move_to_new_window()
        end),
    },
    -- open command palette
    { key = "p", mods = "CTRL|SHIFT", action = action.ActivateCommandPalette },
    -- open launch menu
    { key = "n", mods = "ALT", action = action.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },
    -- Pane switch
    { key = "UpArrow", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },

    { key = "k", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
    { key = "j", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
    { key = "l", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },
    { key = "h", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },

    -- buufer scroll
    { key = "UpArrow", mods = "SHIFT", action = action.ScrollByLine(-1) },
    { key = "DownArrow", mods = "SHIFT", action = action.ScrollByLine(1) },
    { key = "End", mods = "SHIFT", action = action.ScrollToBottom },
    { key = "Home", mods = "SHIFT", action = action.ScrollToTop },
    { key = "PageDown", mods = "SHIFT", action = action.ScrollByPage(1) },
    { key = "PageUp", mods = "SHIFT", action = action.ScrollByPage(-1) },

    -- opacity set
    { key = "0", mods = "ALT", action = action.EmitEvent("toggle-opacity-reset") },
    { key = "-", mods = "ALT", action = action.EmitEvent("toggle-opacity-minus") },
    { key = "=", mods = "ALT", action = action.EmitEvent("toggle-opacity-plus") },

    -- font size set
    { key = "0", mods = "CTRL", action = action.ResetFontSize },
    { key = "-", mods = "CTRL", action = action.DecreaseFontSize },
    { key = "=", mods = "CTRL", action = action.IncreaseFontSize },

    -- Tab switch
    { key = "[", mods = "ALT", action = action.ActivateTabRelative(-1) },
    { key = "]", mods = "ALT", action = action.ActivateTabRelative(1) },

    -- warkspace switch
    {
        key = "[",
        mods = "ALT|CTRL",
        action = action.Multiple({
            action.SwitchWorkspaceRelative(-1),
            action.EmitEvent("set-previous-workspace"),
        }),
    },
    {
        key = "]",
        mods = "ALT|CTRL",
        action = action.Multiple({
            action.SwitchWorkspaceRelative(1),
            action.EmitEvent("set-previous-workspace"),
        }),
    },

    -- Leader key tables
    {
        key = "o",
        mods = "LEADER",
        action = action.ActivateKeyTable({
            name = "Open",
            one_shot = false,
            until_unknown = true,
            timeout_milliseconds = custom.timeout.key,
        }),
    },
    {
        key = "m",
        mods = "LEADER",
        action = action.ActivateKeyTable({
            name = "Move",
            one_shot = false,
            until_unknown = false,
            timeout_milliseconds = custom.timeout.key,
        }),
    },
    {
        key = "r",
        mods = "LEADER",
        action = action.ActivateKeyTable({
            name = "Resize",
            one_shot = false,
            until_unknown = true,
            timeout_milliseconds = custom.timeout.key,
        }),
    },
    {
        key = "y",
        mods = "LEADER",
        action = action.ActivateKeyTable({
            name = "Copy",
            one_shot = false,
            until_unknown = true,
            timeout_milliseconds = custom.timeout.key,
        }),
    },

    -- workspaces
    {
        key = "l",
        mods = "LEADER",
        action = action.Multiple({
            wezterm.action_callback(function(window, pane)
                F.switch_previous_workspace(window, pane)
            end),
            action.EmitEvent("set-previous-workspace"),
        }),
    },
    { key = "q", mods = "LEADER", action = action.QuitApplication },
    {
        key = "s",
        mods = "LEADER",
        action = action.Multiple({
            action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
            action.EmitEvent("set-previous-workspace"),
        }),
    },

    { key = "h", mods = "LEADER", action = action.ActivateCommandPalette },
    { key = "c", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },
    { key = "t", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "TABS" }) },

    { key = "d", mods = "LEADER", action = action.ShowDebugOverlay },
    { key = "v", mods = "LEADER", action = action.ActivateCopyMode },
    { key = "w", mods = "LEADER", action = action.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "LEADER", action = action.TogglePaneZoomState },
    { key = "/", mods = "LEADER", action = action.Search({ CaseInSensitiveString = "" }) },
    -- Tab split
    { key = "-", mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    {
        key = ",",
        mods = "LEADER",
        action = action.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { Color = colors.foreground } },
                { Text = "Renaming tab title:" },
            }),
            action = wezterm.action_callback(function(window, _, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },
    {
        key = "$",
        mods = "LEADER|SHIFT",
        action = action.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { Color = colors.foreground } },
                { Text = "Renaming session/workspace:" },
            }),
            action = wezterm.action_callback(function(_, _, line)
                if line then
                    mux.rename_workspace(mux.get_active_workspace(), line)
                end
            end),
        }),
    },
}

-- Active tab by index
for i = 1, 9 do
    table.insert(config.keys, { key = tostring(i), mods = "ALT", action = action.ActivateTab(i - 1) })
end

config.key_tables = {
    Copy = {
        { key = "b", action = action.EmitEvent("copy-buffer-from-pane") },
        { key = "p", action = action.EmitEvent("copy-text-from-pane") },
        {
            key = "l",
            action = action.QuickSelectArgs({
                label = "COPY LINE",
                patterns = { "^.*\\S+.*$" },
                scope_lines = 1,
                action = action.Multiple({
                    action.CopyTo("ClipboardAndPrimarySelection"),
                    action.ClearSelection,
                }),
            }),
        },
        {
            key = "r",
            action = action.QuickSelectArgs({
                label = "COPY REGEX",
                patterns = {
                    "(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(?:/\\d{1,2})?)", -- ipv4
                    "((?:[[:xdigit:]]{0,4}:){2,7}[[:xdigit:]]{0,4}(?:/\\d{1,3})?)", -- ipv6
                    "[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}", -- mac address
                    "\\S+@\\S+\\.\\S+", -- e-mail
                    "[[:xdigit:]]{12}", -- container id
                    "\\S+/\\S+:\\S+", -- container image name
                    "(br(?:-[[:xdigit:]]{12}|\\d)|eth\\d|en[opsx]\\ds\\d|wlp\\ds\\d\\w+|virbr\\d)", -- interface
                    "(?:https?|s?ftp)://\\S+", -- url
                },
                action = action.Multiple({
                    action.CopyTo("ClipboardAndPrimarySelection"),
                    action.ClearSelection,
                }),
            }),
        },
    },

    Move = {
        { key = "r", action = action.RotatePanes("CounterClockwise") },
        { key = "s", action = action.PaneSelect },
        { key = "Enter", action = "PopKeyTable" },
        { key = "Escape", action = "PopKeyTable" },
        { key = "LeftArrow", mods = "SHIFT", action = action.MoveTabRelative(-1) },
        { key = "RightArrow", mods = "SHIFT", action = action.MoveTabRelative(1) },
    },

    Resize = {
        { key = "DownArrow", action = action.AdjustPaneSize({ "Down", 1 }) },
        { key = "LeftArrow", action = action.AdjustPaneSize({ "Left", 1 }) },
        { key = "RightArrow", action = action.AdjustPaneSize({ "Right", 1 }) },
        { key = "UpArrow", action = action.AdjustPaneSize({ "Up", 1 }) },
        { key = "Enter", action = "PopKeyTable" },
        { key = "Escape", action = "PopKeyTable" },
    },

    Open = {
        {
            key = "u",
            action = action({
                QuickSelectArgs = {
                    label = "open URL on BROWSER",
                    patterns = { "https?://\\S+" },
                    scope_lines = 30,
                    action = wezterm.action_callback(function(window, pane)
                        local url = window:get_selection_text_for_pane(pane)
                        wezterm.log_info("opening: " .. url)
                        wezterm.open_with(url)
                    end),
                },
            }),
        },
    },
}

--------------------------------- Mouse & Cursor ---------------------------------
-- Cursor
F.gsettings_config(config)
config.bypass_mouse_reporting_modifiers = "SHIFT"
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_rate = 500
config.default_cursor_style = "BlinkingBlock"
config.force_reverse_video_cursor = false
config.hide_mouse_cursor_when_typing = true

-- Hyperlink
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
    regex = "\\b[A-Z-a-z0-9-_\\.]+@[\\w-]+(\\.[\\w-]+)+\\b",
    format = "mailto:$0",
})

-- Scrolling
config.enable_scroll_bar = true
config.scrollback_lines = 10000
config.alternate_buffer_wheel_scroll_speed = 5

-- Mouse
-- config.disable_default_mouse_bindings = true
config.mouse_bindings = {
    { event = { Down = { streak = 1, button = "Middle" } }, mods = "NONE", action = action.PasteFrom("Clipboard") },
    -- {
    --     event = { Drag = { streak = 1, button = "Left" } },
    --     mods = "SHIFT",
    --     action = wezterm.action.StartWindowDrag,
    -- },
    -- {
    --     event = { Up = { streak = 1, button = "Left" } },
    --     action = action.Multiple({
    --         action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
    --         action.ClearSelection,
    --     }),
    -- },
    {
        event = { Up = { streak = 1, button = "Left" } },
        action = wezterm.action_callback(function(window, pane)
            wezterm.sleep_ms(100)
            window:perform_action(
                wezterm.action.Multiple({
                    wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
                    wezterm.action.ClearSelection,
                }),
                pane
            )
        end),
    },

    {
        event = { Up = { streak = 2, button = "Left" } },
        mods = "NONE",
        action = action.Multiple({ action.CopyTo("ClipboardAndPrimarySelection"), action.ClearSelection }),
    },
    {
        event = { Up = { streak = 3, button = "Left" } },
        mods = "NONE",
        action = action.Multiple({ action.CopyTo("ClipboardAndPrimarySelection"), action.ClearSelection }),
    },
    { event = { Up = { streak = 1, button = "Left" } }, mods = "SHIFT", action = action.OpenLinkAtMouseCursor },

    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "NONE",
        action = action.ScrollByLine(5),
    },
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "NONE",
        action = action.ScrollByLine(-5),
    },
}

--------------------------------- Events ---------------------------------
wezterm.on("augment-command-palette", function(window, pane)
    return {
        {
            brief = "Rename Tab",
            icon = "md_rename_box",

            action = action.PromptInputLine({
                description = "Enter new name for current tab",
                initial_value = "",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },
        {
            brief = "SSH Login 512",
            icon = "md_login",
            action = wezterm.action_callback(function(window, pane)
                pane:send_text("ssh admin@192.168.225.1\r")
                wezterm.sleep_ms(1000)
                pane:send_text("admin@123\r\n")
                wezterm.sleep_ms(500)
                pane:send_text("support enable\r\n")
                wezterm.sleep_ms(500)
                pane:send_text("inhand\r\n")
                wezterm.sleep_ms(300)
                pane:send_text("root$!^&/2022@inhand\r\n")
                window:active_tab():set_title("SSH->512")
            end),
        },
        {
            brief = "SSH Login 954C",
            icon = "md_login",
            action = wezterm.action_callback(function(window, pane)
                pane:send_text("ssh admin@192.168.2.1\r")
                wezterm.sleep_ms(1000)
                pane:send_text("admin@123\r\n")
                wezterm.sleep_ms(500)
                pane:send_text("inhand\r\n")
                wezterm.sleep_ms(300)
                pane:send_text("64391099@inhand\r\n")
                window:active_tab():set_title("SSH->954C")
            end),
        },
        {
            brief = "Telnet Login 954C",
            icon = "md_login",
            action = wezterm.action_callback(function(window, pane)
                pane:send_text("telnet 192.168.2.1 23\r")
                wezterm.sleep_ms(1000)
                pane:send_text("admin\r\n")
                wezterm.sleep_ms(500)
                pane:send_text("admin@123\r\n")
                wezterm.sleep_ms(500)
                pane:send_text("inhand\r\n")
                wezterm.sleep_ms(200)
                pane:send_text("64391099@inhand\r\n")
                window:active_tab():set_title("Telnet->954C")
            end),
        },
        {
            brief = "Dtu Log",
            icon = "md_math_log",
            action = wezterm.action_callback(function(window, pane)
                pane:send_text("tail -f /var/log/messages\r\n")
            end),
        },
        {
            brief = "Show Shell Color ",
            icon = "cod_symbol_color",
            action = wezterm.action_callback(function(window, pane)
                local cmd = [[
for i in {0..255}; do
    printf "\e[48;5;%dm  \e[49m\e[38;5;%dm%03d\e[0m " $i $i $i
    if [ $((i % 6)) -eq 3 ]; then
        echo
    fi
done
]]
                pane:send_text(cmd .. "\r")
            end),
        },
    }
end)
-- Events update status
wezterm.on("update-status", function(window, pane)
    -- Workspace name
    local active_key_table = window:active_key_table()
    local stat = window:active_workspace()
    local workspace_color = colors.ansi[3]
    -- local time = wezterm.strftime("%Y.%m.%d %H:%M")
    local time = wezterm.strftime("%m.%d %H:%M")

    if active_key_table then
        stat = active_key_table
        workspace_color = colors.ansi[4]
    elseif window:leader_is_active() then
        stat = "leader"
        workspace_color = colors.ansi[2]
    end

    if "default" == stat then
        stat = nerdfonts.dev_scalingo
    end

    -- Current working directory
    local cwd = pane:get_current_working_dir()
    if cwd then
        if type(cwd) == "userdata" then
            -- Wezterm introduced the URL object in 20240127-113634-bbcac864
            if string.len(cwd.path) > config.tab_max_width then
                cwd = F.shorten_path(cwd.path, config.tab_max_width)
                -- cwd = ".." .. string.sub(cwd.path, config.tab_max_width * -1, -1)
            else
                cwd = cwd.path
            end
        end
    else
        cwd = ""
    end

    -- Left status (left of the tab line)
    window:set_left_status(wezterm.format({
        { Attribute = { Intensity = "Normal" } },
        { Background = { Color = colors.background } },
        { Text = " " },
        { Background = { Color = colors.background } },
        { Foreground = { Color = workspace_color } },
        { Text = nerdfonts.ple_left_half_circle_thick },
        { Background = { Color = workspace_color } },
        { Foreground = { Color = colors.ansi[1] } },
        { Text = nerdfonts.cod_terminal_tmux .. " " },
        { Background = { Color = color_inactive_pane_sep } },
        { Foreground = { Color = workspace_color } },
        { Text = " " .. stat .. " " },
        { Background = { Color = colors.background } },
        { Foreground = { Color = color_inactive_pane_sep } },
        { Text = nerdfonts.ple_right_half_circle_thick .. " " },
    }))

    -- Right status
    window:set_right_status(wezterm.format({
        -- Wezterm has a built-in nerd fonts
        --
        -- Current working directory
        -- { Text = " " },
        -- { Background = { Color = colors.background } },
        -- { Foreground = { Color = colors.ansi[4] } },
        -- { Text = nerdfonts.ple_left_half_circle_thick },
        -- { Background = { Color = colors.ansi[4] } },
        -- { Foreground = { Color = colors.background } },
        -- { Text = nerdfonts.md_folder .. " " },
        -- { Background = { Color = colors.ansi[1] } },
        -- { Foreground = { Color = colors.foreground } },
        -- { Text = " " .. cwd },
        -- { Background = { Color = colors.background } },
        -- { Foreground = { Color = colors.ansi[1] } },
        -- { Text = nerdfonts.ple_right_half_circle_thick },

        -- Username
        { Text = " " },
        { Background = { Color = colors.background } },
        { Foreground = { Color = colors.ansi[7] } },
        { Text = nerdfonts.ple_left_half_circle_thick },
        { Background = { Color = colors.ansi[7] } },
        { Foreground = { Color = colors.background } },
        { Text = nerdfonts.fa_user .. " " },
        { Background = { Color = colors.ansi[1] } },
        { Foreground = { Color = colors.foreground } },
        { Text = " " .. custom.username },
        { Background = { Color = colors.background } },
        { Foreground = { Color = colors.ansi[1] } },
        { Text = nerdfonts.ple_right_half_circle_thick },

        -- Hostname
        -- { Text = " " },
        -- { Background = { Color = colors.background } },
        -- { Foreground = { Color = colors.ansi[7] } },
        -- { Text = nerdfonts.ple_left_half_circle_thick },
        -- { Background = { Color = colors.ansi[7] } },
        -- { Foreground = { Color = colors.ansi[1] } },
        -- { Text = nerdfonts.cod_server .. " " },
        -- { Background = { Color = colors.ansi[1] } },
        -- { Foreground = { Color = colors.foreground } },
        -- { Text = " " .. custom.hostname.current },
        -- { Background = { Color = colors.background } },
        -- { Foreground = { Color = colors.ansi[1] } },
        -- { Text = nerdfonts.ple_right_half_circle_thick },

        { Text = " " },
        { Background = { Color = colors.background } },
        { Foreground = { Color = colors.ansi[4] } },
        { Text = nerdfonts.ple_left_half_circle_thick },
        { Background = { Color = colors.ansi[4] } },
        { Foreground = { Color = colors.background } },
        { Text = nerdfonts.md_calendar_clock .. " " },
        { Background = { Color = colors.ansi[1] } },
        { Foreground = { Color = colors.foreground } },
        { Text = " " .. time },
        { Background = { Color = colors.background } },
        { Foreground = { Color = colors.ansi[1] } },
        { Text = nerdfonts.ple_right_half_circle_thick .. " " },
        { Foreground = { Color = color_window_decorations } },
        { Text = nerdfonts.ple_left_half_circle_thick },
    }))
end)

-- Events define tab title
wezterm.on("format-tab-title", function(tab, panes)
    local command_args = nil
    local command = nil
    local pane = tab.active_pane
    local title = F.tab_title(tab)
    local tab_number = tostring(tab.tab_index + 1)
    local program = pane.user_vars.WEZTERM_PROG

    -- Filter command name
    if program and program ~= "" then
        command_args = program
        if command_args then
            command = string.match(command_args, "^%S+")
        end
    end

    -- Shrink title if too long
    if string.len(title) > config.tab_max_width - 3 then
        -- wezterm.log_info("Tab title too long: " .. title)
        -- title = string.sub(title, 1, config.tab_max_width - 12) .. ".. "
        title = F.shorten_path(title, config.tab_max_width - 12)
    else
        title = title:gsub("%.exe$", "")
    end
    -- wezterm.log_info("Tab title: " .. title)

    -- -- Add terminal icon
    -- if tab.is_active then
    --     title = nerdfonts.dev_terminal .. " " .. title
    -- end

    -- Add zoom icon
    if pane.is_zoomed then
        title = nerdfonts.cod_zoom_in .. " " .. title
    end

    -- Add copy icon
    if string.match(pane.title, "^Copy mode:") then
        title = nerdfonts.md_content_copy .. " " .. title
    end

    local need_terminal_icon = true
    -- Add icon to command
    if command then
        need_terminal_icon = false
        -- Add docker icon
        if command == "docker" or command == "podman" then
            title = nerdfonts.linux_docker .. " " .. title
        -- Add kubernetes icon
        elseif command == "kind" or command == "kubectl" then
            title = nerdfonts.md_kuberntes .. " " .. title
        -- Add ssh icon
        elseif command == "ssh" then
            title = nerdfonts.md_remote_desktop .. " " .. title
        -- Add monitoring icon
        elseif string.match(command, "^([bh]?)top") then
            title = nerdfonts.md_monitor_eye .. " " .. title
        -- Add vim icon
        elseif string.match(command, "^vi(m?)") then
            title = nerdfonts.dev_vim .. " " .. title
        -- Add nvim icon
        elseif string.match(pane.title, "^nvim") then
            title = nerdfonts.custom_neovim .. " " .. title
        -- Add watch icon
        elseif command == "watch" then
            title = nerdfonts.md_eye_outline .. " " .. title
        else
            need_terminal_icon = true
        end
    else
        need_terminal_icon = false
        if string.match(pane.title, "^vi(m?)") then
            title = nerdfonts.dev_vim .. " " .. title
        elseif string.match(pane.title, "^nvim") then
            title = nerdfonts.custom_neovim .. " " .. title
        else
            need_terminal_icon = true
        end
    end

    -- Add terminal icon
    if tab.is_active and need_terminal_icon then
        title = nerdfonts.dev_terminal .. " " .. title
    end

    -- Add bell icon
    if not F.is_windows_os() then
        -- on inactive panes if something shows up
        local has_unseen_output = false
        if not tab.is_active then
            for _, pane in ipairs(tab.panes) do
                if pane.has_unseen_output then
                    has_unseen_output = true
                    break
                end
            end
        end

        if has_unseen_output then
            title = nerdfonts.md_bell_ring_outline .. " " .. title
        end
    end

    if tab.is_active then
        return {
            { Background = { Color = colors.background } },
            { Foreground = { Color = colors.indexed[16] } },
            -- { Text = nerdfonts.md_eye_arrow_right_outline .. " " },
            { Text = nerdfonts.fa_paper_plane_o .. " " },
            -- { Text = nerdfonts.indent_dotted_guide },
            { Text = nerdfonts.iec_power_on },
            -- { Background = { Color = colors.indexed[16] } },
            -- { Text = " " },
            -- { Background = { Color = colors.visual_bell } },
            -- { Foreground = { Color = colors.indexed[16] } },
            { Text = " " },
            { Text = title .. " " },
            { Background = { Color = colors.indexed[16] } },
            { Foreground = { Color = colors.background } },
            { Text = " " .. tab_number },
            { Background = { Color = colors.background } },
            { Foreground = { Color = colors.indexed[16] } },
            { Text = nerdfonts.ple_right_half_circle_thick .. " " },
            -- { Text = nerdfonts.fa_hand_point_left .. " " },
        }
    else
        return {
            { Background = { Color = colors.background } },
            { Foreground = { Color = color_inactive_pane_sep } },
            { Text = nerdfonts.ple_left_half_circle_thick },
            { Background = { Color = color_inactive_pane_sep } },
            { Foreground = { Color = colors.foreground } },
            { Text = title .. " " },
            { Background = { Color = colors.ansi[5] } },
            { Foreground = { Color = colors.background } },
            { Text = " " .. tab_number },
            { Background = { Color = colors.background } },
            { Foreground = { Color = colors.ansi[5] } },
            { Text = nerdfonts.ple_right_half_circle_thick .. " " },
        }
    end
end)

wezterm.on("toggle-cursor-bg", function(window, pane, stat)
    local overrides = window:get_config_overrides() or {}
    overrides.colors = config.colors

    if window:active_key_table() then
        overrides.colors.cursor_bg = colors.ansi[4]
    else
        overrides.colors.cursor_bg = colors.indexed[16]
    end

    window:set_config_overrides(overrides)
end)

wezterm.on("toggle-opacity-minus", function(window, pane)
    local overrides = window:get_config_overrides() or {}

    if not overrides.text_background_opacity or not overrides.window_background_opacity then
        overrides.text_background_opacity = config.text_background_opacity
        overrides.window_background_opacity = config.window_background_opacity
    end

    if overrides.window_background_opacity >= 0.01 and overrides.window_background_opacity <= 1 then
        overrides.text_background_opacity = overrides.text_background_opacity - 0.1
        overrides.window_background_opacity = overrides.window_background_opacity - 0.1
        window:set_config_overrides(overrides)
    end
end)

wezterm.on("toggle-opacity-plus", function(window, pane)
    local overrides = window:get_config_overrides() or {}

    if overrides then
        overrides.text_background_opacity = tonumber(string.format("%.2f", overrides.text_background_opacity))
        overrides.window_background_opacity = tonumber(string.format("%.2f", overrides.window_background_opacity))
    else
        overrides.text_background_opacity = config.text_background_opacity
        overrides.window_background_opacity = config.window_background_opacity
    end

    if overrides.window_background_opacity >= 0 and overrides.window_background_opacity < 1 then
        overrides.text_background_opacity = overrides.text_background_opacity + 0.1
        overrides.window_background_opacity = overrides.window_background_opacity + 0.1
        window:set_config_overrides(overrides)
    end
end)

wezterm.on("toggle-opacity-reset", function(window, pane)
    local overrides = window:get_config_overrides() or {}

    overrides.text_background_opacity = config.text_background_opacity
    overrides.window_background_opacity = config.window_background_opacity
    window:set_config_overrides(overrides)
end)

wezterm.on("set-previous-workspace", function(window, pane)
    local current_workspace = window:active_workspace()

    if wezterm.GLOBAL.previous_workspace ~= current_workspace then
        wezterm.GLOBAL.previous_workspace = current_workspace
    end
end)

wezterm.on("copy-buffer-from-pane", function(window, pane)
    -- Copy the entire scrollback text
    local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
    window:copy_to_clipboard(text)

    -- Flash screen
    F.flash_screen(window, pane, config, colors)
end)

wezterm.on("copy-text-from-pane", function(window, pane)
    -- Copy the visable text on pane
    local text = pane:get_lines_as_text(pane:get_dimensions().viewport_rows)
    window:copy_to_clipboard(text)

    -- Flash screen
    F.flash_screen(window, pane, config, colors)
end)

wezterm.on("flash-terminal", function(window, pane)
    -- Flash screen
    F.flash_screen(window, pane, config, colors)
end)

wezterm.on("window-focus-changed", function(window, pane)
    -- Change window's brightness and saturation to active window
    local overrides = window:get_config_overrides() or {}

    if window:is_focused() then
        overrides.foreground_text_hsb = config.foreground_text_hsb
        overrides.inactive_pane_hsb = config.inactive_pane_hsb
    else
        overrides.foreground_text_hsb = config.inactive_pane_hsb
        overrides.inactive_pane_hsb = config.foreground_text_hsb
    end

    window:set_config_overrides(overrides)
end)

-- Events when wezterm is started
-- wezterm.on("gui-startup", function()

--     -- Iterate projects
--     for _, project in pairs(W.workspaces.repositories) do

--       -- Create personal's projects
--       if project.type == "personal" then
--         local _, _, window = mux.spawn_window { workspace = project.workspace, cwd = project.path }
--         window:active_tab():set_title(project.name)
--         wezterm.log_info("Creating workspace: " .. project.workspace )
--       end

--       -- Create work's projects
--       if project.type == "work" and custom.hostname.current == custom.hostname.work then

--         -- Create workspace and tab
--         if project.tabs then

--           local _, _, window = mux.spawn_window { workspace = project.workspace, cwd = project.path .. "/" .. project.tabs[1]  }
--           window:active_tab():set_title(project.name)
--           wezterm.log_info("Creating workspace: " .. project.workspace )

--           for tab = 2, #project.tabs do
--             window:spawn_tab { cwd = project.path .. "/" .. project.tabs[tab] }
--             wezterm.log_info("Creating tab " .. project.tabs[tab] .. " on workspace " .. project.workspace )
--           end

--         else

--           -- Create workspace
--           local _, _, window = mux.spawn_window { workspace = project.workspace, cwd = project.path }
--           window:active_tab():set_title(project.name)
--           wezterm.log_info("Creating workspace: " .. project.workspace )

--         end

--       end

--     end

--     -- Default workspace
--     mux.set_active_workspace(W.workspaces.default_workspace)
--     wezterm.log_info("Setting default workspace: " .. W.workspaces.default_workspace )

-- end)

return config
