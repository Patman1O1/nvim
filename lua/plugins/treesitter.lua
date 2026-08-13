local langs = require("configs.langs")

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = langs.ts_parsers,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
