local lsps = require("configs.lsp")

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = lsps.ts_parsers,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
