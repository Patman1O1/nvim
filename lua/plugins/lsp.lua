-- nvim/lua/plugins/lsp.lua
return {
  -- Mason core (repo moved to mason-org; williamboman still redirects)
  { "mason-org/mason.nvim", opts = {} },

  -- Mason <-> LSP bridge: installs AND auto-enables the real LSP servers.
  -- NOTE (v2): there is NO setup_handlers()/handlers mechanism anymore.
  -- Per-server config lives in after/lsp/<name>.lua; enabling is automatic.
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- NOTE: these are lspconfig SERVER names, not Mason package names
      ensure_installed = {
        "lua_ls", "pyright", "ruff",
        "vtsls", "eslint", "biome",
        "gopls", "rust_analyzer",
        "bashls", "cssls", "tailwindcss", "html",
        "jsonls", "yamlls", "dockerls", "taplo",
      },
      -- automatic_enable = true is the DEFAULT — it runs vim.lsp.enable()
      -- for each installed server, so you don't list these yourself.
    },
  },

  -- Autocompletion + the bits mason-lspconfig doesn't cover
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }),
      })

      -- Completion capabilities for EVERY server
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })

      -- Servers mason-lspconfig can't auto-enable (not installed via Mason):
      --   clangd        -> system package manager (no ARM64 Mason binary)
      --   stylua        -> a formatter package, not an lspconfig server
      --   oxlint/oxfmt  -> installed via pnpm, not Mason
      vim.lsp.enable({ "clangd", "stylua", "oxlint", "oxfmt" })
    end,
  },
}
