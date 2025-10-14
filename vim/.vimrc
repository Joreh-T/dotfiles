" ------------------------------
" Basic Settings
" ------------------------------

let mapleader = " "

" Enable line numbers
set number

" Enable timeout
set timeout

" Set key sequence timeout length
set timeoutlen=800

" Enable relative line numbers
set relativenumber

" Enable syntax highlighting
syntax on

" Use 4 spaces instead of Tab
set tabstop=4
set shiftwidth=4
set expandtab

" Auto indent
set autoindent
set smartindent

" Ignore case when searching, unless uppercase letters are included
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Search while typing (incremental search)
set incsearch

" Enable mouse support (for easy selection and copy)
set mouse=a

" Show matching brackets
set showmatch

" Set status line display
set laststatus=2

" Use system clipboard (requires support)
if has('clipboard')
  set clipboard=unnamedplus
endif

" Show invisible characters like line endings and spaces
set list
set listchars=tab:>-,trail:.,extends:>,precedes:<

" Allow switching files with hidden buffers
set hidden

" Prevent backup file generation
set nobackup
set nowritebackup
set noswapfile

" Make command line prompt more visible
set showcmd
set cmdheight=1

" Show command completion menu
set wildmenu

" ------------------------------
" Key Mappings
" ------------------------------

" Normal and Visual mode: Shift+h jump to line start
nnoremap <S-h> ^

vnoremap <S-h> ^

" Normal mode: Shift+l jump to line end
nnoremap <S-l> $

" Visual mode: Shift+l jump to line end minus one character ($h)
vnoremap <S-l> $h

" Exit vim, press <Leader>q in Normal mode
nnoremap <Leader>qq :q<CR>

" Copy entire line to system clipboard
nnoremap <Leader>y yy"+y

" Paste system clipboard content
nnoremap <Leader>p "+p

" Vertical split: <Leader>\
nnoremap <Leader>\ :vsplit<CR>

" Horizontal split: <Leader>-
nnoremap <Leader>- :split<CR>

" Window navigation shortcuts
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


