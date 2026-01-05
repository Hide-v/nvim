---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global
local palette = require("catppuccin.palettes").get_palette()
local utils = require("heirline.utils")
local conditions = require("heirline.conditions")
local dim_color = palette.surface1
local colors = {
  diag_warn = utils.get_highlight("DiagnosticWarn").fg,
  diag_error = utils.get_highlight("DiagnosticError").fg,
  diag_hint = utils.get_highlight("DiagnosticHint").fg,
  diag_info = utils.get_highlight("DiagnosticInfo").fg,
  git_del = utils.get_highlight("diffDeleted").fg,
  git_add = utils.get_highlight("diffAdded").fg,
  git_change = utils.get_highlight("diffChanged").fg,
}

local M = {}
M.Spacer = { provider = " " }
M.Fill = { provider = "%=" }
--- 为组件添加右侧间距的包装器
--- @param child table Heirline组件表
--- @param num_space number? 空格数量 (默认为 1)
M.RightPadding = function(child, num_space)
  -- 健壮性检查：如果组件不存在，直接返回空表
  if not child then
    return {}
  end
  local result = {
    -- 核心逻辑：继承子组件的显示条件
    -- 这样当组件不显示时，多余的空格也不会显示
    condition = child.condition,
    child,
  }

  -- 默认添加 1 个空格，如果传入 0 则不添加
  local spaces = num_space or 1
  if spaces > 0 then
    for _ = 1, spaces do
      table.insert(result, M.Spacer)
    end
  end

  return result
end
M.Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%4l,%-3c %P",
}
M.ScrollBar = {
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = palette.yellow, bg = palette.base },
}

M.ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
  end,
  static = {
    mode_names = { -- change the strings if you like it vvvvverbose!
      n = "N",
      no = "N?",
      nov = "N?",
      noV = "N?",
      ["no\22"] = "N?",
      niI = "Ni",
      niR = "Nr",
      niV = "Nv",
      nt = "Nt",
      v = "V",
      vs = "Vs",
      V = "V_",
      Vs = "Vs",
      ["\22"] = "^V",
      ["\22s"] = "^V",
      s = "S",
      S = "S_",
      ["\19"] = "^S",
      i = "I",
      ic = "Ic",
      ix = "Ix",
      R = "R",
      Rc = "Rc",
      Rx = "Rx",
      Rv = "Rv",
      Rvc = "Rv",
      Rvx = "Rv",
      c = "C",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "T",
    },
    mode_colors = {
      n = palette.blue,
      nt = palette.blue,

      i = palette.green,
      v = palette.mauve,
      V = palette.mauve,
      ["\22"] = palette.mauve,
      c = palette.sky,
      s = palette.pink,
      S = palette.pink,
      ["\19"] = palette.pink,
      R = palette.peach,
      r = palette.peach,
      ["!"] = palette.red,
      t = palette.blue,
    },
  },
  provider = function(self)
    return " " .. "%1(" .. self.mode_names[self.mode] .. "%)" .. " ▍"
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1) -- get only the first mode character
    return { fg = palette.base, bg = self.mode_colors[mode], bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      pcall(function()
        vim.cmd("redrawstatus")
      end)
    end),
  },
}

M.Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = function(self)
    return { fg = self.has_changes and palette.maroon or dim_color }
  end,

  { -- git branch name
    provider = function(self)
      if self.has_changes then
        return "󰘬 " .. self.status_dict.head .. "*"
      else
        return "󰘬 " .. self.status_dict.head
      end
    end,
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = { fg = colors.git_add },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = { fg = colors.git_del },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = { fg = colors.git_change },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ")",
  },
  on_click = {
    name = "heirline_git",
    callback = function()
      ---@diagnostic disable-next-line: missing-fields
      Snacks.lazygit({ cwd = Snacks.git.get_root() })
    end,
  },
}

M.LSPActive = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },

  -- You can keep it simple,
  -- provider = " [LSP]",

  -- Or complicate things a bit and get the servers names
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      table.insert(names, server.name)
    end
    return " [" .. table.concat(names, " ") .. "]"
  end,
  hl = { fg = palette.green, bold = true },
}

-- M.LSPMessages = {
--   provider = require("lsp-status").status,
--   hl = { fg = "gray" },
-- }

M.Diagnostics = {
  condition = conditions.has_diagnostics,

  init = function(self)
    local diag_config = vim.diagnostic.config()

    -- 1. 解决第一个 Check Nil: 检查 diag_config 和 signs 是否存在且为 table
    local signs = {}
    if diag_config and type(diag_config.signs) == "table" then
      signs = diag_config.signs.text or {}
    end

    -- 2. 解决第二个 Check Nil: 访问索引时提供回退值
    self.error_icon = signs[vim.diagnostic.severity.ERROR] or "󰅚 "
    self.warn_icon = signs[vim.diagnostic.severity.WARN] or "󰀪 "
    self.info_icon = signs[vim.diagnostic.severity.INFO] or "󰋽 "
    self.hint_icon = signs[vim.diagnostic.severity.HINT] or "󰌶 "

    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { "DiagnosticChanged", "BufEnter" },

  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = { fg = colors.diag_error },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = { fg = colors.diag_warn },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = { fg = colors.diag_info },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = colors.diag_hint },
  },
  on_click = {
    name = "heirline_diagnostic",
    callback = function()
      Snacks.picker.diagnostics_buffer()
    end,
  },
} -- Diagnostics

local FileIcon = {
  init = function(self)
    local filename = vim.api.nvim_buf_get_name(0)
    -- 从 mini.icons 获取图标
    if _G.MiniIcons then
      self.icon, self.icon_hl, _ = MiniIcons.get("file", filename)
    end
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return self.icon_hl
  end,
}

local FileName = {
  provider = function()
    -- 获取相对路径文件名
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
    if filename == "" then
      return "[No Name]"
    end
    -- 如果文件名太长，可以进行缩减
    if not conditions.width_percent_below(#filename, 0.4) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  hl = { fg = palette.text, bold = true },
}

-- 3. 文件状态标记 (修改、只读)
local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = " ●", -- 或者使用加号 [+]
    hl = { fg = palette.green },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = " ",
    hl = { fg = palette.red },
  },
}

M.FileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  -- 组合图标、名字和标记
  FileIcon,
  FileName,
  FileFlags,
  -- 当鼠标悬停时显示完整路径
  on_click = {
    callback = function()
      print(vim.api.nvim_buf_get_name(0))
    end,
    name = "heirline_filename_click",
  },
}
return M
