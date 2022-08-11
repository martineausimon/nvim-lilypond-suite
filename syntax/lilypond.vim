if exists('b:current_syntax')
	finish 
endif

if exists("b:current_syntax")
	unlet b:current_syntax
endif

if !exists('g:nvls_light')
	let g:nvls_light='false'
endif

setlocal mps+=<:>

syn case match

if g:nvls_light == 'true'
	runtime! syntax/lilypond-light.vim
else
	runtime! syntax/lilypond-full.vim
endif

syn match  lilyValue         "#[^'(0-9 ]*[\n ]"ms=s+1
syn match  lilySymbol        "#'[^'(0-9 ]*[\n ]"ms=s+2
syn region lilyString        start=/"/ end=/"/ skip=/\\"/
syn region lilyComment       start="%{" skip="%$" end="%}"
syn region lilyComment       start="%\([^{]\|$\)" end="$"
syn match  lilyNumber        "[-_^.]\?\d\+[.]\?"
syn match  lilySpecial       "[(~)]\|[(*)]"
syn match  lilySpecial       "\\[()]"
syn match  lilySpecial       "\\[({)\|(})]"
syn match  lilyDynamics      "\\[<!>\\]"
syn match  lilyArticulation  "[-_^][-_^+|>.]"

match Delimiter "{\|}\|<\|>\|\[\|\]\|(\|)"
syn include @embeddedScheme syntax/scheme.vim
unlet b:current_syntax
syn region lilyScheme matchgroup=Delimiter start="#['`]\?(" matchgroup=Delimiter end=")" contains=@embeddedScheme

command -nargs=+ HiLink hi def link <args>
	HiLink lilyString              String
	HiLink lilyDynamics            SpecialChar
	HiLink lilyComment             Comment
	HiLink lilyArticulations       Statement
	HiLink lilyNumber              Constant
	HiLink lilySpecial             Special
	HiLink lilyValue               PreCondit
	HiLink lilySymbol              PreCondit
delcommand HiLink

let b:current_syntax = "lilypond"
