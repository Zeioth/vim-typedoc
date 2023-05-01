" typedoc.vim - Automatic typedoc management for Vim
" Maintainer:   Zeioth
" Version:      1.0.0




" Globals - Boiler plate {{{

if (&cp || get(g:, 'typedoc_dont_load', 0))
    finish
endif

if v:version < 704
    echoerr "typedoc: this plugin requires vim >= 7.4."
    finish
endif

let g:typedoc_debug = get(g:, 'typedoc_debug', 0)

if (exists('g:loaded_typedoc') && !g:typedoc_debug)
    finish
endif
if (exists('g:loaded_typedoc') && g:typedoc_debug)
    echom "Reloaded typedoc."
endif
let g:loaded_typedoc = 1

let g:typedoc_trace = get(g:, 'typedoc_trace', 0)

let g:typedoc_enabled = get(g:, 'typedoc_enabled', 1)

" }}}




" Globals - For border cases {{{


let g:typedoc_project_root = get(g:, 'typedoc_project_root', ['.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout'])

let g:typedoc_project_root_finder = get(g:, 'typedoc_project_root_finder', '')

let g:typedoc_exclude_project_root = get(g:, 'typedoc_exclude_project_root', 
            \['/usr/local', '/opt/homebrew', '/home/linuxbrew/.linuxbrew'])

let g:typedoc_include_filetypes = get(g:, 'typedoc_include_filetypes', ['typescript'])
let g:typedoc_resolve_symlinks = get(g:, 'typedoc_resolve_symlinks', 0)
let g:typedoc_generate_on_new = get(g:, 'typedoc_generate_on_new', 1)
let g:typedoc_generate_on_write = get(g:, 'typedoc_generate_on_write', 1)
let g:typedoc_generate_on_empty_buffer = get(g:, 'typedoc_generate_on_empty_buffer', 0)

let g:typedoc_init_user_func = get(g:, 'typedoc_init_user_func', 
            \get(g:, 'typedoc_enabled_user_func', ''))

let g:typedoc_define_advanced_commands = get(g:, 'typedoc_define_advanced_commands', 0)


" }}}




" Globals - The important stuff {{{

let g:typedoc_auto_setup = get(g:, 'typedoc_auto_setup', 1)

" typedoc - Clone tsdoc.json from a repository
let g:typedoc_clone_config_repo = get(g:, 'typedoc_clone_config_repo', 'https://github.com/Zeioth/vim-typedoc-template.git')
let g:typedoc_clone_cmd = get(g:, 'typedoc_clone_cmd', 'git clone')
let g:typedoc_clone_destiny_dir = get(g:, 'typedoc_clone_destiny_dir', './typedoc')
let g:typedoc_clone_post_cmd = get(g:, 'typedoc_clone_post_cmd', '&& cp ' . g:typedoc_clone_destiny_dir . '/typedoc.json ./typedoc.json  && rm -rf ' . g:typedoc_clone_destiny_dir)

" typedoc - Local mode (disables cloning)
let g:typedoc_local_mode = get(g:, 'typedoc_local_enabled', 0)
let g:typedoc_local_cmd = get(g:, 'typedoc_local_cmd', 'touch ./typedoc.json')

" typedoc - Auto regen
let g:typedoc_auto_regen = get(g:, 'typedoc_auto_regen', 1)
let g:typedoc_cmd = get(g:, 'typedoc_cmd', 'typedoc')

" typedoc - Open on browser
let g:typedoc_browser_cmd = get(g:, 'typedoc_browser_cmd', 'xdg-open')
let g:typedoc_browser_file = get(g:, 'typedoc_browser_file', '/docs/index.html')

" typedoc - Verbose
let g:typedoc_verbose_manual_regen = get(g:, 'typedoc_verbose_open', '1')
let g:typedoc_verbose_open = get(g:, 'typedoc_verbose_open', '1')


" }}}




" typedoc Setup {{{

augroup typedoc_detect
    autocmd!
    autocmd BufNewFile,BufReadPost *  call typedoc#setup_typedoc()
    autocmd VimEnter               *  if expand('<amatch>')==''|call typedoc#setup_typedoc()|endif
augroup end

" }}}




" Misc Commands {{{

if g:typedoc_define_advanced_commands
    command! TypedocToggleEnabled :let g:typedoc_enabled=!g:typedoc_enabled
    command! TypedocToggleTrace   :call typedoc#toggletrace()
endif

" }}}

