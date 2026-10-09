-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set
local del = vim.keymap.del

-- disable marco
map({ "n", "v" }, "q", "<cmd> echo 'marco not set'<cr>")
-- better paste
-- map({ "v", "n" }, "[p", '"0p', { desc = "[p]aste latest after corsur" })
map({ "v", "n" }, "[P", '"0P', { desc = "[P]aste latest before corsur" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>wa<cr><esc>", { desc = "[S]ave File" })

map({ "n", "t" }, "<c-t>", '<cmd>Lspsaga term_toggle<cr>', { desc = "Terminal (Root Dir)" })
-- map({ "t" }, "<A-n>", '<C-\\><C-n>', { desc = "Terminal Normal Mode" })

-- map("n", "<leader>gb", '<cmd>Gitsigns blame_line<cr>', { desc = "[G]it [B]lame Line" })

map("n", "<leader>uM", '<cmd>SmearCursorToggle<cr>', { desc = "Toggle S[m]ear" })

if vim.fn.executable("lazygit") == 1 then
    map("n", "<leader>gG", function() Snacks.lazygit({ cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
    map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uz")
Snacks.toggle.zen():map("<leader>uZ")

del("n", "<A-j>")
del("n", "<A-k>")
del("i", "<A-j>")
del("i", "<A-k>")
del("v", "<A-j>")
del("v", "<A-k>")

