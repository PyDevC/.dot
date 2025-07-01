vim.g.mapleader = " "


local function map(mode, lhs, rhs, opt)
	local opts = opt or {}
	opts.silent = true
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- map("n", "<leader>pv", vim.cmd.Ex) -- stay just in case i delete oil.lua

-- map("i", "jk", "<Esc>")
map({"i","c"}, "<C-c>", "<Esc>") -- changed my keyboard keymappings to home row mod

-- map("i", "jk", <Esc>) -- just in case I switch to normal keyboard
-- Basic commands
--map("n", "<leader>w", "<CMD>w<CR>")
-- I am removing this habit but you can keep it. Just uncomment the above two lines
-- got habit again with :w

map("x", "<leader>p", [["_dP]])

map({"n", "v"}, "<leader>y", [["+y]])

-- tmux-sessionizer
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- move line up and down
map("v", "<leader>j", ":m '>+1<CR>gv=gv")
map("v", "<leader>k", ":m '>-2<CR>gv=gv")

map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "=ap", "ma=ap'a")

-- what are these used for???
map("n", "<C-n>", "<cmd>cnext<CR>zz")
map("n", "<C-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

map("n", "<leader>s", "<cmd>so<CR>")
map("n", "<leader>x", "<cmd>!chmod +x %<CR>")
