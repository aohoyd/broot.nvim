local Float = require("broot.float")
--@type Config
local Config = require("broot.config")

local M = {}

M.init = function()
  local opts = Config.options
  if vim.fn.filereadable(opts.broot_vim_conf_path) == 1 then
    return
  end

  local parent_dir = vim.fn.fnamemodify(opts.broot_vim_conf_path, ":h")
  if vim.fn.isdirectory(parent_dir) == 0 then
    vim.loop.fs_mkdir(parent_dir, 448)
  end
  vim.fn.writefile(opts.broot_vim_conf, opts.broot_vim_conf_path)
end

local function cmd_to_open(cmd, ln, file)
  if ln == 0 then
    return string.format("%s %s", cmd, file)
  end
  return string.format("%s +%d %s", cmd, ln, file)
end

local function parse_lines(lines)
  local filtered_files = {}
  for _, line in ipairs(lines) do
    local ln, file = 0, line

    local ln_match, file_match = line:match("^%s*+(%d+)%s+(.*)")
    file_match = file_match or line

    ln = tonumber(ln_match) or 0
    file = file_match:gsub("^%s+", "")

    if vim.fn.filereadable(file) == 1 then
      table.insert(filtered_files, { file = file, ln = ln })
    end
  end

  if #filtered_files > 0 then
    vim.cmd(cmd_to_open("edit", filtered_files[1].ln, filtered_files[1].file))
    table.remove(filtered_files, 1)
  end

  for _, file in ipairs(filtered_files) do
    vim.cmd(cmd_to_open(Config.options.open_split_type, file.ln, file.file))
  end
end

local function remove_file(file)
  if vim.fn.filereadable(file) ~= 0 then
    os.remove(file)
  end
end

-- Opens a floating window
M.open = function(path)
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) == 0 then
    path = Config.options.default_explore_path
  end

  local tmp_file = os.tmpname()
  local broot_command =
      string.format("%s %s %s %s", Config.options.broot_command, path, Config.options.shellredir, tmp_file)
  local cmd = { Config.options.shell, Config.options.shellcmdflag, broot_command }

  local opts = {
    ft = "broot",
    size = Config.options.ui.size,
    border = Config.options.ui.border,
  }

  local float = Float.new(opts)

  for _, key in ipairs(Config.options.pass_keys) do
    vim.keymap.set("t", key, key, { buffer = float.buf, nowait = true })
  end

  local function on_exit(_, e, _)
    if e ~= 0 then
      float:wipe()
      remove_file(tmp_file)
      return
    end

    local lines = {}
    if vim.fn.filereadable(tmp_file) then
      for line in io.lines(tmp_file) do
        table.insert(lines, line)
      end
    end

    parse_lines(lines)

    float:wipe()
    remove_file(tmp_file)
  end

  local terminal = vim.fn.termopen(cmd, { on_exit = on_exit })

  vim.cmd.startinsert()
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = float.buf,
    callback = function()
      vim.cmd.startinsert()
    end,
  })

  vim.api.nvim_create_autocmd("TermClose", {
    once = true,
    buffer = float.buf,
    callback = function()
      float:close()
      vim.cmd.checktime()
    end,
  })

  return terminal
end

local function root()
  local buf = vim.api.nvim_get_current_buf()

  local buf_path = vim.api.nvim_buf_get_name(assert(buf)) or vim.loop.cwd()
  local path = vim.loop.fs_realpath(buf_path) or buf_path
  local root_path =
      vim.fs.find(Config.options.root_patterns, { path = path, upward = true, stop = vim.loop.os_homedir() })[1]
  return root_path and vim.fs.dirname(root_path) or vim.loop.cwd()
end

local function create_commands()
  vim.api.nvim_create_user_command("Broot", function()
    M.open(Config.options.default_explore_path)
  end, {})
  vim.api.nvim_create_user_command("BrootCurrentDir", function()
    M.open("%:p:h")
  end, {})
  vim.api.nvim_create_user_command("BrootWorkingDir", function()
    M.open(".")
  end, {})
  vim.api.nvim_create_user_command("BrootHomeDir", function()
    M.open("~")
  end, {})
  vim.api.nvim_create_user_command("BrootProjectDir", function()
    M.open(root())
  end, {})
end

M.setup = function(opts)
  Config.setup(opts)

  M.init()

  create_commands()
end

return M
