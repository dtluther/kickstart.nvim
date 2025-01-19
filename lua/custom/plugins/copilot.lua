-- copilot
-- https://github.com/zbirenbaum/copilot.lua?tab=readme-ov-file#setup-and-configuration

-- Default Configuration
-- require('copilot').setup({
--   panel = {
--     enabled = true,
--     auto_refresh = false,
--     keymap = {
--       jump_prev = "[[",
--       jump_next = "]]",
--       accept = "<CR>",
--       refresh = "gr",
--       open = "<M-CR>"
--     },
--     layout = {
--       position = "bottom", -- | top | left | right | horizontal | vertical
--       ratio = 0.4
--     },
--   },
--   suggestion = {
--     enabled = true,
--     auto_trigger = false,
--     hide_during_completion = true,
--     debounce = 75,
--     keymap = {
--       accept = "<M-l>",
--       accept_word = false,
--       accept_line = false,
--       next = "<M-]>",
--       prev = "<M-[>",
--       dismiss = "<C-]>",
--     },
--   },
--   filetypes = {
--     yaml = false,
--     markdown = false,
--     help = false,
--     gitcommit = false,
--     gitrebase = false,
--     hgcommit = false,
--     svn = false,
--     cvs = false,
--     ["."] = false,
--   },
--   copilot_node_command = 'node', -- Node.js version must be > 18.x
--   server_opts_overrides = {},
-- })

return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<Tab>',
        },
      },
    }

    -- Custom Tab keybinding logic
    vim.keymap.set('i', '<Tab>', function()
      -- If a Copilot suggestion is visible, accept it
      if require('copilot.suggestion').is_visible() then
        require('copilot.suggestion').accept()
      else
        -- Otherwise, fall back to the default Tab behavior (e.g., indentation or snippet jumping)
        return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
      end
    end, { expr = true, noremap = true }) -- 'expr' allows the function to return a result, 'noremap' avoids remapping loops

    vim.keymap.set('i', '<S-Tab>', function()
      -- Always fall back to the default Shift-Tab behavior (e.g., reverse indentation or snippet jumping)
      return vim.api.nvim_replace_termcodes('<S-Tab>', true, true, true)
    end, { expr = true, noremap = true }) -- Same options as above
  end,
}
