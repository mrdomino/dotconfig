vim.cmd.syntax 'off'
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
vim.g.localleader = '\\'

-- Use C-i to get an indent rather than supertab
vim.keymap.set('i', '<C-i>', '<Tab>')

vim.g.python3_host_prog = vim.fn.stdpath('data') .. '/virtualenv/bin/python3'
if not vim.loop.fs_stat(vim.g.python3_host_prog) then
  vim.fn.system {
    'virtualenv',
    '--system-site-packages',
    vim.fn.stdpath('data') .. '/virtualenv',
  }
end

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
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        auto_install = true,
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
    end,
    keys = {
      { '<localleader>th', function () vim.cmd.TSBufToggle 'highlight' end }
    },
    lazy = false,
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
    cmd = { 'UndotreeToggle' },
    keys = {
      { '<leader>u', vim.cmd.UndotreeToggle },
    },
  },

  { 'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = { },
  },

  { 'williamboman/mason.nvim',
    config = true,
  },

  { 'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function ()
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },

  { 'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = 'L3MON4D3/LuaSnip',
    config = function ()
      local lsp_zero = require'lsp-zero'
      lsp_zero.extend_cmp()
      local cmp = require'cmp'
      local cmp_action = lsp_zero.cmp_action()
      cmp.setup {
        preselect = 'item',
        completion = {
          autocomplete = false,
          completeopt = 'menu,menuone,noinsert',
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm { select = false },
          -- ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
          ['<Tab>'] = cmp_action.luasnip_supertab(),
          ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
        }
      }
    end,
  },

  { 'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function ()
      local lsp_zero = require'lsp-zero'
      lsp_zero.extend_lspconfig()
      lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps { buffer = bufnr }
      end)
      require'mason-lspconfig'.setup {
        ensure_installed = {},
        handlers = {
          lsp_zero.default_setup,
        },
      }
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
  },

  { 'pmizio/typescript-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
    },
    ft = {
      'javascript',
      'javascript.jsx',
      'javascriptreact',
      'typescript',
      'typescript.tsx',
      'typescriptreact',
    },
    keys = {
      { '<leader>tso', '<cmd>TSToolsOrganizeImports<cr>' },
      { '<leader>tss', '<cmd>TSToolsSortImports<cr>' },
      { '<leader>tsi', '<cmd>TSToolsRemoveUnusedImports<cr>' },
      { '<leader>tsu', '<cmd>TSToolsRemoveUnused<cr>' },
      { '<leader>tsf', '<cmd>TSToolsFixAll<cr>' },
      { '<leader>tsd', '<cmd>TSToolsGoToSourceDefinition<cr>' },
      { '<leader>tsr', '<cmd>TSToolsRenameFile<cr>' },
    },
    opts = {},
  },

  { 'dpayne/CodeGPT.nvim',
    cmd = 'Chat',
    config = function ()
      require'codegpt.config'
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
  },
}
