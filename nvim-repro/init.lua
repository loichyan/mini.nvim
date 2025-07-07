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

require('mini.completion').setup()
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

-- Track logs
_G.log = {}
_G.save_logs = function()
  local f = io.open('nvim-repro/logs.txt', 'w')
  f:write(vim.inspect(log))
  f:close()
  vim.cmd.edit('nvim-repro/logs.txt')
end
vim.api.nvim_create_autocmd({ 'CompleteDone', 'CompleteDonePre' }, {
  callback = function(ev)
    table.insert(log, {
      event = ev.event,
      ['v:event'] = vim.v.event,
      ['v:completed_item'] = vim.v.completed_item,
    })
  end,
})
