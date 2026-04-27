local ok, ls = pcall(require, "luasnip")
if not ok then
	vim.notify("LuaSnip not found — snippet setup skipped", vim.log.levels.WARN)
	return
end

-- Load your existing JSON snippets (keeps everything working as before)
require("luasnip.loaders.from_vscode").load({ paths = "~/.config/nvim/snippets/" })

-- Load components.lua (the new category snippets)
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

-- Tab: expand → jump → cycle choices
vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	elseif ls.choice_active() then
		ls.change_choice(1)
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
	end
end, { silent = true })

-- Shift-Tab: jump back / cycle choices in reverse
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	elseif ls.choice_active() then
		ls.change_choice(-1)
	end
end, { silent = true })
