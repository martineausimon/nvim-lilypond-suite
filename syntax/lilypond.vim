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
  \lilyPitch,
  \lilyFunction,
  \lilyString,
  \lilyComment,
  \lilyNumber,
  \lilySpecial,
  \lilyDynamic,
  \lilySchemeReg,
  \lilyScheme,
  \lilyBoolean,
  \lilyLyrics,
  \lilyMarkup,
  \lilyArgument,
  \lilyContext,
  \lilyGrob,
  \lilyTranslator,
  \lilyClef,
  \lilyAccidentalsStyle,
  \lilyRepeatType,
  \lilyPitchLanguageName,
  \lilyDefineVar,
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

syn match  lilyFing "\(\-\|[(\)]\)" display contained nextgroup=lilyNumber
syn match  lilyChordBass "\/" display contained nextgroup=lilyPitch

syn match lilyClef "\<\(C\|F\|G\|G2\|GG\|alto\|altovarC\|baritone\|baritonevarC\|baritonevarF\|bass\|blackmensural-c1\|blackmensural-c2\|blackmensural-c3\|blackmensural-c4\|blackmensural-c5\|french\|hufnagel-do-fa\|hufnagel-do1\|hufnagel-do2\|hufnagel-do3\|hufnagel-fa1\|hufnagel-fa2\|kievan-do\|medicaea-do1\|medicaea-do2\|medicaea-do3\|medicaea-fa1\|medicaea-fa2\|mensural-c1\|mensural-c2\|mensural-c3\|mensural-c4\|mensural-c5\|mensural-f\|mensural-g\|mezzosoprano\|moderntab\|neomensural-c1\|neomensural-c2\|neomensural-c3\|neomensural-c4\|neomensural-c5\|percussion\|petrucci-c1\|petrucci-c2\|petrucci-c3\|petrucci-c4\|petrucci-c5\|petrucci-f\|petrucci-f2\|petrucci-f3\|petrucci-f4\|petrucci-f5\|petrucci-g\|petrucci-g1\|petrucci-g2\|soprano\|subbass\|tab\|tenor\|tenorG\|tenorvarC\|treble\|varC\|varbaritone\|varpercussion\|vaticana-do1\|vaticana-do2\|vaticana-do3\|vaticana-fa1\|vaticana-fa2\|violin\)\(\A\|\n\)"

syn match lilyRepeatType "\<\(percent\|segno\|tremolo\|unfold\|volta\)\(\A\|\n\)"

syn match lilyPitchLanguageNames "\<\(arabic\|catalan\|català\|deutsch\|english\|espanol\|español\|français\|italiano\|nederlands\|norsk\|portugues\|português\|suomi\|svenska\|vlaams\)\(\A\|\n\)"

syn match lilyAccidentalsStyle "\<\(choral-cautionary\|choral\|default\|dodecaphonic-first\|dodecaphonic-no-repeat\|dodecaphonic\|forget \|modern-cautionary\|modern-voice\|modern-voice-cautionary\|neo-modern-cautionary\|neo-modern-voice\|neo-modern-voice-cautionary\|neo-modern\|modern\|no-reset\|piano-cautionary\|piano\|teaching\|voice\)\(\A\|\n\)"me=e,ms=s

syn match lilyGrob     "\<\u\a\+\>" display nextgroup=lilyVarReg
syn match lilyMarkupFn "\\\a\(\i\|\-\)\+"
syn match lilyFunction "\\\a\(\i\|\-\)\+"
syn match lilyFunction "\(\\tweak\|\\set\)\s\+" display nextgroup=lilyVarReg
syn match lilyDynamic "[-_^]\?\\\(cr\|cresc\|decr\|decresc\|dim\|endcr\|endcresc\|enddecr\|enddecresc\|enddim\|f\|ff\|fff\|ffff\|fffff\|fp\|fz\|mf\|mp\|n\|p\|pp\|ppp\|pppp\|ppppp\|rfz\|sf\|sff\|sfp\|sfz\|sp\|spp\)\(\A\|\n\)"me=e-1

