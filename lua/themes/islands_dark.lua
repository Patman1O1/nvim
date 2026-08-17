-- Islands Dark — ported from JetBrains "Islands Dark" (.icls)
local M = {}

M.base_30 = {
  white        = "#bcbec4",  -- DEFAULT_IDENTIFIER / TEXT fg
  black        = "#191a1c",  -- TEXT background / CONSOLE_BACKGROUND
  darker_black = "#141517",
  black2       = "#1f2024",  -- CARET_ROW_COLOR
  one_bg       = "#27282b",  -- DOCUMENTATION_COLOR / LOOKUP_COLOR
  one_bg2      = "#2b2d30",  -- DIFF_SEPARATORS_BACKGROUND
  one_bg3      = "#323438",  -- INDENT_GUIDE / RIGHT_MARGIN
  line          = "#27282b",
  grey          = "#4b5059",  -- LINE_NUMBERS_COLOR
  grey_fg       = "#6f737a",  -- WHITESPACES / NOT_USED_ELEMENT
  grey_fg2      = "#7a7e85",  -- DEFAULT_BLOCK_COMMENT / LINE_COMMENT
  light_grey    = "#8d9199",  -- ANNOTATIONS_COLOR
  red           = "#f75464",  -- BAD_CHARACTER / ERROR
  baby_pink     = "#fa6675",  -- ERRORS_ATTRIBUTES effect
  pink          = "#c77dbb",  -- DEFAULT_CONSTANT / INSTANCE_FIELD
  line_bg       = "#1f2024",
  vibrant_green = "#6aab73",  -- DEFAULT_STRING / CONSOLE_USER_INPUT
  green         = "#549159",  -- ADDED_LINES_COLOR
  nord_blue     = "#56a8f5",  -- DEFAULT_FUNCTION_DECLARATION
  blue          = "#548af7",  -- HYPERLINK / CTRL_CLICKABLE
  yellow        = "#d5b778",  -- HTML_TAG / XML_TAG
  sun           = "#e0bb65",  -- LOG_INFO_OUTPUT
  purple        = "#b189f5",  -- TEMPLATE_VARIABLE / FOLLOWED_HYPERLINK
  dark_purple   = "#9c9cff",  -- JS.JSX_CLIENT_COMPONENT
  teal          = "#2fbaa3",  -- HTML_CUSTOM_TAG / XML_CUSTOM_TAG
  orange        = "#cf8e6d",  -- DEFAULT_KEYWORD / DEFAULT_VALID_STRING_ESCAPE
  cyan          = "#2aacb8",  -- DEFAULT_NUMBER
  statusline_bg = "#1f2024",
  lightbg       = "#2b2d30",
  pmenu_bg      = "#56a8f5",
  folder_bg     = "#56a8f5",
}

M.base_16 = {
  base00 = "#191a1c",  -- Default Background
  base01 = "#1f2024",  -- Lighter Background (status bars, line numbers)
  base02 = "#2b2d30",  -- Selection Background
  base03 = "#7a7e85",  -- Comments, Invisibles
  base04 = "#8d9199",  -- Dark Foreground (status bars)
  base05 = "#bcbec4",  -- Default Foreground
  base06 = "#ced0d6",  -- Light Foreground (not often used)
  base07 = "#dfe1e5",  -- Light Background (not often used)
  base08 = "#f75464",  -- Variables, XML Tags, Markup Link Text → red/errors
  base09 = "#cf8e6d",  -- Integers, Boolean, Constants, XML Attributes → orange/keyword
  base0A = "#d5b778",  -- Classes, Markup Bold, Search Background → yellow (HTML tags)
  base0B = "#6aab73",  -- Strings, Inherited Class, Markup Code → green
  base0C = "#2aacb8",  -- Support, Regular Expressions, Escape → cyan/numbers
  base0D = "#56a8f5",  -- Functions, Methods, Attribute IDs → blue
  base0E = "#c77dbb",  -- Keywords, Storage, Selector, Markup Italic → pink/purple
  base0F = "#b189f5",  -- Deprecated, Opening/Closing Embedded Language Tags → purple
}

M.type = "dark"

return M
