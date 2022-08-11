if vim.g.do_filetype_lua == 1 then
	vim.filetype.add({
		extension = {
			ly = 'lilypond',
			ily = 'lilypond',
		},
	})
	else
	vim.api.nvim_create_autocmd(
		{ 'BufNewFile', 'BufRead' },
		{
			command = "set ft=lilypond",
			pattern = { '*.ly', '*.ily' },
			group =  vim.api.nvim_create_augroup(
				"LilypondAutocmds", { clear = true}
			)
		}
	)
end
