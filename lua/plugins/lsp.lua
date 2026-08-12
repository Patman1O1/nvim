return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls", "pyright", "ruff",
        "vtsls", "eslint", "biome",
        "gopls", "rust_analyzer",
        "bashls", "cssls", "tailwindcss",
        "html", "jsonls", "yamlls", "dockerls", "taplo",
      },
      -- automatic_enable = true is the default; reads after/lsp/<name>.lua
    },
  },
}
