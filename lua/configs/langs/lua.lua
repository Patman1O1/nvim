return {
  ts_parser = "lua",
  lsp_name = "lua_ls",
  setup_lsp = function()
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end,
}
