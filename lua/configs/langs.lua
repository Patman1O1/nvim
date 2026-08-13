-- lua/configs/languages.lua
local M = {
  ts_parsers = { "vim", "vimdoc" }, -- base defaults
  lsps = {},
}

-- Target directory path
local lang_dir = vim.fn.stdpath("config") .. "/lua/configs/langs"

-- Scan all .lua files inside lua/configs/languages/
local handle = vim.uv.fs_scandir(lang_dir)
if handle then
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if type == "file" and name:sub(-4) == ".lua" then
      local mod_name = name:sub(1, -5)
      local lang = require("configs.langs." .. mod_name)

      -- Collect Treesitter parsers
      if lang.ts_parser then
        table.insert(M.ts_parsers, lang.ts_parser)
      end

      -- Collect LSP initializers
      if lang.setup_lsp then
        table.insert(M.lsps, lang.setup_lsp)
      end
    end
  end
end

return M
