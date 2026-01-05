---@diagnostic disable: undefined-global
local components = require("config.heirline.components")
local palette = require("catppuccin.palettes").get_palette()

return {
  hl = { fg = palette.text, bg = palette.base },
  -- 1. 模式指示器 (带有右侧间距)
  components.RightPadding(components.ViMode, 1),

  -- 2. 文件信息 (图标 + 文件名 + 修改标记)
  components.RightPadding(components.FileNameBlock, 2),

  -- 3. Git 状态 (分支名 + 增删改统计)
  components.RightPadding(components.Git, 1),

  -- 4. 诊断信息 (错误、警告、提示图标)
  components.RightPadding(components.Diagnostics, 1),

  -- ==================== 中间部分 ====================
  components.Fill, -- 将左侧内容推向左边，右侧内容推向右边

  -- 如果你想在中间显示宏录制或正在运行的命令，可以放这里
  -- components.MacroRecording,

  components.Fill,

  -- ==================== 右侧部分 ====================
  -- 5. LSP 活动状态 (显示已连接的服务器名称)
  components.RightPadding(components.LSPActive, 1),

  -- 6. 标尺 (行:列 百分比)
  components.RightPadding(components.Ruler, 1),

  -- 7. 滚动条 (视觉化进度)
  components.ScrollBar,
}
