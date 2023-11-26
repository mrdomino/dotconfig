vim.cmd[[syntax off]]
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
  { 'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      vim.cmd[[colorscheme tokyonight-night]]
    end,
  },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = {
          'bash',
          'beancount',
          'c',
          'cpp',
          'css',
          'git_rebase',
          'gitcommit',
          'go',
          'hoon',
          'html',
          'javascript',
          'lua',
          'python',
          'ruby',
          'rust',
          'tsx',
          'typescript',
          'vim',
        },
        indent = { enable = true },
      }
      vim.keymap.set('n', '<leader>th', function ()
        vim.cmd.TSBufToggle('highlight')
      end)
    end,
  },
  { 'nvim-telescope/telescope.nvim', tag = '0.1.4',
    config = function ()
      local builtin = require'telescope.builtin'
      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
    end,
    dependencies = 'nvim-lua/plenary.nvim',
    keys = {
      { '<leader>ff' },
      { '<leader>fg' },
    },
  },
  { 'mbbill/undotree',
    keys = {
      { '<leader>u', function () vim.cmd.UndotreeToggle() end },
    },
  },
}
