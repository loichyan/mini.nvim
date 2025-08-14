-- stylua: ignore start

-- This is treated as a snippet, hence word inserted is `test`.
local test = function(a, b, c) vim.print(a, b, c) end
-- This is *not* treated as a snippet, hence word inserted is `test2()`.
local test2 = function() end

-- CompleteDone with <C-y>




-- CompleteDone with <CR>/(




-- CompleteDone with <Space>




-- Cancel completion with <C-c>




