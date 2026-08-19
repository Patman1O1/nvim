-- Islands Dark
---@type Base46Table
local M = {}

-- UI
M.base_30 = {
  white         = "#CED0D6", -- CARET_COLOR / ANNOTATIONS_LAST_COMMIT_COLOR
  black         = "#191A1C", -- TEXT background (CONSOLE_BACKGROUND_KEY)
  darker_black  = "#111315", -- ~6% darker than black
  black2        = "#1F2024", -- CARET_ROW_COLOR (~6% lighter than black)
  one_bg        = "#27282B", -- DOCUMENTATION_COLOR / LOOKUP_COLOR
  one_bg2       = "#2B2D30", -- DIFF_SEPARATORS_BACKGROUND / INFORMATION_HINT
  one_bg3       = "#313438", -- ~6% lighter than one_bg2
  grey          = "#4B5059", -- LINE_NUMBERS_COLOR
  grey_fg       = "#6F737A", -- WHITESPACES / BREADCRUMBS_INACTIVE
  grey_fg2      = "#868A91", -- ANNOTATIONS_COLOR / INLAY_DEFAULT fg
  light_grey    = "#9DA0A8", -- BREADCRUMBS_DEFAULT / LIVE_TEMPLATE_INACTIVE_SEGMENT
  red           = "#F75464", -- BAD_CHARACTER / CONSOLE_ERROR_OUTPUT / LOG_ERROR_OUTPUT
  baby_pink     = "#E88F89", -- FILESTATUS_UNKNOWN
  pink          = "#FA7DB1", -- WRITE_SEARCH_RESULT error stripe
  line          = "#2B2D30", -- FOLDED_TEXT_BORDER_COLOR (~15% lighter than black)
  green         = "#6AAB73", -- DEFAULT_STRING / CONSOLE_USER_INPUT
  vibrant_green = "#73BD79", -- FILESTATUS_ADDED / FILESTATUS_COPIED
  nord_blue     = "#56A8F5", -- DEFAULT_FUNCTION_DECLARATION / CSS.COLOR
  blue          = "#548AF7", -- CTRL_CLICKABLE / HYPERLINK_ATTRIBUTES
  seablue       = "#375FAD", -- MODIFIED_LINES_COLOR / IGNORED_MODIFIED_LINES_BORDER_COLOR
  yellow        = "#D5B778", -- HTML_TAG / XML_TAG
  sun           = "#E0BB65", -- LOG_INFO_OUTPUT
  purple        = "#C77DBB", -- DEFAULT_CONSTANT / DEFAULT_INSTANCE_FIELD
  dark_purple   = "#B189F5", -- TEMPLATE_VARIABLE_ATTRIBUTES / FOLLOWED_HYPERLINK
  teal          = "#2AACB8", -- DEFAULT_NUMBER
  orange        = "#CF8E6D", -- DEFAULT_KEYWORD / DEFAULT_VALID_STRING_ESCAPE
  cyan          = "#2FBAA3", -- HTML_CUSTOM_TAG_NAME / XML_CUSTOM_TAG_NAME
  statusline_bg = "#1F2024", -- CARET_ROW_COLOR, slightly lifted from black
  lightbg       = "#2B2D30", -- FOLDED_TEXT_ATTRIBUTES bg / INLAY bg
  pmenu_bg      = "#56A8F5", -- function blue, used as pmenu accent
  folder_bg     = "#548AF7", -- CTRL_CLICKABLE blue
}

