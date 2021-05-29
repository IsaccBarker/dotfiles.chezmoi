
call plug#begin(stdpath('data') . '/plugged')

Plug 'tpope/vim-fugitive' " Git plugin
Plug 'scrooloose/nerdtree' " NERD file explorer
Plug 'PhilRunninger/nerdtree-buffer-ops' " Highlighter for NERD
Plug 'ycm-core/YouCompleteMe' " Super handy code completion for a shit load of languages
Plug 'Nopik/vim-nerdtree-direnter' " Fix issue in which opening a directory in NERDTree opens a new tab
Plug 'szw/vim-g' " Search Google inside vim!
Plug 'hienvd/vim-stackoverflow' " Search Stack Overflow inside vim!
Plug 'vim-airline/vim-airline' " Cool status bar
Plug 'cespare/vim-toml' " TOML syntax
Plug 'tikhomirov/vim-glsl' " GLSL syntax
Plug 'beyondmarc/hlsl.vim' " HLSL syntax

call plug#end()

" Line numbers
set nu

" Setup tabing shortcuts
nnoremap <leader>n :tabnew<CR>
nnoremap <S-Left> :-tabnext<CR>
nnoremap <S-Right> :+tabnext<CR>

" Setup NERDTree shortcuts
nnoremap <leader>g :NERDTreeFocus<CR>
nnoremap <leader>f :NERDTreeToggle<CR>

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Open all files selected in NERDTree in new tabs.
let NERDTreeMapOpenInTab='<ENTER>'

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Exit Vim if terminal in the only tab left
autocmd TabEnter * if stridx(@%, '/bin/zsh') != -1 | quit | endif 

" Setup YouCompleteMe goto shortcuts
nnoremap <leader>ji :YcmCompleter GoTo<CR>

" Setup YouCompleteMe semantic information shortcuts
nnoremap <leader>gt :YcmCompleter GetType<CR>

" Setup YouCompleteMe refactoring shortcuts
nnoremap <leader>rr :YcmCompleter FixIt<CR>
nnoremap <leader>rn :YcmCompleter RefactorName<CR>
nnoremap <leader>rf :YcmCompleter Format<CR>

" Setup random YouCompleteMe shortcuts
nnoremap <leader>e :YcmShowDetailedDiagnostic<CR>

" Move back to file that is wanted
autocmd BufReadPost * tabfirst

" Setup our cool tab line.
let g:airline#extensions#tabline#enabled = 1 " Display all buffers when only one tab is open.
let g:airline#extensions#tabline#formatter = 'unique_tail' " Get better tab names

" Show all the errors
let g:ycm_max_diagnostics_to_display = 1000

" Enable Rust for YCM
let g:ycm_global_ycm_extra_conf = '~/.config/nvim/global_extra_conf.py'

" Use 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab

" Setup character encoding
set encoding=UTF-8

" Set two semicolons to be escape
imap ;; <Esc>

" Auto change directory
set autochdir

" Mouse support
set mouse=a

