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
