-- ==============================
-- lua/config/live-server.lua
-- ==============================
-- Live server integration for web development

local M = {}

-- Start live-server for current HTML file or directory
function M.start()
	if vim.fn.executable("live-server") == 1 then
		local file = vim.fn.expand("%:t") -- Get just the filename
		local dir = vim.fn.expand("%:p:h") -- Get the directory

		-- Check if current file is HTML
		if vim.bo.filetype == "html" or file:match("%.html?$") then
			vim.notify("Starting Live Server for " .. file .. "...", vim.log.levels.INFO)
			-- Start live-server in the file's directory and open the specific file
			vim.fn.jobstart("live-server --open=" .. vim.fn.shellescape(file), {
				cwd = dir,
				detach = true,
			})
		else
			-- If not HTML, start normally in current directory
			vim.notify("Starting Live Server in current directory...", vim.log.levels.INFO)
			vim.fn.jobstart("live-server", { detach = true })
		end
	else
		vim.notify("Live Server not installed. Run: npm install -g live-server", vim.log.levels.WARN)
	end
end

-- Stop live-server
function M.stop()
	vim.fn.system("pkill -f live-server")
	vim.notify("Live Server stopped", vim.log.levels.INFO)
end

-- Setup keymaps
function M.setup()
	vim.keymap.set("n", "<leader>ls", M.start, { noremap = true, silent = true, desc = "Start live server" })
	vim.keymap.set("n", "<leader>lk", M.stop, { noremap = true, silent = true, desc = "Stop live server" })
end

return M
