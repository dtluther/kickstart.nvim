-- copilot
-- https://github.com/zbirenbaum/copilot.lua?tab=readme-ov-file#setup-and-configuration

return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup()
  end,
}
