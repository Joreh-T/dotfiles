-- if true then return {} end

-- blink.cmp as a replacement for nvim-cmp (lazy.vim 14.x)
return {
    "saghen/blink.cmp",
    dependencies = {
        "xzbdmw/colorful-menu.nvim", -- Adding Syntax Highlighting to the Completion Window
    },
    opts = function(_, opts)
        opts.keymap = {
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- see the "default configuration" section below for full documentation on how to define
            preset = "super-tab",
            ["<Tab>"] = { "accept", "fallback" }, -- fallback: Runs the next non-blink keymap, or runs the built-in neovim binding
        }
        opts.completion = {
            menu = {
                draw = {
                    -- Adding Syntax Highlighting to the Completion Window
                    -- We don't need label_description now because label and label_description are already
                    -- combined together in label by colorful-menu.nvim.
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                    treesitter = { "lsp" },
                },
            },
            accept = {
                -- experimental auto-brackets support
                auto_brackets = {
                    enabled = true,
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
            ghost_text = {
                enabled = vim.g.ai_cmp,
            },
        }
    end,
}

-- return {
--
--   -- auto completion
--   {
--     "hrsh7th/nvim-cmp",
--     version = false, -- last release is way too old
--     event = "InsertEnter",
--     dependencies = {
--       "hrsh7th/cmp-nvim-lsp",
--       "hrsh7th/cmp-buffer",
--       "hrsh7th/cmp-path",
--     },
--     -- Not all LSP servers add brackets when completing a function.
--     -- To better deal with this, LazyVim adds a custom option to cmp,
--     -- that you can configure. For example:
--     --
--     -- ```lua
--     -- opts = {
--     --   auto_brackets = { "python" }
--     -- }
--     -- ```
--     opts = function()
--       vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
--       local cmp = require("cmp")
--       local defaults = require("cmp.config.default")()
--       local auto_select = true
--       return {
--         auto_brackets = {}, -- configure any filetype to auto add brackets
--         completion = {
--           completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
--         },
--         preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
--         mapping = cmp.mapping.preset.insert({
--           ["<C-b>"] = cmp.mapping.scroll_docs(-4),
--           ["<C-f>"] = cmp.mapping.scroll_docs(4),
--           ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
--           ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
--           ["<C-Space>"] = cmp.mapping.complete(),
--           ["<Tab>"] = LazyVim.cmp.confirm({ select = auto_select }),
--           ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
--           ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--           ["<C-CR>"] = function(fallback)
--             cmp.abort()
--             fallback()
--           end,
--         }),
--         sources = cmp.config.sources({
--           { name = "nvim_lsp" },
--           { name = "path" },
--         }, {
--           { name = "buffer" },
--         }),
--         formatting = {
--           format = function(entry, item)
--             local icons = LazyVim.config.icons.kinds
--             if icons[item.kind] then
--               item.kind = icons[item.kind] .. item.kind
--             end
--
--             local widths = {
--               abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
--               menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
--             }
--
--             for key, width in pairs(widths) do
--               if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
--                 item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
--               end
--             end
--
--             return item
--           end,
--         },
--         experimental = {
--           ghost_text = {
--             hl_group = "CmpGhostText",
--           },
--         },
--         sorting = defaults.sorting,
--          -- 添加边框
--         window = {
--         completion = cmp.config.window.bordered(), -- 为补全窗口添加边框
--         documentation = cmp.config.window.bordered(), -- 为文档窗口添加边框
--         },
--       }
--     end,
--     main = "lazyvim.util.cmp",
--   },
-- }
--
