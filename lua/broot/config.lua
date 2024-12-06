local M = {}

M.defaults = {
  broot_conf_path = vim.fn.expand("~/.config/broot/conf.hjson"),
  broot_vim_conf_path = vim.fn.expand(vim.fn.stdpath("data") .. "/broot.nvim/conf_nvim.hjson"),
  broot_vim_conf = {
    "verbs: [",
    "  {",
    "    key: enter",
    '    external: "echo +{line} {file}"',
    '    apply_to: "file"',
    "  }",
    "]",
  },
  broot_exec = "broot",

  shell = vim.o.shell,
  shellcmdflag = vim.o.shellcmdflag,
  shellredir = vim.o.shellredir,

  default_explore_path = "%:p:h",

  broot_replace_netrw = 0,

  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    size = { width = 0.8, height = 0.8 },
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "shadow",
  },

  -- Keystrokes to pass into broot
  pass_keys = { "<esc>", "<c-h>", "<c-j>", "<c-k>", "<c-l>" },

  open_split_type = "vsplit",

  root_patterns = { ".git" },
}

-- taken from https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/48ffb8de688a22942940f50411d5928631368848/lua/telescope/_extensions/file_browser/config.lua#L72
M.hijack_netrw = function()
  local netrw_bufname

  -- clear FileExplorer appropriately to prevent netrw from launching on folders
  -- netrw may or may not be loaded before broot.nvim config
  -- conceptual credits to nvim-tree
  pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    once = true,
    callback = function()
      pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("broot", { clear = true }),
    pattern = "*",
    callback = function()
      vim.schedule(function()
        if vim.bo[0].filetype == "netrw" then
          return
        end
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(bufname) == 0 then
          _, netrw_bufname = pcall(vim.fn.expand, "#:p:h")
          return
        end

        -- prevents reopening of file-browser if exiting without selecting a file
        if netrw_bufname == bufname then
          netrw_bufname = nil
          return
        else
          netrw_bufname = bufname
        end

        -- ensure no buffers remain with the directory name
        vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")

        require("broot").open(vim.fn.expand("%:p:h"))
      end)
    end,
    desc = "broot.nvim replacement for netrw",
  })
end

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("keep", opts, M.defaults)

  M.options.broot_command =
      string.format("%s --conf '%s;%s'", M.options.broot_exec, M.options.broot_conf_path, M.options.broot_vim_conf_path)

  if M.options.broot_replace_netrw then
    M.hijack_netrw()
  end
end

return M
