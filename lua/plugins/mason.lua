local langs = require("configs.langs")

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Pass the dynamically collected LSP names from your language files
      ensure_installed = langs.lsp_names,
      -- Automatically install missing servers when Neovim starts up
      automatic_installation = true,
    },
  },
}
