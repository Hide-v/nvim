---@diagnostic disable: undefined-field
-- Neovide Configuration
if vim.g.neovide then
  -- 字体：Maple Mono 支持很好，保持现状
  vim.o.guifont = "Maple_Mono_NF_CN:h10"

  -- 主题
  vim.g.neovide_theme = "auto"
  local function sync_wallbash_mode()
    local mode_file = vim.fn.expand("~/.cache/hyde/wallbash/shell-colors")
    local f = io.open(mode_file, "r")

    if f then
      local content = f:read("*all")
      f:close()

      local pry1 = content:match("wallbash_pry1='([^']+)'")

      if pry1 then
        local r_val = tonumber(pry1:sub(2, 3), 16)

        -- 使用 schedule 确保在插件加载后再执行主题切换
        vim.schedule(function()
          if r_val and r_val > 128 then
            vim.o.background = "light"
            -- 避免直接调用 :Catppuccin 命令，改用标准 colorscheme
            pcall(function()
              vim.cmd("colorscheme catppuccin-latte")
            end)
          else
            vim.o.background = "dark"
            pcall(function()
              vim.cmd("colorscheme catppuccin-mocha")
            end)
          end
        end)
      end
    end
  end

  -- 初次启动同步
  sync_wallbash_mode()

  -- 监听器部分保持不变
  local w = vim.loop.new_fs_event()
  local wallbash_cache_path = vim.fn.expand("~/.cache/hyde/wallbash/")

  w:start(
    wallbash_cache_path,
    {},
    vim.schedule_wrap(function(_, fname)
      if fname == "shell-colors" then
        sync_wallbash_mode()
      end
    end)
  )

  -- 透明度优化：建议不要太透明
  vim.g.neovide_opacity = 0.85
  -- 只有在失去焦点时才变得更透明（可选）
  -- vim.g.neovide_focused_pause = true

  -- 缩放与间距
  vim.g.neovide_scale_factor = 1.0
  -- 建议给左侧留一点点间距，视觉上更平衡
  vim.g.neovide_padding_left = 5

  -- 光标动画与特效 (修复了变量名)
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.8 -- 修正后的变量名
  vim.g.neovide_cursor_antialiasing = true

  -- 星尘特效强化
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2 -- 稍微缩短寿命，避免屏幕太乱
  vim.g.neovide_cursor_vfx_particle_density = 20.0 -- 增加密度，星星更多
  vim.g.neovide_cursor_vfx_particle_speed = 15.0 -- 增加速度，更有爆发感

  -- 渲染优化
  vim.g.neovide_refresh_rate = 165 -- 如果你是高刷屏，一定要加这行
  vim.g.neovide_scroll_animation_length = 0.3 -- 滚动动画
end
