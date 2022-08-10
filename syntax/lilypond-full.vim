runtime! syntax/lilypond-words.vim

command -nargs=+ HiLink hi def link <args>
	HiLink lilyPitches             Identifier
	HiLink lilyKeywords            Statement
	HiLink lilyMusicCommands       Statement
	HiLink lilyMusicFunctions      Statement
	HiLink lilyDynamics            Statement
	HiLink lilyScales              Statement
	HiLink lilyMarkupCommands      Keyword
	HiLink lilyGrobs               Include
	HiLink lilyGrobProperties      Tag
	HiLink lilyPaperVariables      Tag
	HiLink lilyHeaderVariables     Tag
	HiLink lilyContextProperties   Special
	HiLink lilyContextsCmd         StorageClass
	HiLink lilyContexts            Type
	HiLink lilyTranslators         Type
	HiLink lilyClefs               Label
	HiLink lilyAccidentalsStyles   Tag
	HiLink lilyRepeatTypes         Label
	HiLink lilyPitchLanguageNames  Label
	HiLink lilyMisc                SpecialComment
delcommand HiLink

hi lilyUsrVar cterm=bold
