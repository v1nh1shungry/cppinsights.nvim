if _G.cppinsights_loaded then
  return
end

_G.cppinsights_loaded = true

vim.api.nvim_create_user_command('CppInsights', function() require('cppinsights').run() end, {})
