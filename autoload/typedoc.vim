" typedoc.vim - Automatic typedoc management for Vim
" Maintainer:   Zeioth
" Version:      1.0.0




" Path helper methods {{{

function! typedoc#chdir(path)
    if has('nvim')
        let chdir = haslocaldir() ? 'lcd' : haslocaldir(-1, 0) ? 'tcd' : 'cd'
    else
        let chdir = haslocaldir() ? ((haslocaldir() == 1) ? 'lcd' : 'tcd') : 'cd'
    endif
    execute chdir fnameescape(a:path)
endfunction

" Throw an exception message.
function! typedoc#throw(message)
    throw "typedoc: " . a:message
endfunction

" Show an error message.
function! typedoc#error(message)
    let v:errmsg = "typedoc: " . a:message
    echoerr v:errmsg
endfunction

" Show a warning message.
function! typedoc#warning(message)
    echohl WarningMsg
    echom "typedoc: " . a:message
    echohl None
endfunction

" Prints a message if debug tracing is enabled.
function! typedoc#trace(message, ...)
    if g:typedoc_trace || (a:0 && a:1)
        let l:message = "typedoc: " . a:message
        echom l:message
    endif
endfunction

" Strips the ending slash in a path.
function! typedoc#stripslash(path)
    return fnamemodify(a:path, ':s?[/\\]$??')
endfunction

" Normalizes the slashes in a path.
function! typedoc#normalizepath(path)
    if exists('+shellslash') && &shellslash
        return substitute(a:path, '\v/', '\\', 'g')
    elseif has('win32')
        return substitute(a:path, '\v/', '\\', 'g')
    else
        return a:path
    endif
endfunction

" Shell-slashes the path (opposite of `normalizepath`).
function! typedoc#shellslash(path)
    if exists('+shellslash') && !&shellslash
        return substitute(a:path, '\v\\', '/', 'g')
    else
        return a:path
    endif
endfunction

" Returns whether a path is rooted.
if has('win32') || has('win64')
    function! typedoc#is_path_rooted(path) abort
        return len(a:path) >= 2 && (
                    \a:path[0] == '/' || a:path[0] == '\' || a:path[1] == ':')
    endfunction
else
    function! typedoc#is_path_rooted(path) abort
        return !empty(a:path) && a:path[0] == '/'
    endfunction
endif

" }}}




" typedoc helper methods {{{

" Finds the first directory with a project marker by walking up from the given
" file path.
function! typedoc#get_project_root(path) abort
    if g:typedoc_project_root_finder != ''
        return call(g:typedoc_project_root_finder, [a:path])
    endif
    return typedoc#default_get_project_root(a:path)
endfunction

" Default implementation for finding project markers... useful when a custom
" finder (`g:typedoc_project_root_finder`) wants to fallback to the default
" behaviour.
function! typedoc#default_get_project_root(path) abort
    let l:path = typedoc#stripslash(a:path)
    let l:previous_path = ""
    let l:markers = g:typedoc_project_root[:]
    while l:path != l:previous_path
        for root in l:markers
            if !empty(globpath(l:path, root, 1))
                let l:proj_dir = simplify(fnamemodify(l:path, ':p'))
                let l:proj_dir = typedoc#stripslash(l:proj_dir)
                if l:proj_dir == ''
                    call typedoc#trace("Found project marker '" . root .
                                \"' at the root of your file-system! " .
                                \" That's probably wrong, disabling " .
                                \"typedoc for this file...",
                                \1)
                    call typedoc#throw("Marker found at root, aborting.")
                endif
                for ign in g:typedoc_exclude_project_root
                    if l:proj_dir == ign
                        call typedoc#trace(
                                    \"Ignoring project root '" . l:proj_dir .
                                    \"' because it is in the list of ignored" .
                                    \" projects.")
                        call typedoc#throw("Ignore project: " . l:proj_dir)
                    endif
                endfor
                return l:proj_dir
            endif
        endfor
        let l:previous_path = l:path
        let l:path = fnamemodify(l:path, ':h')
    endwhile
    call typedoc#throw("Can't figure out what file to use for: " . a:path)
endfunction

" }}}




" ============================================================================
" YOU PROBABLY ONLY CARE FROM HERE
" ============================================================================

" typedoc Setup {{{

