if exists('b:current_syntax')
  finish 
endif

if !exists('g:nvls_language')
  let g:nvls_language = "default"
endif

let s:keepcpo= &cpo
set cpo&vim

setlocal mps+=<:>

syn case match

syn cluster lilyMatchGroup contains=
  \lilyMatcher,
  \lilyPitches,
  \lilyFunctions,
  \lilyString,
  \lilyValue,
  \lilySymbol,
  \lilyComment,
  \lilyNumber,
  \lilySpecial,
  \lilyDynamics,
  \lilyArticulation,
  \lilyScheme,
  \lilyLyrics,
  \lilyMarkup,
  \lilyDynamics,
  \lilyScales,
  \lilyArticulation,
  \lilyContexts,
  \lilyGrobs,
  \lilyTranslators,
  \lilyClefs,
  \lilyAccidentalsStyles,
  \lilyRepeatTypes,
  \lilyPitchLanguageNames,
  \lilyMisc,
  \lilyVar,
  \lilyAltVar1,
  \lilyAltVar2,
  \Error

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="{"
  \ skip="\\\\\|\\[<>]"
  \ end="}"
  \ contains=@lilyMatchGroup 
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="\["
  \ end="]"
  \ contains=@lilyMatchGroup
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter 
  \ start="<" 
  \ skip="\\\\\|\\[{<>}]" 
  \ end=">" 
  \ contains=@lilyMatchGroup 
  \ fold

syn match lilyClefs "\<\(C\|F\|G\|G2\|GG\|alto\|altovarC\|baritone\|baritonevarC\|baritonevarF\|bass\|blackmensural-c1\|blackmensural-c2\|blackmensural-c3\|blackmensural-c4\|blackmensural-c5\|french\|hufnagel-do-fa\|hufnagel-do1\|hufnagel-do2\|hufnagel-do3\|hufnagel-fa1\|hufnagel-fa2\|kievan-do\|medicaea-do1\|medicaea-do2\|medicaea-do3\|medicaea-fa1\|medicaea-fa2\|mensural-c1\|mensural-c2\|mensural-c3\|mensural-c4\|mensural-c5\|mensural-f\|mensural-g\|mezzosoprano\|moderntab\|neomensural-c1\|neomensural-c2\|neomensural-c3\|neomensural-c4\|neomensural-c5\|percussion\|petrucci-c1\|petrucci-c2\|petrucci-c3\|petrucci-c4\|petrucci-c5\|petrucci-f\|petrucci-f2\|petrucci-f3\|petrucci-f4\|petrucci-f5\|petrucci-g\|petrucci-g1\|petrucci-g2\|soprano\|subbass\|tab\|tenor\|tenorG\|tenorvarC\|treble\|varC\|varbaritone\|varpercussion\|vaticana-do1\|vaticana-do2\|vaticana-do3\|vaticana-fa1\|vaticana-fa2\|violin\)\(\A\|\n\)"

syn match lilyRepeatTypes "\<\(percent\|segno\|tremolo\|unfold\|volta\)\(\A\|\n\)"

syn match lilyPitchLanguageNames "\<\(arabic\|catalan\|català\|deutsch\|english\|espanol\|español\|français\|italiano\|nederlands\|norsk\|portugues\|português\|suomi\|svenska\|vlaams\)\(\A\|\n\)"

syn match lilyAccidentalsStyles "\<\(choral-cautionary\|choral\|default\|dodecaphonic-first\|dodecaphonic-no-repeat\|dodecaphonic\|forget \|modern-cautionary\|modern-voice\|modern-voice-cautionary\|neo-modern-cautionary\|neo-modern-voice\|neo-modern-voice-cautionary\|neo-modern\|modern\|no-reset\|piano-cautionary\|piano\|teaching\|voice\)\(\A\|\n\)"me=e,ms=s

syn match lilyGrobs          "\<\u\a\+\>"
syn match lilyMarkupCommands "\\\a\(\i\|\-\)\+"
syn match lilyFunctions      "\\\a\(\i\|\-\)\+"

syn match lilyContexts "\(\\\|\<\)\(AncientRemoveEmptyStaffContext\|ChoirStaff\|ChordNames\|CueVoice\|Devnull\|DrumStaff\|DrumVoice\|Dynamics\|FiguredBass\|FretBoards\|Global\|GrandStaff\|GregorianTranscriptionStaff\|GregorianTranscriptionVoice\|KievanStaff\|KievanVoice\|Lyrics\|MensuralStaff\|MensuralVoice\|NoteNames\|NullVoice\|OneStaff\|PetrucciStaff\|PetrucciVoice\|PianoStaff\|RemoveEmptyDrumStaffContext\|RemoveEmptyRhythmicStaffContext\|RemoveEmptyStaffContext\|RemoveEmptyTabStaffContext\|RhythmicStaff\|Score\|Staff\|StaffGroup\|TabStaff\|TabVoice\|VaticanaStaff\|VaticanaVoice\|Voice\)\(\A\|\n\)"me=e-1

syn match lilyDynamics "[-_^]\?\\\(cr\|cresc\|decr\|decresc\|dim\|endcr\|endcresc\|enddecr\|enddecresc\|enddim\|f\|ff\|fff\|ffff\|fffff\|fp\|fz\|mf\|mp\|n\|p\|pp\|ppp\|pppp\|ppppp\|rfz\|sf\|sff\|sfp\|sfz\|sp\|spp\)\(\A\|\n\)"me=e-1

