" Installation
" ============
"
" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"
" :PluginInstall
"
" cd .vim/bundle/YouCompleteMe && ./install.sh --clang-completer
" sudo apt-get install fonts-powerline
" cd .vim/bundle/vimproc.vim && make

set nocompatible 
filetype off 
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'bling/vim-airline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'djjcast/mirodark'
Plugin 'morhetz/gruvbox'
Plugin 'rust-lang/rust.vim'

if !has('nvim')
    Plugin 'jszakmeister/vim-togglecursor'
endif

" Plugin 'Valloric/YouCompleteMe'

call vundle#end()
filetype plugin indent on 

" let g:ycm_confirm_extra_conf = 0

set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set colorcolumn=80

set number

set laststatus=2 " show vim-airline all the time, not just on first split
let g:airline_powerline_fonts=1

set relativenumber
set number

" Colorscheme
" set t_Co=256
" set background=dark
" let g:solarized_termcolors=256

" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

:nnoremap <A-h> <C-w>h
:nnoremap <A-j> <C-w>j
:nnoremap <A-k> <C-w>k
:nnoremap <A-l> <C-w>l
if has('nvim')
    :tnoremap <A-h> <C-\><C-n><C-w>h
    :tnoremap <A-j> <C-\><C-n><C-w>j
    :tnoremap <A-k> <C-\><C-n><C-w>k
    :tnoremap <A-l> <C-\><C-n><C-w>l
endif

if has('nvim')
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
else
    " Tweaks for togglecursor
    set timeout timeoutlen=1000 ttimeoutlen=50
endif

color gruvbox
set bg=dark
set t_Co=256

