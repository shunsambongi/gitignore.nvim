# gitignore.nvim

Work with `.gitignore` files.

## Tree-sitter parser

Install the gitignore parser from [https://github.com/shunsambongi/tree-sitter-gitignore](https://github.com/shunsambongi/tree-sitter-gitignore), and add the following to your neovim configuration.

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
