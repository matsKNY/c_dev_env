" From vim to nvim !
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Defining mappings specific to neovim.
augroup nvim_mappings
	tnoremap jk <C-\><C-n>

    function! Function_OpenTerm(height)
        execute "botright ". a:height . "split"
        execute "terminal"
    endfunction

    command! OpenTerm call Function_OpenTerm(10)
augroup END

" Adapting the theme associated with emulated terminals.
augroup Terminal
    autocmd!
    hi TermHL ctermbg=236 ctermfg=248
    autocmd TermOpen * set nonumber
    autocmd TermOpen * set winhighlight=Normal:TermHL
augroup END 
