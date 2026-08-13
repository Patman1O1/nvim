local langs = require("configs.langs")

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local nvlsp = require("nvchad.configs.lspconfig")

    -- Attach global defaults/capabilities
    vim.lsp.config("*", {
      root_markers = { ".git" },
      capabilities = nvlsp.capabilities,
    })

    -- Run native setup for each server
    for _, setup in ipairs(langs.lsps) do
      setup()
    end
  end,
}
