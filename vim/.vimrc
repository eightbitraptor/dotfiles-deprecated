let $PATH = system("printenv PATH")
let $PATH = substitute($PATH, "\<C-J>$", "", "")

set rtp+=/usr/local/opt/fzf

set nocompatible

call plug#begin('~/.vim/plugged')

" Make buffers work better
Plug 'vim-scripts/bufkill.vim'
Plug 'vim-scripts/scratch.vim'

" Git
Plug 'tpope/vim-fugitive'

" Project navigation
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'junegunn/fzf.vim'

" Code utils
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'

" Ruby/Rails
Plug 'tpope/vim-rails'

" Rust
Plug 'wting/rust.vim'
Plug 'racer-rust/vim-racer'

" Qt/Qml
Plug 'peterhoeg/vim-qml'

" Nix
Plug 'LnL7/vim-nix'

" Typescript
"Plug 'mhartington/nvim-typescript', { 'do': ':UpdateRemotePlugins', 'for': ['typescript', 'typescript.tsx']}
Plug 'leafgarland/typescript-vim', {'for': ['typescript', 'typescript.tsx']}
Plug 'ianks/vim-tsx', { 'for': 'typescript.tsx' }

" linting
Plug 'w0rp/ale'

" Theme & Appearance
Plug 'nanotech/jellybeans.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'aereal/vim-colors-japanesque'
Plug 'morhetz/gruvbox'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax on

set background=dark
set t_Co=256

set clipboard=unnamed

set autoindent " Auto-indent
set expandtab " Expand tabs to spaces
set tabstop=2
set shiftwidth=2
set number " Line numbers on
set backspace=indent,eol,start " Backspace over everything
set isk+=$,@,%,# " these aren't word dividers
set showcmd " show current command in status bar
set hidden " Allow hidden buffers
set laststatus=2
set ttimeoutlen=0 timeoutlen=1000

set mouse=a

set ruler " co-ords in status bar

set showmode " Show modeline in status
set colorcolumn=80

set hlsearch
set ignorecase
set smartcase
set incsearch

set scrolloff=5

set encoding=utf-8
set fileencoding=utf-8

set wildmode=list:longest,list:full
set wildignore+=*.o,*.pyc,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*,bundle,
      \_html,env,tmp,node_modules,public/uploads,public/assets/source_maps,
      \public

set nobackup
set nowb
set noswapfile

set lispwords+=module,describe,it,define-system

let g:deoplete#enable_at_startup = 1
let g:python3_host_prog = '/usr/local/bin/python3'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

function! CleanupWhiteSpace()
  execute "normal! ma"
  :%s/\s\+$//
  execute "normal! `a"
endfunction

function! MakeDirectory()
  call system('mkdir -p ' . expand('%:p:h') )
  if v:shell_error != 0
    echo "Make Directory did not return successfully"
  endif
  :w
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Running Tests
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" A project root is defined as a location that contains a .git directory,
" somewhere in the file tree, above the file in question.
"
" By default, the project root is calculated based on the file path of the
" open buffer when this command was called. Optionally a path can be passed in
" as a second parameter
"
" Args:
"   path: start looking for the project root from here
function! GetProjectRoot(path)
  let project_marker = '/.git/'
  let search_dirs = split(expand(a:path), '/')
  let new_project_root = getcwd()

  let i = len(search_dirs)
  while i >= 0
    let try_project_root = '/' . join(search_dirs[0:i], '/')

    if isdirectory(try_project_root . project_marker)
      let new_project_root = try_project_root
      break
    endif
    let i -= 1
  endwhile

  return new_project_root
endfunction

" Changes directory to the "project root" of a file runs a command and then
" changes the dir back to it's previous value.
"
" Args:
"   cmd (required) - the command to run
"   path (optional) - a file path to use when finding the project root.
" Returns:
"   0
function! WithProjectDirectory(cmd, ...)
  let path = get(a:, 1, expand("%"))

  let old_project_root = getcwd()
  let new_project_root = GetProjectRoot(path)

  execute(":cd" . new_project_root)
  execute(":!" . a:cmd)
  execute(":cd" . old_project_root)
endfunction

" Assume we're reading an RSpec spec, if the filename ends with _spec.rb
"
" Args:
"   file: a file path
" Returns:
"   0: the path does not end with _spec.rb
"   1: the path ends with _spec.rb
function! IsRspec(file)
  return match(expand(a:file), '_spec.rb$') != -1
endfunction

