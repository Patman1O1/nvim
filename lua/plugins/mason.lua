return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
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
    "mason-org/mason-lspconfig.nvim",
    event = "User FilePost",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      require("configs.lspconfig").setup()
    end,
    opts = function()
      return {
        ensure_installed = require("configs.lspconfig").mason_servers(),
        automatic_enable = false,
      }
    end,
  },
}
