-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local utils = require("config.utils")

local map = vim.keymap.set
local del = vim.keymap.del

-----------------------------------------------------------
-- Mapping 'yw' to 'viwy' avoids copying extra spaces.
map("n", "yw", "viwy", { noremap = true, silent = true })
map("n", "<A-j>", "<C-d>", { noremap = true, silent = true, desc = "Scroll Up Half Page" })
map("n", "<A-k>", "<C-u>", { noremap = true, silent = true, desc = "Scroll Down Half Page" })
map("n", "<C-i>", "<C-i>", { noremap = true, silent = true })
map("n", "<C-o>", "<C-o>", { noremap = true, silent = true })
map("n", "<S-u>", "<C-r>", { noremap = true, silent = true })
map("n", "<leader>r", "<cmd>LspRestart<CR>", { noremap = true, silent = false, desc = "Restart LSP" })
map("n", "<CR>", "o<esc>", { noremap = true, silent = true })

--open/close terminal
map({"n", "t"}, "<a-`>", function() Snacks.terminal(nil) end, { desc = "Terminal (cwd)" })
-- map("n", "<a-`>", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Open Terminal (Root Dir)" })
-- { map("t", "<a-`>", "<cmd>close<cr>", { desc = "Hide Terminal" }) },

-- map("n", "<a-`>", utils.open_terminal_rezise_height, { desc = "Terminal (cwd)" })
-- map("t", "<a-`>", utils.close_terminal_and_focus_largest, { desc = "Hide Terminal and Focus Largest Window" })


map("n", "<leader>ft", function()
    Snacks.terminal()
end, { desc = "Terminal (cwd)" })
map("n", "<leader>fT", function()
    Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

-- buffer motion
map("n", "<leader>bh", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>bl", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- map("n", "<leader>fr", function()
--   require("telescope").extensions["recent-files"].recent_files({})
-- end, { noremap = true, silent = true, desc = "Recent Files" })
-- map("n", "<leader><leader>", function()
--   require("telescope").extensions["recent-files"].recent_files({})
-- end, { noremap = true, silent = true, desc = "Recent Files" })

del("n", "<leader>|") -- del keymap: map("<leader>|", "<C-W>v", { desc = "Split Window Right" }) },
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>\\", "<C-W>v", { desc = "Split Window Right", remap = false })
-----------------------------------------------------------
map({ "n", "v" }, "<S-h>", "^", { noremap = true, silent = true })
map("n", "<S-l>", "$", { noremap = true, silent = true })
map("v", "<S-l>", "$h", { noremap = true, silent = true })

-----------------------------------------------------------
map("i", "jk", "<esc>", { noremap = true, silent = true })
-- map("t", "jk", [[<C-\><C-n>]], { noremap = true, silent = true })
-----------------------------------------------------------
map("v", "jkl", "<esc>", { noremap = true, silent = true })

map("n", "gh", function()
    vim.diagnostic.open_float(nil, {
        border = "rounded", -- You can choose "single", "double", "rounded", or "solid"
    })
end, { noremap = true, silent = true, desc = "Hover diagnostic" })

-- Ctrl + c
-- map({ "n", "v" }, "<C-c>", '"+y', { noremap = true, desc = "Copy to system clipboard" })

map("v", "p", '"_dP') -- Prevent overwriting the system clipboard when pasting in visual mode
-- Ctrl + v
-- map("n", "<C-v>", '"+p', { noremap = true, desc = "Paste from system clipboard" })
-- map("i", "<C-v>", "<C-r>+", { noremap = true, desc = "Paste from system clipboard" }) -- In Neovide, if the data to be pasted contains comment symbols, it will trigger automatic commenting.
-- map("i", "<C-v>", '<esc>"+p', { noremap = true, desc = "Paste from system clipboard" })
-- map('c', '<C-v>', '<C-r>+', { noremap = true, silent = true }) -- The UI won't refresh immediately.
-- map("c", "<C-v>", function()
--     return vim.fn.getreg("+")
-- end, { noremap = true, expr = true, desc = "Paste clipboard in cmdline" })
-- map("t", "<C-v>", [[<C-\><C-n>"+pa<Right>]], { noremap = true, desc = "Paste from system clipboard in terminal" })
--   {map("n", "gk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })},
--   {map("n", "gj", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })}
--   { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },

------------------------- Git Tools -------------------------
map("n", "<leader>gd", utils.toggle_diffview, { noremap = true, silent = true, desc = "Toggle Diffview" })
map("n", "<leader>gH", utils.toggle_history_view, { noremap = true, silent = true, desc = "Toggle File History" })

-- map("n", "q", function()
--     local closed_diffview = false
--     -- Traverse all windows
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--         -- check if the window is a Diffview window
--         local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
--         if ok then
--             local cur_buf_type = vim.bo[buf].filetype
--             if cur_buf_type == "DiffviewFiles" or cur_buf_type == "DiffviewFileHistory" then
--                 vim.api.nvim_win_call(win, function()
--                     vim.cmd("DiffviewClose")
--                 end)
--                 closed_diffview = true
--                 diffview_open = false
--                 diffviewFileHistory_open = false
--             end
--         end
--     end
--     -- If no Diffview window is closed, perform the default 'q' action.
--     if not closed_diffview then
--         vim.api.nvim_feedkeys("q", "n", false) -- WARN: This may trigger a recursive call.
--     end
-- end)

-- lazygit
-- if vim.fn.executable("lazygit") == 1 then
--     local util = require(("config.util"))
--     map("n", "<leader>gg", function()
--         -- If cursor will automatically enter insert mode in avante ask, the following steps are not needed.
--         if util.has_avante_window() then
--             vim.cmd("AvanteToggle")
--         end
--         Snacks.lazygit({ cwd = LazyVim.root.git() })
--         vim.defer_fn(function()
--             if vim.fn.mode() ~= "i" then
--                 vim.cmd("startinsert")
--             end
--         end, 500)
--     end, { desc = "Lazygit (Root Dir)" })
--
--     map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
--     map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
--     map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, { desc = "Git Log" })
--     map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
-- end
-------------------------End Of Git Tools -------------------------
