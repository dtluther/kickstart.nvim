-- Map <leader>r in visual mode:
-- Replace the highlighted text by using it as the search pattern in a substitution command.
-- The selected text is first yanked into register "h", then used to populate the search field.
vim.keymap.set('v', '<leader>r', '"hy:%s/<C-r>h//g<Left><Left>', {
  noremap = true,
  silent = false,
  desc = 'Replace highlighted text globally',
})

vim.keymap.set('v', '<leader>R', '"hy:%s/<C-r>h//gc<Left><Left><Left>', {
  noremap = true,
  silent = false,
  desc = 'Replace highlighted text globally with confirmation',
})

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  -- Use the system clipboard by default.
  vim.opt.clipboard = 'unnamedplus'
end)

-- Remap visual mode paste to avoid overwriting the clipboard.
-- Explanation:
-- 1. When in visual mode ("x"), pressing 'p':
--    - '"_d' deletes the selected text into the black hole register,
--      which discards it instead of updating your clipboard.
--    - 'P' pastes the content from your current clipboard before the cursor.
-- 2. This ensures that you can press 'p' repeatedly to paste the same content,
--    since the clipboard remains unchanged.
vim.keymap.set('x', 'p', '"_dP', { noremap = true, silent = true })
