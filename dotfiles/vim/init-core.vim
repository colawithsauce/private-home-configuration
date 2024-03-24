set shiftwidth=4
set tabstop=4
set number
set relativenumber 
set expandtab

set backupdir=~/.cache/vim/backup,/tmp
set directory=~/.cache/vim/swap,/tmp
set undodir=~/.cache/vim/undo,/tmp

nnoremap <SPACE> <Nop>
let mapleader=" "
source $VIMRUNTIME/vimrc_example.vim

set autochdir

" set paste
set clipboard=unnamedplus
set go+=a

" completion on commands
set wildmenu
set wildmode=longest:full,full
set wildoptions=pum

let mapleader=" "
" nnoremap <leader>tt :ALEToggle<CR>

" Default tabstop and shiftwidth
set expandtab
set hlsearch

" -- FZF settings
" Mapping selecting mappings
nmap <C-?> <plug>(fzf-maps-n)
xmap <C-?> <plug>(fzf-maps-x)
omap <C-?> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" -- FZF settings end

let g:markdown_fenced_languages = ['html', 'js=javascript', 'ruby', 'cpp', 'c']

" Folding
set foldmethod=manual
set nofoldenable
" autocmd FileType c,cpp setlocal foldmethod=syntax

" Gui option
set guicursor+=a:blinkon0
set guioptions -=m " no menubar
set guioptions -=T " no toolbar
set guioptions -=r " no scroll bar
set number

set guifont=RecursiveMnCslSt\ Nerd\ Font\ 16

set wrap!

" Catppuccin
set cursorline
autocmd VimEnter * ++nested set t_Co=256
autocmd VimEnter * ++nested set termguicolors
autocmd VimEnter * ++nested let g:airline_theme='catppuccin'
autocmd VimEnter * ++nested color catppuccin_latte
" autocmd VimEnter * ++nested hi CursorLine term=bold cterm=bold guibg=Grey10
" set cursorlineopt=screenline

" Codeium
let g:codeium_manual = v:true
let g:codeium_disable_bindings = 1
imap <script><silent><nowait><expr> <C-a> codeium#Accept()
imap <C-;>   <Cmd>call codeium#CycleOrComplete()<CR>
map <leader>?   <Cmd>call codeium#Chat()<CR>

" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" 所生成的数据文件的名称 "
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录 "
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
" 检测 ~/.cache/tags 不存在就新建 "
if !isdirectory(s:vim_tags)
  silent! call mkdir(s:vim_tags, 'p')
endif

" 配置 ctags 的参数 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--exclude=.direnv,.git']
