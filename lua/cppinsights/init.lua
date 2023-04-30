local M = {}

local options = {
  standard = 'cpp17',
  alternative_styles = {
    ['alt-syntax-for'] = false,
    ['alt-syntax-subscription'] = false,
  },
  more_transformations = {
    ['all-implicit-casts'] = false,
    ['use-libcpp'] = false,
    ['edu-show-initlist'] = false,
    ['edu-show-noexcept'] = false,
    ['edu-show-padding'] = false,
    ['edu-show-coroutines'] = false,
  },
}

M.setup = function(opt)
  opt = opt or {}
  options = vim.tbl_deep_extend('force', options, opt)
end

M.run = function()
  local request = {}
  local buf_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  request.code = table.concat(buf_contents, '\n')
  request.insightsOptions = { options.standard }
  for key, enabled in pairs(options.alternative_styles) do
    if enabled then
      request.insightsOptions[#request.insightsOptions + 1] = key
    end
  end
  for key, enabled in pairs(options.more_transformations) do
    if enabled then
      request.insightsOptions[#request.insightsOptions + 1] = key
    end
  end
  require('plenary.curl').post('https://cppinsights.io/api/v1/transform', {
    body = vim.fn.json_encode(request),
    callback = vim.schedule_wrap(function(res)
      res = vim.fn.json_decode(res.body)
      assert(res ~= nil)
      if res.returncode == 1 then
        local diagnostics = vim.fn.split(res.stderr, '\n')
        vim.notify(res.stdout, vim.log.levels.ERROR)
        vim.fn.setqflist({}, ' ', { title = 'C++ Insights' })
        vim.fn.setqflist({}, 'a', { lines = diagnostics })
        vim.cmd 'bot 10 copen'
        vim.cmd 'wincmd p'
      else
        local output = vim.split(res.stdout, '\n')
        local new_bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(new_bufnr, 'ft', 'cpp')
        vim.api.nvim_buf_set_option(new_bufnr, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_name(new_bufnr, 'C++ Insights')
        vim.cmd.vsplit()
        vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), new_bufnr)
        vim.api.nvim_buf_set_option(new_bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, output)
        vim.api.nvim_buf_set_option(new_bufnr, 'modifiable', false)
        vim.cmd 'wincmd p'
      end
    end),
    headers = { content_type = 'application/json' },
  })
end

return M
