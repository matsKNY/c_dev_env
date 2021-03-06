" General VIM settings -------> {{{
augroup general_vim_settings
    autocmd!
    set nocompatible
    set number
    set ignorecase
    set showmode
    set backspace=indent,eol,start
    set encoding=utf-8
    set guicursor=
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
    " Managing the Universal Text Linking plugin.
    Plugin 'vim-scripts/utl.vim'
    " Managing the repeat plugin.
    Plugin 'tpope/vim-repeat'
    " Managing the tagbar plugin.
    Plugin 'majutsushi/tagbar'
    " Managing the SyntaxRange plugin.
    Plugin 'vim-scripts/SyntaxRange'
    " Managing the IndentLine plugin.
    Plugin 'Yggdroot/indentLine'
    " Managing the R plugin.
    Plugin 'jalvesaq/Nvim-R'
    " Managing the fugitive plugin.
    Plugin 'tpope/vim-fugitive'
    " Managing the jedi plugin.
    Plugin 'davidhalter/jedi-vim'

    " Terminating Vundle.
    call vundle#end()
augroup END
" <------- }}}

" Theme -------> {{{
augroup theme
    autocmd!
    set t_Co=256
    silent! colorscheme molokai
    hi MatchParen cterm=none ctermbg=black ctermfg=81
    set nohlsearch
augroup END
" <------- }}}

" Vim mappings -------> {{{
augroup vim_mappings
    autocmd!
    let mapleader = "/"

    " Text editing mappings
    inoremap <esc> <nop>
    inoremap jk <esc>
    inoremap ù %
    inoremap % ù
    " Unicode-related mappings.
    inoremap <C-l> <C-V>u2937 
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
    " Plugin-related remappings.
    noremap <F8> :TagbarOpenAutoClose<cr>
    " Laboratory notebook-related remappings.
    noremap <F2> :call OpenLab("notebook.org")<cr>
    noremap <F3> :call OpenLab("todo.org")<cr>
    noremap <F4> :call OpenLab("references.org")<cr>
    noremap <F5> :call OpenLab("knowledge.org")<cr>
    noremap <F6> :call OpenLab("ideas.org")<cr>
    noremap <F7> :call OpenLab("writing.org")<cr>
    noremap <F12> :! push_lab_notebook<cr>
    " Comment-related mappings.
    noremap <C-f> :call FilterCommentsOut()<cr>
    " Windows-management related mappings:
    noremap w <C-w>
    noremap ww <C-w>w
    " Tab-management related mappings:
    noremap gr gT
    noremap ge :tabnew<cr>
augroup END
" <------- }}}

" Filetype - Global -------> {{{
augroup filetype_global
    autocmd!
    filetype plugin indent on
    filetype plugin on
    filetype on
    set fdm=marker
augroup END
" <------- }}}