" Assume we're in a Rails project if the string Rails.application appears in
" config.ru in the project dir
"
" Args:
"   file: a file path
" Returns:
"   0: if config.ru doesn't exist, or if config.ru doesn't contain the string
"      Rails.application
"   1: if config.ru exists and contains the string Rails.application
function! IsRails(file)
  let project_root = GetProjectRoot(expand(a:file))
  let testfile = project_root . '/config.ru'

  if !filereadable(testfile)
    return 0
  endif

  let testfile_lines = join(readfile(testfile), " ")
  let in_rails = 0
  if testfile_lines =~ "Rails.application"
    let in_rails = 1
  endif

  return in_rails
endfunction

function! TestRunFile()
  let filetype = b:current_syntax

  " TODO: refactor to use some kind of intelligent dispatch?
  if filetype ==? 'ruby'
    call RbRunTestFile()
  elseif filetype ==? 'rust'
    call RsRunTests()
  endif
endfunction

function! RsRunTests()
  call WithProjectDirectory("cargo test")
endfunction

function! RbRunTestFile()
  execute(":w")
  if IsRspec("%")
    call WithProjectDirectory("bundle exec rspec " . "%")
  elseif IsRails("%")
    call WithProjectDirectory("bundle exec rails test " . "%")
  else
    call WithProjectDirectory("bundle exec ruby -Ilib:test " . "%")
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AutoCommand Definitions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd VimEnter                    * set vb t_vb=
autocmd BufRead,BufNewFile Makefile * set noet
autocmd BufRead,BufNewFile          *.tsv set noet
autocmd BufRead,BufNewFile          *.clj set filetype=clojure
autocmd BufWritePre                 * %s/\s\+$//e

augroup RustShenanigans
  au!
  autocmd BufRead,BufNewFile *.rs
        \ set filetype=rust |
        \ nnoremap ;F :w ! rustfmt %<cr>
augroup END

augroup RubyShenanigans
  au!
  autocmd BufRead,BufNewFile Gemfile,Rakefile,Capfile,*.rake
        \ set filetype=ruby
  autocmd BufRead,BufNewFile *.rb
        \ hi def Tab ctermbg=red guibg=red |
        \ hi def TrailingWS ctermbg=red guibg=red |
        \ hi rubyStringDelimiter ctermbg=NONE |
        \ map <C-s> :!ruby -cw %<cr> |
        \ map <F8> :!ruby-tags
augroup END
let g:ruby_indent_assignment_style = 'variable'

augroup PythonShenanigans
  au!
  autocmd BufRead,BufNewFile *.py,*.pyw
    \ set filetype=python |
    \ set tabstop=4 shiftwidth=4 smarttab expandtab |
    \ nnoremap ;t :w\|:!nosetests %<cr>
augroup END

augroup CShenanigans
  au!
  autocmd BufRead,BufNewFile *.c,*.h
        \ set filetype=c |
        \ set tabstop=8 shiftwidth=4 smarttab expandtab |
augroup END

augroup HighlightPeskyTabs
  au!
  autocmd BufRead,BufNewFile *
      \ syn match Tab "\t" |
      \ syn match TrailingWS "\s\+$" |
      \ hi def Tab ctermbg=red guibg=red |
      \ hi def TrailingWS ctermbg=red guibg=red |
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keyboard Mapping
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

noremap <Up>       :echoerr "Use k instead!"<CR>
noremap <Down>     :echoerr "Use j instead!"<CR>
noremap <Left>     :echoerr "Use h instead!"<CR>
noremap <Right>    :echoerr "Use l instead!"<CR>

" Beginning and end of line
nnoremap <C-a> ^
nnoremap <C-e> $

" Window switching shortcuts
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nnoremap <leader>n <ESC>:NERDTreeToggle<cr>
nnoremap <CR> :noh<CR><CR>

" Command-][ to increase/decrease indentation
vmap <D-]> >gv
vmap <D-[> <gv

" Cleanup whitespace
noremap <leader>c :call CleanupWhiteSpace()<cr>

" run shell commands quick from normal mode
nmap ! :!

" Tagbar
noremap <leader>t :TagbarToggle<CR>

" switch to most recent active buffer
noremap ,, <c-^>

" context sensitive tab key
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" Use fzf
nnoremap <c-p> :Files<CR>
nnoremap <c-b> :Buffers<CR>

" run tests
nnoremap ;t :call TestRunFile()<cr>

nmap <F6> :call MakeDirectory()<cr>
nmap Q :qa!<cr>
map :W :w
map :E :e

let g:ale_lint_on_text_changed = 'never'
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_lint_on_enter = 0
let g:ale_linters = {
\   'ruby': ['rubocop'],
\   'javascript': ['eslint'],
\}
