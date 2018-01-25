""" Definition of variables global to this script.
" The number of replacements contained by the snippet.
let s:nb_repl   = 0
" A dictionary data structure which will contain the association
" "replacement_order <-> placeholder".
let s:dict_repl = {}

" Index number of the next replacement to be performed.
let s:cur_repl = 0

" A list retaining the user's mappings to restore them once the snippet has been
" inserted (because this script defines some mappings effective during its
" execution).
let s:map_save = []

""" Definition of the functions of the plugin.
" Inserts the snippet, and initializes some variables about the former.
"
" Arguments :
"   + name (String): the path to the snippet to insert (the path is relative,
"   considering ~/.vim/snippet/ as the current directory).
function! s:SnippetInclusion(name)
    " Setting the current buffer as "hidden" so as to be able to switch to
    " another buffer even if the former is marked as modified.
    set hidden

    " Building the path to the snippet.
    let path = fnamemodify("~/.vim/snippet", ":p:h") . "/" . a:name

    " Outlining the inserted snippet so as to properly indent it later.
    let init_line = line('.')

    " Determining the current level of indentation to properly indent the
    " snippet once inserted.
    execute "normal! ^ia\<Esc>==^"
    let nb_indent = (col('.') - 1) / &tabstop
    execute "normal! ^\<Del>"

    " Opening the snippet file so as to initialize variables about it:
    "   + Its number of line, so as to be able to indent it later;
    "   + Its number of placeholders to be later replaced.
    let initial_buffer = bufnr("%")
    execute "e " . path
    let temporary_buffer = bufnr("%")
    
    let nb_line   = line('$')
    let last_line = init_line + nb_line - 1

    " Searching for placeholders starting by the end of the file with wrapping
    " around end of the file enabled. This way, the first placeholder which will
    " be found will be the first one to appear in the snippet.
    normal G$
    let flags = "w"
    while search('#![^#!]\+!#', flags) > 0
        let s:nb_repl = s:nb_repl + 1
        let flags = "W"
    endwhile

    " Closing the temporary buffer and returning to the one in which the snippet
    " should be inserted.
    execute "bu " . initial_buffer
    execute "bd " . temporary_buffer

    " Inserting the snippet.
    execute "r " . path
    execute "normal! kdd^"

    " Indenting the freshly inserted snippet.
    let cmd_indent  = ':' . init_line . ',' . last_line
    let curr_indent = 0
    while (curr_indent < nb_indent)
        let cmd_indent = cmd_indent . '>'
        let curr_indent = curr_indent + 1
    endwhile
    execute cmd_indent

    " Setting back the current buffer to its initial state.
    set nohidden
endfunction

" Extracts a placeholder and the index number of the latter from the snippet.
" Is dedicated to be called from s:SnippetSetup, which actually performs the
" extraction.
"
" Arguments :
"   + placeholder (String) : the placeholder to extract;
"   + id (Int) : the index number of the placeholder to extract.
function! s:ReplacementExtract(placeholder, id)
    " Adding the extracted placeholder to the script-scoped dictionary
    " containing all the placeholders.
    let s:dict_repl[a:id] = a:placeholder

    " Returning the modified placeholder to be inserted in the snippet.
    return '#!' . a:placeholder . '!#'
endfunction

" Initializes the inserted snippet by extracting the information related to the
" placeholder and inserting the modified versions of the latter into the
" snippet.
function! s:SnippetSetup()
    " Iterates over all the placeholders.
    let repl_count = 1
    while (repl_count <= s:nb_repl)
        silent call search('#![^#!@]\+@[^#!@]\+!#')

        " Extracting the information about a placeholder, thanks to
        " s:ReplacementExtract, and substituting it.
        s/#!\([^#!@]\+\)@\([1-9]\)!#/\=s:ReplacementExtract(submatch(1), submatch(2))/

        let repl_count = repl_count + 1
    endwhile
endfunction

