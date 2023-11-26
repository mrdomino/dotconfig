vim.cmd('syntax off')
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }
vim.opt.showbreak = '↪ '
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.mouse = ''
vim.g.mapleader = ';'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require'lazy'.setup {
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = {
          "bash",
          "beancount",
          "c",
          "cpp",
          "css",
          "git_rebase",
          "gitcommit",
          "go",
          "hoon",
          "html",
          "javascript",
          "lua",
          "python",
          "rust",
          "tsx",
          "typescript",
          "vim",
        },
        indent = { enable = true },
      }
    end
  },
}
