---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
-- Neovide Configuration

return {
  {
    "neovide-config", -- 借用 lazy 载入机制执行自定义配置
    virtual = true,
    lazy = false, -- 启动时立即加载
    priority = 1000, -- 确保视觉配置优先于其他插件加载
    config = function()
      if not vim.g.neovide then
        return
      end
      -- 1. 基础视觉配置 (全系统通用)
      vim.o.guifont = "Maple_Mono_NF_CN:h10"

      -- 透明度与间距
      vim.g.neovide_theme = "auto"
      vim.g.neovide_opacity = 0.85
      vim.g.neovide_scale_factor = 1.0
      vim.g.neovide_padding_left = 5

      -- 光标动画与渲染
      vim.g.neovide_cursor_animation_length = 0.1
      vim.g.neovide_cursor_trail_size = 0.8
      vim.g.neovide_cursor_antialiasing = true
      vim.g.neovide_refresh_rate = 165
      vim.g.neovide_scroll_animation_length = 0.3

      -- 星尘特效强化
      vim.g.neovide_cursor_vfx_mode = "pixiedust"
      vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
      vim.g.neovide_cursor_vfx_particle_density = 20.0
      vim.g.neovide_cursor_vfx_particle_speed = 15.0

      -- 2. Wallbash 自动换色逻辑 (仅在 Linux 启用)
      local is_linux = vim.loop.os_uname().sysname == "Linux"
      if is_linux then
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
              -- 使用 schedule 确保在主题插件加载后再切换
              vim.schedule(function()
                if r_val and r_val > 128 then
                  vim.o.background = "light"
                  pcall(vim.cmd.colorscheme, "catppuccin-latte")
                else
                  vim.o.background = "dark"
                  pcall(vim.cmd.colorscheme, "catppuccin-mocha")
                end
              end)
            end
          end
        end

        -- 初次启动同步
        sync_wallbash_mode()

        -- 文件监听器
        local wallbash_cache_path = vim.fn.expand("~/.cache/hyde/wallbash/")
        if vim.fn.isdirectory(wallbash_cache_path) == 1 then
          local w = vim.loop.new_fs_event()
          w:start(
            wallbash_cache_path,
            {},
            vim.schedule_wrap(function(_, fname)
              if fname == "shell-colors" then
                sync_wallbash_mode()
              end
            end)
          )
        end
      end -- end if is_linux
    end,
  },
}
