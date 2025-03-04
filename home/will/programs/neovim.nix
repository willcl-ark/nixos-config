{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # Color scheme
      tokyonight-nvim

      # UI enhancements
      nvim-web-devicons
      lualine-nvim
      nvim-tree-lua

      # LSP support
      nvim-lspconfig

      # Autocompletion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline

      # Snippets
      luasnip
      # cmp-luasnip

      # Telescope (fuzzy finder)
      plenary-nvim
      telescope-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          bash
          c
          fish
          go
          json
          lua
          nix
          python
          rust
        ]))
    ];

    # Extra packages needed for some plugins
    extraPackages = with pkgs; [
      ripgrep
      fd

      # Language servers
      clang-tools
      gopls
      nil
      nodePackages.vscode-langservers-extracted
      pyright
      ruff-lsp
      rust-analyzer
    ];

    extraConfig = ''
      " Basic settings
      set number relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set ignorecase
      set smartcase
      set mouse=a
      set termguicolors

      " Set colorscheme
      colorscheme tokyonight
    '';

    # more complex configurations
    extraLuaConfig = ''
      -- LSP Configuration
      local lspconfig = require('lspconfig')

      -- Setup language servers
      lspconfig.rust_analyzer.setup {}
      lspconfig.clangd.setup {}
      lspconfig.gopls.setup {}
      lspconfig.pyright.setup {}
      lspconfig.nil_ls.setup {}

      -- Global mappings
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

      -- Mappings when LSP attaches to buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          -- Enable completion triggered by <c-x><c-o>
          vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings
          local opts = { buffer = bufnr }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end,
      })

      -- Setup nvim-cmp for autocompletion
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })

      -- Setup nvim-tree
      require('nvim-tree').setup()

      -- Telescope setup
      local telescope = require('telescope')
      telescope.setup()

      -- Keymaps for Telescope
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

      -- Configure lualine
      require('lualine').setup {
        options = {
          theme = 'tokyonight'
        }
      }
    '';
  };
}
