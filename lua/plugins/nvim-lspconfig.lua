return {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp" -- Connects LSP to autocomplete
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps to trigger when an LSP connects to a file
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)      -- Go to definition
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)           -- Show documentation
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)     -- Find references
        end,
      })

      -- Set up servers using mason-lspconfig's handler
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
      })
    end,
}
