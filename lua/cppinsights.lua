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
  options = vim.tbl_deep_extend('force', options, opt)
end

local error = function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'cppinsights.nvim' })
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
  vim.system({
    'curl',
    'https://cppinsights.io/api/v1/transform',
    '-X',
    'POST',
    '-d',
    vim.json.encode(request),
    '--header',
    'Content-Type: application/json',
  }, {}, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      error("Can't connect to https://cppinsights.io:\n" .. res.stderr)
      return
    end
    res = vim.json.decode(res.stdout)
    if res.returncode == 1 then
      local diagnostics = vim.fn.split(res.stderr, '\n')
      error(res.stdout)
      vim.fn.setqflist({}, ' ', { title = 'C++ Insights' })
      vim.fn.setqflist({}, 'a', { lines = diagnostics })
      vim.cmd 'bot 10 copen'
      vim.cmd 'wincmd p'
    else
      local output = vim.split(res.stdout, '\n')
      local buf = vim.api.nvim_create_buf(false, true)
      local bo = vim.bo[buf]
      bo.ft = 'cpp'
      bo.bufhidden = 'wipe'
      bo.modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
      bo.modifiable = false
      vim.api.nvim_buf_set_name(buf, 'C++ Insights')
      vim.cmd.vsplit()
      vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
      vim.cmd 'wincmd p'
    end
  end))
end

return M
