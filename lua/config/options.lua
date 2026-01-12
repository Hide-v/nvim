-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.loader.enable()

-- 开启软换行
vim.opt.wrap = true

-- 优化软换行的显示效果
vim.opt.linebreak = true -- 不会在单词中间断开，而是尽量在空格处换行
vim.opt.breakindent = true -- 换行后的行首会与上一行保持相同的缩进，视觉上更整齐
