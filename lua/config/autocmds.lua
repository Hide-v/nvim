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

-- 自动提交并推送 lazy-lock.json 变更
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyUpdate", -- 当 LazyVim 完成插件更新或同步时触发
  callback = function()
    -- 1. 获取当前 Neovim 配置仓库的绝对路径
    local repo_dir = vim.fn.stdpath("config")
    local lockfile = repo_dir .. "/lazy-lock.json"

    -- 2. 构建 Git 命令组合 (注意：-C 参数可以让 git 在指定目录下运行)
    -- 这里做了三件事：添加 lock 物理文件 -> 提交说明 -> 推送到当前分支
    local cmd = {
      "git",
      "-C",
      repo_dir,
      "add",
      lockfile,
      "&&",
      "git",
      "-C",
      repo_dir,
      "commit",
      "-m",
      "chore: auto-update lazy-lock.json [skip ci]",
      "&&",
      "git",
      "-C",
      repo_dir,
      "push",
    }

    -- 3. 异步执行 shell 命令（不卡顿你的 Neovim 界面）
    vim.system({ "sh", "-c", table.concat(cmd, " ") }, {}, function(obj)
      -- 如果 Git 命令成功执行（退出码为 0）
      if obj.code == 0 then
        -- 回到 Neovim 的主线程弹窗提示你
        vim.schedule(function()
          vim.notify("🚀 lazy-lock.json 已自动提交并推送到远程仓库！", vim.log.levels.INFO, {
            title = "Git 自动化",
          })
        end)
      end
    end)
  end,
})
