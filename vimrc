"""""""""""""""""""""""
"""""""""""""""""""""""
" General VIM settings:
"""""""""""""""""""""""
"""""""""""""""""""""""
set nocompatible
set number
set ignorecase
set showmode
set backspace=indent,eol,start
syntax on



""""""""""""""""""
""""""""""""""""""
" Indent settings:
""""""""""""""""""
""""""""""""""""""
set smartindent
set autoindent
set smarttab
set expandtab
set tabstop=4
set shiftwidth=4
set colorcolumn=80



""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""
" List of plugins to install thanks to Vundle:
""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""
" The filetype features must be deactivated.
filetype off 

" Setting the runtime path to include Vundle, and initializing it.
set rtp+=/root/.vim/bundle/Vundle.vim
call vundle#begin()

" Letting Vundle manage itself (this is required).
Plugin 'VundleVim/Vundle.vim'
" Managing the molokai theme.
Plugin 'tomasr/molokai'
" Managing the YCM plugin.
Plugin 'valloric/YouCompleteMe'
" Managing the goyo plugin.
Plugin 'junegunn/goyo.vim'
" Managing the limelight plugin.
Plugin 'junegunn/limelight.vim'

" Terminating Vundle.
call vundle#end()



"""""""""""""""""
"""""""""""""""""
" Theme settings:
"""""""""""""""""
"""""""""""""""""
set t_Co=256
silent! colorscheme molokai



""""""""""""""""""""""""""""
""""""""""""""""""""""""""""
" Filetype related settings:
""""""""""""""""""""""""""""
""""""""""""""""""""""""""""
filetype plugin indent on
filetype plugin on
filetype on



"""""""""""""""
"""""""""""""""
" (Re)mappings:
"""""""""""""""
"""""""""""""""
let mapleader = "/"

" Text editing mappings:
""""""""""""""""""""""""
nnoremap <leader>o o<esc>^
nnoremap <leader>O O<esc>^

" VimRC editing mappings:
"""""""""""""""""""""""""
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Clipboard mappings:
"""""""""""""""""""""
vnoremap <C-c> "+y
inoremap <C-v> <esc>"+pi

"""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""
" C and C++ - YouCompleteMe settings:
"""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""
augroup filetype_c_family
    autocmd!
    " Go to declaration:
    """"""""""""""""""""
    autocmd FileType c,c++ nnoremap <leader>gtd :YcmCompleter GoToDeclaration<cr>

    " Go to definition:
    """""""""""""""""""
    autocmd FileType c,c++ nnoremap <leader>gtf :YcmCompleter GoToDefinition<cr>

    " Go to include:
    """"""""""""""""
    autocmd FileType c,c++ nnoremap <leader>gti :YcmCompleter GoToInclude<cr>
augroup END



""""""""""""""
""""""""""""""
" Status line:
""""""""""""""
""""""""""""""
" Displaying the status line:
"""""""""""""""""""""""""""""
set laststatus=2

" Colorscheme of the status line:
"""""""""""""""""""""""""""""""""
hi User1 ctermbg=57  ctermfg=15 cterm=bold 
hi User2 ctermbg=33  ctermfg=15 cterm=bold
hi User3 ctermbg=69 ctermfg=15 cterm=bold

" Status line features:
"""""""""""""""""""""""
set statusline=
set statusline+=%1*\[%n]                                  " Buffer
set statusline+=%1*\ %<%F\                                " File+path
set statusline+=%1*\ %y\                                  " FileType
set statusline+=%2*\ %{''.(&fenc!=''?&fenc:&enc).''}      " Encoding
set statusline+=%2*\ %{(&bomb?\",BOM\":\"\")}\            " Encoding2
set statusline+=%2*\ %{&ff}\                              " FileFormat
set statusline+=%3*\ %=\ line:%l/%L\ (%03p%%)\            " Row number/total (%)
set statusline+=%3*\ column:%03c\                         " Column number
set statusline+=%3*\ \ %m%r\                              " Modified? Readonly?
