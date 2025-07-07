-- Clone latest 'mini.nvim' (requires Git CLI installed)
vim.cmd('echo "Installing `mini.nvim`" | redraw')
local mini_path = vim.fn.stdpath('data') .. '/site/pack/deps/start/mini.nvim'
local clone_cmd = { 'git', 'clone', '--depth=1', 'https://github.com/echasnovski/mini.nvim', mini_path }
vim.fn.system(clone_cmd)
vim.cmd('echo "`mini.nvim` is installed" | redraw')

-- Make sure 'mini.nvim' is available
vim.cmd('packadd mini.nvim')
require('mini.deps').setup()

-- Add extra setup steps needed to reproduce the behavior
-- Use `MiniDeps.add('user/repo')` to install another plugin from GitHub

---Removes the argument part from each function-like completion item.
local postprocess_items = function(items)
  if type(items) ~= 'table' then return items end
  for _, item in ipairs(items) do
    local word = item.abbr or item.word
    item.abbr = word -- Show the original word anyway
    item.word = word:match('([-_.%w]+)%(.*%)') or item.word
  end
  return items
end

require('mini.completion').setup()

local completefunc = MiniCompletion.completefunc_lsp
MiniCompletion.completefunc_lsp = function(...) return postprocess_items(completefunc(...)) end

-- Press '<CR>' to expand snippet when selected
_G.cr_action = function()
  if vim.fn.complete_info()['selected'] ~= -1 then return '\25' end
  return '\r'
end
vim.keymap.set('i', '<CR>', 'v:lua.cr_action()', { expr = true })

-- Press '(' to expand snippet when selected
_G.pair_action = function()
  if vim.fn.complete_info()['selected'] ~= -1 then return '\25' end
  return '('
end
vim.keymap.set('i', '(', 'v:lua.pair_action()', { expr = true })

-- Manually close the completion menu
vim.keymap.set('i', '<C-c>', '<C-o><Esc>')

-- Configurations for tracking logs --------------------------------------------

vim.o.signcolumn = 'yes'

-- Copied from: https://github.com/neovim/nvim-lspconfig/blob/45ff1914044de7dbd4cd85053dc09f47312a2f4d/lsp/lua_ls.lua#L70
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
    },
  },
})
vim.lsp.enable('lua_ls')
