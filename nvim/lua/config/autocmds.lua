vim.api.nvim_create_autocmd('VimEnter', {
  desc     = 'Open oil when no arguments are specified',
  group    = vim.api.nvim_create_augroup('StartupDir', { clear = true }),
  once     = true,
  callback = function (_)
    if vim.fn.argc() ~= 0 then return end
    vim.schedule(vim.cmd.Oil)
  end
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc     = 'Highlight text after yank',
  group    = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function (_) vim.hl.on_yank { timeout = 100 } end
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
  desc     = 'Configure CmdWin',
  group    = vim.api.nvim_create_augroup('ConfigCmdWin', { clear = true }),
  callback = function (_)
    vim.wo[0][0].colorcolumn = ''
    vim.cmd.startinsert()
  end
})

vim.api.nvim_create_autocmd('PackChanged', {
  desc     = 'Plugin post-install build hook',
  group    = vim.api.nvim_create_augroup('PluginBuildHook', { clear = true }),
  callback = function (ev)
    if ev.data.kind ~= 'update' and ev.data.kind ~= 'install' then return end

    if ev.data.spec.name == 'telescope-fzf-native.nvim' then
      vim.system({ 'make' }, { cwd = ev.data.path })
    elseif ev.data.spec.name == 'nvim-treesitter' then
      vim.cmd.TSUpdate()
    elseif ev.data.spec.name == 'blink.cmp' then
      vim.system({ 'cargo', 'build', '--release' }, { cwd = ev.data.path })
    end
  end
})

do -- Macro notifications
  local group = vim.api.nvim_create_augroup('MacroNotify', { clear = true })

  vim.api.nvim_create_autocmd('RecordingEnter', {
    desc     = 'Notify on macro record start',
    group    = group,
    callback = function (_)
      vim.notify('Started recording macro to register @' .. vim.fn.reg_recording())
    end
  })

  vim.api.nvim_create_autocmd('RecordingLeave', {
    desc     = 'Notify on macro record stop',
    group    = group,
    callback = function (_)
      vim.notify('Stopped recording macro to register @' .. vim.fn.reg_recording())
    end
  })
end

do -- Auto setup treesitter parsers
  local function search_list(list, value)
    for _, val in ipairs(list) do
      if val == value then return true end
    end
    return false
  end

  vim.api.nvim_create_autocmd('FileType', {
    desc     = 'Automatically install and configure TreeSitter parsers',
    group    = vim.api.nvim_create_augroup('TSParserSetup', { clear = true }),
    callback = function (ev)
      local ts   = require 'nvim-treesitter'
      local lang = vim.treesitter.language.get_lang(ev.match)

      -- Check if parser is installed
      if not search_list(ts.get_installed(), lang) then
        -- Try to install it
        if not search_list(ts.get_available(), lang) then return end
        -- FIXME: This should be asynchronous
        vim.schedule(function ()
          ts.install(lang, { summary = true }):wait(300000)
          vim.treesitter.start(ev.buf, lang)
        end)
      else
        vim.treesitter.start(ev.buf, lang)
      end

      vim.wo[0][0].foldexpr   = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldlevel  = 99
    end
  })
end

vim.api.nvim_create_autocmd('TermOpen', {
  group    = vim.api.nvim_create_augroup('ConfigTerm', { clear = true }),
  callback = function (_)
    vim.cmd.startinsert()
  end
})
