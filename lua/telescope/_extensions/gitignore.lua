local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local previewers = require 'telescope.previewers'

local curl = require 'plenary.curl'
local log = require('plenary.log').new { plugin = 'gitignore' }

---@class Template
---@field name string
---@field key string
---@field fileName string
---@field contents string

---@return Template[]
local fetch_templates = function()
  local url = 'https://www.toptal.com/developers/gitignore/api/list?format=json'
  log.info('Fetching templates from %s...', url)

  local response = curl.get(url)
  assert(response.status < 400, response.body)

  local templates = {}
  for _, value in pairs(vim.fn.json_decode(response.body)) do
    table.insert(templates, value)
  end

  assert(#templates > 0, 'Fetched 0 templates.')

  table.sort(templates, function(a, b)
    return a.key < b.key
  end)

  return templates
end

---@return Template[]|nil
local load_templates = function(path)
  if not vim.loop.fs_stat(path) then
    return nil
  end

  log.debug 'Loading templates from cache...'
  local f = io.open(path, 'rb')
  local ok, templates = pcall(function()
    return vim.mpack.decode(f:read '*a')
  end)

  if not ok then
    log.warn(string.format('Corrupted cache file, %s. Invalidating...', path))
    os.remove(path)
  end

  return templates
end

---@param templates Template[]
---@param path string
local save_templates = function(templates, path)
  log.debug(string.format('Caching templates to cache file, %s', path))
  local f = io.open(path, 'w+b')
  f:write(vim.mpack.encode(templates))
  f:flush()
end

---@return Template[]
local get_templates = function() end

local generate = function(opts)
  opts = opts or {}

  local cache_path = vim.fn.stdpath 'cache' .. '/gitignore_templates'

  local templates = load_templates(cache_path)
  if not templates then
    templates = fetch_templates()
    save_templates(templates, cache_path)
  end

  pickers.new(opts, {
    prompt_title = '.gitignore templates',

    finder = finders.new_table {
      results = templates,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.key,
        }
      end,
    },

    sorter = conf.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer {
      define_preview = function(self, entry, status)
        local bufnr = self.state.bufnr
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.fn.split(entry.value.contents, '\n'))
        require('telescope.previewers.utils').highlighter(bufnr, 'gitignore')
      end,
    },

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selections = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
        if #selections == 0 then
          selections = { action_state.get_selected_entry() }
        end
        actions.close(prompt_bufnr)

        local result = ''
        for _, selection in ipairs(selections) do
          result = result .. selection.value.contents
        end

        local filename = vim.fn.fnamemodify('.gitignore', ':p')
        local f = io.open(filename, 'w+')
        f:write(result)
        f:flush()

        local message = string.format('Generated .gitignore file: %s', filename)
        vim.notify(message, vim.log.levels.INFO)
      end)
      return true
    end,
  }):find()
end

return require('telescope').register_extension {
  exports = {
    generate = generate,
  },
}
