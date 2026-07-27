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
            -- clangd flags (binary is chosen per-project below)
            local clangd_flags = {
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders=true",
                "--fallback-style=llvm",
                "--query-driver=**",
            }
            opts.servers.clangd = {
                cmd = vim.list_extend({ "clangd" }, clangd_flags),
            }
            -- One-shot binary detection: pick the clangd binary from the FIRST C/C++
            -- project file opened in the session (reads <root>/.nvim-clangd), register it,
            -- then hand off to vim.lsp.enable so nvim's native FileType handling attaches
            -- every subsequent buffer. Our autocmd self-deletes after that single run, so
            -- detection happens exactly once per session.
            -- NOTE: assumes ONE clangd binary per session -- restart nvim to switch projects.
            opts.setup = vim.tbl_deep_extend("force", opts.setup or {}, {
                clangd = function(server, conf)
                    vim.lsp.config(server, conf) -- register base config (keeps defaults + "*")
                    local group = vim.api.nvim_create_augroup("clangd_pick_bin", { clear = true })
                    vim.api.nvim_create_autocmd("FileType", {
                        group = group,
                        pattern = vim.lsp.config[server].filetypes
                            or { "c", "cpp", "objc", "objcpp", "cuda" },
                        callback = function(args)
                            -- Only commit once we're in a real project (has a root marker),
                            -- otherwise stay armed for the next file.
                            -- vim.notify("clangd: detecting binary for project root...", vim.log.levels.INFO)
                            local root = vim.fs.root(args.buf, {
                                ".nvim-clangd",
                                "compile_commands.json",
                                "compile_flags.txt",
                                ".clangd",
                                ".git",
                            })
                            if not root then
                                return
                            end
                            local bin = utils.detect_specified_clangd(args.buf)
                            -- Self-delete: detection runs only this once in the session.
                            vim.api.nvim_clear_autocmds({ group = group })
                            -- Register the chosen binary and make sure this project resolves
                            -- as a root, then let nvim attach this and all future C buffers.
                            vim.lsp.config(server, {
                                cmd = vim.list_extend({ bin }, clangd_flags),
                                root_markers = {
                                    ".nvim-clangd",
                                    "compile_commands.json",
                                    "compile_flags.txt",
                                    ".clangd",
                                    ".git",
                                },
                            })
                            vim.lsp.enable(server)
                        end,
                    })
                    return true
                end,
            })
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
