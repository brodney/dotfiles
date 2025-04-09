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
let g:mapleader="\<Space>"

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

nnoremap `` ``zz

if has('clipboard')     " If the feature is available
  set clipboard=unnamed " copy to the system clipboard

  if has('unnamedplus')
    set clipboard+=unnamedplus
  endif
endif

" Close all the lists
nnoremap <silent> <leader>q :call <SID>CloseLists()<CR>
function! s:CloseLists()
  lclose
  cclose
  pclose
  silent! TagbarClose
endfunction

" Concatenate the directory into the ls-files command
function! s:GitListCommand(directory)
  " Until you can use --recurse-submodules and --others together
  if filereadable(".gitmodules")
    return "git ls-files " . a:directory . " --cached --exclude-standard --recurse-submodules 2>/dev/null"
  else
    return "git ls-files " . a:directory . " --cached --exclude-standard --others 2>/dev/null"
  endif
endfunction

" Command for searching folders even if they
" aren't tracked with git
function! s:SearchCommand()
  let l:command = ""
  if isdirectory(".git") || filereadable(".git")
    let l:command = s:GitListCommand(".")
  endif

  if strlen(l:command) < 1
    let l:output = system("git rev-parse --show-toplevel")
    if v:shell_error == 0
      let l:output = substitute(l:output, "\\n", "", "")
      let l:command = s:GitListCommand(l:output)
    else
      let l:command = "find * -type f -o -type l"
    endif
  endif

  return l:command
endfunction

function! s:EscapeFilePath(path)
  return substitute(a:path, ' ', '\\ ', 'g')
endfunction

function! FuzzyFindCommand(vimCommand)
  update

  try
    let selection = system(s:SearchCommand() . " | fzy")
  catch /Vim:Interrupt/
    redraw!
    return
  endtry

  redraw!
  " Catch the ^C so that the redraw happens
  if v:shell_error
    return
  endif

  exec ":" . a:vimCommand . " " . s:EscapeFilePath(selection)
endfunction

nnoremap <C-p>  :call FuzzyFindCommand("edit")<cr>
nnoremap <C-p>e :call FuzzyFindCommand("edit")<cr>
nnoremap <C-p>v :call FuzzyFindCommand("vsplit")<cr>
nnoremap <C-p>s :call FuzzyFindCommand("split")<cr>

" Replace the current word with the pasteboard, then put it back
nnoremap <C-y> viwpyiw
