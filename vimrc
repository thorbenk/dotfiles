" vim:fdm=marker
"
" Documentation {{{
"
" Installation
" ============
"
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" :PlugInstall
"
" sudo apt-get install fonts-powerline

" sudo add-apt-repository ppa:neovim-ppa/unstable
" sudo apt-get update
" sudo apt-get install neovim
" pip install --user neovim
"
" Notes
" =====
"
" * folds:
"   - open/close via 'zo' and 'zc' (remember: z == folded piece of paper)
"   - close all folds in a file: 'zm'     
"   - open all folds: 'zR'
"
" Keyboard Shortcuts (Plugins, this configuration)
" ==================
"
" tab completion   : C-n
"
" FZF:
" open file      :   C-k (like in QtCreator) | <Leader>-f
" open buffer    :   C-b                     | <Leader>-b
" search in files:   C-f (via ripgrep)       | <Leader>-a
" search in history:                         | <Leader>-h
" }}}
" Plugins {{{
set nocompatible 
filetype off 
set rtp+=~/.fzf
call plug#begin('~/.vim/plugged')

" Colorschemes
Plug 'hzchirs/vim-material'
Plug 'altercation/vim-colors-solarized'
Plug 'djjcast/mirodark'
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'

" Eye candy
Plug 'kyazdani42/nvim-web-devicons'
Plug 'machakann/vim-highlightedyank'
Plug 'vim-airline/vim-airline'

let g:sneak#label = 1
Plug 'justinmk/vim-sneak'

Plug 'farmergreg/vim-lastplace' " open files at the last edited place

let g:rooter_manual_only = 1
" call :Rooter to determine the root directory (e.g. where the .git is)
"              and then switch to it
Plug 'airblade/vim-rooter'

Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/Align'

Plug 'dyng/ctrlsf.vim'

" Syntax Highlighting for Jenkinsfile and Dockerfile
Plug 'ekalinin/Dockerfile.vim'
au BufNewFile,BufRead *Jenkinsfile setf groovy

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lewis6991/gitsigns.nvim'

" coc.nvim
" --------
"
" 1.) make sure `node` is recent enough (node shipped with Ubuntu 18.04 is not)
"     curl -sL install-node.now.sh/lts | bash
"
" 2.) :CocInstall coc-python
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Show absolute line numbers in insert mode,
"      relative line numbers in normal mode
" Use C-n to toggle the mode.
Plug 'jeffkreeftmeijer/vim-numbertoggle'

if !has('nvim')
    Plug 'jszakmeister/vim-togglecursor'
endif

" rust
Plug 'rust-lang/rust.vim'

Plug 'christoomey/vim-tmux-navigator'
" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch=2

Plug 'benmills/vimux'

call plug#end()
" }}}

" Basic settings {{{
filetype plugin indent on 
syntax enable
set backspace=indent,eol,start
set encoding=UTF-8

set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set mouse=a
set clipboard+=unnamedplus " use system clipboard by default

set termguicolors

set laststatus=2 " show vim-airline all the time, not just on first split
let g:airline_powerline_fonts=1
let g:airline_theme='onedark'

set relativenumber
set number

set hidden " keep buffer around when switching to different buffer

" leader key is SPACE
let mapleader=" "

" jk is ESC
inoremap jk <esc>

" tab completion: <C-n>
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" saving
noremap  <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

set autowrite

" }}}
" Leader {{{
" save file with <leader>w
noremap <Leader>wa :update<CR>
" }}}

" Telescope {{{

lua << EOF
local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    layout_config = {
      horizontal = { width = 0.95 },
    },
    mappings = {
      i = {
        -- do not to enter a normal-like mode when hitting escape
        -- (and instead exit)
        ["<esc>"] = actions.close
      }
    },
  },
})
EOF

nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <leader>fo <cmd>lua require('telescope.builtin').oldfiles()<cr>
nnoremap <leader>fl <cmd>lua require('telescope.builtin').loclist()<cr>
nnoremap <leader>fj <cmd>lua require('telescope.builtin').jumplist()<cr>
" nnoremap <leader>fr <cmd>lua require('telescope.builtin').registers()<cr>
nnoremap <leader>fr <cmd>lua require('telescope.builtin').resume()<cr>
nnoremap <leader>fq <cmd>lua require('telescope.builtin').quickfix()<cr>

" noremap <leader>f <cmd>Telescope find_files<cr>
" noremap <Leader>f :Files<CR>
" noremap <Leader>r :Rg<CR>
" noremap <Leader>b :Buffers<CR>
" noremap <Leader>h :History:<CR>
" }}}
" Colors {{{
" color gruvbox
" set bg=dark
" set t_Co=256

colorscheme onedark

set colorcolumn=80
highlight ColorColumn guibg=#21242b guifg=#9f9f9f

" Window dimming {{{
" Background colors for active vs inactive windows
" (note: needs `termguicolors` set to on
" background of onedark
hi ActiveWindow guibg=#282c34
hi InactiveWindow guibg=#21242b

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of active/inactive windows
function! Handle_Win_Enter()
  setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
endfunction
" }}}

" tmux {{{
" https://www.bugsnag.com/blog/tmux-and-vim
map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vl :wa <bar> :VimuxRunLastCommand<CR>
map <Leader>vq :VimuxCloseRunner<CR>
map <Leader>vx :VimuxInterruptRunner<CR>
map <Leader>vz :VimuxZoomRunner<CR>
" }}}

" coc.nvim {{{

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" }}}

let g:xml_syntax_folding=1 
au FileType xml setlocal foldmethod=syntax

nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

let g:ctrlsf_default_root = 'project'
let g:ctrlsf_position = 'bottom'

