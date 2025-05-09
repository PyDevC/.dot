return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        vim.keymap.set("n", "<leader>gp", "<cmd>Git add -A<CR>")
        local pydevc_fug = vim.api.nvim_create_augroup("pydevc_fug", {})
        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = pydevc_fug,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end
                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git("push")
                end, opts)
                vim.keymap.set("n", "<leader>t", ":Git push -u origin", opts)
            end,
        })
        vim.keymap.set("n", "<leader>gu", "<cmd>diffget//2<CR>")
        vim.keymap.set("n", "<leader>gh", "<cmd>diffget//3<CR>")
    end,
}
