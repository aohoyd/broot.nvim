# broot.nvim

> [broot.vim](https://github.com/lstwn/broot.vim) plugin port to lua with several tweaks

A tiny plugin that integrates [broot](https://github.com/Canop/broot) with neovim.

Broot is configured in such a way that when pressing enter _on a file_ this file
is opened in vim.

Staging area is also supported. Choose several files, go to staging area's panel
and execute `:pp`. Chosen files will be opened in splits.

At the same time, your broot `conf.hjson` is respected, i.e. only the little
mentioned enter behavior is appended to your defaults!

## Installation

Use your favourite vim plugin manager. For instance, with `lazy.vim`:

```
{ "aohoyd/broot.nvim", opts = {} }
```

Then try `:Broot` in nvim which opens broot in nvim's current working directory in a floating window.

## Customization

### Configuration

| variable name                                    | description                                                                                                                               | default value                                                                                                                                              |
| ---------------------------------------          | -----------------------------------------------------------------------------------------------------------                               | --------------------------------------------------------------------------------------------                                                               |
| `broot_conf_path`                                | path to broot's default `conf.hjson` (assumes HJSON config format per default, adjust if using TOML!)                                     | `expand('~/.config/broot/conf.hjson')`                                                                                                                     |
| `broot_vim_conf_path`                            | path to store appended config. It won't rewrite existing file                                                                             | `expand(stdpath("data") .. "/broot.nvim/conf_nvim.hjson")`                                                                                                 |
| `broot_vim_conf`                                 | appended broot config                                                                                                                     | `"verbs: [", "  {", "    key: enter", '    external: "echo +{line} {file}"', '    apply_to: "file"', "  }", "]"`                                           |
| `broot_exec`                                     | broot launch command                                                                                                                      | `broot`                                                                                                                                                    |
| `shell`                                          | shell in which broot should be runned (per default it respects your shell choice)                                                         | `&shell`                                                                                                                                                   |
| `shellcmdflag`                                   | command flag for shell (per default it respects your shell choice)                                                                        | `&shellcmdflag`                                                                                                                                            |
| `broot_default_explore_path`                     | default path to explore                                                                                                                   | `.`                                                                                                                                                        |
| `broot_replace_netrw`                            | set to TRUE (e.g. 1) if you want to replace netrw (see below)                                                                             | off                                                                                                                                                        |
| `ui.size.width`                                  | width of floating window                                                                                                                  | `0.8`                                                                                                                                                      |
| `ui.size.height`                                 | height of floating window                                                                                                                 | `0.8`                                                                                                                                                      |
| `ui.border`                                      | the border to use for the UI window. Accepts same border values as `nvim_open_win()`                                                      | `shadow`                                                                                                                                                   |
| `pass_keys`                                      | list of keystrokes to pass into broot                                                                                                     | `"<esc>", "<c-h>", "<c-j>", "<c-k>", "<c-l>"`                                                                                                              |
| `open_split_type`                                | type of split for several opened files                                                                                                    | `vsplit`                                                                                                                                                   |
| `root_patterns`                                  | list of files which indicates project's root                                                                                              | `".git"`                                                                                                                                                   |

### Commands

Here are the defined commands:

```
vim.api.nvim_create_user_command("Broot",           function() M.open(Config.options.default_explore_path) end, {})
vim.api.nvim_create_user_command("BrootCurrentDir", function() M.open("%:p:h")                             end, {})
vim.api.nvim_create_user_command("BrootWorkingDir", function() M.open(".")                                 end, {})
vim.api.nvim_create_user_command("BrootHomeDir",    function() M.open("~")                                 end, {})
vim.api.nvim_create_user_command("BrootProjectDir", function() M.open(vim.loop.cwd())                      end, {})
```

### Hijacking netrw

If you set `broot_replace_netrw = 1` in module's config,
netrw will not launch anymore if you open a folder but instead launch broot.


## Thanks

- This project is a port of [broot.vim](https://github.com/lstwn/broot.vim) and many things are reused from there
- Floating window's implementation was taken from the great [lazy.vim](https://github.com/folke/lazy.nvim.git)
- netrw hijacking part was taken from [telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim.git)