" Positions the cursor at the beginning of the specified placeholder.
"
" Arguments :
"   + replacement_id (Int) : the index number of the placeholder on which the
"   cursor should be positioned.
function! s:SnippetCursor(replacement_id)
    let search_pattern = '#!' . s:dict_repl[a:replacement_id] . '!#'
    silent call search(search_pattern, "w")
endfunction

" Highlights the placeholders according to the index number of the specified
" placeholder.
" In a few words, the placeholder which index number is specified is highlighted
" differently (because it is the placeholder being replaced).
"
" Arguments :
"   + replacement_id (Int) : the index number of the placeholder being replaced.
function! s:SnippetHighlightOn(replacement_id)
    " Determining the outlining lines of the snippet containing all the
    " placeholders, so as to apply highlighting only within the snippet.
    execute "normal! gg"
    silent call search('#![^#!]\+!#')
    let first_line = line('.') - 1

    execute "normal! G"
    silent call search('#![^#!]\+!#', 'b')
    let last_line  = line('.') + 1

    " Highlighting differently the placeholder to be replaced.
    let curr_repl = a:replacement_id
    let last_repl = s:nb_repl

    " Defining the matching pattern associated with the current placeholder.
    " Then, applying highlighting.
    let highlight_current = '/\%>' . first_line . 'l' . s:dict_repl[curr_repl]
    let highlight_current = highlight_current . '\%<' . last_line . 'l/'
    execute 'match User1 ' . highlight_current

    " If some placeholder are still to be replaced, highlighting them, but in a
    " grey shade.
    if (curr_repl < last_repl)
        let index_repl = curr_repl + 1
        let highlight_remaining = '/\%>' . first_line . 'l'

        " Aggregating the remaining placeholders.
        while (index_repl < last_repl)
            let highlight_remaining = highlight_remaining . s:dict_repl[index_repl]
            let highlight_remaining = highlight_remaining . '\|'
            let index_repl = index_repl + 1
        endwhile
        let highlight_remaining = highlight_remaining . s:dict_repl[last_repl]
        let highlight_remaining = highlight_remaining . '\%<' . last_line . 'l/'

        " Applying highlighting.
        execute '2match DiffChange ' . highlight_remaining
    endif
endfunction

" Removes highlighting of the placeholders of the snippet.
function! s:SnippetHighlightOff()
    execute "match"
    execute "2match"
endfunction

" Terminates the current replacement procedure, then starts the next one.
function! NextReplacement()
    " By unmapping <Tab> in normal mode, it makes sure that the mapping will be
    " used simply once (since it is mapped to call this function).
    " Doing so, it makes sure that the user can only switch to the next
    " replacement.
    silent! nunmap <Tab>
    
    " Starting the next replacement.
    let s:cur_repl = s:cur_repl + 1
    if (s:cur_repl > s:nb_repl)
        silent call SnippetTerm()
    else
        silent call s:SnippetReplacement()
    endif
endfunction

" Performs the replacement of the placeholder. In other words, removes the
" placeholder and enters Insertion mode.
function! DoReplacement()
    " Positioning the cursor at a steady location, namely the beginning of the
    " current placeholder.
    " Indeed, this function is called as an autocommand on InsertEnter. In other
    " words, as soon as the user enters Insertion mode, this function is called.
    " As a consequence, this function can perform some work before restoring
    " Insertion mode.
    " To make sure the cursor will be at a steady position no matter the key
    " used to enter Insertion mode, v:char must be set to a String (something
    " different from 0).
    let v:char = "no_cursor_automated_restoration"

    " Thanks to this mapping, the user will be able to switch to the next
    " replacement by typing <Tab> in normal mode.
    nnoremap <silent> <Tab> :call NextReplacement()<CR>

    " Deactivating the autocommand on InsertEnter to avoid looping over the call
    " to the current function.
    augroup snippet_replacement
        autocmd!
    augroup END

    " Positioning the cursor at the beginning of the placeholder.
    execute "stopinsert"
    silent call s:SnippetCursor(s:cur_repl)

    " If the placeholder is the only word of the line, then an additional space
    " must be inserted in front of the placeholder to comply with the
    " indentation. To determine whether the placeholder is the only word of the
    " line, comparing the columns of the last character of the placeholder and
    " of the last character of the line.
    execute "normal! f#"
    let cursor_snippet = col('.')
    execute "normal! $"
    let cursor_lineend = col('.')
    silent call s:SnippetCursor(s:cur_repl)

    " Removing the placeholder before entering Insertion mode.
    execute "normal! vf#d"

    " If needed, inserting a leading space.
    " Note that since Insertion mode has to be entered to do so, it is
    " compulsory to set again v:char to something different from 0 to make sure
    " the cursor will be at the beginning of the placeholder no matter what key
    " the user then presses to enter Insertion mode.
    if (cursor_snippet == cursor_lineend)
        execute "normal! i \<Esc>l"
        let v:char = "no_cursor_automated_restoration"
    endif
    execute "startinsert"

