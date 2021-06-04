let $PATH = system("printenv PATH")
let $PATH = substitute($PATH, "\<C-J>$", "", "")

call plug#begin('~/.vim/plugged')

" Make buffers work better
Plug 'vim-scripts/bufkill.vim'
Plug 'vim-scripts/scratch.vim'

" Git
Plug 'tpope/vim-fugitive'

" Project navigation
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/tagbar'

" Code utils
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'

" Ruby/Rails
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'

" Rust
Plug 'wting/rust.vim'
Plug 'racer-rust/vim-racer'

" Theme & Appearance
Plug 'nanotech/jellybeans.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'aereal/vim-colors-japanesque'
Plug 'morhetz/gruvbox'
Plug 'haishanh/night-owl.vim'
Plug 'artanikin/vim-synthwave84'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

filetype on
filetype plugin on
filetype indent on
set nocompatible
let skip_defaults_vim=1
set viminfo=
set synmaxcol=300
set ttyfast
set lazyredraw

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

syntax on

set background=dark
colorscheme synthwave84

"set clipboard=unnamed

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
set relativenumber

set mouse=a

set ruler " co-ords in status bar

set showmode " Show modeline in status
set colorcolumn=81

set hlsearch
set ignorecase
set smartcase
set incsearch

set tags+=.git/tags

set scrolloff=5

set encoding=utf-8
set fileencoding=utf-8

set wildmode=longest:list,full
set wildignore+=*.o,*.pyc,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*,bundle,
      \_html,env,tmp,node_modules,public/uploads,public/assets/source_maps,
      \public
set suffixesadd=.rb

set nobackup
set nowb
set noswapfile

set lispwords+=module,describe,it,define-system

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
" AutoCommand Definitions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd VimEnter                    * set vb t_vb=
autocmd BufRead,BufNewFile Makefile * set noet
autocmd BufRead,BufNewFile          *.tsv set noet
autocmd BufRead,BufNewFile          *.clj set filetype=clojure

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

function! ToggleTabHighlightBehaviour()
  if !exists('#HighlightPeskyTabs#BufRead,BufNewFile')
    augroup HighlightPeskyTabs
      autocmd!
      autocmd BufRead,BufNewFile *
            \ syn match Tab "\t" |
            \ syn match TrailingWS "\s\+$" |
            \ hi def Tab ctermbg=red guibg=red |
            \ hi def TrailingWS ctermbg=red guibg=red |
    augroup END
  else
    augroup HighlightPeskyTabs
      autocmd!
    augroup END
  endif

  :e %
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keyboard Mapping
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader="\<Space>"

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

" Hightlight literal Tabs
noremap <leader>w :call ToggleTabHighlightBehaviour()<cr>
" Cleanup whitespace
noremap <leader>c :call CleanupWhiteSpace()<cr>

" run shell commands quick from normal mode
nmap ! :!

" Tags
map <Leader>rt :!ctags --tag-relative=yes --extras=+f -Rf.git/tags --languages=-javascript,sql .<cr><cr>

" switch to most recent active buffer
noremap ,, <c-^>

" context sensitive tab key
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" Use fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>o :Buffers<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>T :Tags<CR>
nnoremap <leader>t :BTags<CR>

" building Ruby
nnoremap <leader>m :make miniruby<cr>
nnoremap <leader>M :make<cr>

" run tests
nnoremap ;t :call TestRunFile()<cr>

nmap <F6> :call MakeDirectory()<cr>
nmap Q :qa!<cr>
map :W :w
map :E :e

