-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("n", "<C-d>", "10jzz", { desc = "Scroll down 10 lines + center" })
map("n", "<C-u>", "10kzz", { desc = "Scroll up 10 lines + center" })
