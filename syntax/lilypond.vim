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
  \lilyMarkupReg,
  \lilyChordReg,
  \lilyMarkup,
  \lilyScheme,
  \lilyBoolean,
  \lilyLyrics,
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

syn region lilyChordReg
  \ matchgroup=lilyChord
  \ start="<"
  \ end=">"
  \ contained
  \ contains=lilyPitch,lilyFing
  \ nextgroup=lilyRythm

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="{"
  \ skip="\\\\\|\\[<>]"
  \ end="}"
  \ contains=@lilyMatchGroup 
  \ nextgroup=lilyArticulation
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter
  \ start="\["
  \ end="]"
  \ contains=@lilyMatchGroup
  \ fold

syn region lilyMatcher  
  \ matchgroup=Delimiter 
  \ start="<\{2}" 
  \ skip="\\\\\|\\[{<>}]" 
  \ end=">\{2}" 
  \ contains=@lilyMatchGroup 
  \ fold

if g:nvls_language != "nohl"
  syn match  lilyFing "\s\{}[-_^\\]\d\+" contained nextgroup=lilyFing
endif

syn match lilyChordBass "\/" contained containedin=@lilyPitchGroup nextgroup=lilyPitch

syn match lilyMarkup   "[-_^]\?\\\a\([-_]\{}\a\)\{}\s\{}"
syn match lilyFunction "[-_^]\?\\\a\([-_]\{}\a\)\{}\s\{}" nextgroup=lilyPitch,lilyMatcher
syn match lilyFunction "[-_^]\?\(\\tweak\|\\set\|\\unset\)\s\+" nextgroup=lilyVar,lilyContext,lilyGrob
syn match lilyDynamic  "[-_^]\?\\\v((end)?(de)?cr(esc)?|(end)?dim|f{1,5}(p|z)?|m(f|p)?|n|p{1,5}|rfz|sf{1,2}|sf(p|z)?|sp{1,2})(\A|\n)"me=e-1

syn cluster lilyPitchGroup contains=lilyPitch,lilyRythm,lilyChordStart,lilyChordNat,lilyChordExt

if g:nvls_language == "français"
  syn match lilyPitch "\_^\?\v<(la|si|do|re|ré|mi|fa|sol|la|si|R|r)(dd|bb|x|sd|sb|dsd|bsb|d|b){}('+|,+){}(\?|\!)=(\A|\n)"me=e-1
    \ nextgroup=lilyRythm contained
elseif g:nvls_language == "english"
  syn match lilyPitch "\_^\?\v<([a-g]|s|R|r)(ss|ff|x|qs|qf|tqs|tqf|s|f|-flatflat|-sharpsharp|-flat|-sharp){}('+|,+){}(\?|\!)=(\A|\n)"me=e-1
    \ nextgroup=lilyRythm contained
elseif g:nvls_language == "nohl"
else
  syn match lilyPitch "\_^\?\v<([a-g]|s|R|r)(isis|eses|eh|ih|eseh|isih|is|es){}('+|,+){}(\?|\!)=(\A|\n)"me=e-1
    \ nextgroup=lilyRythm contained
  syn match lilyPitch "\_^\?\v<(a|e)(ses|s)('+|,+){}(\?|\!)=(\A|\n)"me=e-1
    \ nextgroup=lilyRythm contained
endif

syn match lilyRythm "\(\/\l\+\)\@<!\v(1024|512|256|128|64|32|16|8|4|2|1)=\.{}(\*\d{1,2})="
  \ contained contains=lilySpecial nextgroup=lilyArticulation,lilyFunction,lilyChordNat,lilyChordBass,lilyFing,lilySpecial,lilyDynamic,lilyMarkupReg

if g:nvls_language != "nohl"
  syn match lilyChordStart "\:" contained 
        \ containedin=lilyChordNat

  syn match lilyChordNat "\:\v(\d{1,2}(\+|-)?)?(maj|dim|sus|aug|min|m)?(\d{,2}(\+|-)?)?>"me=e+1,hs=s+1,he=e+1 contained
        \ containedin=@lilyPitchGroup
        \ nextgroup=lilyChordExt,lilyChordBass
        \ contains=lilyChordStart

  syn match lilyChordExt "\.\v([2-9]|1[0-3])(\+|-)=(\A|\n)"me=e-1 contained 
        \ containedin=lilyChordNat,lilyChordExt
        \ nextgroup=lilyChordExt,lilyChordBass
        \ contains=lilyDots
end

syn match lilyClef "\<\v(C|F|G|G2|GG|alto(varC)?|baritone(var(C|F))?|bass|blackmensural-c[1-5]|french|hufnagel-do-fa|hufnagel-do[1-3]|hufnagel-fa[1-2]|kievan-do|medicaea-do[1-3]|medicaea-fa[1-2]|mensural-(f|g|c[1-5])|mezzosoprano|moderntab|neomensural-c[1-5]|percussion|petrucci-c[1-5]|petrucci-f[2-5]?|petrucci-g(1|2)?|soprano|subbass|tab|tenor(G|varC)?|treble|var(C|baritone|percussion)|vaticana-do[1-3]|vaticana-fa[1-2]|violin)(\A|\n)"me=e-1

syn match lilyRepeatType "\<\v(percent|segno|tremolo|unfold|volta)(\A|\n)"me=e-1

