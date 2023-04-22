# vim-typedoc
Out of the box, this plugin automatically regenerates your typedoc
documentation. Currently, this plugin is in highly experimental state.

## Dependencies
```sh
# For this to work, you must install typedoc like
sudo npm -g typedoc
```

You also need to have this on the tsconfig.json
```typescript
{
  "typedocOptions": {
    "entryPoints": './index.ts',
    "out": 'docs'
  }
}
```

## Documentation
Please use <:h typedoc> on vim to read the [full documentation](https://github.com/Zeioth/vim-typedoc/blob/main/doc/typedoc.txt).

## How to use

You just need to define the next keybindings (you MUST setup this)

```
" Shortcuts to open and generate docs
nmap <silent> <C-k> :<C-u>TypedocRegen<CR>
nmap <silent> <C-h> :<C-u>TypedocOpen<CR>
```

Enable automated doc generation on save (optional)
```
let g:typedoc_auto_regen = 1

" typedoc - Open on browser
let g:typedoc_browser_cmd = get(g:, 'typedoc_browser_cmd', 'xdg-open')
let g:typedoc_browser_file = get(g:, 'typedoc_browser_file', './docs/index.html')
```

Custom command to generate the typedoc documentation (optional)

```
let g:typedoc_cmd = get(g:, 'typedoc_cmd', 'typedoc')
```

Change the way the root of the project is detected (optional)

```
" By default, we detect the root of the project where the first .git file is found
g:typedoc_project_root = ['.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout']
```

## Final notes

Please have in mind that you are responsable for adding your typedoc directory to the .gitignore if you don't want it to be pushed by accident.

It is also possible to disable this plugin for a single project. For that, create .notypedoc file in the project root directory.

## Credits
This project started as a hack of [vim-doxygen](https://github.com/Zeioth/vim-doxygen), which started as a hack of [vim-guttentags](https://github.com/ludovicchabant/vim-gutentags). We use its boiler plate functions to manage directories in vimscript with good compatibility across operative systems. So please support its author too if you can!