-- Base16 — syntax highlighting palette
-- https://github.com/chriskempson/base16/blob/master/styling.md
M.base_16 = {
  base00 = "#191A1C", -- Default Background           (TEXT bg)
  base01 = "#1F2024", -- Lighter Background            (caret row / status areas)
  base02 = "#2B2D30", -- Selection Background          (DIFF_SEPARATORS / folded text bg)
  base03 = "#7A7E85", -- Comments                      (DEFAULT_LINE_COMMENT / DEFAULT_BLOCK_COMMENT)
  base04 = "#868A91", -- Dark Foreground / line nums   (INLAY_DEFAULT fg)
  base05 = "#BCBEC4", -- Default Foreground            (DEFAULT_IDENTIFIER / TEXT fg)
  base06 = "#CED0D6", -- Light Foreground              (CARET_COLOR / doc code fg)
  base07 = "#DFE1E5", -- Light Background              (BREADCRUMBS_CURRENT fg)
  base08 = "#F75464", -- Variables / red accent        (BAD_CHARACTER / ERRORS)
  base09 = "#CF8E6D", -- Integers / orange             (DEFAULT_KEYWORD / DEFAULT_NUMBER alt)
  base0A = "#B3AE60", -- Classes / yellow-green        (DEFAULT_METADATA / REGEXP.CHAR_CLASS)
  base0B = "#6AAB73", -- Strings / green               (DEFAULT_STRING)
  base0C = "#2AACB8", -- Support / cyan                (DEFAULT_NUMBER)
  base0D = "#56A8F5", -- Functions / blue              (DEFAULT_FUNCTION_DECLARATION)
  base0E = "#C77DBB", -- Keywords / purple             (DEFAULT_CONSTANT / DEFAULT_INSTANCE_FIELD)
  base0F = "#16BAAC", -- Deprecated / teal             (TYPE_PARAMETER_NAME_ATTRIBUTES)
}

-- Optional per-theme highlight overrides
M.polish_hl = {
  defaults = {
    Comment = {
      fg = "#7A7E85", -- DEFAULT_LINE_COMMENT
      italic = true,
    },
    Keyword = {
      fg = "#CF8E6D", -- DEFAULT_KEYWORD
    },
    Constant = {
      fg = "#C77DBB", -- DEFAULT_CONSTANT
      italic = true,
    },
    String = {
      fg = "#6AAB73", -- DEFAULT_STRING
    },
    Number = {
      fg = "#2AACB8", -- DEFAULT_NUMBER
    },
    Type = {
      fg = "#16BAAC", -- TYPE_PARAMETER_NAME_ATTRIBUTES
    },
    Function = {
      fg = "#56A8F5", -- DEFAULT_FUNCTION_DECLARATION
    },
    Todo = {
      fg = "#8BB33D", -- TODO_DEFAULT_ATTRIBUTES
      bold = true,
    },
  },
  treesitter = {
    ["@keyword"]          = { fg = "#CF8E6D" }, -- DEFAULT_KEYWORD
    ["@string"]           = { fg = "#6AAB73" }, -- DEFAULT_STRING
    ["@string.escape"]    = { fg = "#CF8E6D" }, -- DEFAULT_VALID_STRING_ESCAPE
    ["@number"]           = { fg = "#2AACB8" }, -- DEFAULT_NUMBER
    ["@constant"]         = { fg = "#C77DBB", italic = true }, -- DEFAULT_CONSTANT
    ["@function"]         = { fg = "#56A8F5" }, -- DEFAULT_FUNCTION_DECLARATION
    ["@function.call"]    = { fg = "#56A8F5" }, -- DEFAULT_FUNCTION_CALL
    ["@function.method"]  = { fg = "#57AAF7" }, -- DEFAULT_INSTANCE_METHOD
    ["@variable"]         = { fg = "#BCBEC4" }, -- DEFAULT_IDENTIFIER
    ["@field"]            = { fg = "#C77DBB" }, -- DEFAULT_INSTANCE_FIELD
    ["@property"]         = { fg = "#C77DBB" }, -- DEFAULT_INSTANCE_FIELD
    ["@type"]             = { fg = "#16BAAC" }, -- TYPE_PARAMETER_NAME_ATTRIBUTES
    ["@type.builtin"]     = { fg = "#CF8E6D" }, -- keyword-colored builtins
    ["@comment"]          = { fg = "#7A7E85", italic = true },
    ["@punctuation"]      = { fg = "#BCBEC4" }, -- DEFAULT_BRACES / DEFAULT_COMMA etc.
    ["@tag"]              = { fg = "#D5B778" }, -- HTML_TAG / XML_TAG
    ["@tag.attribute"]    = { fg = "#BCBEC4" }, -- XML_ATTRIBUTE_NAME
    ["@tag.delimiter"]    = { fg = "#D5B778" },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "islands_dark")
return M
