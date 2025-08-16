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
  local item_kind = vim.lsp.protocol.CompletionItemKind
  local textformat = vim.lsp.protocol.InsertTextFormat

  -- For each item, use only its first keyword part as the completion word if
  -- possible, which can increase the fuzzy-filtering accuracy and stop Nvim
  -- from inserting too many useless characters when it gets selected.
  for _, item in ipairs(items) do
    -- For snippet items, respect the abbr/word/filterText anyway, since they
    -- are configured intentionally.
    if item.kind ~= item_kind.Snippet then
      local abbr = item.label -- word shown in popupmenu
      local word = abbr:match('^[-_.%w]+') or abbr -- word used to match
      local textedit = (item.textEdit or {}).newText
      local inserttext = textedit or item.insertText or abbr -- word to be inserted

      item.filterText = word
      item.sortText = word

      if word == inserttext and word == abbr then
        -- If the completion word matches the text to be inserted, do not make it
        -- a potential snippet, since some LSPs report all items as snippets.
        item.insertTextFormat = textformat.PlainText
      else
        -- Otherwise, ensure the new item can be recognized as a snippet by
        -- mini.completion. The presence of at least one tabstop is important,
        -- which resolves <https://github.com/echasnovski/mini.nvim/issues/1944>.
        item.insertTextFormat = textformat.Snippet
        local has_tabstop = inserttext:find('[^\\]%${?%w') or inserttext:find('^%${?%w')
        if has_tabstop then
        elseif textedit then
          item.textEdit.newText = textedit .. '$0'
        else
          item.insertText = inserttext .. '$0'
        end
      end
    end
  end

  return items
end

-- Must be executed before mini.completion's autocommmands
vim.api.nvim_create_autocmd('CompleteDonePre', {
  desc = 'Filter out unintended confirms',
  callback = function()
    -- Only use certain keys to confirm a completion.
    -- This resolves <https://github.com/echasnovski/mini.nvim/issues/1938>.
    if not vim.g.complete_confirm then
      vim.v.completed_item = vim.empty_dict()
    else
      vim.g.complete_confirm = nil
    end
  end,
})

-- Deliberately select the key to accept a completion
local whitelist = { '<C-y>', '<CR>', '(' }
for _, key in ipairs(whitelist) do
  vim.keymap.set('i', key, function()
    vim.g.complete_confirm = true
    return '<C-y>'
  end, { expr = true })
end

require('mini.completion').setup({
  lsp_completion = { process_items = process_lsp_items },
})
