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

vim.o.completeopt = 'menuone,noinsert,fuzzy'
require('mini.completion').setup({
  delay = { completion = 50, info = 0 },
})
