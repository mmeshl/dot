vim.pack.add {
  github 'nvim-lua/plenary.nvim',
  github 'nvim-tree/nvim-web-devicons',
  github 'nvim-lualine/lualine.nvim',
  github 'stevearc/oil.nvim',
  github 'nvim-telescope/telescope-fzf-native.nvim',
  github 'nvim-telescope/telescope.nvim',
  github 'nvim-treesitter/nvim-treesitter',
  github 'nvim-mini/mini.nvim',
  github 'saghen/blink.cmp',
  github 'neovim/nvim-lspconfig',
  github 'mason-org/mason.nvim',
  github 'mason-org/mason-lspconfig.nvim',
  github 'folke/trouble.nvim',
  github 'folke/which-key.nvim',
  github 'MeanderingProgrammer/render-markdown.nvim'
}

do
  local configs = {
    'lualine',
    'oil',
    'telescope',
    'mini',
    'blink',
    'mason',
    'trouble',
    'which-key',
  }

  local path = 'plugins.config'
  for _, plugin in ipairs(configs) do
    require(path .. '.' .. plugin)
  end
end
