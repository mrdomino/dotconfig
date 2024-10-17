vim.cmd.syntax 'off'
vim.cmd.colorscheme 'habamax'
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
vim.opt.runtimepath:prepend(lazypath)

require'lazy'.setup {
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        auto_install = vim.fn.executable('tree-sitter') ~= 0,
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
        ignore_install = {},
        indent = { enable = true },
        modules = { },
        sync_install = false,
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
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'live grep' },
    },
    opts = {
      defaults = {
        layout_strategy = 'vertical',
      },
    },
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

  { 'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = function () end,
    init = function ()
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },

  { 'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  { 'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = 'lazydev',
        group_index = 0,
      })
    end,
    event = 'InsertEnter',
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
        formatting = lsp_zero.cmp_format({}),
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }
      }
    end,
    dependencies = {
      { 'L3MON4D3/LuaSnip' },
    },
  },

  { 'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function ()
      local lsp_zero = require'lsp-zero'
      lsp_zero.extend_lspconfig()
      lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps {
          buffer = bufnr,
          preserve_mappings = false,
        }
        vim.keymap.set('n', '<localleader>ls', '<cmd>LspStop<cr>')
        vim.keymap.set('n', '<localleader>lt', '<cmd>LspStart<cr>')
      end)
      local servers = {}
      local add_server = function(exe, name)
        if not name then
          name = exe
        end
        if vim.fn.executable(exe) ~= 0 then
          table.insert(servers, name)
        end
      end
      add_server('clangd')
      add_server('gopls')
      add_server('lua-language-server', 'lua_ls')
      add_server('rust-analyzer', 'rust_analyzer')
      add_server('tsserver', 'ts_ls')
      add_server('zls')
      lsp_zero.setup_servers(servers)
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
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

  { 'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function ()
      require'go'.setup()
    end,
    event = {'CmdlineEnter'},
    ft = {'go', 'gomod'},
    build = ':lua require("go.install").update_all_sync()',
  },

  { 'frankroeder/parrot.nvim',
    dependencies = {
      'ibhagwan/fzf-lua',
      'nvim-lua/plenary.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require'parrot'.setup {
        providers = {
          anthropic = {
            api_key = os.getenv 'ANTHROPIC_API_KEY',
          },
        },
      }
    end,
  },
}

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufWinEnter' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('mine', {}),
  callback = function()
    if (vim.bo.textwidth or 0) > 0 then
      vim.wo.colorcolumn = '+1'
    else
      vim.wo.colorcolumn = '81'
    end
  end,
})

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require('go.format').goimports()
  end,
  group = format_sync_grp,
})
