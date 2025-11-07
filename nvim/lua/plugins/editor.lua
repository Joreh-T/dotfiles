local utils = require("config.utils")
local leet_arg = "leetcode"

local outline_refresh_blacklist_exact = {
    "neo-tree",
    "lazygit",
    "snacks_notif",
    "grug-far",
}
local outline_refresh_blacklist_pattern = {
    "Avante",
    "help",
    "terminal",
    "git",
    "fzf",
    "yazi",
    "bookmark",
    "dashboard",
}

return {
    -- Auto switch input method depends on Nvim's edit mode.
    {
        "keaising/im-select.nvim",
        event = "VeryLazy",
        config = function()
            require("im_select").setup({})
        end,
    },

    {
        -- Search and replace keywords
        "MagicDuck/grug-far.nvim",
        -- version = utils.is_nvim_le(0, 10, 4) and "v1.6.3" or nil,

        -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
        -- additional lazy config to defer loading is not really needed...
        config = function()
            -- optional setup call to override plugin options
            -- alternatively you can set options with vim.g.grug_far = { ... }
            local width = utils.get_global_col_scaled(0.35)
            require("grug-far").setup({
                windowCreationCommand = string.format("%d vsplit", width),
            })
        end,
    },

    {
        -- Fuzzy finder which is used by fzf-lua
        "junegunn/fzf",
        build = function()
            if vim.fn.executable("fzf") == 0 then
                return "./install --bin"
            else
                return nil -- Don't inastall if fzf is already installed
            end
        end,
    },

    {
        -- Fuzzy finder for nvim. Replaced telescope.nvim
        "ibhagwan/fzf-lua",
        -- event = "VeryLazy",
        keys = {
            { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
            -- { "<leader>/", LazyVim.pick("grep_project"), desc = "Fuzzy search (project)" },
            { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
            { "<leader>sf", LazyVim.pick("grep_project", { root = false }), desc = "Fuzzy search (project)" },
            { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
            { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
            { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
            { "<leader>fR", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
            { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
            { "<leader><leader>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
        },
        opts = function(_, opts)
            local fzf = require("fzf-lua")
            local config = fzf.config
            local actions = fzf.actions

            config.defaults.keymap.fzf["alt-j"] = "preview-down"
            config.defaults.keymap.fzf["alt-k"] = "preview-up"
            config.defaults.keymap.builtin["<a-j>"] = "preview-down"
            config.defaults.keymap.builtin["<a-k>"] = "preview-up"

            local hl = vim.api.nvim_get_hl(0, { name = "FzfLuaCursorLine", link = false })
            local underline = vim.api.nvim_get_hl(0, { name = "FzfLuaHeaderBind", link = false })

            local new_hl = {
                fg = hl.fg,
                bg = hl.bg,
                bold = true,
                italic = hl.italic,
                special = underline.fg,
                -- underline = true,
                underdashed = true,
                -- undercurl = true,
            }
            hl.underline = true
            vim.api.nvim_set_hl(0, "CustomFzfCursorline", new_hl)

            return {
                "default-title",
                fzf_colors = {
                    true, -- inherit fzf colors that aren't specified below from
                    -- the auto-generated theme similar to `fzf_colors=true`
                    ["fg"] = { "fg", "CursorLine" },
                    ["bg"] = { "bg", "Normal" },
                    ["hl"] = { "fg", "Comment" },
                    ["fg+"] = { "fg", "CursorLine" },
                    ["bg+"] = { "bg", { "CursorLine", "Normal" } },
                    ["hl+"] = { "fg", "Green" },
                    ["info"] = { "fg", "PreProc" },
                    ["prompt"] = { "fg", "Conditional" },
                    ["pointer"] = { "fg", "Exception" },
                    ["marker"] = { "fg", "Keyword" },
                    ["spinner"] = { "fg", "Label" },
                    ["header"] = { "fg", "Comment" },
                    ["gutter"] = "-1",
                },
                hls = {
                    cursorline = "CustomFzfCursorline",
                },
                fzf_opts = {
                    ["--no-scrollbar"] = false,
                },
                defaults = {
                    formatter = "path.dirname_first",
                },
                winopts = {
                    width = 0.8,
                    height = 0.85,
                    row = 0.5,
                    col = 0.5,
                    preview = {
                        layout = "vertical", -- horizontal or vertical
                        vertical = "down:55%",
                        scrollchars = { "┃", "" },
                    },
                    on_create = function()
                        -- <C-\><C-n>: Switch from terminal mode to normal mode;
                        -- "+p: Paste from the system clipboard (+ register);
                        -- i: Return to insert mode (fzf is interactive input);
                        -- buffer = true: Only effective for fzf's temporary buffer, does not affect global settings;
                        -- silent = true: Avoid command-line prompts;
                        -- noremap = true: Avoid recursive mappings
                        --
                        -- '+' register
                        -- vim.keymap.set("t", "<C-v>", [[<C-\><C-n>"+pi]], { noremap = true, silent = true, buffer = true })
                        -- '*' register
                        -- vim.keymap.set("t", "<C-v>", [[<C-\><C-n>"*pi]], { noremap = true, silent = true, buffer = true })
                    end,
                },
                files = {
                    winopts = { title = " Files " },
                    cwd_prompt = true,
                    actions = {
                        ["alt-i"] = { actions.toggle_ignore },
                        ["alt-h"] = { actions.toggle_hidden },
                    },
                },
                grep_project = {
                    winopts = { title = " Fuzzy Search " },
                },
                live_grep = {
                    winopts = { title = " Live Grep " },
                },
                oldfiles = {
                    winopts = { title = " Recent Files " },
                },
                buffers = {
                    winopts = { title = " Buffers " },
                },
                grep = {
                    cwd_prompt = true,
                    cwd_prompt_shorten_len = 32,
                    cwd_prompt_shorten_val = 1,
                    winopts = { title = " Grep " },
                    actions = {
                        ["alt-i"] = { actions.toggle_ignore },
                        ["alt-h"] = { actions.toggle_hidden },
                    },
                },
                -- previewers = {},
                ui_select = function(fzf_opts, items)
                    return vim.tbl_deep_extend("force", fzf_opts, {
                        prompt = " ",
                        winopts = {
                            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                            title_pos = "center",
                        },
                    }, fzf_opts.kind == "codeaction" and {
                        winopts = {
                            layout = "vertical",
                            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
                            width = 0.5,
                            preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                                layout = "vertical",
                                vertical = "down:15,border-top",
                                hidden = "hidden",
                            } or {
                                layout = "vertical",
                                vertical = "down:15,border-top",
                            },
                        },
                    } or {
                        winopts = {
                            width = 0.5,
                            -- height is number of items, with a max of 80% screen height
                            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
                        },
                    })
                end,
                lsp = {},
            }
        end,
    },
    -- {
    --   -- Cursor Animation
    --   "sphamba/smear-cursor.nvim",
    --   opts = {
    --     -- cursor_color = "#ff8800",
    --     stiffness = 0.5,
    --     trailing_stiffness = 0.4,
    --     -- trailing_exponent = 1,
    --     -- distance_stop_animating = 0.5,
    --     -- gamma = 1,
    --     --  -- Smear cursor when switching buffers or windows.
    --     smear_between_buffers = true,
    --
    --     -- Smear cursor when moving within line or to neighbor lines.
    --     smear_between_neighbor_lines = false,
    --
    --     -- Draw the smear in buffer space instead of screen space when scrolling
    --     scroll_buffer_space = true,
    --
    --     -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
    --     -- Smears will blend better on all backgrounds.
    --     legacy_computing_symbols_support = false,
    --   },
    -- },
    {
        -- Multiple cursors support
        "brenton-leighton/multiple-cursors.nvim",
        version = "*", -- Use the latest tagged version
        opts = {}, -- This causes the plugin setup function to be called
        keys = {
            -- { "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Add cursor and move down" },
            -- { "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Add cursor and move up" },

            { "<A-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "i", "x" }, desc = "Add cursor and move up" },
            {
                "<A-Down>",
                "<Cmd>MultipleCursorsAddDown<CR>",
                mode = { "n", "i", "x" },
                desc = "Add cursor and move down",
            },

            {
                "<A-LeftMouse>",
                "<Cmd>MultipleCursorsMouseAddDelete<CR>",
                mode = { "n", "i" },
                desc = "Add or remove cursor",
            },
            { "<Leader>a", false },
            { "<Leader>A", false },

            -- {
            --   "<Leader>a",
            --   "<Cmd>MultipleCursorsAddMatches<CR>",
            --   mode = { "n", "x" },
            --   desc = "Add cursors to all the cword",
            -- },
            -- {
            --   "<Leader>A",
            --   "<Cmd>MultipleCursorsAddMatchesV<CR>",
            --   mode = { "n", "x" },
            --   desc = "Add cursors to cword in previous area",
            -- },

            {
                "<A-j>",
                "<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
                mode = { "n", "x" },
                desc = "Add cursor and jump to next cword",
            },
            -- { "<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = { "n", "x" }, desc = "Jump to next cword" },

            -- { "<Leader>l", "<Cmd>MultipleCursorsLock<CR>", mode = { "n", "x" }, desc = "Lock virtual cursors" },
        },
    },

    {
        -- Replaces the UI for messages, cmdline and the popupmenu.
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            opts.messages = {
                view_search = false, -- disable  virtual text when use "/" or "?"
            }
            local cmdline_pos = {
                row = utils.get_global_row_scaled(0.2),
                col = "50%",
            }
            opts.views = {
                -- position of cmdline
                cmdline_popup = {
                    position = {
                        row = cmdline_pos.row,
                        col = cmdline_pos.col,
                    },
                    size = {
                        width = 60,
                        height = "auto",
                    },
                },
                -- position of cmdline's completion
                cmdline_popupmenu = {
                    position = {
                        row = cmdline_pos.row + 3,
                    },
                },
                confirm = {
                    backend = "popup",
                    position = {
                        row = cmdline_pos.row,
                        -- col = "50%",
                    },
                },
            }
        end,
    },

    {
        -- Display hexadecimal colors in the editor
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },
    -- {
    --     "lewis6991/hover.nvim",
    --     pin = true,
    --     config = function()
    --         require("hover").setup({
    --             init = function()
    --                 -- Require providers
    --                 require("hover.providers.lsp")
    --                 -- require('hover.providers.gh')
    --                 -- require('hover.providers.gh_user')
    --                 -- require('hover.providers.jira')
    --                 -- require('hover.providers.dap')
    --                 -- require('hover.providers.fold_preview')
    --                 require("hover.providers.diagnostic")
    --                 -- require('hover.providers.man')
    --                 -- require('hover.providers.dictionary')
    --             end,
    --             preview_opts = {
    --                 border = "none",
    --             },
    --             -- Whether the contents of a currently open hover window should be moved
    --             -- to a :h preview-window when pressing the hover keymap.
    --             preview_window = false,
    --             title = false,
    --             mouse_providers = {
    --                 "LSP",
    --             },
    --             mouse_delay = 1000,
    --         })
    --
    --         -- Setup keymaps
    --         -- vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
    --         -- vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
    --         -- vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
    --         -- vim.keymap.set("n", "<C-n>", function() require("hover").hover_switch("next") end, {desc = "hover.nvim (next source)"})
    --         --
    --         -- Mouse support
    --         vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
    --         vim.o.mousemoveevent = true
    --     end,
    -- },

    {
        -- Save and restore sessions
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {
            dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
            -- minimum number of file buffers that need to be open to save
            -- Set to 0 to always save
            need = 1,
            branch = true, -- use git branch to save session
        },
        keys = {
            {
                "<leader>qs",
                function()
                    require("persistence").load()
                end,
                desc = "Restore Session",
            },
            {
                "<leader>qS",
                function()
                    require("persistence").select()
                end,
                desc = "Select Session",
            },
            {
                "<leader>ql",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Restore Last Session",
            },
            {
                "<leader>qd",
                function()
                    require("persistence").stop()
                end,
                desc = "Don't Save Current Session",
            },
        },
    },
    {
        "Joreh-T/caseConverter.nvim",
        event = "VeryLazy",
        -- config = function()
        --     require("case_converter").setup({
        --         -- Optional configuration
        --     })
        -- end,
        -- defualt keymaps:
        --  `<Leader>tt` - Convert between snake_case and camelCase/PascalCase
        --  `<Leader>tc` - Cycle through cases: snake_case → camelCase → PascalCase → snake_case
        --  `<Leader>ts` - Convert to snake_case
        --  `<Leader>tm` - Convert to camelCase
        --  `<Leader>tp` - Convert to PascalCase
    },

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = true, -- show icons in the signs column
            sign_priority = 8, -- sign priority
            keywords = {
                FIX = {
                    icon = " ", -- icon used for the sign, and in search results
                    color = "error", -- can be a hex color, or a named color (see below)
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "FIX_N" }, -- a set of other keywords that all map to this FIX keywords
                },
                -- TODO = { icon = " ", color = "info", alt = { "TODO_N", "TODO" } },
                -- HACK = { icon = " ", color = "warning" },
                -- WARN = { icon = " ", color = "warning", alt = { "WARNING", "WARN_N", "WARN" } },
                -- PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                -- NOTE = { icon = " ", color = "hint", alt = { "INFO", "INFO_N", "HINT_N", "HINT" } },
                TODO = { icon = "🧩", color = "info", alt = { "TODO_N", "TODO" } },
                HACK = { icon = "🧪", color = "warning" },
                WARN = { icon = "🧯", color = "warning", alt = { "WARNING", "WARN_N", "WARN" } },
                PERF = { icon = "🚩", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "💡", color = "hint", alt = { "INFO", "INFO_N", "HINT_N", "HINT" } },
                -- TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED", "TEST_Q" } },
            },
            gui_style = {
                fg = "NONE", -- The gui style to use for the fg highlight group.
                bg = "BOLD", -- The gui style to use for the bg highlight group.
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            highlight = {
                multiline = true, -- enable multiline todo comments
                multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
                multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
                before = "", -- "fg" or "bg" or empty
                keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty
                after = "fg", -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
                comments_only = true, -- uses treesitter to match keywords in comments only
                max_line_len = 400, -- ignore lines longer than this
                exclude = {}, -- list of file types to exclude highlighting
            },
            -- colors = {
            --   error = { "Red" },
            --   warning = { "Yellow" },
            --   info = { "Orange" },
            --   hint = { "Green" },
            --   default = { "Purple" },
            --   test = { "Blue" }
            -- },
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                pattern = [[\b(KEYWORDS)_N\b]], -- ripgrep regex
            },
        },
    },

    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                {
                    mode = { "n" },
                    { "<leader>o", desc = "Toggle Outline", icon = { icon = "", color = "yellow" } },
                },

                {
                    mode = { "v" },
                    { "<leader>t", group = "Text case switch", icon = { icon = "" } },
                },

                {
                    mode = { "n", "v" },
                    { "<leader>p", group = "File path", icon = { icon = "󰴠", color = "cyan" } },
                    {
                        "<leader>pn",
                        ':let @+ = expand("%:t")<CR>',
                        mode = "n",
                        desc = "Copy filename",
                    },
                    {
                        "<leader>pc",
                        ':let @+ = fnamemodify(expand("%:p"), ":." )<CR>',
                        mode = "n",
                        desc = "Copy relative path",
                    },
                    {
                        "<leader>pC",
                        ':let @+ = expand("%:p")<CR>',
                        mode = "n",
                        desc = "Copy absolute path",
                    },
                    {
                        "<leader>ps",
                        ':echo fnamemodify(expand("%:p"), ":." )<CR>',
                        mode = "n",
                        desc = "Show relative path",
                    },
                    {
                        "<leader>pS",
                        ':echo expand("%:p")<CR>',
                        mode = "n",
                        desc = "Show absolute path",
                    },
                },
                { "<leader>m", group = "Bookmarks", icon = { icon = "", color = "yellow" } },
                { "<leader>i", group = "Get Icons", icon = { icon = "", color = "green" } },
                { "<leader>K", group = "Keyword Manual", icon = { icon = "󰷈", color = "" } },
                { "<leader>r", group = "Restart LSP", icon = { icon = "", color = "red" } },
                { "<leader>a", group = "Avante", icon = { icon = "󰆾", color = "yellow" } },
                { "<leader>t", group = "Task Runner", icon = { icon = "", color = "yellow" } },
            },
        },
    },

    {
        "petertriho/nvim-scrollbar",
        event = "VeryLazy",
        dependencies = {
            "kevinhwang91/nvim-hlslens",
            {
                "lewis6991/gitsigns.nvim",
            },
        },
        config = function()
            require("scrollbar").setup({})
            require("gitsigns").setup({})
            require("scrollbar.handlers.gitsigns").setup()
            require("scrollbar.handlers.search").setup({
                override_lens = function(render, posList, nearest, idx, relIdx)
                    local sfw = vim.v.searchforward == 1
                    local indicator, text, chunks
                    -- disable indicator
                    indicator = ""
                    -- enable indicator
                    -- local absRelIdx = math.abs(relIdx)
                    -- if absRelIdx > 1 then
                    --     indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "▲" or "▼")
                    -- elseif absRelIdx == 1 then
                    --     indicator = sfw ~= (relIdx == 1) and "▲" or "▼"
                    -- else
                    --     indicator = ""
                    -- end

                    local lnum, col = unpack(posList[idx])
                    local cnt = #posList
                    if nearest then
                        if indicator ~= "" then
                            -- text = ("[%s %d/%d]"):format(indicator, idx, cnt)
                            text = ("[%d/%d]"):format(idx, cnt)
                        else
                            text = ("[ %d/%d]"):format(idx, cnt)
                        end
                        chunks = { { " " }, { text, "HlSearchLensNear" } }
                    else
                        -- text = ("[%d %s]"):format(idx, indicator)
                        text = ("[%d/%d]"):format(idx, cnt)
                        chunks = { { " " }, { text, "HlSearchLens" } }
                    end
                    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
                end,
            })
        end,
    },

    {
        "Joreh-T/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = {
            { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {
            keymaps = {
                up_and_jump = "<up>",
                down_and_jump = "<down>",
            },
            outline_items = {
                show_symbol_details = false,
                update_on_buf_enter_blacklist_exact = outline_refresh_blacklist_exact,
                update_on_buf_enter_blacklist_pattern = outline_refresh_blacklist_pattern,
            },
            outline_window = {
                position = utils.has_yazi() and "left" or "right",
                split_command = nil,
                width = 18,
                -- relative_width = true,
                wrap = false,
                focus_on_open = true,
                auto_close = false,
                auto_jump = false,
                show_numbers = false,
                show_relative_numbers = false,
                ---@type boolean|string?
                show_cursorline = true,
                hide_cursor = false,
                winhl = "Normal:OutlineBackground",
                jump_highlight_duration = 400,
                center_on_jump = true,
            },
            preview_window = {
                auto_preview = false,
                auto_preview_delay = 1000,
                -- Border option for floating preview window.
                -- Options include: single/double/rounded/solid/shadow or an array of border
                -- characters.
                -- See :help nvim_open_win() and search for "border" option.
                border = "rounded",
                -- Experimental feature that let's you edit the source content live
                -- in the preview window. Like VS Code's "peek editor".
                live = true,
            },
            symbols = {
                ---@type outline.FilterConfig?
                filter = nil,
                icon_source = nil,
                icon_fetcher = nil,
                icons = {
                    File = { icon = "󰈔", hl = "Identifier" },
                    Module = { icon = "󰆧", hl = "Include" },
                    Namespace = { icon = "󰦮", hl = "Include" },
                    Package = { icon = "󰏗", hl = "Include" },
                    Class = { icon = "", hl = "Type" },
                    Method = { icon = "", hl = "Function" },
                    Property = { icon = "", hl = "Identifier" },
                    Field = { icon = "󰆨", hl = "Identifier" },
                    Constructor = { icon = "", hl = "Special" },
                    Enum = { icon = "ℰ", hl = "Type" },
                    Interface = { icon = "󰜰", hl = "Type" },
                    Function = { icon = "ƒ", hl = "Function" },
                    Variable = { icon = "󰀫", hl = "Constant" },
                    Constant = { icon = "", hl = "Constant" },
                    String = { icon = "󱄽", hl = "String" },
                    Number = { icon = "#", hl = "Number" },
                    Boolean = { icon = "󰨙", hl = "Boolean" },
                    Array = { icon = "󰅪", hl = "Constant" },
                    Object = { icon = "", hl = "Type" },
                    Key = { icon = "󰌋", hl = "Type" },
                    Null = { icon = "󰟢", hl = "Type" },
                    EnumMember = { icon = "", hl = "Identifier" },
                    Struct = { icon = "", hl = "Structure" },
                    Event = { icon = "🗲", hl = "Type" },
                    Operator = { icon = "+", hl = "Identifier" },
                    TypeParameter = { icon = "𝙏", hl = "Identifier" },
                    Component = { icon = "󰅴", hl = "Function" },
                    Fragment = { icon = "󰅴", hl = "Constant" },
                    -- ccls
                    TypeAlias = { icon = " ", hl = "Type" },
                    Parameter = { icon = " ", hl = "Identifier" },
                    StaticMethod = { icon = " ", hl = "Function" },
                    Macro = { icon = " ", hl = "Function" },
                },
            },
        },

        init = function()
            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = vim.api.nvim_create_augroup("Outline_start", { clear = true }),
                desc = "Auto open Outline",
                callback = function(args)
                    -- vim.schedule(function()
                    vim.api.nvim_set_hl(0, "OutlineBackground", { fg = "#cfcfcf", bg = "#24272e" })

                    local bufnr = args.buf
                    local stats = vim.uv.fs_stat(vim.fn.argv(0))
                    if stats and stats.type == "directory" and "" == vim.bo[bufnr].filetype then
                        return
                    end

                    -- if in cmd mode
                    if vim.api.nvim_get_mode().mode:sub(1, 1) == "c" then
                        return
                    end

                    if not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    local buftype = vim.bo[bufnr].buftype
                    if not (buftype == "" or buftype == "acwrite" or buftype == "nofile") then
                        return
                    end

                    if vim.bo[bufnr].swapfile == false then
                        return
                    end

                    if vim.api.nvim_buf_get_name(bufnr) == "" then
                        return
                    end

                    if utils.has_target_ft_window(outline_refresh_blacklist_exact) then
                        return
                    end

                    if utils.has_target_ft_window(outline_refresh_blacklist_pattern, true) then
                        return
                    end

                    if utils.has_target_ft_window({ "Outline", "welcome" }) then
                        vim.api.nvim_del_autocmd(args.id)
                        return
                    end

                    vim.cmd("Outline")
                    vim.api.nvim_del_autocmd(args.id)
                    vim.defer_fn(function()
                        utils.focus_largest_window()
                    end, 50)
                    -- end)
                end,
            })
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        cond = not utils.has_yazi(),
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- optional, but recommended
        },
        keys = {
            { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
            { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
        },
        opts = function(_, opts)
            -- vim.diagnostic.config({
            --   signs = {
            --     text = {
            --       [vim.diagnostic.severity.ERROR] = '',
            --       [vim.diagnostic.severity.WARN] = '',
            --       [vim.diagnostic.severity.INFO] = '',
            --       [vim.diagnostic.severity.HINT] = '󰌵',
            --     },
            --   }
            -- })
            opts.default_component_configs.diagnostics = {
                enabled = false,
            }
            opts.hide_root_node = false
            opts.source_selector = {
                winbar = true,
                statusline = false,
                show_scrolled_off_parent_node = true,
                sources = {
                    { source = "filesystem" },
                    { source = "buffers" },
                    { source = "git_status" },
                },
                padding = 0,
                -- separator_active = "|",
                separator = { left = "|", right = "|", override = "left" },
                -- separator = { left = "/", right = "\\", override = "left" },  -- |/  a  /  b  /  c  /...
                -- separator = { left = "/", right = "\\", override = "active" },-- |/  a  / b:active \  c  \...
                show_separator_on_edge = false,
            }
            opts.symlink_target = {
                enabled = true,
                text_format = " 󱦰 %s", -- %s will be replaced with the symlink target's path.
            }

            opts.open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy", "Outline", "snacks_terminal" } -- when opening files, do not use windows containing these filetypes or buftypes
            opts.window = opts.window or {}
            opts.window = {
                position = "left",
                width = function()
                    local total_width = vim.o.columns
                    return math.max(33, math.floor(total_width * 0.20))
                end,
                mappings = {
                    ["Y"] = function(state)
                        -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
                        -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local filename = node.name
                        local modify = vim.fn.fnamemodify

                        local results = {
                            filepath,
                            modify(filepath, ":."),
                            modify(filepath, ":~"),
                            filename,
                            modify(filename, ":r"),
                            modify(filename, ":e"),
                        }

                        vim.ui.select({
                            "1. Absolute path: " .. results[1],
                            "2. Path relative to CWD: " .. results[2],
                            "3. Path relative to HOME: " .. results[3],
                            "4. Filename: " .. results[4],
                            "5. Filename without extension: " .. results[5],
                            "6. Extension of the filename: " .. results[6],
                        }, { prompt = "Choose to copy to clipboard:" }, function(choice)
                            local i = tonumber(choice:sub(1, 1))
                            local result = results[i]
                            vim.fn.setreg("+", result) -- copy to system clipboard "+"
                            vim.notify("Copied: " .. result)
                        end)
                    end,
                },
            }
            -- opts.window.width = function()
            --     local total_width = vim.o.columns
            --     return math.max(33, math.floor(total_width * 0.20))
            -- end
            opts.window.title = ""

            opts.filesystem = {
                use_libuv_file_watcher = true,
                follow_current_file = {
                    enabled = true, -- This will find and focus the file in the active buffer every time
                    --               -- the current file is changed while the tree is open.
                    leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                },
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = true,
                },
                always_show = { -- remains visible even if other settings would normally hide it
                    ".gitignored",
                },
            }
            opts.buffers = {
                follow_current_file = {
                    enabled = true, -- This will find and focus the file in the active buffer every time
                    --              -- the current file is changed while the tree is open.
                    leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                },
            }
            -- opts.filesystem.window = { title = "" }
            opts.default_component_configs = opts.default_component_configs or {}
            opts.default_component_configs.icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰉖",
                folder_empty_open = "󰷏",
                provider = function(icon, node, state)
                    if node.type == "file" or node.type == "terminal" then
                        local success, web_devicons = pcall(require, "nvim-web-devicons")
                        local name = node.type == "terminal" and "terminal" or node.name
                        if success then
                            local devicon, hl = web_devicons.get_icon(name)
                            icon.text = devicon or icon.text
                            icon.highlight = hl or icon.highlight
                        end
                    end
                end,
            }
            opts.default_component_configs.modified = {
                symbol = "● ",
                highlight = "NeoTreeGitModified",
            }
            opts.default_component_configs.git_status = {
                symbols = {
                    added = "",
                    modified = "",
                    deleted = "󰗨",
                    renamed = "󰁕",
                    untracked = "",
                    ignored = "",
                    unstaged = "",
                    staged = "",
                    conflict = "",
                },
            }
            return opts
        end,
    },

    {
        "mikavilpas/yazi.nvim",
        cond = utils.has_yazi(),
        version = "*", -- use the latest stable version
        event = "VeryLazy",
        dependencies = {
            { "nvim-lua/plenary.nvim", lazy = true },
        },
        keys = {
            {
                "<leader>e",
                mode = { "n", "v" },
                "<cmd>Yazi<cr>",
                desc = "File Explorer Current File",
            },
            {
                -- Open in the current working directory
                "<leader>E",
                "<cmd>Yazi cwd<cr>",
                desc = "File Explorer CWD",
            },
            -- {
            --     "<c-up>",
            --     "<cmd>Yazi toggle<cr>",
            --     desc = "Resume the last yazi session",
            -- },
        },
        opts = {
            open_for_directories = true, -- open yazi when opening a directory
            keymaps = {
                show_help = "<f1>",
            },
            integrations = {
                grep_in_selected_files = "fzf-lua", -- or "telescope"
                grep_in_directory = "fzf-lua", -- or "telescope"
            },
        },
        init = function()
            -- 👇 if you use `open_for_directories=true`, this is recommended
            -- mark netrw as loaded so it's not loaded at all.
            -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
            vim.g.loaded_netrwPlugin = 1
        end,
    },

    {
        "Joreh-T/bookmarks.nvim",
        event = "BufRead",
        branch = "main",
        dependencies = { "kyazdani42/nvim-web-devicons", "nvim-telescope/telescope.nvim" },
        config = function()
            local mark_icon = ""
            if vim.g.neovide then
                mark_icon = "󰍎"
            else
                mark_icon = "⭐"
            end

            require("bookmarks").setup({
                vim.api.nvim_set_hl(0, "bookmarks_virt_text_hl", { fg = "#879FA7", bg = "#354157" }),

                -- default keymap
                keymap = {
                    toggle = "<leader>mt", -- Toggle bookmarks(global keymap)
                    close = "q", -- close bookmarks (buf keymap)
                    add = "<leader>ma", -- Add bookmarks(global keymap)
                    add_global = "<leader>mA", -- Add global bookmarks(global keymap), global bookmarks will appear in all projects. Identified with the symbol '󰯾'
                    jump = "<CR>", -- Jump from bookmarks(buf keymap)
                    delete = "dd", -- Delete bookmarks(buf keymap)
                    order = "<space><space>", -- Order bookmarks by frequency or updated_time(buf keymap)
                    delete_on_virt = "<leader>md", -- Delete bookmark at virt text line(global keymap)
                    show_desc = "<leader>ms", -- show bookmark desc(global keymap)
                    focus_tags = "<c-j>", -- focus tags window
                    focus_bookmarks = "<c-k>", -- focus bookmarks window
                    toogle_focus = "<S-Tab>", -- toggle window focus (tags-window <-> bookmarks-window)
                },
                width = 0.8, -- Bookmarks window width:  (0, 1]
                height = 0.7, -- Bookmarks window height: (0, 1]
                preview_ratio = 0.42, -- Bookmarks preview window ratio (0, 1]
                tags_ratio = 0.07, -- Bookmarks tags window ratio
                fix_enable = false, -- If true, when saving the current file, if the bookmark line number of the current file changes, try to fix it.

                virt_text = "🌟",

                sign_icon = mark_icon, -- if it is not empty, show icon in signColumn.

                virt_pattern = {
                    "*.go",
                    "*.lua",
                    "*.sh",
                    "*.php",
                    "*.rs",
                    "*.c",
                    "*.cpp",
                    "*.h",
                    "*.hpp",
                    "*.py",
                    "*.xml",
                    "*.yaml",
                    "*.xml",
                    "*.html",
                }, -- Show virt text only on matched pattern
                virt_ignore_pattern = {}, -- Ignore showing virt text on matched pattern, this works after virt_pattern
                border_style = "rounded", -- "single", "double", "rounded"
                hl = {
                    -- border = "CustomBorder",
                    cursorline = "guibg=Gray guifg=White",
                },
                datetime_format = "%Y.%m.%d %H:%M", -- os.date
                -- •%Y: Four-digit year
                -- •%m: Two-digit month (01 to 12)
                -- •%d: Two-digit day (01 to 31)
                -- •%H: Hour in 24-hour format (00 to 23)
                -- •%I: Hour in 12-hour format (01 to 12)
                -- •%M: Two-digit minute (00 to 59)
                -- •%S: Two-digit second (00 to 59)
                -- •%p: AM/PM indicator
            })
            require("telescope").load_extension("bookmarks")
            -- vim.api.nvim_set_keymap("n", "<C-i>", "<C-i>", { noremap = true, silent = true })
            --INFO_N: vim.api.nvim_set_hl(0, "CustomBorder", { fg = "#56b6c2"} )
        end,
    },

    {
        "ziontee113/icon-picker.nvim",
        event = "VeryLazy",
        config = function()
            require("icon-picker").setup({ disable_legacy_commands = true })

            local opts = { noremap = true, silent = true }

            vim.keymap.set("n", "<Leader>ip", "<cmd>IconPickerNormal<cr>", opts)
            vim.keymap.set("n", "<Leader>iy", "<cmd>IconPickerYank<cr>", opts) --> Yank the selected icon into register
            -- vim.keymap.set("i", "<C-i>", "<cmd>IconPickerInsert<cr>", opts)
        end,
    },

    -- {
    --     "skywind3000/asyncrun.vim", -- asynchronous run some task or cmds
    -- },

    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerSaveBundle",
            "OverseerLoadBundle",
            "OverseerDeleteBundle",
            "OverseerRunCmd",
            "OverseerRun",
            "OverseerInfo",
            "OverseerBuild",
            "OverseerQuickAction",
            "OverseerTaskAction",
            "OverseerClearCache",
        },
        opts = {
            dap = false,
            task_list = {
                bindings = {
                    ["<C-h>"] = false,
                    ["<C-j>"] = false,
                    ["<C-k>"] = false,
                    ["<C-l>"] = false,
                    ["j"] = "NextTask",
                    ["k"] = "PrevTask",
                },
            },
            form = {
                win_opts = {
                    winblend = 0,
                },
            },
            confirm = {
                win_opts = {
                    winblend = 0,
                },
            },
            task_win = {
                win_opts = {
                    winblend = 0,
                },
            },
        },
        keys = {
            { "<leader>tl", "<cmd>OverseerToggle<cr>", desc = "Task list" },
            { "<leader>tn", "<cmd>OverseerRun<cr>", desc = "Run new task" },
            { "<leader>tr", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
            { "<leader>ti", "<cmd>OverseerInfo<cr>", desc = "Overseer info" },
            { "<leader>tc", "<cmd>OverseerBuild<cr>", desc = "Create task" },
            { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
            { "<leader>td", "<cmd>OverseerClearCache<cr>", desc = "Delete cache" },
            -- disabled default keymaps
            { "<leader>ow", false, "<cmd>OverseerToggle<cr>", desc = "Task list" },
            { "<leader>oo", false, "<cmd>OverseerRun<cr>", desc = "Run task" },
            { "<leader>oq", false, "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
            { "<leader>oi", false, "<cmd>OverseerInfo<cr>", desc = "Overseer Info" },
            { "<leader>ob", false, "<cmd>OverseerBuild<cr>", desc = "Task builder" },
            { "<leader>ot", false, "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
            { "<leader>oc", false, "<cmd>OverseerClearCache<cr>", desc = "Clear cache" },
        },
    },

    {
        "Joreh-T/leetcode.nvim",
        lazy = leet_arg ~= vim.fn.argv(0, -1),
        cmd = "Leet",
        dependencies = {
            -- include a picker of your choice, see picker section for more details
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            arg = leet_arg, -- Starter command, e.g. nvim leetcode
            lang = "cpp",
            cn = { -- leetcode.cn
                enabled = true, ---@type boolean
                translator = true, ---@type boolean
                translate_problems = true, ---@type boolean
            },
            storage = {
                home = vim.fn.stdpath("data") .. "/leetcode",
                cache = vim.fn.stdpath("cache") .. "/leetcode",
            },
            plugins = {
                non_standalone = false,
            },
            logging = true,
            injector = {
                ["cpp"] = {
                    imports = function()
                        return {
                            "// Base & Common",
                            "#include <bits/stdc++.h>",
                            "",

                            "#include <cassert>",
                            "#include <cstdio>",
                            "#include <cstring>",
                            "#include <iostream>",
                            "#include <string>",
                            -- "#include <cstdlib>",
                            -- "#include <utility>",
                            -- "#include <functional>",
                            -- "#include <iomanip>",
                            -- "#include <sstream>",

                            "// Containers",
                            "#include <array>",
                            "#include <deque>",
                            "#include <list>",
                            "#include <queue>",
                            "#include <stack>",
                            "#include <vector>",

                            "// Associative Containers",
                            "#include <map>",
                            "#include <set>",
                            "#include <unordered_map>",
                            "#include <unordered_set>",

                            "// Algorithms & Numeric",
                            "#include <algorithm>",
                            "#include <bitset>",
                            "#include <cmath>",
                            "#include <numeric>",

                            "// Tuples",
                            "#include <tuple>",

                            "// Limits & Constants",
                            "#include <climits>",
                            "#include <cfloat>",

                            "// Time & Random",
                            "#include <chrono>",
                            "#include <random>",
                            "",

                            "using namespace std;",

                            "",
                            "#define DEBUG 1",
                            "",
                            "#if DEBUG",
                            "    #define debug_print(format, ...) do { printf(format, ##__VA_ARGS__); } while (0)",
                            "#else",
                            "    #define debug_print(format, ...)",
                            "#endif",
                            "",
                        }
                    end,
                    after = [[int main() {

}

]],
                },
            },
            cache = {
                update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
            },
            editor = {
                reset_previous_code = true, ---@type boolean
                fold_imports = true, ---@type boolean
            },
            console = {
                open_on_runcode = true, ---@type boolean
                dir = "row",
                size = {
                    width = "90%",
                    height = "75%",
                },
                result = {
                    size = "60%",
                },
                testcase = {
                    virt_text = true,
                    size = "40%",
                },
            },
            description = {
                position = "left",
                width = "40%",
                show_stats = true,
            },
            picker = { provider = "fzf-lua" },
            hooks = {
                ---@type fun()[]
                ["enter"] = {},

                ---@type fun(question: lc.ui.Question)[]
                ["question_enter"] = {
                    function()
                        local found = vim.fn.search("Solution", "w")
                        if found == 0 then
                            vim.cmd("normal! G")
                        end
                    end,
                },

                ["submit"] = {
                    function(question, buffer, status_msg, success)
                        if success then
                            local current_file_path = question.file:absolute()
                            if not current_file_path or current_file_path == "" then
                                print("Current file path not found, skipping file movement.")
                                return
                            end
                            local solved_dir = vim.fn.stdpath("data") .. "/leetcode/solved"
                            vim.fn.mkdir(solved_dir, "p") -- Ensure the directory exists

                            -- Get the filename (e.g., TwoSum.cpp)
                            local file_name = vim.fn.fnamemodify(current_file_path, ":t")
                            local new_file_path = solved_dir .. "/" .. file_name

                            -- Prompt user to confirm moving the file
                            -- vim.fn.confirm returns 1 for the first option, 2 for the second
                            vim.defer_fn(function()
                                local choice =
                                    vim.fn.confirm("Submission successful! Move this file to the solved directory?", "&Yes\n&No", 1)

                                if choice == 1 then -- User chose "Yes"
                                    -- vim.fn.rename returns 0 on success, -1 on failure
                                    local ok, err = pcall(vim.fn.rename, current_file_path, new_file_path)
                                    if ok == 0 then
                                        print("File successfully moved to: " .. new_file_path)
                                    else
                                        print("Failed to move file: " .. err)
                                    end
                                end
                            end, 1000)
                        end
                    end,
                },

                ---@type fun()[]
                ["leave"] = {},
            },
            keys = {
                toggle = { "q" },
                confirm = { "<CR>" },

                reset_testcases = "r",
                use_testcase = "U",
                focus_testcases = "H",
                focus_result = "L",
            },
            theme = {},
            image_support = false,
        },
    },
}
