local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets", "nvim-mini/mini.icons" },

    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-N>"] = { "select_next", "show" },
        ["<C-P>"] = { "select_prev", "show" },
        ["<C-J>"] = { "select_next", "fallback" },
        ["<C-K>"] = { "select_prev", "fallback" },
        ["<C-U>"] = { "scroll_documentation_up", "fallback" },
        ["<C-D>"] = { "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          function(cmp)
            if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          function(cmp)
            if vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        list = {
          selection = {
            preselect = false,
          },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  {
    -- ==================== mini.icons 配置（独立 spec） ====================
    {
      "nvim-mini/mini.icons",
      lazy = true,
      optional = true,
      opts = {
        lsp = {
          -- ==================== 简约风格 ====================
          array = { glyph = "" },
          boolean = { glyph = "󰨙" },
          class = { glyph = "" },
          color = { glyph = "" },
          constant = { glyph = "" },
          constructor = { glyph = "" },
          enum = { glyph = "" },
          enummember = { glyph = "" },
          event = { glyph = "" },
          field = { glyph = "" },
          file = { glyph = "" },
          folder = { glyph = "" },
          ["function"] = { glyph = "" },
          interface = { glyph = "" },
          key = { glyph = "" },
          keyword = { glyph = "" },
          method = { glyph = "" },
          module = { glyph = "" },
          namespace = { glyph = "" },
          null = { glyph = "" },
          number = { glyph = "" },
          object = { glyph = "" },
          operator = { glyph = "" },
          package = { glyph = "" },
          property = { glyph = "" },
          reference = { glyph = "" },
          snippet = { glyph = "" },
          string = { glyph = "" },
          struct = { glyph = "" },
          text = { glyph = "" },
          typeparameter = { glyph = "" },
          unit = { glyph = "" },
          value = { glyph = "" },
          variable = { glyph = "" },

          -- Go 语言常用额外覆盖
          NewCond = { glyph = "" },
          OnceFunc = { glyph = "" },
          OnceValue = { glyph = "" },

          -- ==================== LSPkind风格 ====================
          -- array         = { glyph = "" },     -- 数组
          -- boolean       = { glyph = "󰨙" },     -- 布尔值
          -- class         = { glyph = "󰠱" },     -- 类
          -- color         = { glyph = "󰏘" },     -- 颜色
          -- constant      = { glyph = "󰏿" },     -- 常量
          -- constructor   = { glyph = "" },     -- 构造函数
          -- enum          = { glyph = "" },     -- 枚举
          -- enummember    = { glyph = "" },     -- 枚举成员
          -- event         = { glyph = "" },     -- 事件
          -- field         = { glyph = "󰜢" },     -- 字段
          -- ["function"]  = { glyph = "󰊕" },     -- 函数（OnceFunc 等常用）
          -- interface     = { glyph = "" },     -- 接口
          -- keyword       = { glyph = "󰌋" },     -- 关键字
          -- method        = { glyph = "󰆧" },     -- 方法
          -- module        = { glyph = "" },     -- 模块
          -- namespace     = { glyph = "󰦮" },     -- 命名空间
          -- property      = { glyph = "󰜢" },     -- 属性
          -- reference     = { glyph = "󰈇" },     -- 引用
          -- snippet       = { glyph = "" },     -- 代码片段
          -- struct        = { glyph = "󰙅" },     -- 结构体（sync.Cond、sync.Mutex、sync.Map、sync.Pool 等 Go 常用）
          -- text          = { glyph = "󰉿" },     -- 文本
          -- typeparameter = { glyph = "󰊄" },     -- 类型参数
          -- unit          = { glyph = "󰑭" },     -- 单位
          -- value         = { glyph = "󰎠" },     -- 值（OnceValue 等）
          -- variable      = { glyph = "󰀫" },     -- 变量
          --
          -- Go 语言特定覆盖
          -- NewCond       = { glyph = "󰙅" },     -- NewCond（通常属于 struct）
          -- OnceFunc      = { glyph = "󰊕" },     -- OnceFunc（通常属于 function）
        },
      },
    },
  },
}
