-- Derived from Microsoft VS Code's current Dark 2026 theme:
-- extensions/theme-defaults/themes/2026-dark.json
--
-- VS Code's TextMate and semantic scopes do not map one-to-one to Neovim, so
-- this translates the official UI and syntax colours to their closest Vim,
-- Tree-sitter, and LSP highlight groups.

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "vscode-dark-2026"

local c = {
  bg = "#121314",
  panel = "#191a1b",
  menu = "#202122",
  line = "#242526",
  widget = "#262728",
  selection = "#276782",
  border = "#2a2b2c",
  border_alt = "#333536",
  fg = "#bbbebf",
  variable = "#c9d1d9",
  dim = "#8c8c8c",
  muted = "#555555",
  white = "#ededed",
  accent = "#3994bc",
  link = "#48a0c7",
  comment = "#8b949e",
  red = "#ff7b72",
  red_bright = "#ffa198",
  green = "#7ee787",
  yellow = "#ffa657",
  warning = "#e5ba7d",
  blue = "#79c0ff",
  purple = "#d2a8ff",
  teal = "#4ec9b0",
  string = "#a5d6ff",
  error = "#f48771",
  info = "#6796e6",
}

local function hl(group, spec) vim.api.nvim_set_hl(0, group, spec) end
local function fg(group, color, extra)
  extra = extra or {}
  extra.fg = color
  hl(group, extra)
end

hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalNC", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.menu })
hl("FloatBorder", { fg = c.border_alt, bg = c.menu })
hl("FloatTitle", { fg = c.fg, bg = c.menu, bold = true })
hl("ColorColumn", { bg = c.line })
hl("CursorLine", { bg = c.line })
hl("CursorColumn", { bg = c.line })
hl("CursorLineNr", { fg = c.fg, bg = c.line, bold = true })
hl("LineNr", { fg = c.dim })
hl("SignColumn", { fg = c.dim, bg = c.bg })
hl("FoldColumn", { fg = c.dim, bg = c.bg })
hl("Folded", { fg = c.dim, bg = c.panel })
hl("Visual", { bg = c.selection })
hl("Search", { fg = c.white, bg = c.selection })
hl("IncSearch", { fg = c.white, bg = c.accent })
hl("CurSearch", { fg = c.white, bg = c.accent })
hl("MatchParen", { fg = c.fg, bg = c.accent, bold = true })
hl("Pmenu", { fg = c.fg, bg = c.menu })
hl("PmenuSel", { fg = c.white, bg = c.accent })
hl("PmenuSbar", { bg = c.panel })
hl("PmenuThumb", { bg = c.dim })
hl("StatusLine", { fg = c.dim, bg = c.panel })
hl("StatusLineNC", { fg = c.muted, bg = c.panel })
hl("WinSeparator", { fg = c.border })
hl("VertSplit", { fg = c.border })
hl("TabLine", { fg = c.dim, bg = c.panel })
hl("TabLineSel", { fg = c.fg, bg = c.bg })
hl("TabLineFill", { bg = c.panel })
hl("Directory", { fg = c.blue })
hl("Title", { fg = c.fg, bold = true })
hl("Question", { fg = c.green })
hl("NonText", { fg = c.muted })
hl("Whitespace", { fg = c.muted })
hl("SpecialKey", { fg = c.muted })

fg("Comment", c.comment)
fg("Constant", c.blue)
fg("String", c.string)
fg("Character", c.red)
fg("Number", c.blue)
fg("Boolean", c.blue)
fg("Float", c.blue)
fg("Identifier", c.variable)
fg("Function", c.purple)
fg("Statement", c.red)
fg("Conditional", c.red)
fg("Repeat", c.red)
fg("Label", c.red)
fg("Operator", c.red)
fg("Keyword", c.red)
fg("Exception", c.red)
fg("PreProc", c.red)
fg("Include", c.variable)
fg("Define", c.red)
fg("Macro", c.link)
fg("PreCondit", c.red)
fg("Type", c.teal)
fg("StorageClass", c.red)
fg("Structure", c.teal)
fg("Typedef", c.teal)
fg("Special", c.yellow)
fg("SpecialComment", c.comment)
fg("Error", c.error)
fg("Todo", c.yellow, { bold = true })

