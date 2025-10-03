return {
  {
    "neovim/nvim-lspconfig",
    event = 'VimEnter',
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      local lspconfig = require "lspconfig"
      local servers = {
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },

        clangd = {
          init_options = { clangdFileStatus = true },
          filetypes = { "c", "cpp" },
        },

        lua_ls = {},
        pyright = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end,

          ["jsonls"] = function()
            lspconfig["jsonls"].setup(vim.tbl_deep_extend("force", {}, {
              capabilities = capabilities,
            }, servers.jsonls))
          end,
          ["yamlls"] = function()
            lspconfig["yamlls"].setup(vim.tbl_deep_extend("force", {}, {
              capabilities = capabilities,
            }, servers.yamlls))
          end,
          ["clangd"] = function()
            lspconfig["clangd"].setup(vim.tbl_deep_extend("force", {}, {
              capabilities = capabilities,
            }, servers.clangd))
          end,
        },
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = false,
        float = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(e)
          local opts = { buffer = e.buf }
          vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
          vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
          vim.keymap.set("n", "<leader>dt", function() vim.diagnostic.open_float() end, opts) -- extremly useful in diagnostics
          vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
          vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
          vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
          vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
          vim.keymap.set({ "n", "x" }, "<leader>f", vim.lsp.buf.format, { buffer = 0 })
        end
      })
    end,
  },
}
