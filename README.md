# gitignore.nvim

Work with `.gitignore` files.

## Features

- Highlight `.gitignore` files.
- Generate `.gitignore` files with common exclude patterns for various languages and tools.

## Installation

Using packer.nvim:

```lua
use {
  'shunsambongi/gitignore.nvim',
  requires = "nvim-lua/plenary.nvim",
}
```

### Highlights

Highlights are provided by tree-sitter. Install the gitignore parser from [https://github.com/shunsambongi/tree-sitter-gitignore](https://github.com/shunsambongi/tree-sitter-gitignore):

```lua
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.gitignore = {
  install_info = {
    url = 'https://github.com/shunsambongi/tree-sitter-gitignore',
    files = { 'src/parser.c' },
    branch = 'main',
  },
  filetype = 'gitignore',
}
```

## Generate `.gitignore` files

Generate `.gitignore` files based on templates with common exclude patterns. Templates are provided by [gitignore.io](https://gitignore.io). There is a `telescope.nvim` picker for selecting the templates.

Load the extension:

```lua
require('telescope').load_extension 'gitignore'
```

and run the following command:

```viml
Telescope gitignore templates
```
