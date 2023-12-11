vim.cmd.syntax 'off'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }
vim.opt.showbreak = '↪ '
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.colorcolumn = '+1'
vim.opt.textwidth = 80
vim.opt.mouse = ''
vim.g.mapleader = ';'
vim.g.localleader = '\\'

vim.g.python3_host_prog = vim.fn.stdpath('data') .. '/virtualenv/bin/python3'
if not vim.loop.fs_stat(vim.g.python3_host_prog) then
  vim.fn.system {
    'python3', '-m', 'venv', '--system-site-packages',
    vim.fn.stdpath('data') .. '/virtualenv',
  }
  vim.fn.system {
    vim.fn.stdpath('data') .. '/virtualenv/bin/pip', 'install', 'pynvim',
  }
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require'lazy'.setup {
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
    end,
    keys = {
      { '<localleader>th',
        function () vim.cmd.TSBufToggle 'highlight' end,
        desc = 'Toggle highlighting'
      },
    },
    lazy = false,
  },
  { 'nvim-telescope/telescope.nvim', tag = '0.1.4',
    cmd = 'Telescope',
    dependencies = 'nvim-lua/plenary.nvim',
    keys = function ()
      local builtin = require'telescope.builtin'
      return {
        { '<leader>ff', builtin.find_files, desc = 'find files' },
        { '<leader>fg', builtin.live_grep, desc = 'live grep' },
      }
    end,
  },
  { 'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    keys = {
      { '<leader>u', vim.cmd.UndotreeToggle, desc = 'undo tree' },
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
    config = function ()
      local lsp_zero = require'lsp-zero'
      lsp_zero.extend_cmp()
      local cmp = require'cmp'
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
        ensure_installed = {'lua_ls', 'tsserver', 'rust_analyzer'},
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
    config = function ()
      require'typescript-tools'.setup {}
      vim.keymap.set('n', '<leader>tso', '<cmd>TSToolsOrganizeImports<cr>')
      vim.keymap.set('n', '<leader>tss', '<cmd>TSToolsSortImports<cr>')
      vim.keymap.set('n', '<leader>tsi', '<cmd>TSToolsRemoveUnusedImports<cr>')
      vim.keymap.set('n', '<leader>tsu', '<cmd>TSToolsRemoveUnused<cr>')
      vim.keymap.set('n', '<leader>tsf', '<cmd>TSToolsFixAll<cr>')
      vim.keymap.set('n', '<leader>tsd', '<cmd>TSToolsGoToSourceDefinition<cr>')
      vim.keymap.set('n', '<leader>tsr', '<cmd>TSToolsRenameFile<cr>')
    end,
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

if vim.version.lt(vim.version(), {0, 10, 0}) then
  vim.api.nvim_create_autocmd({ 'SwapExists' }, {
    pattern = '*',
    group = vim.api.nvim_create_augroup('nvim_swapfile', {}),
    callback = function()
      local info = vim.fn.swapinfo(vim.v.swapname)
      local user = vim.loop.os_get_passwd().username
      local iswin = 1 == vim.fn.has('win32')
      if info.error or info.pid <= 0 or (not iswin and info.user ~= user) then
        vim.v.swapchoice = ''
        return
      end
      vim.v.swapchoice = 'e'
      vim.notify(('W325: Ignoring swapfile from Nvim process %d'):format(info.pid))
    end,
  })
end
