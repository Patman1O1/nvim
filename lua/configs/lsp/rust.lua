return {
  ts_parser = "rust",
  lsp_name = "rust_analyzer",
  setup_lsp = function()
    vim.lsp.config("rust_analyzer", {
      cmd = { "rust-analyzer" },
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = true,
          cargo = { allFeatures = true },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")
  end,
}