" Custom commands and functions -------> {{{
augroup functions_and_commands
    autocmd!

    " Function and associated command to open a PDF from its path in Vim:
    function! Function_OpenPDF()
        let line=getline('.')
        execute "!okular " . line
    endfunction
    "
    command! OpenPDF call Function_OpenPDF()

    " Function to format a range of line according to the given line width.
    function! FormatLineWidth(width) range
        let old_width=&textwidth
        let &textwidth=a:width
        execute "normal gv gq"
        let &textwidth=old_width
    endfunction

    " Function to create a new split buffer occupying the full height, and a
    " ratio of the global width. the name of the new split
    " Arguments :
    "   percentWidth : the ratio of the global width which should be allocated
    "       to the new split buffer. The ratio must be comprised between 0.0 
    "       and 1.0. If not, it is set to 0.5 by default;
    "   windowName : a string containing the name of the new split buffer to be
    "       created;
    "   noFile : a boolean representing "Should the new split buffer be
    "      a temporary buffer ?".
    function! SplitSize(percentWidth, windowName, noFile)
        if (1.0 < a:percentWidth) || (0.0 > a:percentWidth)
            let percentWidth = 0.5
        else
            let percentWidth = a:percentWidth
        endif
        let totalWidth   = &columns
        let newWidth     = floor(totalWidth*(percentWidth))
        execute "vsplit ". a:windowName
        execute "vertical resize " . float2nr(newWidth)
        if (a:noFile)
            setlocal buftype=nofile
        endif
    endfunction

    " Lists all the tags used in the current buffer, without any duplicate, in a
    " separate temporary buffer.
    function! ListTags()
        let listTags = []
        " The following line is tricky:
        "   - sed is used on the whole file to match a pattern representing a
        "   tag ":\(.+\):". The parenthesis are used to select the submatch;
        "   - So as not apply any substitution in the end (the goal is just to
        "   extract the tags), the search and substitution patterns have to be
        "   'zeroed'. To do so on the search pattern, "\zs" is appended;
        "   - To add the tags to the list, the "add" function must be called. To
        "   call a function in a sed expression, "\=" should be appended;
        "   - Since the replace pattern has to be 'zeroed', and the "add"
        "   function returns the resulting list cast into a string, an substring
        "   beginning at the first character of the latter and of length 0 is
        "   extracted. It is done thanks to "[1:0]".
        %s/:\([^:]\+\):\zs/\=add(listTags, submatch(1))[1:0]/g

        " To eliminate the duplicated tags, the list is transformed into a
        " dictionary, and the keys of the latter are extracted.
        let tags = {}
        for t in listTags
            let tags[t] = ""
        endfor
        let listTags = keys(tags)

        " Creating a new temporary buffer.
        call SplitSize(0.2, "List_of_tags", 1)

        " Adding the tags, one line per entry of the list, after the 0th line of
        " current buffer (the newly created temporary buffer).
        call append(0, listTags)
        execute "wincmd l"
        execute "normal u"

    endfunction

    " Filters the content of the current buffer to select only the subtrees of
    " the headers which are associated with a specified tag.
    " The selection is appended to a new temporary buffer, and the concerned tag
    " is specified thanks to a user input prompt.
    function! FilterTags()
        " Prompting for the tag to look for.
        call inputsave()
        let inputTag = input('Filter according to: ')
        call inputrestore()

        " Building the pattern string associated with the tag to look for.
        let pattern = ":" . inputTag . ":"

        " Copying the original buffer to a temporary one in order to modify it
        " without actually modifying the original buffer.
        execute "normal ggVGy"
        execute "e filter_tags.org"
        setlocal buftype=nofile
        execute "normal pggdd"

        " Parsing the file starting by the end, and authorizing only one wrap
        " around, so as to be sure not to infinitely loop.
        execute "normal G$"
        let flags = "cw"
        while search("^* ", flags) > 0
            let flags = "cn"
            " If the looked for tag is not associated with the current header,
            " deleting the whole subtree of the latter.
            if (search(pattern, flags, line(".")) == 0)
                execute "normal dar"
            else
                execute "normal l"
            endif
            let flags = "cW"
        endwhile

    endfunction

    " Simple function aiming at opening a file from the laboratory notebook.
    " Arguments :
    "   file : the basename of the file to open.
    function! OpenLab(file)
        let home_path = fnamemodify(expand("$HOME"), ":p:h")
        let file_path = home_path . "/.lab_notebook/" . a:file
        execute "e " . file_path
    endfunction

    " Opens a temporary buffer to display the current file without any full-line
    " comments.
    function! FilterCommentsOut()
        " Storing the current position of the cursor so as to restore it in the
        " temporary buffer.
        let init_line = line('.')
        let init_col  = col('.')
        
        " Copying the original buffer to a temporary one in order to modify it
        " without actually modifying the original buffer.
        setlocal hidden
        execute "normal ggVGy"
        execute "e filter_comments_out-" . expand('%:t')
        setlocal buftype=nofile
        execute "normal pggdd^"

        " The position the cursor should be set to is going to evolve with line
        " deletions.
        let cursor_line = init_line
        let nb_deletion = 0

        " Iterating over all the lines of the file.
        let count_line = 1
        let nb_lines   = line('$')
        while (count_line <= nb_lines)
            " Making sure to be at the beginning of the line.
            execute "normal! ^"
            " Determining the syntax group of the first character.
            " Indeed, since the goal of the function is to filter out the
            " comment lines, it is sufficient to determine the syntax group of
            " the first character.
            let highlight_group = synIDattr(synID(line('.'), col('.'), 1), 'name')

            " If the line belong to the syntax group of the comments, deleting
            " it.
            " Since it modifies the total number of lines, "nb_line" must be
            " updated.
            " However, since the next line before deletion becomes the curretn
            " line after deletion, "count_line" should not be updated.
            if (highlight_group =~ ".*comment.*")
                execute "normal! dd^"
                let nb_lines = nb_lines - 1

                " Updating the line the cursor should be put to in the temporary
                " buffer - taking into account line deletion.
                let nb_deletion = nb_deletion + 1
                if (init_line >= (nb_deletion + count_line))
                    let cursor_line = cursor_line - 1
                endif
            else
                execute "normal! j^"
                let count_line = count_line + 1
            endif
        endwhile

        " Positioning the cursor to its last known position in the original
        " buffer.
        call cursor(cursor_line, init_col)

    endfunction

    " Applies proper syntax highlighting in .org files (for vim-orgmode plugin) 
    " to no-default programming languages.
    function! OrgmodeSyntaxHighlight()
        " Defining a dictionary containing all the programming languages for
        " which the syntax should be highlighted.
        let dictHighlight = {'bash': 'sh', 'fortran': 'fortran'}

        " Iterating over all the programming languages to highlight.
        for key in keys(dictHighlight)
            silent! call SyntaxRange#Include('#+BEGIN_SRC ' . key, '#+END_SRC', dictHighlight[key], 'NonText')
        endfor
    endfunction

