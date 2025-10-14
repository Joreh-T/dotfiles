vim.g.sonokai_style = "atlantis" -- default, atlantis, espresso, maia, andromeda, shusia
vim.g.sonokai_menu_selection_background = "bg"
vim.g.sonokai_diagnostic_virtual_text = "grey" -- Available values:   `'grey'`, `'colored'`, `'highlighted'`

local enabled_theme = "sonokai" -- "onedark" "one_monokai" "everforest" "nightfox" "kanagawa" "vscode"



local themes = {
    {
        "navarasu/onedark.nvim",
        config = function()
            local ok, palette = pcall(require, "onedark.palette")
            if not ok then
                vim.notify("onedark.palette not found", vim.log.levels.WARN)
                return
            end

            local onedark = require("onedark")
            local onedark_style = "dark"

            onedark.setup({
                style = onedark_style,
                term_colors = false,
                ending_tildes = true,
                colors = {
                    dir_color = "#cccccc",
                    delimiter_color = "#bbbbbb",
                    keyword_color = "#E47255",
                    keyword_conditional_color = "#bb97ee",
                    string_color_1 = "#D7D7E0",
                    string_color_2 = "#D2E1E4",
                    string_color_3 = "#E1E2E3",
                    git_untracked_color = "#72cce8",
                    var_color_2 = "#C6C2C2",
                    var_color_3 = "#E4E3E1",
                    purple = "#cf86d1",
                    pink = "#e06c75",
                    local_white = "#C2C7E5",
                    local_light_purple = "#E0CAFB",
                    type_pr_color = "#79C5C3",
                    var_color = "#F1AFF5",
                    float_color_bg = "#21242C",
                    float_color_fg = "#B0C996",
                    type_comment_color = "#879FA7",
                },
                highlights = {
                    TelescopeBorder = { fg = palette[onedark_style].green },
                    DiagnosticHint = { fg = "$keyword_color" },

                    Directory = { fg = "$dir_color" },
                    Delimiter = { fg = "$delimiter_color" },
                    NeoTreeGitUntracked = { fg = palette[onedark_style].green },
                    NeoTreeGitConflict = { fg = palette[onedark_style].yellow, fmt = "bold,italic" },

                    Title = { fg = palette[onedark_style].green },
                    Special = { fg = "#e6756e" },

                    DiagnosticInfo = { fg = palette[onedark_style].green },
                    FloatBorder = { fg = palette[onedark_style].green },
                    -- ["@tag.delimiter"] = colors.Purple, -- "<", ">"
                    ["@function"] = { fg = palette[onedark_style].green },
                    ["@lsp.typemod.method.defaultLibrary"] = { fg = palette[onedark_style].blue },
                    ["@lsp.typemod.function.defaultLibrary"] = { fg = palette[onedark_style].blue },

                    ["@function.macro"] = { fg = palette[onedark_style].bg_blue, fmt = "bold" },
                    ["@lsp.type.macro"] = { fg = palette[onedark_style].bg_blue, fmt = "bold" },

                    ["@punctuation.delimiter"] = { fg = "$delimiter_color" },

                    ["@keyword"] = { fg = "$keyword_color" },
                    ["@keyword.conditional"] = { fg = palette[onedark_style].red },

                    ["@variable"] = { fg = "$var_color_2" },
                    ["@lsp.type.variable"] = { fg = "$var_color_2" },
                    ["@variable.parameter"] = { fg = "$purple" },
                    ["@lsp.type.parameter"] = { fg = "$purple" },
                    -- ["@variable.builtin"] = {fg = "$pink"},

                    ["@string"] = { fg = "$string_color_3" },

                    ["@operator"] = { fg = "$pink" },
                },
            })
        end,
    },

    {
        "cpea2506/one_monokai.nvim",
        --   opts = {
        --     transparent = false,
        --     colors = {
        --       local_white = "#C2C7E5",
        --       local_orange = "#F8957B",
        --       local_light_purple = "#E0CAFB",
        --       dir_color = "#cccccc",
        --       type_pr_color = "#79C5C3",
        --       var_color = "#F1AFF5",
        --       var_color_2 = "#C6C2C2",
        --       delimiter_color = "#bbbbbb",
        --       string_color = "#DFCF9A",
        --       float_color_bg = "#21242C", -- #21252b
        --       float_color_fg = "#B0C996",
        --       type_comment_color = "#879FA7",
        --       -- float_color_fg = "#91A4C4",
        --     },
        --     themes = function(colors)
        --       return {
        --         Statement = { fg = colors.local_orange },
        --         Operator = { fg = colors.pink },
        --         Macro = { fg = colors.pink },
        --         Directory = { fg = colors.dir_color },
        --         String = { fg = colors.string_color },
        --         Structure = { fg = colors.orange },
        --         NormalFloat = { fg = colors.float_color_fg, bg = colors.float_color_bg },
        --         Delimiter = { fg = colors.delimiter_color }, -- color of “;”
        --         ["@lsp.type.comment"] = { fg = colors.type_comment_color }, -- Unenabled code for macro control in C/CPP
        --         ["@lsp.type.macro"] = { fg = colors.local_white },
        --         ["@lsp.type.property"] = { fg = colors.type_pr_color },
        --         ["@variable"] = { fg = colors.var_color_2 },
        --       }
        --     end,
        --   },
    },
    --
    -- {
    --   "olimorris/onedarkpro.nvim",
    --   lazy = true,
    --   priority = disable, -- defautl 50, make it higher to fast load
    -- },
    {
        -- "sainnhe/sonokai",
        "Joreh-T/sonokai",
    },

    {
        "sainnhe/everforest",
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.everforest_enable_italic = true
            -- vim.cmd.colorscheme('everforest')
        end,
    },

    {
        "EdenEast/nightfox.nvim",
        -- colorscheme can be "nightfox", "terafox", "dayfox", "dawnfox", "duskfox", "nordfox", "terafox", "carbonfox"
    },

    { "rebelot/kanagawa.nvim" },

    { "Mofiqul/vscode.nvim" },

    -- Load colorscheme by LazyVim
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = enabled_theme,
        },
    },
}

local function setup_themes(theme_list, active_theme_name)
    for _, theme_spec in ipairs(theme_list) do
        local theme_name = theme_spec[1]
        local short_name = theme_name:match("/([%w-_]+)%.nvim$") or theme_name:match("/([%w-_]+)$")

        if short_name == active_theme_name then
            theme_spec.lazy = false
            theme_spec.priority = 1000 -- High priority to load this theme as soon as possible

            -- local original_config = theme_spec.config
            -- theme_spec.config = function(...)
            --     if original_config then
            --         original_config(...)
            --     end
            --     -- Don't enable colorscheme here, let LazyVim handle it
            --     -- vim.cmd("colorscheme " .. active_theme_name)
            -- end
        else
            theme_spec.lazy = true
            theme_spec.priority = nil
        end
    end
    return theme_list
end

return setup_themes(themes, enabled_theme)
