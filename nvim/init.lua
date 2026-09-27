vim.cmd.syntax 'off'
vim.cmd.colorscheme 'habamax'
vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true
vim.o.listchars = 'tab:→ ,trail:·,nbsp:␣'
vim.o.showbreak = '↪ '
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.mouse = ''
vim.o.completeopt = 'menuone,noinsert,popup,fuzzy'
vim.g.mapleader = ';'

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/conform.nvim',
}

vim.cmd.packadd 'nvim.undotree'
vim.keymap.set('n', '<leader>u', vim.cmd.Undotree)

if vim.fn.executable 'rg' == 1 then
  vim.o.grepprg = 'rg --vimgrep'
  function _G.RgFind(arg)
    local files = vim.fn.systemlist 'rg --files'
    return arg == '' and files or vim.fn.matchfuzzy(files, arg)
  end
  vim.o.findfunc = 'v:lua.RgFind'
end
vim.keymap.set('n', '<leader>ff', ':find ')
vim.keymap.set('n', '<leader>fg', ':silent grep ')
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = 'grep',
  command = 'cwindow',
})

vim.diagnostic.config {
  virtual_text = { current_line = true },
  severity_sort = true,
}
vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist)

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      workspaceFiles = { '**/BUILD', '**/WORKSPACE', '**/*.{bzl,bazel}' },
      directoryFilters = {
        '-bazel-bin',
        '-bazel-out',
        '-bazel-testlogs',
        '-bazel-stairwell',
      },
    },
  },
})
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})
vim.lsp.config('rust_analyzer', {
  settings = { ['rust-analyzer'] = { cargo = { features = 'all' } } },
})
vim.lsp.config('yamlls', {
  cmd = { 'yaml-language-server', '--stdio' },
  settings = { yaml = { schemas = { kubernetes = 'k8s-*.yaml' } } },
})
for _, name in ipairs {
  'basedpyright',
  'clangd',
  'gopls',
  'lua_ls',
  'nixd',
  'ruff',
  'rust_analyzer',
  'sourcekit',
  'starpls',
  'vtsls',
  'yamlls',
  'zls',
} do
  if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end
vim.keymap.set('n', '<leader>ls', '<cmd>lsp disable<cr>')
vim.keymap.set('n', '<leader>lt', '<cmd>lsp enable<cr>')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
    local function map(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = ev.buf })
    end
    map('gd', vim.lsp.buf.definition)
    map('gD', vim.lsp.buf.declaration)
    map('go', vim.lsp.buf.type_definition)
    map('gs', vim.lsp.buf.signature_help)
    for _, key in ipairs { '<C-n>', '<C-p>' } do
      vim.keymap.set('i', key, function()
        return vim.fn.pumvisible() == 1 and key
          or '<Cmd>lua vim.lsp.completion.get()<CR>'
      end, { buffer = ev.buf, expr = true })
    end
    vim.keymap.set('i', '<BS>', function()
      return vim.fn.pumvisible() == 1
          and '<BS><Cmd>lua vim.lsp.completion.get()<CR>'
        or '<BS>'
    end, { buffer = ev.buf, expr = true })
    vim.keymap.set('i', '<CR>', function()
      return vim.fn.complete_info({ 'selected' }).selected >= 0 and '<C-y>'
        or '<CR>'
    end, { buffer = ev.buf, expr = true })
    for key, scroll in pairs { ['<C-u>'] = '4\25', ['<C-d>'] = '4\5' } do
      vim.keymap.set('i', key, function()
        local win = vim.fn.complete_info().preview_winid
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            vim.cmd.normal { scroll, bang = true }
          end)
        else
          vim.api.nvim_feedkeys(vim.keycode(key), 'n', false)
        end
      end, { buffer = ev.buf })
    end
  end,
})

local js = { 'biome', 'prettier', stop_after_first = true }
require('conform').setup {
  formatters_by_ft = {
    go = { 'goimports', lsp_format = 'fallback' },
    javascript = js,
    javascriptreact = js,
    python = { lsp_format = 'fallback' },
    rust = { lsp_format = 'fallback' },
    typescript = js,
    typescriptreact = js,
  },
  formatters = { biome = { require_cwd = true } },
  format_on_save = true,
}

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufWinEnter' }, {
  callback = function()
    vim.wo.colorcolumn = vim.bo.textwidth > 0 and '+1' or '81'
  end,
})
