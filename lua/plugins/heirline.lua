---@diagnostic disable: undefined-global
return {
  "rebelot/heirline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  depedencies = {
    { "echasnovski/mini.icons", opts = {} },
  },
  init = function()
    vim.keymap.set("n", "<leader>tt", function()
      vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
    end, { desc = "Toggle tabline" })
  end,
  config = function()
    local utils = require("heirline.utils")
    local function setup_colors()
      local function get_hl(name, fallback)
        local hl = utils.get_highlight(name)
        if not hl or (not hl.fg and not hl.bg) then
          return fallback
        end
        return hl
      end

      local Normal = get_hl("Normal", { fg = "#cdd6f4", bg = "#1e1e2e" })
      local StatusLine = get_hl("StatusLine", { fg = "#cdd6f4", bg = "#181825" })

      local colors = {
        bg = StatusLine.bg,
        fg = StatusLine.fg,
        bright_bg = Normal.bg,
        bright_fg = Normal.fg,

        normal = get_hl("HeirlineNormal", { fg = "#89b4fa" }).fg,
        insert = get_hl("HeirlineInsert", { fg = "#a6e3a1" }).fg,
        visual = get_hl("HeirlineVisual", { fg = "#cba6f7" }).fg,
        replace = get_hl("HeirlineReplace", { fg = "#f38ba8" }).fg,
        command = get_hl("HeirlineCommand", { fg = "#f9e2af" }).fg,

        git_added = get_hl("GitSignsAdd", { fg = "#a6e3a1" }).fg,
        git_changed = get_hl("GitSignsChange", { fg = "#fab387" }).fg,
        git_removed = get_hl("GitSignsDelete", { fg = "#f38ba8" }).fg,

        diag_ERROR = get_hl("DiagnosticError", { fg = "#f38ba8" }).fg,
        diag_WARN = get_hl("DiagnosticWarn", { fg = "#f9e2af" }).fg,
        diag_INFO = get_hl("DiagnosticInfo", { fg = "#89b4fa" }).fg,
        diag_HINT = get_hl("DiagnosticHint", { fg = "#94e2d5" }).fg,

        -- 其他
        scrollbar = get_hl("TypeDef", { fg = "#f9e2af" }).fg,
        blue = "#89b4fa",
        orange = "#fab387",
      }

      return colors
    end

    vim.opt.cmdheight = 0
    require("heirline").setup({
      statusline = require("config.heirline.statusline"),
      opts = {
        colors = setup_colors,
      },
    })

    vim.api.nvim_create_augroup("Heirline", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        utils.on_colorscheme(setup_colors)
      end,
      group = "Heirline",
    })
  end,
}
