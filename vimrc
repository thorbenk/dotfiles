" vim:fdm=marker
"
" Documentation {{{
"
" Installation
" ============
"
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"
" :PluginInstall
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
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/.fzf
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Colorschemes
Plugin 'hzchirs/vim-material'
Plugin 'altercation/vim-colors-solarized'
Plugin 'djjcast/mirodark'
Plugin 'joshdick/onedark.vim'
Plugin 'morhetz/gruvbox'

" Eye candy
Plugin 'ryanoasis/vim-devicons' " ???
Plugin 'machakann/vim-highlightedyank'
Plugin 'vim-airline/vim-airline'
Plugin 'mhinz/vim-startify'

Plugin 'justinmk/vim-sneak'

Plugin 'farmergreg/vim-lastplace' " open files at the last edited place

Plugin 'airblade/vim-rooter'
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/Align'

Plugin 'neoclide/coc.nvim'
" and then run:
" :call coc#util#install()

" Show absolute line numbers in insert mode,
"      relative line numbers in normal mode
" Use C-n to toggle the mode.
Plugin 'jeffkreeftmeijer/vim-numbertoggle'

if !has('nvim')
    Plugin 'jszakmeister/vim-togglecursor'
endif

" rust
Plugin 'rust-lang/rust.vim'

Plugin 'christoomey/vim-tmux-navigator'
" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch=2

call vundle#end()
" }}}
" Basic settings {{{
filetype plugin indent on 
syntax enable
set backspace=indent,eol,start

set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set mouse=a
set clipboard+=unnamedplus " use system clipboard by default

set colorcolumn=80

set termguicolors

set laststatus=2 " show vim-airline all the time, not just on first split
let g:airline_powerline_fonts=1
let g:airline_theme='onedark'

set relativenumber
set number

set hidden " keep buffer around when switching to different buffer

" leader key is SPACE
let mapleader=" "

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

" fzf
noremap <Leader>f :Files<CR>
noremap <Leader>a :Rg<CR>
noremap <Leader>b :Buffers<CR>
noremap <Leader>h :History:<CR>
" }}}
" Colors {{{
" color gruvbox
" set bg=dark
" set t_Co=256

colorscheme onedark
" }}}
" Backup files {{{
set nobackup
set noswapfile
" }}}
" Window management {{{
"
" Alt+Shift+{hjkl} to resize windows
:nnoremap <A-S-h> :vertical resize +1<CR>
:nnoremap <A-S-j> :resize -1<CR>
:nnoremap <A-S-k> :resize +1<CR>
:nnoremap <A-S-l> :vertical resize -1<CR>
" }}}
" NeoVim {{{
if has('nvim')
    tnoremap <silent> <m-h> <C-\><C-n>:TmuxNavigateLeft<cr>
    tnoremap <silent> <m-j> <C-\><C-n>:TmuxNavigateDown<cr>
    tnoremap <silent> <m-k> <C-\><C-n>:TmuxNavigateUp<cr>
    tnoremap <silent> <m-l> <C-\><C-n>:TmuxNavigateRight<cr>
    
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

    " Enter and leave insert mode when switch to/from terminal buffer
    autocmd BufWinEnter,WinEnter term://* startinsert
    autocmd BufLeave term://* stopinsert

    " Save a handle to terminal as global variable
    augroup Terminal
      au!
      au TermOpen * let g:last_terminal_job_id = b:terminal_job_id
    augroup END

    " For rust let F6 save current file, then run 'cargo build' in terminal
    function! SendLinesToTerminal(lines)
      exe ":write" 
      call jobsend(g:last_terminal_job_id, add(a:lines, ''))
    endfunction
    command! RunCargoBuild call SendLinesToTerminal(['clear && cargo build'])
    nnoremap <silent> <f6> :RunCargoBuild<cr>
endif
" }}}
" Standard vim {{{
if !has('nvim')
    " Tweaks for togglecursor
    set timeout timeoutlen=1000 ttimeoutlen=50
endif
" }}}
" gvim {{{
if has('gui')
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
endif
" }}}
" Ignore files {{{
set wildignore+=*/.git/*,*/.svn/*
set wildignore+=*.so,*.swp,*.swo
set wildignore+=*/target/debug*,*/target/release/*
set wildignore+=Cargo.lock
" }}}
" vim-sneak {{{
"let g:sneak#label = 1
" }}}
" fzf {{{
" :nnoremap <c-k> :Files<CR>
" :nnoremap <c-b> :Buffers<CR>
" :nnoremap <c-f> :Rg<CR>
" }}}
" Neovim Remote {{{
" pip3 install neovim-remote
" }}}
" Rust Make {{{

autocmd BufRead,BufNewFile Cargo.toml,Cargo.lock,*.rs compiler cargo

au FileType rust compiler cargo

let g:racer_cmd = "/opt/racer/target/release/racer"

" This uses the vim-dispatch plugin to run ':make build'
" (which translates into 'cargo build' for rust projects)
" _in the background_.
"
" It opens the quickfix window (when there are errors only, warnings
" don't count).
" To jump to error, either 
"  - Select a line in the quickfix window and hit <CR> to jump
"  - :cfirst, :cn
"
:nnoremap <F1> :wa<bar>:Make build<CR>

" Alternatively, this would the build _synchronously_
" :nnoremap <F1> :wa<CR>:make build<CR>
" }}}
" Misc {{{
" Save all buffers when window loses focus
:au FocusLost * silent! :wa
" save when switching buffers etc.
:set autowriteall

set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" }}}
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

