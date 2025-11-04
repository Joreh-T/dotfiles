local utils = require("config.utils")

return {
    -- git blame
    {
        "APZelos/blamer.nvim",
        config = function()
            if utils().is_windows() then
                vim.g.blamer_enabled = true
                vim.g.blamer_delay = 500
            end
        end,
    },

    -- diffview
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            local actions = require("diffview.actions")

            opts.keymaps = {
                view = {
                    ["<leader>e"] = actions.toggle_files,
                    { desc = "Toggle the file panel" },
                },
                file_panel = {
                    ["<leader>e"] = actions.toggle_files,
                    { desc = "Toggle the file panel" },
                },
                file_history_panel = {
                    ["<leader>e"] = actions.toggle_files,
                    { desc = "Toggle the file panel" },
                },
            }

            -- Remove the `<leader>b` keybinding (if it exists by default)
            opts.keymaps.view["<leader>b"] = nil
            opts.keymaps.file_panel["<leader>b"] = nil
            opts.keymaps.file_history_panel["<leader>b"] = nil
            opts.hooks = {
                diff_buf_win_enter = function()
                    utils.detach_lsp_in_current_tab_if_diff()
                end,
            }

            return opts
        end,
    },
    {
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            lazygit = {
                -- automatically configure lazygit to use the current colorscheme
                -- and integrate edit with the current neovim instance
                configure = true,
                -- extra configuration for lazygit that will be merged with the default
                -- snacks does NOT have a full yaml parser, so if you need `"test"` to appear with the quotes
                -- you need to double quote it: `"\"test\""`
                config = {
                    os = { editPreset = "nvim-remote" },
                    gui = {
                        -- set to an empty string "" to disable icons
                        nerdFontsVersion = "3",
                    },
                },
                theme_path = vim.fs.normalize(vim.fn.stdpath("cache") .. "/lazygit-theme.yml"),

                -- Theme for lazygit
                theme = {
                    [241] = { fg = "Special" },
                    activeBorderColor = { fg = "Special", bold = true },
                    cherryPickedCommitBgColor = { fg = "Identifier" },
                    cherryPickedCommitFgColor = { fg = "Function" },
                    defaultFgColor = { fg = "Normal" },
                    inactiveBorderColor = { fg = "NormalFloat" },
                    optionsTextColor = { fg = "Function" },
                    searchingActiveBorderColor = { fg = "MatchParen", bold = true },
                    selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
                    unstagedChangesColor = { fg = "DiagnosticError" },
                },

                win = {
                    style = "lazygit",
                },
            },
        },
    },

    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        -- keys = {
        --     { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        -- },
    },
}
