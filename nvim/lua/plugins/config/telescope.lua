require('telescope').load_extension 'fzf'

do
  local borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
  require('telescope').setup {
    defaults = {
      theme            = 'borderless',
      prompt_prefix    = ' ',
      selection_caret  = ' ',
      sorting_strategy = 'ascending',
      layout_strategy  = 'horizontal',
      layout_config    = { prompt_position = 'top', height = 25, },
      borderchars      = {
        prompt  = borderchars,
        results = borderchars,
        preview = borderchars,
      }
    }
  }
end