" Setup typedoc for the current buffer.
function! typedoc#setup_typedoc() abort
    if exists('b:typedoc_files') && !g:typedoc_debug
        " This buffer already has typedoc support.
        return
    endif

    " Don't setup typedoc for anything that's not a normal buffer
    " (so don't do anything for help buffers and quickfix windows and
    "  other such things)
    " Also don't do anything for the default `[No Name]` buffer you get
    " after starting Vim.
    if &buftype != '' || 
          \(bufname('%') == '' && !g:typedoc_generate_on_empty_buffer)
        return
    endif

    " We only want to use vim-typedoc in the filetypes supported by typedoc
    if !index(g:doxygen_include_filetypes, &filetype) >= 0
        return
    endif

    " Let the user specify custom ways to disable typedoc.
    if g:typedoc_init_user_func != '' &&
                \!call(g:typedoc_init_user_func, [expand('%:p')])
        call typedoc#trace("Ignoring '" . bufname('%') . "' because of " .
                    \"custom user function.")
        return
    endif

    " Try and find what file we should manage.
    call typedoc#trace("Scanning buffer '" . bufname('%') . "' for typedoc setup...")
    try
        let l:buf_dir = expand('%:p:h', 1)
        if g:typedoc_resolve_symlinks
            let l:buf_dir = fnamemodify(resolve(expand('%:p', 1)), ':p:h')
        endif
        if !exists('b:typedoc_root')
            let b:typedoc_root = typedoc#get_project_root(l:buf_dir)
        endif
        if !len(b:typedoc_root)
            call typedoc#trace("no valid project root.. no typedoc support.")
            return
        endif
        if filereadable(b:typedoc_root . '/.notypedoc')
            call typedoc#trace("'.notypedoc' file found... no typedoc support.")
            return
        endif

        let b:typedoc_files = {}
        " for module in g:typedoc_modules
        "     call call("typedoc#".module."#init", [b:typedoc_root])
        " endfor
    catch /^typedoc\:/
        call typedoc#trace("No typedoc support for this buffer.")
        return
    endtry

    " We know what file to manage! Now set things up.
    call typedoc#trace("Setting typedoc for buffer '".bufname('%')."'")

    " Autocommands for updating typedoc on save.
    " We need to pass the buffer number to the callback function in the rare
    " case that the current buffer is changed by another `BufWritePost`
    " callback. This will let us get that buffer's variables without causing
    " errors.
    let l:bn = bufnr('%')
    execute 'augroup typedoc_buffer_' . l:bn
    execute '  autocmd!'
    execute '  autocmd BufWritePost <buffer=' . l:bn . '> call s:write_triggered_update_typedoc(' . l:bn . ')'
    execute 'augroup end'

    " Miscellaneous commands.
    command! -buffer -bang TypedocRegen :call s:manual_typedoc_regen(<bang>0)
    command! -buffer -bang TypedocOpen :call s:typedoc_open()

    " Keybindings
    "nmap <silent> <C-k> :<C-u>typedocRegen<CR>
    "nmap <silent> <C-h> :<C-u>typedocOpen<CR>
    nmap <silent> g:typedoc_shortcut_regen . :<C-u>typedocRegen<CR>
    nmap <silent> g:typedoc_shortcut_open . :<C-u>typedocOpen<CR>

endfunction

" }}}




"  typedoc Management {{{

" (Re)Generate the docs for the current project.
function! s:manual_typedoc_regen(bufno) abort
    if g:typedoc_enabled == 1
      "visual feedback"
      if g:typedoc_verbose_manual_regen == 1
        echo 'Manually regenerating typedoc documentation.'
      endif

      " Run async
      call s:update_typedoc(a:bufno , 0, 2)
    endif
endfunction

" Open typedoc in the browser.
function! s:typedoc_open() abort
    try
        let l:bn = bufnr('%')
        let l:proj_dir = getbufvar(l:bn, 'typedoc_root')

        "visual feedback"
        if g:typedoc_verbose_open == 1
          echo g:typedoc_browser_cmd . ' ' . l:proj_dir . g:typedoc_browser_file
        endif
        call job_start(['sh', '-c', g:doxygen_browser_cmd . ' ' . l:proj_dir . g:doxygen_browser_file], {})
    endtry
endfunction

" (re)generate typedoc for a buffer that just go saved.
function! s:write_triggered_update_typedoc(bufno) abort
    if g:typedoc_enabled && g:typedoc_generate_on_write
      call s:update_typedoc(a:bufno, 0, 2)
    endif
    silent doautocmd user typedocupdating
endfunction

" update typedoc for the current buffer's file.
" write_mode:
"   0: update typedoc if it exists, generate it otherwise.
"   1: always generate (overwrite) typedoc.
"
" queue_mode:
"   0: if an update is already in progress, report it and abort.
"   1: if an update is already in progress, abort silently.
"   2: if an update is already in progress, queue another one.
function! s:update_typedoc(bufno, write_mode, queue_mode) abort
    " figure out where to save.
    let l:proj_dir = getbufvar(a:bufno, 'typedoc_root')

    " Switch to the project root to make the command line smaller, and make
    " it possible to get the relative path of the filename.
    let l:prev_cwd = getcwd()
    call typedoc#chdir(l:proj_dir)
    try
        
        " Generate the typedoc docs where specified.
        if g:typedoc_auto_regen == 1
          call job_start(['sh', '-c', g:typedoc_cmd], {})

        endif       

    catch /^typedoc\:/
        echom "Error while generating ".a:module." file:"
        echom v:exception
    finally
        " Restore the current directory...
        call typedoc#chdir(l:prev_cwd)
    endtry
endfunction

" }}}
