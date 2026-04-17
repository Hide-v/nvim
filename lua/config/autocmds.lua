-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function set_diagnostic_underline()
  local error_color = vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg
  local warn_color = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" }).fg
  local info_color = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg
  local hint_color = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" }).fg

  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = error_color })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = true, sp = warn_color })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = true, sp = info_color })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = true, sp = hint_color })
end

set_diagnostic_underline()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_diagnostic_underline,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- r: 回车时不自动添加注释符
    -- o: 使用 o 或 O 换行时不自动添加注释符
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
