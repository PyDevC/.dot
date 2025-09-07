return {
  "PyDevC/model-cmp.nvim",
  -- dir="~/personal/project/model-cmp.nvim",
  -- dir="~/personal/contrib/model-cmp.nvim",
  config = function()
    require("model_cmp").setup({
      delay = 1,

      api = {
        custom_url = {
          url = "http://127.0.0.1",
          port = "8080"
        }
      },

      virtualtext = {
        enable = false,
        type = "inline",

        style = { -- This is just a highlight group
          fg = "#b53a3a",
          italic = false,
          bold = false
        }

      },
    })
    vim.keymap.set("i", "<C-s>", "<CMD>ModelCmp capture first<CR>", {})
  end,
}
