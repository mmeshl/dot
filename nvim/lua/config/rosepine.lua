vim.pack.add { github 'rose-pine/neovim' }

require('rose-pine').setup {
  highlight_groups = {
    Search                  = { bg = 'iris' },
    CurSearch               = { bg = 'iris', blend = 90 },
    IncSearch               = { bg = 'iris', blend = 90 },
    Visual                  = { bg = 'foam', blend = 15 },
    TelescopePromptTitle    = { bg = 'iris', fg = 'overlay' },
    TelescopePreviewTitle   = { bg = 'gold', fg = 'surface' },
    TelescopeResultsTitle   = { bg = 'rose', fg = 'surface' },
    TelescopePromptPrefix   = { fg = 'iris' },
    TelescopePromptNormal   = { bg = 'overlay' },
    TelescopePromptBorder   = { bg = 'overlay' },
    TelescopeSelection      = { bg = 'rose', blend = 20 },
    TelescopeSelectionCaret = { bg = 'rose', blend = 20 },
    MiniFilesBorder         = { fg = 'surface', bg = 'surface' },
    MiniFilesTitle          = { bg = 'iris', fg = 'overlay' },
    MiniFilesTitleFocused   = { bg = 'rose', fg = 'overlay' },
    MasonNormal             = { bg = 'overlay' },
    MasonHeader             = { bg = 'rose', fg = 'overlay' },
    MasonHighlightBlockBold = { bg = 'love' },
    MasonMutedBlock         = { bg = 'surface' },
    MasonHighlight          = { fg = 'rose' },
    MasonMuted              = { fg = 'base' },
  }
}

vim.cmd.colorscheme 'rose-pine'
