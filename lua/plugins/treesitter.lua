return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed =
      vim.list_extend(opts.ensure_installed or {}, require("configs.lspconfig").ts_parsers())
    opts.highlight = { enable = true }
    opts.indent = { enable = true }
    return opts
  end,
}
