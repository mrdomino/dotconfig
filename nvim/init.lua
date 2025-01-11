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

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
          'comment',
          'cpp',
          'css',
          'git_rebase',
          'gitcommit',
          'go',
          'gomod',
          'gosum',
          'gotmpl',
          'gowork',
          'hoon',
          'html',
          'javascript',
          'json',
          'lua',
          'markdown',
          'python',
          'ruby',
          'rust',
          'sql',
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

  { 'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function ()
      local cmp = require'cmp'

      cmp.setup {
        preselect = 'item',
        completion  = {
          autocomplete = false,
          completeopt = 'menu,menuone,noinsert',
        },
        sources = {
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' },
        },
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
      }
    end,
  },

  { 'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
    },
    config = function ()
      local lsp_defaults = require('lspconfig').util.default_config
      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

          vim.keymap.set('n', '<localleader>ls', '<cmd>LspStop<cr>')
          vim.keymap.set('n', '<localleader>lt', '<cmd>LspStart<cr>')
        end,
      })

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
      add_server('nil', 'nil_ls')
      add_server('rust-analyzer', 'rust_analyzer')
      add_server('tsserver', 'ts_ls')
      add_server('zls')
      for _, name in ipairs(servers) do
        require('lspconfig')[name].setup({})
      end
    end,
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
    build = ':lua require("go.install").update_all()',
  },

  { 'frankroeder/parrot.nvim',
    dependencies = {
      'ibhagwan/fzf-lua',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require'parrot'.setup {
        providers = {
          anthropic = {
            api_key = os.getenv 'ANTHROPIC_API_KEY',
          },
        },
      }
      vim.keymap.set('n', '<leader>pn', '<cmd>PrtChatNew split<cr>')
      vim.keymap.set('n', '<leader>pc', '<cmd>PrtChatToggle split<cr>')
      vim.keymap.set('n', '<leader>pa', '<cmd>PrtAsk<cr>')
      vim.keymap.set('v', '<leader>pi', ":'<,'>PrtImplement<cr>")
      vim.keymap.set('v', '<leader>pr', ":'<,'>PrtRewrite<cr>")
      vim.keymap.set('v', '<leader>pt', ":'<,'>PrtRetry<cr>")
      vim.keymap.set('v', '<leader>pa', ":'<,'>PrtAppend<cr>")
      vim.keymap.set('v', '<leader>pp', ":'<,'>PrtPrepend<cr>")
      vim.keymap.set('v', '<leader>py', ":'<,'>PrtChatPaste split<cr>")
    end,
  },
}

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufWinEnter' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('TextColumn', {}),
  callback = function()
    if (vim.bo.textwidth or 0) > 0 then
      vim.wo.colorcolumn = '+1'
    else
      vim.wo.colorcolumn = '81'
    end
  end,
})

local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    require('go.format').goimports()
  end,
  group = format_sync_grp,
})
