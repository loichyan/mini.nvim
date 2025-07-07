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

-- Install with:
-- ```sh
-- curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y
-- rustup toolchain install stable --profile minimal --component rust-analyzer
-- ```
-- For more information see <https://www.rust-lang.org/tools/install>.
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  settings = {},
})
vim.o.signcolumn = 'yes'
vim.lsp.enable('rust_analyzer')
