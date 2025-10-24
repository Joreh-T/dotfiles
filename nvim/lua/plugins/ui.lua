-- if true then return {} end
local utils = require("config.utils")

local screen_width = vim.o.columns
local center_indent = math.floor((screen_width - 78) / 2) -- Try to center the snacks header as much as possible

return {
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufRead",
        config = function()
            vim.g.rainbow_delimiters = {
                -- strategy = {
                --   [""] = rainbow_delimiters.strategy["global"],
                --   vim = rainbow_delimiters.strategy["local"],
                -- },
                -- query = {
                --   [""] = "rainbow-delimiters",
                --   lua = "rainbow-blocks",
                -- },
                -- priority = {
                --   [""] = 110,
                --   lua = 210,
                -- },
                highlight = {
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },

    { "MunifTanjim/nui.nvim", lazy = true },

    {
        "folke/snacks.nvim",
        opts = {
            scroll = {
                -- use the default settings
            },
            image = {
                -- use the default settings
            },
            input = {
                -- use the default settings
            },
            dashboard = {
                preset = {
                    --           header = [[
                    -- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
                    -- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
                    -- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
                    -- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
                    -- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
                    -- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],

                    header = [[
                                                                         
           ████ ██████           █████      ██                     
          ███████████             █████                             
          █████████ ███████████████████ ███   ███████████   
         █████████  ███    █████████████ █████ ██████████████   
        █████████ ██████████ █████████ █████ █████ ████ █████   
      ███████████ ███    ███ █████████ █████ █████ ████ █████  
     ██████  █████████████████████ ████ █████ █████ ████ ██████ 
          ]],
                    keys = {
                        {
                            icon = " ",
                            key = "f",
                            desc = "Find File",
                            action = ":lua Snacks.dashboard.pick('files')",
                        },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        {
                            icon = " ",
                            key = "g",
                            desc = "Find Text",
                            action = ":lua Snacks.dashboard.pick('live_grep')",
                        },
                        {
                            icon = " ",
                            key = "r",
                            desc = "Recent Files",
                            action = ":lua Snacks.dashboard.pick('oldfiles')",
                        },
                        {
                            icon = " ",
                            key = "c",
                            desc = "Config",
                            action = function()
                                local config_dir = vim.fn.stdpath("config")
                                vim.cmd("cd " .. config_dir)
                                Snacks.dashboard.pick("files")
                            end,
                        },
                        -- { icon = " ", key = "s", desc = "Select Session", action = "<leader>qS" },
                        { icon = " ", key = "s", desc = "Select Session", action = ":lua require('persistence').select()" },
                        { icon = "󰛡 ", key = "p", desc = "Plugins", action = ":Lazy" },
                        -- { icon = " ", key = "x", desc = "Extras", action = ":LazyExtras" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
                sections = {
                    {
                        section = "header",
                        height = 8,
                        padding = 3, -- Spacing from below
                        indent = center_indent, -- Spacing from left
                    },
                    -- {
                    --   pane = 2,
                    --   section = "terminal",
                    --   enabled = function()
                    --     local width = vim.o.columns
                    --
                    --     return width >= 120
                    --   end,
                    --   cmd = "pokemon-colorscripts -n pikachu --no-title; sleep .2", -- 运行终端命令
                    --   random = 10,
                    --   padding = 0,
                    --   indent = 6,
                    --   height = 12,
                    -- },
                    {
                        pane = 2,
                        section = nil,
                        padding = 11,
                    },
                    { section = "keys", gap = 1, padding = 1 },
                    {
                        pane = 2,
                        icon = " ",
                        title = "Recent Files",
                        section = "recent_files",
                        indent = 2,
                        padding = 1,
                    },
                    { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                    -- {
                    --   pane = 2,
                    --   icon = " ",
                    --   title = "Git Status",
                    --   section = "terminal",
                    --   enabled = function()
                    --     return Snacks.git.get_root() ~= nil
                    --   end,
                    --   cmd = (function()
                    --     if vim.fn.executable("hub") == 1 then
                    --       return "hub status --short --branch --renames"
                    --     else
                    --       return "git status --short --branch --renames"
                    --     end
                    --   end)(),
                    --   height = 5,
                    --   padding = 1,
                    --   ttl = 5 * 60,
                    --   indent = 3,
                    -- },
                },
            },
            indent = {
                indent = {
                    priority = 1,
                    enabled = true, -- enable indent guides
                    char = "│",
                    only_scope = false, -- only show indent guides of the scope
                    only_current = false, -- only show indent guides in the current window
                    -- hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
                    -- can be a list of hl groups to cycle through
                    -- hl = {
                    --     "SnacksIndent1",
                    --     "SnacksIndent2",
                    --     "SnacksIndent3",
                    --     "SnacksIndent4",
                    --     "SnacksIndent5",
                    --     "SnacksIndent6",
                    --     "SnacksIndent7",
                    --     "SnacksIndent8",
                    -- },
                },
                scope = {
                    enabled = true, -- enable highlighting the current scope
                    priority = 200,
                    char = "│",
                    underline = false, -- underline the start of the scope
                    only_current = false, -- only show scope in the current window
                    hl = {
                        "RainbowDelimiterYellow",
                        "RainbowDelimiterOrange",
                        "RainbowDelimiterGreen",
                        "RainbowDelimiterBlue",
                        "RainbowDelimiterViolet",
                        "RainbowDelimiterCyan",
                    },
                },
            },
            styles = {
                split = {
                    position = "bottom",
                    height = math.floor(vim.o.lines * 0.21),
                    -- width = 0.4,
                },
            },
        },
    },

    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                -- diagnostics = false,
                diagnostics_indicator = function(_, _, _, _)
                    return ""
                end,
                indicator = {
                    icon = "▎", -- this should be omitted if indicator style is not 'icon'
                    style = "icon",
                },
                custom_filter = function(buf_number, _)
                    local bufname = vim.api.nvim_buf_get_name(buf_number)

                    -- 1. Filter out buffers with file type 'netrw'
                    if vim.bo[buf_number].filetype == "netrw" then
                        return false
                    end

                    -- 2. Filter out buffers with file types that start with 'netrw'
                    if bufname:match("^netrw%%") then
                        return false
                    end

                    -- 3. Filter out buffers representing directories
                    -- Condition: Buffer has a name AND the name points to a directory
                    if bufname ~= "" and vim.fn.isdirectory(bufname) == 1 then
                        return false
                    end

                    return true
                end,
                -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
                --     return "(" .. count .. ")"
                -- end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "🔍 File Explorer",
                        highlight = "Normal",
                        text_align = "center",
                    },
                    {
                        filetype = "snacks_layout_box",
                    },
                    {
                        filetype = "Outline",
                        text = "🎯 Outline",
                        highlight = "Normal",
                        text_align = "left",
                    },
                },
                max_name_length = 30,
                hover = {
                    enabled = false,
                    delay = 200,
                    reveal = { "close" },
                },
                -- separator_style = "slant",
            },

            highlights = {
                buffer_selected = {
                    bold = true,
                    italic = true,
                },
                diagnostic_selected = {
                    bold = false,
                    italic = true,
                },
                hint_selected = {
                    bold = false,
                    italic = true,
                },
                hint_diagnostic_selected = {
                    bold = false,
                    italic = false,
                },
                info_selected = {
                    bold = false,
                    italic = true,
                },
                info_diagnostic_selected = {
                    bold = false,
                    italic = false,
                },
                warning_selected = {
                    bold = false,
                    italic = true,
                },
                warning_diagnostic_selected = {
                    bold = false,
                    italic = false,
                },
                error_selected = {
                    bold = false,
                    italic = true,
                },
                error_diagnostic_selected = {
                    bold = false,
                    italic = false,
                },
                indicator_selected = {
                    fg = "#72cce8",
                },
            },
        },
    },

    {
        "Joreh-T/edgy.nvim",
        event = "VeryLazy",
        init = function()
            vim.opt.laststatus = 3
            vim.opt.splitkeep = "screen"
        end,
        opts = function(_, opts)
            -- Plugin load order check
            local edgy_idx = LazyVim.plugin.extra_idx("ui.edgy")
            local symbols_idx = LazyVim.plugin.extra_idx("editor.outline")
            if edgy_idx and edgy_idx > symbols_idx then
                LazyVim.warn(
                    "The `edgy.nvim` extra must be **imported** before the `outline.nvim` extra to work properly.",
                    { title = "LazyVim" }
                )
            end

            for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
                opts[pos] = opts[pos] or {}
                table.insert(opts[pos], {
                    ft = "snacks_terminal",
                    size = { height = 0.22, width = 0.35 },
                    -- title = "[%{b:snacks_terminal.id}] %{b:term_title} %{b:os.date("%H:%M")}",
                    title = function()
                        -- local term_title = vim.b.term_title or "Terminal"
                        -- local path = term_title:match("^.-:(.+)$") or term_title
                        -- term_title = term_title:match("[^/\\]+$") or term_title
                        -- term_title = #term_title > 20 and "… " .. term_title:sub(-20) or term_title
                        local open_time = vim.b.open_time or os.date("%H:%M")
                        return ("Terminal @%s"):format(open_time)
                    end,

                    filter = function(_buf, win)
                        return vim.w[win].snacks_win
                            and vim.w[win].snacks_win.position == pos
                            and vim.w[win].snacks_win.relative == "editor"
                            and not vim.w[win].trouble_preview
                    end,
                })
            end

            local base_opts = {
                options = {
                    left = { size = 25 },
                    -- bottom = { size = 20 }, -- It'll use the height of the terminal if not set.
                    right = { size = 25 },
                    top = { size = 10 },
                },
                animate = {
                    enabled = false,
                    fps = 60, -- frames per second
                    cps = 200, -- cells per second
                    -- on_begin = function()
                    --   vim.g.minianimate_disable = true
                    -- end,
                    -- on_end = function()
                    --   vim.g.minianimate_disable = false
                    -- end,
                    -- Spinner for pinned views that are loading.
                    -- if you have noice.nvim installed, you can use any spinner from it, like:
                    -- spinner = require("noice.util.spinners").spinners.circleFull,
                    -- spinner = {
                    --   frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                    --   interval = 80,
                    -- },
                },
                wo = {
                    winbar = true,
                    winhighlight = "WinBar:EdgyWinBarNC,WinBarNC:EdgyWinBarNC",
                },
                icons = {
                    closed = "󰪟",
                    open = "⦿",
                },
                keys = {
                    ["<c-Right>"] = function(win)
                        win:resize("width", 2)
                    end,
                    ["<c-Left>"] = function(win)
                        win:resize("width", -2)
                    end,
                    ["<c-Up>"] = function(win)
                        win:resize("height", 2)
                    end,
                    ["<c-Down>"] = function(win)
                        win:resize("height", -2)
                    end,
                },
            }

            local neo_tree_spec = {
                title = "File Explorer",
                ft = "neo-tree",
                wo = {
                    winbar = false,
                },
                size = { width = math.max(base_opts.options.left.size, math.floor(vim.o.columns * 0.19)) },
                filter = function(buf)
                    return vim.b[buf].neo_tree_source == "filesystem"
                end,
                pinned = false,
            }

            local outline_spec = {
                title = "Outline",
                ft = "Outline",
                wo = {
                    winbar = false,
                },
                size = {
                    width = math.max(base_opts.options.right.size, math.floor(vim.o.columns * 0.17)),
                    height = 0.45,
                },
                -- pinned = true,
                -- open = "Outline",
            }

            local left = {}
            local right = {}

            if LazyVim.has("neo-tree.nvim") then
                table.insert(left, neo_tree_spec)
            end

            if LazyVim.has("outline.nvim") then
                if utils.has_yazi() then
                    table.insert(left, outline_spec)
                else
                    table.insert(right, outline_spec)
                end
            end

            if vim.tbl_isempty(left) then
                left = nil
            end

            if vim.tbl_isempty(right) then
                right = nil
            end

            return vim.tbl_deep_extend("force", opts or {}, {
                options = base_opts.options,
                animate = base_opts.animate,
                wo = base_opts.wo,
                icons = base_opts.icons,
                keys = base_opts.keys,
                left = left,
                right = right,
            })
        end,
    },

    {
        -- Bottom Statusbar
        "nvim-lualine/lualine.nvim",
        optional = true,
        event = "VeryLazy",
        opts = function(_, opts)
            -- +-------------------------------------------------+
            -- | A | B | C                             X | Y | Z |
            -- +-------------------------------------------------+
            local icons = LazyVim.config.icons
            -- opts.options.component_separators =  { left = '|', right = '' }
            opts.options = {
                theme = "auto",
                globalstatus = vim.o.laststatus == 3,
                disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
                component_separators = {
                    -- left = "%#WinBarNC#%*",
                    -- right = "%#WinBarNC#%*",
                    left = "",
                    right = "",
                },
            }
            opts.sections.lualine_a = { "mode" }
            opts.sections.lualine_b = { "branch" }
            opts.sections.lualine_c = {
                LazyVim.lualine.root_dir(),
                {
                    "diagnostics",
                    symbols = {
                        error = icons.diagnostics.Error,
                        warn = icons.diagnostics.Warn,
                        info = icons.diagnostics.Info,
                        hint = icons.diagnostics.Hint,
                    },
                },
                { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                { LazyVim.lualine.pretty_path(), separator = "", padding = { left = 1, right = 0 } },
                {
                    function()
                        return vim.bo.modified and "●" or " "
                    end,
                    color = function()
                        -- return vim.bo.modified and { fg = "#e5c07b" } or { fg = "#98c379" }
                        local group = vim.bo.modified and "NeoTreeGitModified" or "Green"
                        local hl = vim.api.nvim_get_hl(0, { name = group })
                        return { fg = hl.fg and string.format("#%06x", hl.fg) or "#e5c07b" }
                    end,
                    padding = { left = 1, right = 1 },
                },

                -- {
                --     function() return vim.bo.modified and "[+]" or "[-]" end,
                --     color = { fg = "#ff9e64" },
                --     padding = { left = 0, right = 1 },
                -- },
            }
            opts.sections.lualine_x = {
                Snacks.profiler.status(),
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("StatusLineNC") } end,
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color("Constant") } end,
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            -- stylua: ignore
            -- {
            --   require("lazy.status").updates,
            --   cond = require("lazy.status").has_updates,
            --   color = function() return { fg = Snacks.util.color("Special") } end,
            -- },
            {
                "diff",
                symbols = {
                    added = icons.git.added,
                    modified = icons.git.modified,
                    removed = icons.git.removed,
                },
                source = function()
                    local gitsigns = vim.b.gitsigns_status_dict
                    if gitsigns then
                        return {
                            added = gitsigns.added,
                            modified = gitsigns.changed,
                            removed = gitsigns.removed,
                        }
                    end
                end,
            },
            }
            opts.sections.lualine_y = {
                {
                    -- function()
                    --     local encoding = vim.opt.fileencoding:get()
                    --     if encoding and encoding ~= "" then
                    --         return encoding:upper()
                    --     else
                    --         return "Unknown" -- fallback
                    --     end
                    -- end,
                    "encoding",
                    -- icon = "",
                    color = { fg = "#98c379" },
                    padding = { left = 1, right = 0 },
                },
                { "progress", separator = " ", padding = { left = 1, right = 0 } },
                { "location", padding = { left = 0, right = 1 } },
            }
            opts.sections.lualine_z = {}

            if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
                local trouble = require("trouble")
                local symbols = trouble.statusline({
                    mode = "symbols",
                    groups = {},
                    title = false,
                    filter = { range = true },
                    format = "{kind_icon}{symbol.name:Normal}",
                    hl_group = "lualine_c_normal",
                })

                local get_clean = function()
                    if not symbols or not symbols.has() then
                        return ""
                    end
                    local raw = symbols.get()
                    return string.gsub(raw, "%s*$", "") -- Delete trailing spaces
                end

                table.insert(opts.sections.lualine_c, {
                    get_clean, -- Replace the default symbols.get
                    cond = function()
                        return vim.b.trouble_lualine ~= false and symbols.has()
                    end,
                })
            end
        end,
    },

    {
        "Joreh-T/placeholder_highlighter.nvim",
        event = "VeryLazy",

        opts = {
            -- highlight = { link = "SpecialChar" },
            -- highlight = { fg = "#F6D5A4", bold = true,},

            filetypes = {
                "c",
                "cpp",
                "python",
                "lua",
                "go",
                "rust",
                "typescript",
            },

            debounce = 150, -- ms
        },
    },
}