if g:nvls_language == "français"
  syn match lilyPitches "\<\(la\|si\|do\|re\|ré\|mi\|fa\|sol\|la\|s\|R\|r\)\(dd\|bb\|x\|sd\|sb\|dsd\|bsb\|d\|b\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilySpecial,lilyArticulation
elseif g:nvls_language == "english"
  syn match lilyPitches "\<\([a-g]\|s\|R\|r\)\(ss\|ff\|x\|qs\|qf\|tqs\|tqf\|s\|f\|\-flatflat\|\-sharpsharp\|\-flat\|\-sharp\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilySpecial,lilyArticulation
elseif g:nvls_language == "nohl"
else
syn match lilyPitches "\<\([a-g]\|s\|R\|r\)\(isis\|eses\|eh\|ih\|eseh\|isih\|is\|es\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilySpecial,lilyArticulation
endif


syn match lilyNotesAttr "\(\'\+\|\,\+\|\)\(?\|!\|\)\(1024\|512\|256\|128\|64\|32\|16\|8\|4\|2\|1\|\)\(\M.\+\|\)\(\A\|\n\)"me=e-1
  \ display contained nextgroup=lilySpecial, lilyArticulation


syn match lilyVar            "\(\i\|\-\)\+\(\s\|\)\+="me=e-1
syn match lilyAltVar2        "\l\(\-\|\u\|\l\)\+\l\."me=e-1
  \ display contained nextgroup=lilyVar
syn match lilyAltVar1        "\l\(\-\|\u\|\l\)\+\l\."he=e-1 
  \ display nextgroup=lilyAltVar2

syn match lilyTranslators "\u\l\+\(_\)\w*\(engraver\|performer\|translator\)"

syn match lilyMisc "\(##f\|##t\|#f\|#t\)\(\A\|\n\)"me=e,ms=s

syn match  lilyValue        "#[^'(0-9 ]*[\n ]"ms=s+1
syn match  lilySymbol       "#'[^'(0-9 ]*[\n ]"ms=s+2
syn region lilyString       start=/"/            end=/"/   skip=/\\"/
syn region lilyComment      start="%{"           skip="%$" end="%}"
syn region lilyComment      start="%\([^{]\|$\)" end="$"
syn match  lilySpecial      "[(~)]\|[(*)]\|[(:)]\|[(=)]"
syn match  lilyDynamics     "\\[<!>\\]"

if g:nvls_language == "nohl"
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\{,3}"
else 
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\?"
end

syn match  lilyArticulation "[-_^][-_^+|>|.]"

syn match Error "}"
syn match Error "\l\+\d[',]\+"
syn match Error "\<\\tuplet\(\s\|\)\+{"me=e-1

syn include @Scheme syntax/scheme.vim
unlet b:current_syntax
syn region lilyScheme
  \ matchgroup=Delimiter 
  \ start="#['`]\?(" 
  \ end=")" 
  \ contains=@Scheme

syn region lilyInnerLyrics 
  \ matchgroup=Delimiter 
  \ start="{" end="}" 
  \ contained contains=ALLBUT,lilyGrobs,lilyPitches,Error,lilyNotesAttr,lilyAltVar1,lilyAltVar2

syn region lilyInnerLyrics 
  \ matchgroup=Delimiter 
  \ start="<" end=">" 
  \ contained contains=ALLBUT,lilyGrobs,lilyPitches,Error,lilyNotesAttr,lilyAltVar1,lilyAltVar2


syn region lilyLyrics
  \ matchgroup=lilyLyrics
  \ start="\(\\addlyrics\s\+{\|\\lyricmode\s\+{\|\\lyricsto\s\+\"\+\l\+\"\+\s\+{\)"
  \ end="}"
  \ contains=ALLBUT,lilyGrobs,lilyPitches,Error,lilyNotesAttr,lilyAltVar1,lilyAltVar2

syn match lilyGrobsExcpt "LyricText"

syn region lilyMarkup
  \ matchgroup=lilyFunctions
  \ start="\([\_\^\-]\\markup\s\+{\|\\markup\s\+{\)"
  \ end="}"
  \ contains=ALLBUT,lilyFunctions,lilyInnerLyrics,lilyNotesAttr

command -nargs=+ HiLink hi def link <args>
  HiLink lilyString             String
  HiLink lilyDynamics           SpecialChar
  HiLink lilyComment            Comment
  HiLink lilyNumber             Constant
  HiLink lilySpecial            SpecialChar
  HiLink lilyValue              PreCondit
  HiLink lilySymbol             PreCondit
  HiLink lilyLyrics             Special
  HiLink lilyInnerLyrics        Special
  HiLink lilyFunctions          Statement
  HiLink lilyArticulation       PreProc
  HiLink lilyContexts           Type
  HiLink lilyGrobs              Include
  HiLink lilyGrobsExcpt         Include
  HiLink lilyTranslators        Type
  HiLink lilyClefs              Label
  HiLink lilyAccidentalsStyles  Label
  HiLink lilyRepeatTypes        Label
  HiLink lilyPitchLanguageNames Label
  HiLink lilyMisc               SpecialComment
  HiLink lilyVar                Tag
  HiLink lilyAltVar1            PreCondit
  HiLink lilyAltVar2            SpecialComment
  HiLink lilyMarkupCommands     Keyword
  HiLink lilyPitches            Function
  HiLink lilyNotesAttr          Function
delcommand HiLink

let b:current_syntax = "lilypond"

let &cpo = s:keepcpo
unlet s:keepcpo
