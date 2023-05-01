# vim-typedoc
Out of the box, this plugin automatically regenerates your typedoc
documentation. Currently, this plugin is in highly experimental state.

## Dependencies
```sh
# For this to work, you must install typedoc like
sudo npm -g typedoc
```

## Documentation
Please use <:h typedoc> on vim to read the [full documentation](https://github.com/Zeioth/vim-typedoc/blob/main/doc/typedoc.txt).

## How to use
Copy this in your vimconfig:

```
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim typedoc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable it for the next languages
let g:typedoc_include_filetypes = ['typescript']

" Enable the keybindings for the languages in g:typedoc_include_filetypes
augroup typedoc_mappings
  for ft in g:typedoc_include_filetypes
    execute 'autocmd FileType ' . ft . ' nnoremap <buffer> <C-h> :<C-u>TypedocOpen<CR>'
    "execute 'autocmd FileType ' . ft . ' nnoremap <buffer> <C-k> :<C-u>TypedocRegen<CR>'
  endfor
augroup END
```

## Most frecuent options users customize

Enable automated typedoc.json file generation (optional)
```
" Clone a default typedoc.json file into the project (ENABLED BY DEFAULT)
" Check the template here: https://github.com/Zeioth/vim-typedoc-template
g:typedoc_auto_setup = 1

" OPTIONAL: You can provide a custom typedoc.json.
let g:typedoc_clone_config_repo = 'https://github.com/Zeioth/typedoc-vim-template.git'
let g:typedoc_clone_destiny_dir = './typedoc'
let g:typedoc_clone_cmd = 'git clone'

" IMPORTANT: The default typedoc.json we create assumes the entry point of the program is './src/main.js'.
"            This is the default entry point for angular projects, but if your project has a different 
"            entry point, you will have to manually edit './typedoc.json'.
```

Enable automated doc generation on save (optional)
```
" Enabled by default for the languages defined in g:typedoc_include_filetypes
let g:typedoc_auto_regen = 1
```

Change the way the documentation is opened (optional)
```
" typedoc - Open on browser
let g:typedoc_browser_cmd = get(g:, 'typedoc_browser_cmd', 'xdg-open')
let g:typedoc_browser_file = get(g:, 'typedoc_browser_file', './docs/index.html')
```

Custom command to generate the typedoc documentation (optional)

```
let g:typedoc_cmd = 'typedoc'
```

Change the way the root of the project is detected (optional)

```
" By default, we detect the root of the project where the first .git file is found
let g:typedoc_project_root = ['.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout']
```

## Final notes

Please have in mind that you are responsable for adding your typedoc directory to the .gitignore if you don't want it to be pushed by accident.

It is also possible to disable this plugin for a single project. For that, create .notypedoc file in the project root directory.

## Credits
This project started as a hack of [vim-doxygen](https://github.com/Zeioth/vim-doxygen), which started as a hack of [vim-guttentags](https://github.com/ludovicchabant/vim-gutentags). We use its boiler plate functions to manage directories in vimscript with good compatibility across operative systems. So please support its author too if you can!
