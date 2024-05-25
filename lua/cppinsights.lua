local M = {}

local options = {
  standard = 'cpp17',
  alternative_styles = {
    ['alt-syntax-for'] = false,
    ['alt-syntax-subscription'] = false,
  },
  more_transformations = {
    ['all-implicit-casts'] = false,
    ['show-all-callexpr-template-parameters'] = false,
    ['use-libcpp'] = false,
    ['edu-show-initlist'] = false,
    ['edu-show-noexcept'] = false,
    ['edu-show-padding'] = false,
    ['edu-show-coroutines'] = false,
    ['edu-show-cfront'] = false,
    ['edu-show-lifetime'] = false,
  },
}

M.setup = function(opt)
  options = vim.tbl_deep_extend('force', options, opt)
end

local notify = function(msg, level)
  vim.notify(msg, level, { title = 'cppinsights.nvim' })
end

M.run = function()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_winnr = vim.api.nvim_get_current_win()
  local current_filename = vim.fn.expand('%')

  local request = {}
  local buf_contents = vim.api.nvim_buf_get_lines(current_bufnr, 0, -1, false)
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
  notify('Connecting to cppinsights.io ...')
  vim.system(
    {
      'curl',
      'https://cppinsights.io/api/v1/transform',
      '-X',
      'POST',
      '-d',
      vim.json.encode(request),
      '--header',
      'Content-Type: application/json',
    },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        notify('Faild to connect to https://cppinsights.io:\n' .. res.stderr, vim.log.levels.ERROR)
        return
      end
      res = vim.json.decode(res.stdout)
      if res.returncode == 1 then
        local diagnostics = vim.fn.split(res.stderr:gsub('/home/insights/insights%.cpp', current_filename), '\n')
        notify(res.stdout, vim.log.levels.ERROR)
        vim.fn.setqflist({}, ' ', { title = 'C++ Insights' })
        vim.fn.setqflist({}, 'a', { lines = diagnostics })
        vim.cmd('bot 10 copen')
        vim.cmd('wincmd p')
      else
        local opts = vim.b[current_bufnr].cppinsights or {}
        local output = vim.split(res.stdout, '\n')
        if opts.buf == nil or not vim.api.nvim_buf_is_valid(opts.buf) then
          opts.buf = vim.api.nvim_create_buf(false, true)
          vim.bo[opts.buf].filetype = 'cpp'
        end
        if opts.win == nil or not vim.api.nvim_win_is_valid(opts.win) then
          opts.win = vim.api.nvim_open_win(opts.buf, false, { split = 'right', win = current_winnr })
        end
        vim.bo[opts.buf].modifiable = true
        vim.api.nvim_buf_set_lines(opts.buf, 0, -1, false, output)
        vim.bo[opts.buf].modifiable = false
        vim.b[current_bufnr].cppinsights = opts
      end
    end)
  )
end

return M
