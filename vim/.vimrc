" ------------------------------
" 基础设置
" ------------------------------

let mapleader = " "

" 启用行号显示
set number

" 启用超时等待
set timeout

" 设置按键序列等待时间
set timeoutlen=800

" 启用相对行号
set relativenumber

" 启用语法高亮
syntax on

" 使用 4 个空格代替 Tab
set tabstop=4
set shiftwidth=4
set expandtab

" 自动缩进
set autoindent
set smartindent

" 搜索时忽略大小写，除非包含大写字母
set ignorecase
set smartcase

" 高亮搜索结果
set hlsearch

" 边输入边搜索（增量搜索）
set incsearch

" 启用鼠标支持（方便选中复制）
set mouse=a

" 显示匹配的括号
set showmatch

" 设置状态栏显示
set laststatus=2

" 使用系统剪贴板（需要支持）
if has('clipboard')
  set clipboard=unnamedplus
endif

" 显示行尾和空格等不可见字符
set list
set listchars=tab:>-,trail:.,extends:>,precedes:<

" 允许使用隐藏缓冲区切换文件
set hidden

" 防止备份文件产生
set nobackup
set nowritebackup
set noswapfile

" 让命令行提示信息更明显
set showcmd
set cmdheight=1

" 提示命令完成
set wildmenu

" ------------------------------
" 快捷键
" ------------------------------

" 普通模式和可视模式下 Shift+h 跳到行首
nnoremap <S-h> ^

vnoremap <S-h> ^

" 普通模式下 Shift+l 跳到行尾
nnoremap <S-l> $

" 可视模式下 Shift+l 跳到行尾减一字符（$h）
vnoremap <S-l> $h

" 退出 vim，Normal 模式下按 <Leader>q
nnoremap <Leader>qq :q<CR>

" 复制整行到系统剪贴板
nnoremap <Leader>y yy"+y

" 粘贴系统剪贴板内容
nnoremap <Leader>p "+p

" 垂直分屏：<Leader>\
nnoremap <Leader>\ :vsplit<CR>

" 水平分屏：<Leader>-
nnoremap <Leader>- :split<CR>

" 切换窗口快捷键
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


