-- lua/configs/lsp.lua
local M = {
  ts_parsers = { "vim", "vimdoc" }, -- base defaults
  lsps = {},
}

-- Target directory path
local lsp_dir = vim.fn.stdpath("config") .. "/lua/configs/lsp"

-- Scan all .lua files inside lua/configs/lsp/
local handle = vim.uv.fs_scandir(lsp_dir)
if handle then
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if type == "file" and name:sub(-4) == ".lua" then
      local mod_name = name:sub(1, -5)
      local lsp = require("configs.lsp." .. mod_name)

      -- Collect Treesitter parsers
      if lsp.ts_parser then
        table.insert(M.ts_parsers, lsp.ts_parser)
      end

      -- Collect LSP initializers
      if lsp.setup_lsp then
        table.insert(M.lsps, lsp.setup_lsp)
      end
    end
  end
end

return M
