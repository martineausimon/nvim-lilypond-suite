syn match lilyGrobs "\<\u\l\w*\>"
syn match lilyFunctions "[-_^]\?\\\([^ ]*[\n ]\)"
syn match lilyVar "\u*\l*-*\w*-*\w*\s\*="me=e-1
syn match lilyVar "\.\w*[-\l]\l\w*"ms=s+1

syn match lilyPaperVariables "\(auto-first-page-number\|binding-offset\|blank-last-page-penalty\|blank-page-penalty\|bottom-margin\|check-consistency\|evenHeaderMarkup\|first-page-number\|footnote-separator-markup\|horizontal-shift\|indent\|inner-margin\|last-bottom-spacing\|left-margin\|line-width\|markup-markup-spacing\|markup-system-spacing\|max-systems-per-page\|min-systems-per-page\|minimum-distance\|oddHeaderMarkup\|outer-margin\|page-breaking-system-system-spacing\|page-breaking\|page-count\|page-number-type\|page-spacing-weight\|paper-height\|paper-width\|print-all-headers\|print-first-page-number\|ragged-bottom\|ragged-last-bottom\|ragged-last\|ragged-right\|right-margin\|score-markup-spacing\|score-system-spacing\|short-indent\|stretchability\|system-count\|system-separator-markup\|system-system-spacing\|systems-per-page\|top-margin\|top-markup-spacing\|top-system-spacing\|two-sided\)\(\A\|\n\)"me=e,ms=s

syn match lilyClefs "\<\(C\|F\|G\|G2\|GG\|alto\|altovarC\|baritone\|baritonevarC\|baritonevarF\|bass\|blackmensural-c1\|blackmensural-c2\|blackmensural-c3\|blackmensural-c4\|blackmensural-c5\|french\|hufnagel-do-fa\|hufnagel-do1\|hufnagel-do2\|hufnagel-do3\|hufnagel-fa1\|hufnagel-fa2\|kievan-do\|medicaea-do1\|medicaea-do2\|medicaea-do3\|medicaea-fa1\|medicaea-fa2\|mensural-c1\|mensural-c2\|mensural-c3\|mensural-c4\|mensural-c5\|mensural-f\|mensural-g\|mezzosoprano\|moderntab\|neomensural-c1\|neomensural-c2\|neomensural-c3\|neomensural-c4\|neomensural-c5\|percussion\|petrucci-c1\|petrucci-c2\|petrucci-c3\|petrucci-c4\|petrucci-c5\|petrucci-f\|petrucci-f2\|petrucci-f3\|petrucci-f4\|petrucci-f5\|petrucci-g\|petrucci-g1\|petrucci-g2\|soprano\|subbass\|tab\|tenor\|tenorG\|tenorvarC\|treble\|varC\|varbaritone\|varpercussion\|vaticana-do1\|vaticana-do2\|vaticana-do3\|vaticana-fa1\|vaticana-fa2\|violin\)\(\A\|\n\)"me=e,ms=s

syn match lilyRepeatTypes "\<\(percent\|segno\|tremolo\|unfold\|volta\)\(\A\|\n\)"me=e,ms=s

syn match lilyPitchLanguageNames "\<\(arabic\|catalan\|català\|deutsch\|english\|espanol\|español\|français\|italiano\|nederlands\|norsk\|portugues\|português\|suomi\|svenska\|vlaams\)\(\A\|\n\)"me=e,ms=s

syn match lilyAccidentalsStyles "\<\(choral-cautionary\|choral\|default\|dodecaphonic-first\|dodecaphonic-no-repeat\|dodecaphonic\|forget \|modern-cautionary\|modern-voice\|modern-voice-cautionary\|neo-modern-cautionary\|neo-modern-voice\|neo-modern-voice-cautionary\|neo-modern\|modern\|no-reset\|piano-cautionary\|piano\|teaching\|voice\)\(\A\|\n\)"me=e,ms=s

syn match lilyScales "[-_^]\?\\\(aeolian\|dorian\|ionian\|locrian\|lydian\|major\|minor\|mixolydian\|phrygian\)\(\A\|\n\)"me=e-1

syn match lilyDynamics "[-_^]\?\\\(cr\|cresc\|decr\|decresc\|dim\|endcr\|endcresc\|enddecr\|enddecresc\|enddim\|f\|ff\|fff\|ffff\|fffff\|fp\|fz\|mf\|mp\|n\|p\|pp\|ppp\|pppp\|ppppp\|rfz\|sf\|sff\|sfp\|sfz\|sp\|spp\)\(\A\|\n\)"me=e-1

syn match lilyContexts "\<\(AncientRemoveEmptyStaffContext\|ChoirStaff\|ChordNames\|CueVoice\|Devnull\|DrumStaff\|DrumVoice\|Dynamics\|FiguredBass\|FretBoards\|Global\|GrandStaff\|GregorianTranscriptionStaff\|GregorianTranscriptionVoice\|KievanStaff\|KievanVoice\|Lyrics\|MensuralStaff\|MensuralVoice\|NoteNames\|NullVoice\|OneStaff\|PetrucciStaff\|PetrucciVoice\|PianoStaff\|RemoveEmptyDrumStaffContext\|RemoveEmptyRhythmicStaffContext\|RemoveEmptyStaffContext\|RemoveEmptyTabStaffContext\|RhythmicStaff\|Score\|Staff\|StaffGroup\|TabStaff\|TabVoice\|VaticanaStaff\|VaticanaVoice\|Voice\)\(\A\|\n\)"me=e-1,ms=s

syn match lilyTranslators "[A-Z][a-z]\w*\(_\)\w*"

syn match lilyMisc "\(##f\|##t\|#f\|#t\)\(\A\|\n\)"me=e,ms=s

command -nargs=+ HiLink hi def link <args>
	HiLink lilyFunctions					 Statement
	HiLink lilyDynamics						 SpecialChar
	HiLink lilyScales							 Statement
	HiLink lilySpecial						 Special
	HiLink lilyArticulation				 PreProc
	HiLink lilyContexts						 Type
	HiLink lilyGrobs							 Include
	HiLink lilyTranslators				 Type
	HiLink lilyClefs							 Label
	HiLink lilyAccidentalsStyles	 Tag
	HiLink lilyRepeatTypes				 Label
	HiLink lilyPitchLanguageNames  Label
	HiLink lilyMisc								 SpecialComment
	HiLink lilyVar								 Tag
	HiLink lilyPaperVariables			 SpecialComment
delcommand HiLink

