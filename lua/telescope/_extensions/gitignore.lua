return require('telescope').register_extension {
  exports = {
    templates = require('telescope._extensions.gitignore.templates'),
  },
}