endfunction

" Starts the replacement procedure of a placeholder.
function! s:SnippetReplacement()
    " Setting up, or updating the highlighting of the placeholders, and
    " positioning the cursor on the current placeholder.
    silent call s:SnippetHighlightOn(s:cur_repl)
    silent call s:SnippetCursor(s:cur_repl)

    " Defining an autocommand so that the placeholder might be removed as soon
    " as the user enters Insertion mode.
    augroup snippet_replacement
        autocmd!
        autocmd InsertEnter * silent call DoReplacement()  
    augroup END
endfunction

" Initializes the plugin to perform the insertion of a snippet.
"
" Arguments :
"   + name (String): the path to the snippet to insert (the path is relative,
"   considering ~/.vim/snippet/ as the current directory).
function! SnippetInit(name)
    " Initialization of the script-scoped variables.
    let s:nb_repl    = 0
    let s:dict_repl  = {}
    let s:cur_repl   = 0

    " Checking if the user has defined some mappings on the keys/modes which are
    " going to be (re)-mapped by the plugin.
    " If so, saving the aforementioned mappings in order to restore them at the
    " termination of the plugin.
    if (!empty(maparg('<Esc>', "i", 0, 1)))
        call add(s:map_save, maparg('<Esc>', "i", 0, 1))
    endif
    inoremap <silent> <Esc> <Esc>:call SnippetTerm()<CR>

    if (!empty(maparg('<C-i>', "n", 0, 1)))
        call add(s:map_save, maparg('<C-i>', "n", 0, 1))
    endif
    nnoremap <silent> <C-i> :call SnippetTerm()<CR>

    if (!empty(maparg('<Tab>', "n", 0, 1)))
        call add(s:map_save, maparg('<Tab>', "n", 0, 1))
    endif

    " Inserting the snippet, and setting up the potential placeholders.
    silent call s:SnippetInclusion(a:name)
    silent call s:SnippetSetup()

    " If the snippet contains at least one placeholder, initiating their
    " replacements.
    if (s:nb_repl > 0)
        let s:cur_repl = 1
        silent call s:SnippetReplacement()
    else
        silent call SnippetTerm()
    endif
endfunction

" Terminates the execution of the plugin, and thus terminates the snippet
" insertion.
function! SnippetTerm()
    " Unmapping the script-scoped mappings created to perform the snippet
    " insertion.
    silent! nunmap <Tab>
    silent! nunmap <C-i>
    silent! iunmap <Esc>

    " Restoring the user's mappings, if any.
    for item in s:map_save
        let mapping = item['mode'] 
        let mapping = mapping . (item['noremap'] == 1 ? 'noremap ' : 'map ')
        let mapping = mapping . item['lhs'] . ' ' . item['rhs']
        
        execute mapping
    endfor

    " Cleaning all the autocommands defined in the plugin to perform the
    " insertion of the snippet.
    augroup snippet_replacement
        autocmd!
    augroup END

    " If the plugin has been terminating while performing the snippet insertion,
    " then some placeholders might still be highlighted. Un-highlighting them.
    silent call s:SnippetHighlightOff()
endfunction