if g:nvls_language == "français"
  syn match lilyPitch "\<\(la\|si\|do\|re\|ré\|mi\|fa\|sol\|la\|s\|R\|r\)\(dd\|bb\|x\|sd\|sb\|dsd\|bsb\|d\|b\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilyArticulation,lilyFunction
elseif g:nvls_language == "english"
  syn match lilyPitch "\<\([a-g]\|s\|R\|r\)\(ss\|ff\|x\|qs\|qf\|tqs\|tqf\|s\|f\|\-flatflat\|\-sharpsharp\|\-flat\|\-sharp\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilyArticulation,lilyFunction
elseif g:nvls_language == "nohl"
else
syn match lilyPitch "\<\([a-g]\|s\|R\|r\)\(isis\|eses\|eh\|ih\|eseh\|isih\|is\|es\|\)\(\A\|\n\)"me=e-1
  \ display nextgroup=lilyNotesAttr,lilyArticulation,lilyFunction,lilySpecial
endif

syn match lilyNotesAttr "\(\'\+\|\,\+\|\)\(?\|!\|\)"
  \ display contained nextgroup=lilyRythm,lilySpecial

syn match lilyRythm "\(1024\|512\|256\|128\|64\|32\|16\|8\|4\|2\|1\|\)\(\.\+\|\)\(\A\|\n\)"me=e-1
  \ display contained nextgroup=lilyArticulation,lilyFunction,lilyChordStart,lilyChordBass,lilyFing,lilySpecial

hi link lilyRythm lilyPitch

if g:nvls_language != "nohl"
  syn match lilyChordStart "\:" display contained nextgroup=lilyChordNat
  syn match lilyChordNat "\([2-9]\|1[0-3]\|\)\(maj\|dim\|sus\|aug\|m\|\)\([2-9]\|1[0-3]\|\)\(+\|\-\|\)" display contained nextgroup=lilyChordExt,lilyChordBass
  syn match lilyChordExt "\.\([2-9]\|1[0-3]\)\(+\|\-\|\)" contained contains=lilyDots nextgroup=lilyChordExt,lilyChordBass
end

syn match  lilyDefineVar "\(\i\|\-\)\+\(\s\|\)\+="me=e-1
syn region lilyVarReg 
  \ start="\(\.\|\i\)" 
  \ end="\s" 
  \ contained contains=lilyDots,lilyVar
syn match lilyVar "\(\a\|\-\)" contained
syn match lilyDots "\." contained

syn match lilyContext "\(\\\|\<\)\(AncientRemoveEmptyStaffContext\|ChoirStaff\|ChordNames\|CueVoice\|Devnull\|DrumStaff\|DrumVoice\|Dynamics\|FiguredBass\|FretBoards\|Global\|GrandStaff\|GregorianTranscriptionStaff\|GregorianTranscriptionVoice\|KievanStaff\|KievanVoice\|Lyrics\|MensuralStaff\|MensuralVoice\|NoteNames\|NullVoice\|OneStaff\|PetrucciStaff\|PetrucciVoice\|PianoStaff\|RemoveEmptyDrumStaffContext\|RemoveEmptyRhythmicStaffContext\|RemoveEmptyStaffContext\|RemoveEmptyTabStaffContext\|RhythmicStaff\|Score\|Staff\|StaffGroup\|TabStaff\|TabVoice\|VaticanaStaff\|VaticanaVoice\|Voice\)\(\A\|\n\)"me=e-1

syn match lilyTranslator "\u\l\+\(_\)\w*\(engraver\|performer\|translator\)"

syn match  lilyScheme  "\(#['`]\?\|\$\)[^'\"(0-9 ]*[\n ]"ms=s+1
syn match  lilyBoolean "\(##f\|##t\|#f\|#t\)\(\A\|\n\)"
syn region lilyString  start=/"/  end=/"/   skip=/\\"/
syn region lilyComment start="%{" skip="%$" end="%}"
syn region lilyComment start="%\([^{]\|$\)" end="$"
syn match  lilyDynamic "\\[<!>\\]"

