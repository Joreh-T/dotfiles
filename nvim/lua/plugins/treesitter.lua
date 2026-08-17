-- nvim-treesitter **main** branch (requires nvim >= 0.12).
-- The plugin is only a parser installer/updater here: highlight/indent/folds are
-- executed by nvim's core `vim.treesitter` APIs, which LazyVim wires up on
-- FileType based on the opts below (lazyvim.TSConfig shape).
-- The old master-branch fallback (legacy `nvim-treesitter.configs.setup`
-- modules for pre-2.31 glibc systems) was removed: master is frozen upstream
-- and incompatible with nvim 0.12.
local languages_parser = {
    "bash",
    "c",
    "cpp",
    "c_sharp",
    "cuda",
    "cmake",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
    "systemverilog",
    "vhdl",
    "arduino",
    "latex",
    "css",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    event = { "LazyFile", "VeryLazy" },
    opts = {
        indent = { enable = true },
        highlight = { enable = true },
        folds = { enable = true },
        ensure_installed = languages_parser,
    },
}
