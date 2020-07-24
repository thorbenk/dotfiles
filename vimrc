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
Plug 'ryanoasis/vim-devicons' " ???
Plug 'machakann/vim-highlightedyank'
Plug 'vim-airline/vim-airline'
Plug 'mhinz/vim-startify'

Plug 'justinmk/vim-sneak'

Plug 'farmergreg/vim-lastplace' " open files at the last edited place

let g:rooter_manual_only = 1
" call :Rooter to determine the root directory (e.g. where the .git is)
"              and then switch to it
Plug 'airblade/vim-rooter'

Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/Align'

" coc.nvim
" --------
"
" 1.) make sure `node` is recent enough (node shipped with Ubuntu 18.04 is not)
"     curl -sL install-node.now.sh/lts | bash
"
" 2.) :CocInstall coc-python
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

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

set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set mouse=a
set clipboard+=unnamedplus " use system clipboard by default

set colorcolumn=80
hi ColorColumn ctermbg=red ctermfg=blue

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

" fzf
noremap <Leader>f :Files<CR>
noremap <Leader>r :Rg<CR>
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
set nowritebackup
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

