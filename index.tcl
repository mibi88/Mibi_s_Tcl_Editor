#!/usr/bin/wish

package require Tcl 8.6
package require Tk
package require ctext
package require tkcon

set tclfile_path [file dirname [file normalize [info script]]]
set fontconfig_path "$tclfile_path/font.mibiconfig"
# puts $tclfile_path
puts $fontconfig_path
set font_o [open $fontconfig_path r]
set font_data [read $font_o]
set font_data_list [split $font_data "\n"]
set font_familly [lindex $font_data_list 0]
set font_size [lindex $font_data_list 1]
set tabswidth 4

set filename "None"
set saved 1
proc askabort {  } {
  global saved
  if { $saved == 0 } {
    set result [tk_messageBox -message "Not saved" -icon question -type yesnocancel -detail "The document isn't saved ! Do you want to save it, and to continue ? Click on \"cancel\" to abort."]
    if { $result == "cancel"} {
      return false
    } elseif { $result == "yes" } {
      save_f
      return true
    } elseif { $result == "no" } {
      return true
    }
  } else {
    return true
  }
}
proc new_f {  } {
  puts "New file"
  if { [askabort] == true} {
    global saved
    global filename
    .mainf.textf.st delete 1.0 end
    set saved 1
    set filename "None"
    settitle
  }
}

proc open_f {  } {
  puts "Open"
  global filename
  global saved
  set filetypes {
    {{Text Files}       {.txt}        }
    {{TCL Scripts}      {.tcl}        }
    {{Python Scripts}   {.py}         }
    {{Python Scripts}   {.pyw}        }
    {{All Files}        *             }
  }
  if { [askabort] == true} {
    set filename [tk_getOpenFile -filetypes $filetypes]
    if { $filename != "" } {
      set saved 1
      settitle
      set file_o [open $filename r]
      set file_content [read $file_o]
      close $file_o
      .mainf.textf.st delete 1.0 end
      .mainf.textf.st insert 1.0 $file_content
    }
  }
}
proc save_f {  } {
  puts "Save"
  global filename
  global saved
  if { $filename != "None" } {
    set saved 1
    settitle
    set file_o [open $filename w]
    puts $file_o [.mainf.textf.st get 1.0 end]
    close $file_o
  } else {
    saveas_f
  }
}
proc saveas_f {  } {
  puts "Save as"
  global filename
  set filetypes {
    {{Text Files}       {.txt}        }
    {{TCL Scripts}      {.tcl}        }
    {{Python Scripts}   {.py}         }
    {{Python Scripts}   {.pyw}        }
    {{All Files}        *             }
  }
  set filename [tk_getSaveFile -filetypes $filetypes -confirmoverwrite true]
  global filename
  global saved
  if { $filename != "" } {
    set saved 1
    settitle
    set file_o [open $filename w]
    puts $file_o [.mainf.textf.st get 1.0 end]
    close $file_o
    set saved 1
    settitle
  }
}
proc settitle {  } {
  global saved
  global filename
  if {$saved == 1} {
    wm title . "Mibi's Tcl IDE - $filename"
  } elseif { $saved == 0 } {
    wm title . "* Mibi's Tcl IDE - $filename *"
  }
}
proc textismodified {  } {
    global saved
    set saved 0
    settitle
}
proc quit_w {  } {
  if { [askabort] == true} {
    exit
  }
}
proc about_w {  } {
  set textvar "TextEditor (test) v.0.1.6.2\nby mibi88\nLicense : The Unlicense\nCodename : v11 public\n2021-2021"
  toplevel .about
  wm transient .about .
  text .about.info
  .about.info insert end $textvar
  .about.info configure -state disabled
   pack .about.info -fill both -expand true
}
proc settings_w {  } {
  global font_familly
  global font_size
  global fontconfig_path
  toplevel .settings
  wm transient .settings .
  #puts [font names]
  #puts [font families]
  ttk::combobox .settings.font -values [font families] -state normal
  .settings.font set $font_familly
  spinbox .settings.fontsize -from 9 -to 96
  .settings.fontsize set $font_size
  button .settings.apply -text "Apply" -command { set font_size [.settings.fontsize get]; set font_familly [.settings.font get]; set font_o [open $fontconfig_path w]; puts $font_o $font_familly; puts $font_o $font_size; close $font_o; font configure textboxfont -family $font_familly -size $font_size}
  pack .settings.font
  pack .settings.fontsize
  pack .settings.apply
}
proc run_f {  } {
  global saved
  global filename
  if { $saved == 1 } {
    if { $filename != "None" } {
      puts "=== Running file : $filename ==="
      tkcon show
      tkcon load $filename
    }
  } else {
    tk_messageBox -icon warning -message "An important warning" "To run a script, save before ;-)." -type "ok"
  }
}
proc consoleshow_w {  } {
  tkcon show
}
proc consolehide_w {  } {
  tkcon hide
}
settitle
menu .mb
. configure -menu .mb
menu .mb.file -tearoff 0
.mb.file add command -label "New file ...  Ctrl-S" -command { new_f }
.mb.file add separator
.mb.file add command -label "Open ...      Ctrl-O" -command { open_f }
.mb.file add separator
.mb.file add command -label "Save          Ctrl-S" -command { save_f }
.mb.file add command -label "Save as ... Ctrl-Shift-S" -command { saveas_f }
.mb.file add separator
.mb.file add command -label "Quit          Ctrl-Q" -command { quit_w }
.mb add cascade -label "File" -menu .mb.file
menu .mb.tools -tearoff 0
.mb.tools add command -label "Settings" -command { settings_w }
.mb.file add separator
.mb.tools add command -label "Run           F5" -command { run_f }
.mb.file add separator
.mb.tools add command -label "Show TkCon" -command { consoleshow_w }
.mb.tools add command -label "Hide TkCon" -command { consolehide_w }
.mb add cascade -label "Tools" -menu .mb.tools
menu .mb.about -tearoff 0
.mb.about add command -label "About" -command { about_w }
.mb add cascade -label "About" -menu .mb.about

