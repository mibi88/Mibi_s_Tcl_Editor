::ctext::addHighlightClass .pan.mainf.textf.st tclkeywords blue [list set info interp uplevel global upvar if elseif else proc text button label entry package puts toplevel frame canvas return for while switch case lappend unset variable foreach namespace for incr list regsub close expr foreach llengthappend concat format load return array gets lrange proc switchfile glob lappend lreplace putsbreak global lsearch set catch eval lindex lsort while exec if linsert open regexp source clock exit package split unknown after info pid rename string unset fblocked interp pkg_mkIndex subst update continue fconfigure join scan uplevel bgerror eof seek tclvars upvar error fileevent library pwd tell vwait filename history read socket time cd flush trace pack insert delete get grid place search]
::ctext::addHighlightClass .pan.mainf.textf.st modulenames purple [list Tk TclOO Tcl ctext autoscroll canvas chatwidget crosshair cursor datefield Diagrams getstring tklib_history ico ipentry khim ntext plotchart style swaplist tablelist tkpiechart tooltip widget]
::ctext::addHighlightClass .pan.mainf.textf.st kwglobal red [list require provide tearoff]
::ctext::addHighlightClassWithOnlyCharStart .pan.mainf.textf.st args brown \-
::ctext::addHighlightClassWithOnlyCharStart .pan.mainf.textf.st vars green \$
::ctext::addHighlightClassForRegexp .pan.mainf.textf.st comments gray {#[^\n\r]*}
::ctext::addHighlightClassForSpecialChars .pan.mainf.textf.st brackets darkblue {[]{}}
::ctext::addHighlightClassForRegexp .pan.mainf.textf.st aquotes darkgreen {"(\\"|[^"])*"}
::ctext::addHighlightClassForRegexp .pan.mainf.textf.st bquotes darkgreen {'(\\'|[^'])*'}
::ctext::addHighlightClassForSpecialChars .pan.mainf.textf.st math darkred {+=*-/&^%!|<> 0 1 2 3 4 5 6 7 8 9 .}
::ctext::addHighlightClass .pan.mainf.textf.st bools darkred [list true false]
::ctext::addHighlightClassForRegexp .pan.mainf.textf.st class darkblue {::}
