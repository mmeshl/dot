local sev = vim.diagnostic.severity

vim.diagnostic.config {
  severity_sort = true,
  signs = {
    text = {
      [sev.ERROR] = '',
      [sev.WARN]  = '',
      [sev.HINT]  = '󰌶',
      [sev.INFO]  = ''
    },
  }
}
