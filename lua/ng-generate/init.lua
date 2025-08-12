local M = {}

local inputs = require("neo-tree.ui.inputs")

--- Main function to run ng generate
---@param state table Neo-tree state object
function M.run(state)
	local node = state.tree:get_node()
	if not node or node.type == "message" then
		return
	end

	local path = node:get_id():gsub("\\", "/")
	if node.type ~= "directory" then
		path = vim.fn.fnamemodify(path, ":h")
	end

	local relative_path = path:match("src/app/(.+)") or ""

	local has_nui, Popup = pcall(require, "nui.popup")
	local has_autocmd, autocmd_utils = pcall(require, "nui.utils.autocmd")
	if not has_nui or not has_autocmd then
		inputs.input("Choose sub-command:", "", function(_) end)
		return
	end
	local event = autocmd_utils.event

	local cmd_map = {
		a = "application",
		c = "component",
		C = "class",
		f = "config",
		d = "directive",
		e = "enum",
		E = "environments",
		g = "guard",
		i = "interceptor",
		I = "interface",
		l = "library",
		m = "module",
		p = "pipe",
		r = "resolver",
		s = "service",
		S = "service-worker",
		w = "web-worker",
	}

	local display_path = relative_path ~= "" and ("src/app/" .. relative_path) or "src/app"
	if #display_path > 50 then
		display_path = "…" .. display_path:sub(-49)
	end

	local function custom_sort(a, b)
		local a_lower = a:lower()
		local b_lower = b:lower()
		if a_lower == b_lower then
			local a_is_lower = a:byte() > 90
			local b_is_lower = b:byte() > 90
			if a_is_lower == b_is_lower then
				return a < b
			else
				return a_is_lower
			end
		else
			return a_lower < b_lower
		end
	end

	local other_keys = {}
	for k in pairs(cmd_map) do
		table.insert(other_keys, k)
	end
	table.sort(other_keys, custom_sort)

	local lines = { "📂 Path: " .. display_path, "" }
	for _, key in ipairs(other_keys) do
		local desc = cmd_map[key]
		table.insert(lines, string.format("%-2s — %s", key, desc))
	end
	table.insert(lines, "")
	table.insert(lines, "Esc — Cancel / click outside to close")

	local pop = Popup({
		enter = true,
		focusable = true,
		relative = "cursor",
		position = { row = 1, col = 0 },
		size = {
			width = 60,
			height = #lines,
		},
		border = {
			style = "rounded",
			text = { top = "Choose sub-command" },
		},
		buf_options = { filetype = "neo-tree-popup", modifiable = false },
		win_options = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
	})

	vim.api.nvim_buf_set_lines(pop.bufnr, 0, -1, false, lines)

	local function gen_and_run(kind, input)
		if not input or input == "" then
			return
		end
		local name, opts = input:match("^(%S+)%s*(.*)$")
		name = name or input
		opts = opts or ""

		local full_path = relative_path ~= "" and (relative_path .. "/" .. name) or name
		local ngcmd = cmd_map[kind]
		if not ngcmd then
			vim.notify("Unknown command kind: " .. kind, vim.log.levels.ERROR)
			return
		end

		ngcmd = ngcmd:lower()
		local skip_import = (ngcmd == "component" or ngcmd == "directive") and "--skip-import" or ""
		local full_cmd =
			string.format("cd %s && npx ng g %s %s %s %s", vim.fn.getcwd(), ngcmd, full_path, skip_import, opts)

		local handle = io.popen(full_cmd .. " 2>&1")
		local result = handle:read("*a")
		handle:close()

		if result:match("[Ee]rror") then
			vim.notify(string.format("❌ Angular %s generation failed:\n%s", ngcmd, result), vim.log.levels.ERROR)
		else
			vim.notify(string.format("✅ Angular %s created at:\n%s", ngcmd, full_path), vim.log.levels.INFO)
			require("neo-tree.sources.manager").refresh("filesystem")
		end
	end

	local function ask_name_and_run(kind)
		local desc = cmd_map[kind] or "Name"
		local prompt = desc:gsub("^%l", string.upper) .. " name [options]:"
		inputs.input(prompt, "", function(input)
			gen_and_run(kind, input)
		end)
	end

	pop:map("n", "<esc>", function()
		pop:unmount()
	end, { noremap = true, silent = true })

	for key in pairs(cmd_map) do
		pop:map("n", key, function()
			pop:unmount()
			ask_name_and_run(key)
		end, { noremap = true, silent = true })
	end

	pop:map("n", "<CR>", function()
		local row = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.api.nvim_buf_get_lines(pop.bufnr, row - 1, row, false)[1] or ""
		local kind = line:match("^(%a)")
		if kind then
			pop:unmount()
			ask_name_and_run(kind)
		end
	end, { noremap = true, silent = true })

	pop:on(event.BufLeave, function()
		if vim.api.nvim_buf_is_valid(pop.bufnr) then
			pop:unmount()
		end
	end, { once = true })

	pop:mount()
	vim.api.nvim_set_current_win(pop.winid)
	vim.api.nvim_win_set_cursor(pop.winid, { 3, 0 })
end

--- Setup function to automatically register in neo-tree
---@param opts? table
function M.setup(opts)
	opts = opts or {}
	local neo_tree = require("neo-tree")
	neo_tree.setup({
		window = {
			mappings = {
				["n"] = M.run,
			},
		},
	})
end

return M