if g:nvls_language == "nohl"
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\{,3}" display nextgroup=lilyInterval,lilyChordStart,lilyArticulation,lilyFing
else 
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\?" display nextgroup=@lilyMatchGroup,lilyInterval,lilyChordStart,lilyArticulation,lilyFing
end
syn match  lilySpecial "[(~)]\|[(*)]\|[(=)]\|[(^)]\|[(-)]\|[(_)]"

syn match  lilyInterval      "\(+\|\-\)" contained

syn match  lilyArticulation "[-_^][-_^+|>|.]" display contained nextgroup=lilyFing

syn match Error ">>"
syn match Error "}"
syn match Error "\l\+\d[',]\+"
syn match Error "\<\\tuplet\(\s\|\)\+{"me=e-1

syn include @Scheme syntax/scheme.vim
unlet b:current_syntax
syn region lilySchemeReg
  \ matchgroup=Delimiter 
  \ start="#['`]\?(" 
  \ end=")" 
  \ contains=@Scheme,lilyInScheme

syn region lilyInScheme
  \ matchgroup=Delimiter 
  \ start="#{" 
  \ end="#}"
  \ contained contains=@lilyMatchGroup,lilyInScheme

syn region lilyInScheme
  \ matchgroup=Delimiter 
  \ start="(" 
  \ end=")"
  \ contains=@Scheme,lilyInScheme

syn region lilyLyrics
  \ matchgroup=lilyLyrics
  \ start="\(\\addlyrics\s\+{\|\\lyricmode\s\+{\|\\lyricsto\s\+\"\+\l\+\"\+\s\+{\)"
  \ end="}"
  \ contains=ALLBUT,lilyGrob,lilyPitch,Error,lilyNotesAttr,lilyVarReg,lilyVar,lilyInnerMarkup,lilyChordNat

syn region lilyInnerLyrics 
  \ matchgroup=Delimiter 
  \ start="\({\|(\|<\)" end="\(}\|)\|>\)" 
  \ contained contains=ALLBUT,lilyGrob,lilyPitch,lilyNotesAttr,lilyVarReg,lilyVar,lilyInnerMarkup,lilyChordNat

syn match lilyGrobsExcpt "LyricText"

syn region lilyMarkup
  \ matchgroup=lilyFunction
  \ start="\([\_\^\-]\\markup\s\+{\|\\markup\s\+{\)"
  \ end="}"
  \ contains=ALLBUT,lilyFunction,lilyInnerLyrics,lilyNotesAttr,lilyInterval,lilyArticulation,lilyVarReg,lilyVar

syn region lilyInnerMarkup
  \ matchgroup=Delimiter
  \ start="{" 
  \ end="}" 
  \ contained contains=ALLBUT,lilyFunction,lilyInnerLyrics,lilyNotesAttr,lilyInterval,lilyArticulation,lilyVarReg,lilyVar


hi link lilyInnerLyrics       lilyLyrics
hi link lilyInnerMarkup       lilyMarkup
hi link lilyGrobsExcpt        lilyGrobs
hi link lilyRepeatType        lilyArgument
hi link lilyPitchLanguageName lilyArgument
hi link lilyAccidentalsStyle  lilyArgument
hi link lilyClef              lilyArgument
hi link lilyInterval          lilySpecial
hi link lilyDots              lilySpecial
hi link lilyDefineVar         lilyVar
hi link lilyNotesAttr         lilyPitch
hi link lilyFing              lilySpecial
hi link lilyChordBass         lilySpecial
hi link lilyChordStart        lilySpecial
hi link lilyChordNat          lilyChord
hi link lilyChordExt          lilyChord

let b:current_syntax = "lilypond"

let &cpo = s:keepcpo
unlet s:keepcpo
