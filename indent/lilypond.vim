if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=GetLilyPondIndent()
setlocal indentkeys=o,O,},>>,!^F

if exists("*GetLilyPondIndent")
	finish
endif

function GetLilyPondIndent()
	if v:lnum == 1
		return 0
	endif
	let lnum = prevnonblank(v:lnum - 1)
	if getline(lnum) =~ '^.*\({\|<<\)\s*$'
		let ind = indent(lnum) + &sw
	else
		let ind = indent(lnum)
	endif
	if getline(v:lnum) =~ '^\s*\(}\|>>\)'
		let ind = ind - &sw
	endif
	for id in synstack(lnum, 1)
		if synIDattr(id, "name") == "lilyScheme"
			let ind = lispindent(v:lnum)
		endif
	endfor
	return ind
endfunction
