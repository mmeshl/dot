vim.api.nvim_create_autocmd('VimEnter', {
  desc     = 'Open Oil when Vim is opened with an unnamed buffer',
  group    = vim.api.nvim_create_augroup('StartupDir', { clear = true }),
  once     = true,
  callback = function (ev)
    if #vim.api.nvim_buf_get_name(ev.buf) == 0 then
      vim.schedule(vim.cmd.Oil)
    end
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

    local fn = ({
      ['telescope-fzf-native'] = function ()
        print 'Building telescope-fzf-native...'
        vim.system({ 'make' }, { cwd = ev.data.path })
      end,
      ['nvim-treesitter'] = function ()
        print 'Updating treesitter parsers...'
        vim.cmd.TSUpdate()
      end
    })[ev.data.spec.name]

    if fn then fn() end
  end
})

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
