return {
  settings = {
    Lua = {
      hint    = { enable = true },
      runtime = {
        version = 'LuaJIT',
        path    = { 'lua/?.lua', 'lua/?/init.lua' }
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath 'config',
          '/usr/share/hypr/stubs/',
        }
      },
      diagnostics = {
        globals = { 'vim', 'hl' }
      }
    }
  }
}
