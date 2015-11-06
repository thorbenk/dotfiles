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
" cd .vim/bundle/YouCompleteMe && ./install.sh --clang-completer
" cd .vim/bundle/vimproc.vim && make

" Notes
" =====
"
" * folds:
"   - open/close via 'zo' and 'zc' (remember: z == folded piece of paper)
"   - close all folds in a file: 'zm'     
"
" Keyboard Shortcuts (Plugins, this configuration)
" ==================
"
" tab completion   : C-n
" toggle nerd tree : A-0
" toggle line num  : C-n (normal mode)
"
" CtrlP:
" when open, switch mode : C-f
" when open, ask for which split to use : C-o
"
" }}}

" Plugins {{{
set nocompatible 
filetype off 
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-dispatch'
Plugin 'vim-scripts/Align'
Plugin 'bling/vim-airline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'djjcast/mirodark'
Plugin 'morhetz/gruvbox'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'

" Show absolute line numbers in insert mode,
"      relative line numbers in normal mode
" Use C-n to toggle the mode.
Plugin 'jeffkreeftmeijer/vim-numbertoggle'

if !has('nvim')
    Plugin 'jszakmeister/vim-togglecursor'
endif

" rust
Plugin 'rust-lang/rust.vim'
Plugin 'racer-rust/vim-racer'

" Plugin 'Valloric/YouCompleteMe'

call vundle#end()
" }}}

filetype plugin indent on 
syntax enable
set backspace=indent,eol,start

set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set colorcolumn=80

set laststatus=2 " show vim-airline all the time, not just on first split
let g:airline_powerline_fonts=1

set relativenumber
set number

set hidden " keep buffer around when switching to different buffer

" tab completion: <C-n>
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Window management {{{
:nnoremap <A-h> <C-w>h
:nnoremap <A-j> <C-w>j
:nnoremap <A-k> <C-w>k
:nnoremap <A-l> <C-w>l
" }}}

" NeoVim {{{
if has('nvim')
    :tnoremap <A-h> <C-\><C-n><C-w>h
    :tnoremap <A-j> <C-\><C-n><C-w>j
    :tnoremap <A-k> <C-\><C-n><C-w>k
    :tnoremap <A-l> <C-\><C-n><C-w>l
    
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
endif
" }}}

" Save all buffers when window loses focus
:au FocusLost * silent! :wa

set wildignore+=*/.git/*,*/.svn/*
set wildignore+=*.so,*.swp,*.swo
set wildignore+=*/target/debug*,*/target/release/*

" CtrlP {{{
" search upwards for a directory containgin .git etc. ('r')
" if no root can be found, use the directory of the current file ('c')
let g:ctrlp_working_path_mode = 'ra'

" Ctrl-k (like Qt Creator)
let g:ctrlp_map = '<c-k>'

" CtrlP at bottom, order top-to-bottom
let g:ctrlp_match_window = 'bottom,order:ttb'

" Search in files, buffers and MRU files at the same time
let g:ctrlp_cmd = 'CtrlPMixed'
" }}}

" NerdTree {{{
map <A-0> :NERDTreeToggle<CR>
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

color gruvbox
set bg=dark
set t_Co=256
