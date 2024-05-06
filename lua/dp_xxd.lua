local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
    } then
  return
end

M.xxd_output_dir_path = B.getcreate_temp_dirpath { 'xxd_output', }

function M.bin_xxd(file)
  if not file then
    file = B.buf_get_name()
  end
  local bin_fname = B.rep(file)
  local bin_fname_tail = vim.fn.fnamemodify(bin_fname, ':t')
  local bin_fname_full__ = string.gsub(vim.fn.fnamemodify(bin_fname, ':h'), '\\', '_')
  bin_fname_full__ = string.gsub(bin_fname_full__, ':', '_')
  local xxd_output_sub_dir_path = M.xxd_output_dir_path:joinpath(bin_fname_full__)
  if not xxd_output_sub_dir_path:exists() then
    vim.fn.mkdir(xxd_output_sub_dir_path.filename)
  end
  local xxd = xxd_output_sub_dir_path:joinpath(bin_fname_tail .. '.xxd').filename
  local c = xxd_output_sub_dir_path:joinpath(bin_fname_tail .. '.c').filename
  local bak = xxd_output_sub_dir_path:joinpath(bin_fname_tail .. '.bak').filename
  vim.fn.system(string.format('copy /y "%s" "%s"', bin_fname, bak))
  vim.fn.system(string.format('xxd "%s" "%s"', bak, xxd))
  vim.fn.system(string.format('%s && xxd -i "%s" "%s"', B.system_cd(bak), vim.fn.fnamemodify(bak, ':t'), c))
  vim.cmd('e ' .. xxd)
  vim.cmd 'setlocal ft=xxd'
end

function M._map()
  require 'which-key'.register {
    ['<leader>x'] = { name = 'xxd', },
    ['<leader>xx'] = { function() M.bin_xxd() end, 'xxd: do', mode = { 'n', 'v', }, silent = true, },
  }
end

return M
