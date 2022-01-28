if vim.filetype and vim.filetype.add then
  vim.filetype.add {
    extension = {
      gitignore = 'gitignore',
    },
    filename = {
      ['.gitignore'] = 'gitignore',
      ['.ignore'] = 'gitignore',
      ['.fdignore'] = 'gitignore', -- fd
      ['.rgignore'] = 'gitignore', -- ripgrep
    },
  }
end
