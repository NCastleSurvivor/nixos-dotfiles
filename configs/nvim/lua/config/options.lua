-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_check_order = false
vim.g.autoformat = false

local opt = vim.opt

opt.tabstop = 4
opt.shiftwidth = 4
opt.swapfile = false
opt.encoding = 'utf-8'
-- opt.foldlevelstart = 99
opt.completeopt = { "menuone", "noselect" }