frame .mainf
frame .mainf.textf
scrollbar .mainf.scroll -command {.mainf.textf.st yview} -orient vertical
scrollbar .mainf.textf.scrollh -command {.mainf.textf.st xview} -orient horizontal
font create textboxfont -family $font_familly -size $font_size
ctext .mainf.textf.st -yscrollcommand {.mainf.scroll set} -xscrollcommand {.mainf.textf.scrollh set} -wrap none -tabs $tabswidth -undo true -font textboxfont
pack .mainf -fill both -expand yes
pack .mainf.textf -fill both -expand yes -side left
pack .mainf.textf.st -fill both -expand yes
pack .mainf.scroll -fill y -side left
pack .mainf.textf.scrollh -fill x
# syntax hightlighting
::ctext::addHighlightClass .mainf.textf.st tclkeywords blue [list set info interp uplevel global upvar if elseif else proc text button label entry package puts toplevel frame canvas return for while switch case lappend unset variable foreach namespace for incr list regsub close expr foreach llengthappend concat format load return array gets lrange proc switchfile glob lappend lreplace putsbreak global lsearch set catch eval lindex lsort while exec if linsert open regexp source clock exit package split unknown after info pid rename string unset fblocked interp pkg_mkIndex subst update continue fconfigure join scan uplevel bgerror eof seek tclvars upvar error fileevent library pwd tell vwait filename history read socket time cd flush trace
]
::ctext::addHighlightClass .mainf.textf.st modulenames purple [list Tk TclOO Tcl ctext autoscroll canvas chatwidget crosshair cursor datefield Diagrams getstring tklib_history ico ipentry khim ntext plotchart style swaplist tablelist tkpiechart tooltip widget]
::ctext::addHighlightClass .mainf.textf.st kwglobal red [list require provide tearoff]
::ctext::addHighlightClassWithOnlyCharStart .mainf.textf.st args brown \-
::ctext::addHighlightClassWithOnlyCharStart .mainf.textf.st vars green \$
::ctext::addHighlightClassWithOnlyCharStart .mainf.textf.st comments gray \#
#=====================
bind .mainf.textf.st <<Modified>> {  textismodified  }
bind . <Control-s> {  save_f  }
bind . <Control-S> {  saveas_f  }
bind . <Control-o> {  open_f  }
bind . <Control-n> {  new_f  }
bind . <Control-q> {  quit_w  }
bind . <F5> {  run_f  }

wm protocol . WM_DELETE_WINDOW { quit_w }
