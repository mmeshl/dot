vim.schedule(function ()
  require('trouble').setup {
    warn_no_results = false,
    open_no_results = true,
    modes = {
      lsp_document_symbols = {
        win = { position = 'right' }
      }
    }
  }
end)