fg("DiagnosticError", c.error)
fg("DiagnosticWarn", c.warning)
fg("DiagnosticInfo", c.info)
fg("DiagnosticHint", c.accent)
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warning })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.accent })

fg("DiffAdd", c.green, { bg = "#04260f" })
fg("DiffChange", c.yellow, { bg = "#5a1e02" })
fg("DiffDelete", c.red_bright, { bg = "#490202" })
fg("diffAdded", c.green)
fg("diffChanged", c.yellow)
fg("diffRemoved", c.red_bright)

local treesitter = {
  ["@comment"] = c.comment,
  ["@constant"] = c.blue,
  ["@constant.builtin"] = c.blue,
  ["@string"] = c.string,
  ["@string.escape"] = c.green,
  ["@string.regexp"] = c.string,
  ["@character"] = c.red,
  ["@number"] = c.blue,
  ["@boolean"] = c.blue,
  ["@variable"] = c.variable,
  ["@variable.parameter"] = c.variable,
  ["@variable.member"] = c.blue,
  ["@function"] = c.purple,
  ["@function.call"] = c.purple,
  ["@function.method"] = c.purple,
  ["@function.method.call"] = c.purple,
  ["@function.builtin"] = c.blue,
  ["@keyword"] = c.red,
  ["@keyword.import"] = c.variable,
  ["@keyword.return"] = c.red,
  ["@operator"] = c.red,
  ["@type"] = c.teal,
  ["@type.builtin"] = c.teal,
  ["@constructor"] = c.teal,
  ["@property"] = c.blue,
  ["@field"] = c.blue,
  ["@attribute"] = c.blue,
  ["@tag"] = c.green,
  ["@tag.attribute"] = c.blue,
  ["@markup.heading"] = c.blue,
  ["@markup.link.url"] = c.string,
  ["@markup.quote"] = c.green,
}
for group, color in pairs(treesitter) do fg(group, color) end

local lsp = {
  ["@lsp.type.variable"] = c.variable,
  ["@lsp.type.parameter"] = c.variable,
  ["@lsp.type.property"] = c.blue,
  ["@lsp.type.function"] = c.purple,
  ["@lsp.type.method"] = c.purple,
  ["@lsp.type.class"] = c.teal,
  ["@lsp.type.interface"] = c.teal,
  ["@lsp.type.struct"] = c.teal,
  ["@lsp.type.enum"] = c.teal,
  ["@lsp.type.enumMember"] = c.blue,
  ["@lsp.type.namespace"] = c.teal,
  ["@lsp.type.typeParameter"] = c.teal,
  ["@lsp.type.macro"] = c.link,
  ["@lsp.type.decorator"] = c.blue,
  ["@lsp.type.keyword"] = c.red,
  ["@lsp.type.string"] = c.string,
  ["@lsp.type.number"] = c.blue,
}
for group, color in pairs(lsp) do fg(group, color) end

fg("GitSignsAdd", c.green)
fg("GitSignsChange", c.yellow)
fg("GitSignsDelete", c.red_bright)
fg("TelescopeBorder", c.border_alt)
fg("TelescopeSelection", c.fg, { bg = c.line })
fg("TelescopeMatching", c.link, { bold = true })

vim.g.terminal_color_0 = c.panel
vim.g.terminal_color_1 = c.red
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_5 = c.purple
vim.g.terminal_color_6 = c.teal
vim.g.terminal_color_7 = c.fg
vim.g.terminal_color_8 = c.muted
vim.g.terminal_color_9 = c.red_bright
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.warning
vim.g.terminal_color_12 = c.string
vim.g.terminal_color_13 = "#b267e6"
vim.g.terminal_color_14 = c.link
vim.g.terminal_color_15 = c.white
