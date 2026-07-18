return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Automatically install these servers if not present
        ensure_installed = { "lua_ls", "ts_ls", "pyright" }, 
      })
    end,
}
