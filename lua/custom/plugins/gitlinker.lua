return {
  'ruifm/gitlinker.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' }, -- Required dependency
  config = function()
    require('gitlinker').setup {
      opts = {
        action_callback = require('gitlinker.actions').copy_to_clipboard, -- Example: copy link to clipboard
      },
    }
  end,
}
