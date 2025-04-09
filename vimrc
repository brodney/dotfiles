" This must be first, because it changes other options
if &compatible
  set nocompatible
endif

call plug#begin()
Plug 'gfontenot/vim-xcode', {'branch': 'main'}
Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-sort-motion'
Plug 'gfontenot/vim-xcode'
Plug 'janko-m/vim-test'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'keith/swift.vim'
Plug 'neomake/neomake'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
call plug#end()

syntax on
filetype plugin indent on

set shell=$SHELL

" Use space as leader!
let mapleader="\<Space>"

set incsearch                  " Match while typing search string
set hlsearch                   " Highlight search matches
set autoindent                 " Indent the next line matching the previous line
set smartindent                " Smart auto-indent when creating a new line
set tabstop=2                  " Number of spaces each tab counts for
set shiftwidth=2               " The space << and >> moves the lines
set softtabstop=2              " Number of spaces for some tab operations
set shiftround                 " Round << and >> to multiples of shiftwidth
set expandtab                  " Insert spaces instead of actual tabs
set smarttab                   " Delete entire shiftwidth of tabs when they're inserted
set history=1000               " The number of history items to remember
set backspace=indent,eol,start " Backspace settings
set nostartofline              " Keep cursor in the same place after saves
set showcmd                    " Show command information on the right side of the command line
set number                     " Shows line numbers
set autoread                   " Auto reload file when changed outside vim

set laststatus=2
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]

set colorcolumn=110
highlight ColorColumn ctermbg=0 guibg=lightgrey
highlight Search cterm=NONE ctermfg=darkgrey ctermbg=white

if executable('sourcekit-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'sourcekit-lsp',
        \ 'cmd': {server_info->['sourcekit-lsp']},
        \ 'whitelist': ['swift'],
        \ })
endif
    
" Create a directory if it doesn't exist yet
function! s:EnsureDirectory(directory)
  if !isdirectory(expand(a:directory))
    call mkdir(expand(a:directory), 'p')
  endif
endfunction

" Save backup files, storage is cheap, losing changes is sad
set backup
set backupdir=$HOME/.tmp/vim/backup
call s:EnsureDirectory(&backupdir)

" Write undo tree to a file to resume from next time the file is opened
if has('persistent_undo')
  set undolevels=2000            " The number of undo items to remember
  set undofile                   " Save undo history to files locally
  set undodir=$HOME/.vimundo     " Set the directory of the undofile
  call s:EnsureDirectory(&undodir)
endif

if has('clipboard')     " If the feature is available
  set clipboard=unnamed " copy to the system clipboard

  if has('unnamedplus')
    set clipboard+=unnamedplus
  endif
endif

" Commands
command! -nargs=* AgQuickfix call ag#quickfix(<f-args>)

" Leader commands

" Replace the current word with the pasteboard, then put it back
nnoremap <leader>y viwpyiw

" Search for files
nnoremap <leader>p :Files<CR>
nnoremap <leader>a :Ag<CR>
nnoremap <leader>A :AgQuickfix<CR>

" git
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gd :Gdiff<CR>