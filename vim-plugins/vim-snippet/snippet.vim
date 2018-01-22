let s:nb_lines = 0
let s:nb_repl  = 0

let s:setup_line = 0
let s:setup_col  = 0
let s:setup_repl = 0

let s:cur_repl = 0

function! NumberToAscii(number)
    let letter = 'j'
    if (a:number == 1)
        let letter = 'a'
    elseif (a:number == 2)
        let letter = 'b'
    elseif (a:number == 3)
        let letter = 'c'
    elseif (a:number == 4)
        let letter = 'd'
    elseif (a:number == 5)
        let letter = 'e'
    elseif (a:number == 6)
        let letter = 'f'
    elseif (a:number == 7)
        let letter = 'g'
    elseif (a:number == 8)
        let letter = 'h'
    elseif (a:number == 9)
        let letter = 'i'
    endif
    
    return letter
endfunction

function! SnippetInclusion(name)
    set hidden

    let path = fnamemodify("~/.vim/snippet", ":p:h") . "/" . a:name

    let initial_buffer = bufnr("%")
    execute "e " . path
    let temporary_buffer = bufnr("%")

    let s:nb_lines = line("$")

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

    set nohidden
endfunction

function! ReplacementExtract(placeholder, id)
    let s:setup_repl = a:id
    return a:placeholder
endfunction

function! SnippetSetup()
    let repl_count = 1
    while (repl_count <= s:nb_repl)
        call search('#![^#!]\+!#')
        let s:setup_line = line('.')
        let s:setup_col  = col('.')

        s/#!\([^#!@]\+\)@\([1-9]\)!#/\=ReplacementExtract(submatch(1), submatch(2))/

        call cursor(s:setup_line, s:setup_col)
        execute "normal! m" . NumberToAscii(s:setup_repl)

        let repl_count = repl_count + 1
    endwhile
endfunction