augroup END
" <------- }}}

" Filetype - C and C++ -------> {{{
augroup filetype_c_and_cpp
    autocmd!
    autocmd Filetype c,cpp let maplocalleader = "/"
    " Closing the preview window of YCM after insertion.
    autocmd Filetype c,cpp let g:ycm_autoclose_preview_window_after_insertion = 1
    " Go to declaration:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gtd :YcmCompleter GoToDeclaration<cr>
    " Go to definition:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gtf :YcmCompleter GoToDefinition<cr>
    " Go to include:
    autocmd FileType c,cpp nnoremap <buffer> <localleader>gti :YcmCompleter GoToInclude<cr>
    " Mappings related to the vim-snippet plugin:
    autocmd Filetype c,cpp inoremap <buffer> <leader>hf <Esc>:call SnippetInit('C/header_file.c')<cr>
    autocmd Filetype c,cpp inoremap <buffer> <leader>hs <Esc>:call SnippetInit('C/header_section.c')<cr>
augroup END
" <------- }}}

" Filetype - Vimscript -------> {{{
augroup filetype_vimscript
    autocmd!
    autocmd Filetype c,cpp let maplocalleader = "/"
    autocmd Filetype vim setlocal foldmethod=marker
augroup END
" <------- }}}

" Filetype - Bash -------> {{{
augroup filetype_bash
    autocmd!
    let maplocalleader = "/"
    autocmd Filetype bash,sh inoremap <c-e> <esc>bi"$<esc>ea"
augroup END
" <------- }}}

" Filetype - Orgmode -------> {{{
augroup filetype_orgmode
    autocmd!
    autocmd Filetype org call OrgmodeSyntaxHighlight()
    autocmd Filetype org let g:loaded_youcompleteme = 1
    autocmd Filetype org let maplocalleader = "/"
    autocmd Filetype org let g:org_todo_keywords = [
        \ ['TODO(t)', 'WIP(w)', '|', 'DONE(d)']
    \]
    autocmd Filetype org noremap <F9> :call ListTags()<cr>
    autocmd Filetype org noremap <F10> :call FilterTags()<cr>
    autocmd Filetype org hi! link org_bold User2
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