syn match lilyPitchLanguageNames "\<\v(arabic|catal(an|à)|deutsch|english|espa(n|ñ)ol|français|italiano|nederlands|norsk|portugu(e|ê)s|suomi|svenska|vlaams)(\A|\n)"

syn match lilyAccidentalsStyle "\v<(choral(-cautionary)?|default|dodecaphonic(-first|-no-repeat)?|forget|(neo-)?modern(-voice)?(-cautionary)?|modern|no-reset|piano(-cautionary)?|teaching|voice)(\A|\n)"me=e-1

syn match lilyGrob     "\<\u\a\+"

syn match lilyDefineVar "\a\(\(\a\|\-\|_\)\{}\a\)\{}\s\{}="he=e-1 contains=lilySpecial
syn match lilyVar "\(\s\|\.\)\=\s\{}\(\l\|\u\|\-\|X\|Y\)\{}\(X\|Y\|\l\)\+" contained nextgroup=lilyVar,lilyDefineVar contains=lilyDots
syn match lilyDefineVar "\l\(\l\|\-\)\+\l\+\." contains=lilyDots nextgroup=lilyVar
syn match lilyDots "\." contained

syn match lilyGrob     "\<\u\a\+\n\{}\s\{}\." nextgroup=lilyVar contains=lilyDots

syn match lilyContext "\v<\\?(Choir|Drum|Grand|Mensural|One|Petrucci|Piano|Rhythmic|Tab|Vaticana|GregorianTranscription|Kievan)?Staff(Group)?>" nextgroup=lilyDots
syn match lilyContext "\v<\\?((Chord|Note)?Names|(Devnull|Dynamics|FiguredBass|FretBoards|Global|Lyrics|Score)|(Cue|Drum|Gregorian|Kievan|Mensural|Null|Tab|Vaticana)?Voice)|((Ancient)?(RemoveEmpty))?(Drums|Rythmic|Tab)?(StaffContext)?>" nextgroup=lilyDots

syn match lilyTranslator "\u\l\+\(_\a\+\)\{}\v(_engraver|_performer|_translator)"

syn match  lilyScheme  "\(#['`]\?\|\$\)[^'\"(0-9 ]*[\n ]"ms=s+1
syn match  lilyBoolean "\v(##f|##t|#f|#t)(\A|\n)"
syn region lilyString  start=/[_^-]\?"/  end=/"/   skip=/\\"/
syn region lilyComment start="%{" skip="%$" end="%}"
syn region lilyComment start="%\([^{]\|$\)" end="$"
syn match  lilyDynamic "\\[<!>\\]"

if g:nvls_language == "nohl"
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\{,3}" nextgroup=lilyChordNat,lilyArticulation,lilyFing
else 
  syn match  lilyNumber       "[-_^.]\?\(\-\.\|\)\d\+[.]\?" nextgroup=@lilyMatchGroup,lilyChordNat,lilyArticulation,lilyFing
end

syn match  lilySpecial "[-_^]\?[(~)]\|[(*)]\|[(=)]"
syn match  lilyArticulation "\s\{}[-_^][-_^+|>|.]"

syn match Error " "
syn match Error ">>"
syn match Error "}"
syn match Error "\l\+\d[',]\+"
syn match Error "\<\\tuplet\(\s\|\)\+{"me=e-1

syn include @Scheme syntax/scheme.vim
unlet b:current_syntax
syn region lilyScheme
  \ matchgroup=Delimiter 
  \ start="#['`]\?\s\{}\(\n\|\s\)\{}(" 
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
  \ contains=ALLBUT,lilyGrob,@lilyPitchGroup,Error,lilyVar,lilyDefineVar,lilyInnerMarkup

syn region lilyInnerLyrics 
  \ matchgroup=Delimiter 
  \ start="\({\|(\|<\)" end="\(}\|)\|>\)" 
  \ contained contains=ALLBUT,lilyGrob,@lilyPitchGroup,lilyVar,lilyDefineVar,lilyInnerMarkup
  \ containedin=lilyLyrics

syn match lilyGrobsExcpt "LyricText"

syn region lilyMarkupReg
  \ matchgroup=lilyMarkup
  \ start="[-_^]\?\\markup\s\+{"
  \ end="}"
  \ contains=ALLBUT,lilyFunction,lilyInnerLyrics,@lilyPitchGroup,lilyVar,lilyDefineVar

syn region lilyInnerMarkup
  \ matchgroup=Delimiter
  \ start="{" 
  \ end="}" 
  \ contained contains=ALLBUT,lilyFunction,lilyInnerLyrics,@lilyPitchGroup,lilyVar,lilyDefineVar
  \ containedin=lilyMarkupReg

hi link lilyInnerLyrics       lilyLyrics
hi link lilyGrobsExcpt        lilyGrob
hi link lilyRepeatType        lilyArgument
hi link lilyPitchLanguageName lilyArgument
hi link lilyAccidentalsStyle  lilyArgument
hi link lilyClef              lilyArgument
hi link lilyDefineVar         lilyVar
hi link lilyRythm             lilyPitch
hi link lilyFing              lilySpecial
hi link lilyChordBass         lilySpecial
hi link lilyChordStart        lilySpecial
hi link lilyDots              lilySpecial
hi link lilyChordNat          lilyChord
hi link lilyChordExt          lilyChord

let b:current_syntax = "lilypond"
let &cpo = s:keepcpo
unlet s:keepcpo
