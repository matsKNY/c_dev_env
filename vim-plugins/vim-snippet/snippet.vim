let s:nb_repl   = 0
let s:dict_repl = {}

let s:cur_repl = 0

function! SnippetInclusion(name)
    set hidden

    let path = fnamemodify("~/.vim/snippet", ":p:h") . "/" . a:name

    let init_line = line('.')

    execute "normal! ^ia\<Esc>==^"
    let nb_indent = (col('.') - 1) / &tabstop
    execute "normal! ^\<Del>"

    let initial_buffer = bufnr("%")
    execute "e " . path
    let temporary_buffer = bufnr("%")
    
    let nb_line   = line('$')
    let last_line = init_line + nb_line - 1

    normal G$
    let flags = "w"
    while search('#![^#!]\+!#', flags) > 0
        let s:nb_repl = s:nb_repl + 1
        let flags = "W"
    endwhile

    execute "bu " . initial_buffer
    execute "bd " . temporary_buffer

    execute "r " . path
    execute "normal! kdd^"

    let cmd_indent  = ':' . init_line . ',' . last_line
    let curr_indent = 0
    while (curr_indent < nb_indent)
        let cmd_indent = cmd_indent . '>'
        let curr_indent = curr_indent + 1
    endwhile
    execute cmd_indent

    set nohidden
endfunction

function! ReplacementExtract(placeholder, id)
    let s:dict_repl[a:id] = a:placeholder
    return '#!' . a:placeholder . '!#'
endfunction

function! SnippetSetup()
    let repl_count = 1
    while (repl_count <= s:nb_repl)
        silent call search('#![^#!@]\+@[^#!@]\+!#')

        s/#!\([^#!@]\+\)@\([1-9]\)!#/\=ReplacementExtract(submatch(1), submatch(2))/

        let repl_count = repl_count + 1
    endwhile
endfunction

function! SnippetCursor(replacement_id)
    let search_pattern = '#!' . s:dict_repl[a:replacement_id] . '!#'
    silent call search(search_pattern, "w")
endfunction

function! SnippetHighlightOn(replacement_id)
    execute "normal! gg"
    silent call search('#![^#!]\+!#')
    let first_line = line('.') - 1

    execute "normal! G"
    silent call search('#![^#!]\+!#', 'b')
    let last_line  = line('.') + 1

    let curr_repl = a:replacement_id
    let last_repl = s:nb_repl

    let highlight_current = '/\%>' . first_line . 'l' . s:dict_repl[curr_repl]
    let highlight_current = highlight_current . '\%<' . last_line . 'l/'
    execute 'match User1 ' . highlight_current

    if (curr_repl < last_repl)
        let index_repl = curr_repl + 1
        let highlight_remaining = '/\%>' . first_line . 'l'

        while (index_repl < last_repl)
            let highlight_remaining = highlight_remaining . s:dict_repl[index_repl]
            let highlight_remaining = highlight_remaining . '\|'
            let index_repl = index_repl + 1
        endwhile
        let highlight_remaining = highlight_remaining . s:dict_repl[last_repl]
        let highlight_remaining = highlight_remaining . '\%<' . last_line . 'l/'

        execute '2match DiffChange ' . highlight_remaining
    endif
endfunction

function! NextReplacement()
    nunmap <Tab>
    
    let s:cur_repl = s:cur_repl + 1
    if (s:cur_repl > s:nb_repl)
        silent call SnippetTerm()
    else
        silent call SnippetReplacement()
    endif
endfunction

function! DoReplacement()
    let v:char = "no_cursor_automated_restoration"
    nnoremap <silent> <Tab> :call NextReplacement()<CR>

    augroup snippet_replacement
        autocmd!
    augroup END

    execute "stopinsert"
    silent call SnippetCursor(s:cur_repl)

    let cursor_snippet = col('.')
    execute "normal! ^"
    let cursor_linestart = col('.')
    silent call SnippetCursor(s:cur_repl)

    execute "normal! vf#d"
    if (cursor_snippet == cursor_linestart)
        execute "normal! i \<Esc>l"
        let v:char = "no_cursor_automated_restoration"
    endif
    execute "startinsert"

endfunction

function! SnippetReplacement()
    silent call SnippetHighlightOn(s:cur_repl)
    silent call SnippetCursor(s:cur_repl)

    augroup snippet_replacement
        autocmd!
        autocmd InsertEnter * silent call DoReplacement()  
    augroup END
endfunction

function! SnippetInit(name)
    let s:nb_repl    = 0
    let s:dict_repl  = {}
    let s:cur_repl   = 0

    silent call SnippetInclusion(a:name)
    silent call SnippetSetup()

    if (s:nb_repl > 0)
        let s:cur_repl = 1
        silent call SnippetReplacement()
    endif
endfunction

function! SnippetTerm()
    augroup snippet_replacement
        autocmd!
    augroup END
endfunction
