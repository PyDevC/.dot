-- Global Neovim Options
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"

---
-- 1. Setup LSP Kind Icons
---
local lspkind = require "lspkind"
lspkind.init {}

---
-- 2. Setup LuaSnip
---
local ls = require "luasnip"

ls.config.set_config {
  history = false,
  updateevents = "TextChanged,TextChangedI",
}

-- Mappings for Jumping *within* an active snippet
vim.keymap.set({ "i", "s" }, "<C-l>", function()
  -- Jump forward (1) in the snippet
  if ls.jumpable(1) then
    ls.jump(1)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
  -- Jump backward (-1) in the snippet
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

---
-- 3. Setup nvim-cmp
---
local cmp = require "cmp"

-- This function simplifies checking if a snippet is being highlighted
local check_backspace = function()
  return not ls.expand_or_jumpable(-1)
end

cmp.setup {
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" }, -- **CRITICAL: Must include luasnip source**
    { name = "path" },
    { name = "buffer" },
  },

  mapping = {
    -- Navigation
    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },

    -- Standard Confirmation (use C-y for non-snippet completion)
    ["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },

    -- **THE FIX FOR SNIPPET EXPANSION**
    ["<C-k>"] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_active_entry() and cmp.get_active_entry().source.name == "luasnip" then
        -- If a snippet item is selected, confirm it and then expand it.
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
        ls.expand()
      elseif cmp.visible() then
        -- If another item is selected, confirm normally (like C-y)
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
      else
        -- Fallback to the global C-k keymap if cmp menu is not visible
        fallback()
      end
    end, { "i", "c" }),

    -- TAB Mappings for both completion and snippet navigation (optional but recommended)
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif ls.expand_or_jumpable() then
        ls.expand_or_jumpable() -- Expands or jumps forward
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ls.jumpable(-1) then
        ls.jump(-1) -- Jumps backward
      else
        fallback()
      end
    end, { "i", "s" }),

    -- Automatically close completion menu when backspacing out of the trigger
    ["<C-BS>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.abort()
      else
        fallback()
      end
    end, { "i", "c" }),

    -- Additional backspace mapping to handle snippet closing
    ["<BS>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.close()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
}

-- Setup up vim-dadbod filetype specific settings
cmp.setup.filetype({ "sql" }, {
  sources = {
    { name = "vim-dadbod-completion" },
    { name = "buffer" },
  },
})
