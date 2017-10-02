" General VIM settings -------> {{{
augroup general_vim_settings
    autocmd!
    set nocompatible
    set number
    set ignorecase
    set showmode
    set backspace=indent,eol,start
    syntax on
augroup END
" <------- }}}
"
" Indent settings -------> {{{
augroup indent_settings
    autocmd!
    set smartindent
    set autoindent
    set smarttab
    set expandtab
    set wrap
    set tabstop=4
    set shiftwidth=4
    set textwidth=80
    set colorcolumn=80
augroup END
" <------- }}}

" Handling Plugins - Vundle -------> {{{
augroup vundle_plugins
    autocmd!
    " The filetype features must be deactivated.
    filetype off 

    " Setting the runtime path to include Vundle, and initializing it.
    set rtp+=~/.vim/bundle/Vundle.vim
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
    " Managing the org-mode plugin.
    Plugin 'jceb/vim-orgmode.git'
    " Managing the speed-dating plugin.
    Plugin 'tpope/vim-speeddating.git'

    " Terminating Vundle.
    call vundle#end()
augroup END
" <------- }}}

" Theme -------> {{{
augroup theme
    autocmd!
    set t_Co=256
    silent! colorscheme molokai
augroup END
" <------- }}}

" Vim mappings -------> {{{
augroup vim_mappings
    autocmd!
    let mapleader = "/"

    " Text editing mappings
    inoremap <esc> <nop>
    inoremap jk <esc>
    inoremap œ <del>
    inoremap ù %
    inoremap § <down>
    inoremap % <left>
    inoremap µ <right>
    inoremap £ <up>
    " New lines mappings
    nnoremap <leader>o o<esc>^
    nnoremap <leader>O O<esc>^
    " Text formating mappings
    inoremap <c-u> <esc>bveUea
    " VimRC editing mappings
    nnoremap <leader>ev :vsplit $MYVIMRC<cr>
    nnoremap <leader>sv :source $MYVIMRC<cr>
    " Clipboard mappings
    vnoremap <C-c> "+y
    inoremap <C-v> <esc>"+pi
augroup END
" <------- }}}

" Filetype - Global -------> {{{
augroup filetype_global
    autocmd!
    filetype plugin indent on
    filetype plugin on
    filetype on
augroup END
" <------- }}}

" Filetype - C and C++ -------> {{{
augroup filetype_c_and_cpp
    autocmd!
    autocmd Filetype c,cpp let maplocalleader = "/"
    " Go to declaration:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gtd :YcmCompleter GoToDeclaration<cr>
    " Go to definition:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gtf :YcmCompleter GoToDefinition<cr>
    " Go to include:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gti :YcmCompleter GoToInclude<cr>
augroup END
" <------- }}}

" Filetype - Vimscript -------> {{{
augroup filetype_vimscript
    autocmd!
    autocmd Filetype vim setlocal foldmethod=marker
augroup END
" <------- }}}

" Filetype - Bash -------> {{{
augroup filetype_bash
    autocmd!
    autocmd Filetype bash,sh inoremap <c-e> <esc>bi"$<esc>ea"
augroup END
" <------- }}}

" Status line -------> {{{
augroup status_line
    autocmd!
    " Displaying the status line:
    set laststatus=2
    " Colorscheme of the status line:
    hi User1 ctermbg=57  ctermfg=15 cterm=bold 
    hi User2 ctermbg=33  ctermfg=15 cterm=bold
    hi User3 ctermbg=69  ctermfg=15 cterm=bold
    " Status line features:
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
augroup END
" <------- }}}
