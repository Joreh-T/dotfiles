local utils = require("config.utils")
-- local LazyVim = require("lazyvim.util") -- Ensure access to lazyvim's utility functions.

return {
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.servers.harper_ls = {
                autostart = false,
                filetypes = {},
            }
            opts.servers.clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders=true",
                    "--fallback-style=llvm",
                    "--query-driver=**/*gcc*",
                    -- "--compile-commands-dir=build", 
                }
            }
        end,
    },

    {
        "mason-org/mason-lspconfig.nvim",
        opts = function(_, opts)
            -- add 'lsp', 'linter', 'formatter', 'debugger' etc categories which lazyVim extral doesn't support
            opts.ensure_installed = { "html", "cssls", "jsonls", "eslint" }
            -- opts.dependencies = {
            --     { "mason-org/mason.nvim", opts = {} },
            --     "neovim/nvim-lspconfig",
            -- }
        end,
    },

    {
        "linux-cultist/venv-selector.nvim",
        branch = "main",
        cmd = "VenvSelect",
        event = "VeryLazy",
        enabled = function()
            -- return LazyVim.has("telescope.nvim")
            return _G.LazyVim ~= nil and LazyVim.has("telescope.nvim")
        end,
        opts = {
            settings = {
                options = {
                    notify_user_on_venv_activation = true,
                },
            },
        },
        --  Call config for python files and load the cached venv automatically
        ft = "python",
        keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            code = {
                sign = true,
                width = "block",
                right_pad = 1,
            },
            heading = {
                enabled = true,
                icons = { " " },
                render_modes = false,
                width = "block",
                right_pad = 5,
                left_pad = 2,
                border = false,
                border_virtual = true,
                border_prefix = true,
                -- Used above heading for border.
                above = "",
                -- Used below heading for border.
                below = "󰽿",
                -- atx = false,
                backgrounds = {
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH5Bg",
                },
                foregrounds = {
                    "RenderMarkdownH1",
                    "RenderMarkdownH2",
                    "RenderMarkdownH3",
                    "RenderMarkdownH4",
                    "RenderMarkdownH5",
                    "RenderMarkdownH6",
                },
            },

            checkbox = {
                enabled = false,
            },
        },
    },
}
