let $PATH = system("printenv PATH")
let $PATH = substitute($PATH, "\<C-J>$", "", "")

set nocompatible

call plug#begin('~/.vim/plugged')

Plug 'majutsushi/tagbar'
Plug 'vim-scripts/bufkill.vim'
Plug 'vim-scripts/scratch.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'rodjek/vim-puppet'
Plug 'scrooloose/nerdtree'
Plug 'kien/ctrlp.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'junegunn/vim-easy-align'
Plug 'wting/rust.vim'
Plug 'vim-scripts/Align'
Plug 'racer-rust/vim-racer'
Plug 'aereal/vim-colors-japanesque'
Plug 'lucidstack/ctrlp-mpc.vim'
Plug 'peterhoeg/vim-qml'
Plug 'noahfrederick/vim-hemisu'
Plug 'w0rp/ale'
Plug 'plan9-for-vimspace/acme-colors'

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax on

colo japanesque
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
set ttimeoutlen=80

set mouse=a

set ruler " co-ords in status bar

set showmode " Show modeline in status
set colorcolumn=80
hi ColorColumn ctermbg=255

set hlsearch
set ignorecase
set smartcase
set incsearch

set scrolloff=5

set encoding=utf-8
set fileencoding=utf-8

set wildmode=list:longest,list:full
set wildignore+=*.o,*.pyc,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*,bundle,_html,env,tmp,node_modules,public/uploads,public/assets/source_maps,public

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Javascript Functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! JsUnMinify()
    %s/{\ze[^\r\n]/{\r/g
    %s/){/) {/g
    %s/};\?\ze[^\r\n]/\0\r/g
    %s/;\ze[^\r\n]/;\r/g
    %s/[^\s]\zs[=&|]\+\ze[^\s]/ \0 /g
    normal ggVG=
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ruby Functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! RbOpenTestAlternate()
  let new_file = RbAlternateForCurrentFile()
  exec ':e ' . new_file
endfunction

function! RbOpenTestAlternateVsplit()
  let new_file = RbAlternateForCurrentFile()
  exec ':vs ' . new_file
endfunction

function! RbAlternateForCurrentFile()
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 ||
        \      match(current_file, '\<presenters\>') != -1 ||
        \      match(current_file, '\<services\>') != -1 ||
        \      match(current_file, '\<decorators\>') != -1 ||
        \      match(current_file, '\<models\>') != -1 ||
        \      match(current_file, '\<helpers\>') != -1 ||
        \      match(current_file, '\<views\>') != -1
  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    end
  endif
  return new_file
endfunction

" Running tests
function! RbRunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    let l:params = '-f documentation'
    if a:filename == ''
      let l:params = ''
    end

    if match(a:filename, '\.feature$') != -1
      exec ":!bundle exec cucumber --require features " . a:filename
    elseif match(a:filename, '_test.rb$') != -1
      exec ":!ruby -I test:lib " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable("config/environment.rb")
            exec ":!spring rspec ". l:params . " " . a:filename
        elseif filereadable("Gemfile")
            exec ":!bundle exec rspec ". l:params . " " . a:filename
        else
            exec ":!rspec " . l:params . " " . a:filename
        end
    end
endfunction

function! RbSetTestFile()
    let t:mvh_test_file=@%
endfunction

function! RbRunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
    if in_test_file
        call RbSetTestFile()
    elseif !exists("t:mvh_test_file")
        return
    end
    call RbRunTests(t:mvh_test_file . command_suffix)
endfunction

function! RbRunNearestTest()
    let spec_line_number = line('.')
    call RbRunTestFile(":" . spec_line_number)
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
        \ nnoremap ;t :!cargo test
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
        \ map <F8> :!ctags -f TAGS --tag-relative=yes --exclude=public --exclude=_html --exclude=tmp --exclude=log --exclude=coverage --exclude=node_modules --extra=+f -R *<CR><CR> |
        \ nnoremap // :call RbOpenTestAlternateVsplit()<cr> |
        \ nnoremap /. :call RbOpenTestAlternate()<cr>|
        \ nnoremap ;t :call RbRunTestFile()<cr>|
        \ nnoremap ;T :call RbRunNearestTest()<cr>|
        \ nnoremap ;a :call RbRunTests('')<cr>|
augroup END

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

" buffer management
nmap <F2> :bprev<cr>
nmap <F3> :bnext<cr>
nmap <F4> :BD<cr>

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
vmap <Enter> <Plug>(EasyAlign)

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

" Open CtrlP in buffer mode
nnoremap <c-b> :CtrlPBuffer<cr>

nmap <F6> :call MakeDirectory()<cr>
nmap Q :qa!<cr>
map :W :w
map :E :e

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_linters = {
\   'javascript': ['eslint'],
\}

