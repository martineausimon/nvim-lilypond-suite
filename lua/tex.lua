local texPdfFile = vim.fn.shellescape(vim.fn.expand('%:p:r') .. '.pdf')

local M = {}

function M.DetectLilypondSyntax()
	if vim.g.lytexSyn == 1 then
		vim.g.lytexSyn = 0
		vim.cmd[[set syntax=tex]]
		return
	else
		if vim.fn.search("begin{lilypond}", "n") ~= 0 then
			vim.b.current_syntax = nil
			vim.cmd('syntax include @TEX syntax/tex.vim')
			vim.b.current_syntax = nil
			vim.cmd('syntax include @lilypond syntax/lilypond.vim')
			vim.cmd [[ 
			syntax region litex 
				\ matchgroup=Snip 
				\ start="\\begin{lilypond}" 
				\ end="\\end{lilypond}" 
				\ containedin=@TEX 
				\ contains=@lilypond
			]]
			vim.cmd('filetype plugin on')
			vim.b.current_syntax = "litex"
			vim.g.lytexSyn = 1
		end
	end
end

function M.SelectMakePrgType()
	if vim.fn.search("usepackage{lyluatex}", "n") ~= 0 then
		require('tex').lualatexCmp()
	else 
		if vim.fn.search("begin{lilypond}", "n") ~= 0 then
			require('tex').lilypondBookCmp()
		else
			require('tex').lualatexCmp()
		end
	end
end

function M.lytexCmp()
	vim.b.nvls_makeprg = "cd tmpOutDir/ && lualatex --shell-escape " ..
		"--interaction=nonstopmode '%:r.tex' && " ..
		"cd .. && mv tmpOutDir/'%:r.pdf' ."
	vim.b.nvls_efm = "%+G! LaTeX %trror: %m," ..
		"%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
		"%+GLaTeX %.%#Warning: %m," ..
		"%+G! %m,%+El.%l %m,%-G%.%#"
	require('nvls').make()
end

function M.lualatexCmp()
	vim.b.nvls_makeprg = "lualatex --shell-escape " ..
		"--interaction=nonstopmode %:p:S"
	vim.b.nvls_efm = "%+G! LaTeX %trror: %m," ..
		"%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
		"%+GLaTeX %.%#Warning: %m," ..
		"%+G! %m,%+El.%l %m,%-G%.%#"
	require('nvls').make()
end

function M.lilypondBookCmp()
	vim.fn.execute('silent:!rm -rf ./tmpOutDir')
	vim.b.nvls_makeprg = "lilypond-book --output=tmpOutDir --pdf %:p:S"
	vim.b.nvls_efm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'
	require('nvls').make()
end

function M.texViewer()
	vim.fn.jobstart('xdg-open ' .. texPdfFile)
end

return M
