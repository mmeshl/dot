local g, o = vim.g, vim.opt

g.mapleader      = ' '
g.maplocalleader = ' '

o.number         = true
o.relativenumber = true
o.mouse          = 'a'
o.undofile       = true
o.ignorecase     = true
o.smartcase      = true
o.incsearch      = true
o.hlsearch       = true
o.signcolumn     = 'yes:1'
o.updatetime     = 250
o.timeoutlen     = 300
o.splitright     = true
o.splitbelow     = true
o.inccommand     = 'split'
o.cursorline     = true
o.scrolloff      = 10
o.sidescrolloff  = 10
o.confirm        = true
o.shiftwidth     = 4
o.softtabstop    = 4
o.expandtab      = true
o.termguicolors  = true
o.wrap           = false
o.colorcolumn    = '100'
o.showmode       = false
o.cmdheight      = 1
o.autoread       = true
o.autowrite      = false
o.selection      = 'inclusive'
o.modifiable     = true
o.encoding       = 'utf-8'
o.fillchars      = { eob = ' ', fold = ' ' }

o.iskeyword:append '-'
o.shortmess:append 'I'
