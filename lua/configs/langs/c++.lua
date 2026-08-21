return {
  ts_parser = "cpp",
  lsp_name = "clangd",
  setup_lsp = function()
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
      },
    })
    vim.lsp.enable("clangd")
  end,
}
