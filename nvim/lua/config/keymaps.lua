--- Wrapper around `vim.keymap.set()`
--- @param keys   string
--- @param action string|function
--- @param desc   string?
--- @param modes  string|string[]?
--- @param buf    number?
local function setk(keys, action, desc, modes, buf)
  local opts = { desc = desc, silent = true }
  if buf ~= nil then opts.buffer = buf end
  vim.keymap.set(modes or 'n', keys, action, opts)
end

--- Append '<Leader>' to keys
--- @param  keys string
---
--- @return string
local function ld(keys)
  return '<Leader>' .. keys
end

setk('<Esc>', vim.cmd.nohlsearch, 'Clear search highlights')
setk(ld 'rs', vim.cmd.restart, 'Restart neovim')

setk('j', 'gj')
setk('k', 'gk')

setk('J', 'mzJ`z', 'Join next line without moving cursor')
setk('<C-d>', '<C-d>zz', 'Move down and center cursor')
setk('<C-u>', '<C-u>zz', 'Move up and center cursor')
setk('n', 'nzzzv', 'Goto next result and center cursor')
setk('N', 'Nzzzv', 'Goto prev result and center cursor')

setk('<', '<gv', 'Shift left, maintaining selection', 'x')
setk('>', '>gv', 'Shift right, maintaining selection', 'x')

setk(ld 'p', '"+p', 'Paste from system clipboard', { 'n', 'x' })
setk(ld 'P', '"+P', 'Paste from system clipboard', 'n')
setk(ld 'y', '"+y', 'Copy to system clipboard', { 'n', 'x' })

setk('<C-h>', function () vim.cmd.wincmd 'h' end, 'Focus left')
setk('<C-j>', function () vim.cmd.wincmd 'j' end, 'Focus down')
setk('<C-k>', function () vim.cmd.wincmd 'k' end, 'Focus up')
setk('<C-l>', function () vim.cmd.wincmd 'l' end, 'Focus right')

setk('<C-down>', function () vim.cmd.resize '-5' end, 'Resize down')
setk('<C-up>', function () vim.cmd.resize '+5' end, 'Resize up')
setk('<C-left>', function ()
  vim.cmd.resize { args = { '-5' }, mods = { vertical = true } }
end, 'Resize left')
setk('<C-right>', function ()
  vim.cmd.resize { args = { '+5' }, mods = { vertical = true } }
end, 'Resize right')

setk('<C-l>', '<Del>', 'Delete in insert', 'i')

setk(ld 'o', function ()
  vim.fn.append(vim.fn.line('.'), vim.fn['repeat']({''}, vim.v.count1))
end, 'Insert lines below')
setk(ld 'O', function ()
  vim.fn.append(vim.fn.line('.') - 1, vim.fn['repeat']({''}, vim.v.count1))
end, 'Insert lines above')

setk(ld 'ti', function()
  vim.bo.shiftwidth = (vim.bo.shiftwidth * 2) % 14
  vim.notify('Set shiftwidth to ' .. vim.bo.shiftwidth .. ' spaces')
end, 'Cycle buffer shiftwidth between 2, 4, and 8')

setk(ld 'pwd', function () vim.notify(vim.fn.getcwd()) end, 'Get the CWD')

setk('-', vim.cmd.Oil, 'Open parent directory in Oil')
setk(ld 'mf', require('mini.files').open, 'Open Mini files')

do -- Builtin Telescope keymaps

  --- Get Telescope picker with the given name
  --- @param name string
  ---
  --- @return function
  local function tsb(name)
    return require('telescope.builtin')[name]
  end

  setk(ld 'sf', tsb 'find_files', '[S]earch [F]iles')
  setk(ld 'sw', tsb 'grep_string', '[S]earch [W]ord')
  setk(ld 'sg', tsb 'live_grep', '[S]earch [G]rep')
  setk(ld 'sb', tsb 'buffers', '[S]earch [B]uffers')
  setk(ld 'shh', tsb 'help_tags', '[S]earch [H]elp')
  setk(ld 'smp', tsb 'man_pages', '[S]earch [M]an [P]ages')
  setk(ld 'smm', tsb 'marks', '[S]earch [M]arks')
  setk(ld 'sq', tsb 'quickfix', '[S]earch [Q]quickfix')
  setk(ld 'sj', tsb 'jumplist', '[S]earch [J]umplist')
  setk(ld 'srg', tsb 'registers', '[S]earch [R]e[g]isters')
  setk(ld 'shl', tsb 'highlights', '[S]earch [H]igh[l]ights')
  setk(ld 'sk', tsb 'keymaps', '[S]earch [K]eymaps')
  setk(ld 'sd', tsb 'diagnostics', '[S]earch [D]iagnostics')
  setk(ld 'stb', tsb 'builtin', '[S]earch [T]elescope [B]uiltin')
  setk(ld 'sru', tsb 'resume', '[S]earch [R]es[u]me')

  vim.api.nvim_create_autocmd('LspAttach', {
    desc     = 'Set LSP keymaps',
    group    = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
    callback = function (ev)

      --- Set a keymap in `ev.buf`
      --- @param keys   string
      --- @param action string|function
      --- @param desc   string?
      local function setlsk(keys, action, desc)
        setk(keys, action, desc, 'n', ev.buf)
      end

      setlsk('gd', tsb 'lsp_definitions', '[G]oto [D]efinition(s)')
      setlsk('gr', tsb 'lsp_references', '[G]oto [R]eferences')
      setlsk('gI', tsb 'lsp_implementations', '[G]oto [I]mplementation(s)')
      setlsk(ld 'td', tsb 'lsp_type_definitions', '[T]ype [D]efinition(s)')
      setlsk(ld 'ds', tsb 'lsp_document_symbols', '[D]ocument [S]ymbols')
      setlsk(ld 'ws', tsb 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')
      setlsk(ld 'rn', vim.lsp.buf.rename, '[R]e[n]ame')
      setlsk(ld 'ca', vim.lsp.buf.code_action, '[C]ode [A]ction(s)')

      setlsk(ld 'th', function ()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, '[T]oggle inlay [H]ints')
    end
  })
end

do -- Trouble keymaps

  --- Get trouble mode function
  --- @param mode string
  ---
  --- @return function
  local function tr(mode)
    return function () require('trouble').toggle(mode) end
  end

  setk(ld 'tr', tr 'diagnostics', 'Toggle [T]rouble [D]iagnostics')
  setk(ld 'ts', tr 'lsp_document_symbols', 'Toggle [T]rouble document [S]ymbols')
end

setk(ld 'mls', vim.cmd.Mason, 'Open Mason')
