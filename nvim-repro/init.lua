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

-- Copied from: https://github.com/neovim/nvim-lspconfig/blob/45ff1914044de7dbd4cd85053dc09f47312a2f4d/lsp/lua_ls.lua#L70
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
    },
  },
})
vim.lsp.enable('lua_ls')
vim.o.signcolumn = 'yes'

local process_lsp_items = function(items)
  local snippet_kind = vim.lsp.protocol.CompletionItemKind.Snippet
  local snippet_format = vim.lsp.protocol.InsertTextFormat.Snippet

  for _, item in ipairs(items) do
    -- Match only the name for completion filtering of function-like items.
    local textedit = vim.tbl_get(item, 'textEdit', 'newText')
    local inserttext = item.insertText
    local word = textedit or inserttext or item.label
    local new_word = word:match('([-_.%w]+)%(.*%)')

    if not new_word then goto continue end
    item.filterText = item.filterText or new_word

    -- Adds a tabstop anyway for functions anyway to resolve
    -- <https://github.com/echasnovski/mini.nvim/issues/1938>.
    local is_snippet_kind = item.kind == snippet_kind
    local is_snippet_format = item.insertTextFormat == snippet_format
    if not is_snippet_kind and not is_snippet_format then goto continue end

    local has_tabstop = word:find('[^\\]%${?%w') or word:find('^%${?%w')
    if has_tabstop then
    elseif textedit then
      item.textEdit.newText = textedit .. '$0'
    else
      item.insertText = inserttext .. '$0'
    end

    ::continue::
  end

  return items
end

require('mini.completion').setup({
  lsp_completion = { process_items = process_lsp_items },
})

-- Completely disable the CompleteDonePre event
local enable_comp = function() vim.opt.eventignore:remove('CompleteDonePre') end
local disable_comp = function() vim.opt.eventignore:append('CompleteDonePre') end
vim.api.nvim_create_autocmd('InsertEnter', { callback = disable_comp })
vim.api.nvim_create_autocmd('InsertLeave', { callback = enable_comp })

-- But enable it for certain keys
local whitelist = { '<C-y>', '<CR>', '(' }
for _, key in ipairs(whitelist) do
  vim.keymap.set('i', key, function()
    enable_comp()
    local rawkey = vim.api.nvim_replace_termcodes(key, true, true, true)
    vim.api.nvim_feedkeys(rawkey, 'n', false)
    vim.schedule(disable_comp)
  end)
end
