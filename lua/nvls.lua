local M = {}

function M.make()
	local lines = {""}
	local cmd = vim.fn.expandcmd(vim.b.nvls_makeprg)
	local function on_event(job_id, data, event)
		if event == "stdout" or event == "stderr" then
			if data then
				vim.list_extend(lines, data)
			end
		end

		if event == "exit" then
			vim.fn.setqflist({}, " ", {
				title = cmd,
				lines = lines,
				efm = vim.b.nvls_efm,
			})
			vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
			if vim.b.nvls_makeprg == "lilypond-book " .. 
			"--output=tmpOutDir --pdf %:p:S" then
				require('tex').lytexCmp()
			else
				vim.cmd("echo ' '")
			end
		end
	end
	local job_id =
		vim.fn.jobstart(
			cmd,
			{
				on_stderr = on_event,
				on_stdout = on_event,
				on_exit = on_event,
				stdout_buffered = true,
				stderr_buffered = true,
			}
		)
end

function M.viewer()
	vim.fn.jobstart('xdg-open ' .. vim.b.nvls_pdf)
end

return M
