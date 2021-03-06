#! /usr/bin/wish

######################################
## Mibi's Tcl Editor                ##
## by Mibi88                        ##
## v.0.5                            ##
## -------------------------------- ##
## A small Tcl IDE                  ##
## -------------------------------- ##
## Requirements :                   ##
## o Tcl 8.6                        ##
## o Tk  8.6                        ##
## o ctext 3.2                      ##
## -------------------------------- ##
## License : GNU GPL v2             ##
######################################

######################################
## Variables :                      ##
## o tclfile_path -> Language       ##
##   configuration file.            ##
## o fontconfig_path -> Text box    ##
##   font and tabs width            ##
##   configuration file.            ##
## o font_o -> fontconfig_path file ##
##   object.                        ##
## o font-data -> Content of font   ##
##   configuration file.            ##
######################################

package require Tcl 8.6
package require Tk 8.6
package require ctext 3.2

proc loadconfig {  } {
  global tclfile_path
  global fontconfig_path
  global font_o
  global font_data
  global font_data_list
  global font_family
  global font_size
  global file_tabswidth
  global tabswidth
  global mainconfig_path
  global mainconfig_o
  global mainconfig_data
  global mainconfig_data_list
  global lang
  global config_lenght
  global langs
  global cmdconfig_path
  global langpath
  global lang_path
  global langs_names
  global langs_path
  global lang_o
  global langconf
  global langconf_list
  global langname
  global cmdconfig_path
  global cmd_o
  global cmd_data
  global cmd_data_list
  global language
  global cmd
  global tclsh_cmd
  global chan
  global filename
  global saved
  global index
  set tclfile_path [file dirname [file normalize [info script]]]
  set fontconfig_path "$tclfile_path/data/font.mibiconfig"
  puts $fontconfig_path
  set font_o [open $fontconfig_path r]
  set font_data [read $font_o]
  close $font_o
  puts "(Info) Font config : $font_data at $fontconfig_path"
  set font_data_list [split $font_data "\n"]
  set font_family [lindex $font_data_list 0]
  set font_size [lindex $font_data_list 1]
  set file_tabswidth [lindex $font_data_list 2]
  set tabswidth "{ $file_tabswidth c numeric 1c }"
  ########### MAIN CONFIG START ##############
  set mainconfig_path "$tclfile_path/data/config.mibiconfig"
  set mainconfig_o [open $mainconfig_path r]
  set mainconfig_data [read $mainconfig_o]
  close $mainconfig_o
  set mainconfig_data_list [split $mainconfig_data "\n"]
  set lang [lindex $mainconfig_data_list 0]
  set config_lenght [llength $mainconfig_data_list]
  #for {set i 1} {$i < $config_lenght} {incr i} {
  #  set langdata [lindex $mainconfig_data_list $i]
  #  set langdata_list [split $langdata " "]
  #  set langname [lindex $langdata_list 0]
  #  set langdir [lindex $langdata_list 0]
  # }
  set langs [glob -directory "$tclfile_path/langs" -type d *]
  #puts $langs
  puts "----- LANGS -----"
  set cmdconfig_path ""
  set langpath ""
  set langs_names {}
  set langs_path {}
  foreach i $langs {
    set lang_o [open "$i/langconf.mibiconfig"]
    set langconf [read $lang_o]
    close $lang_o
    set langconf_list [split $langconf "\n"]
    set langname [lindex $langconf_list 0]
    puts "$langname : $i"
    if {$langname == $lang} {
      set cmdconfig_path "$i/langconf.mibiconfig"
      set langpath $i
    }
    set langs_names [concat $langs_names $langname]
    set langs_path [concat $langs_path $i]
  }
  puts "----- LANGS DATA -----"
  puts $langs_names
  puts $langs_path
  ########### MAIN CONFIG END ################
  set cmd_o [open $cmdconfig_path r]
  set cmd_data [read $cmd_o]
  set cmd_data_list [split $cmd_data "\n"]
  set language [lindex $cmd_data_list 0]
  set cmd [lindex $cmd_data_list 1]
  set tclsh_cmd [lindex $cmd_data_list 2]
  close $cmd_o
  set chan "none"
  set filename "None"
  set saved 1
  set index 1.0
  puts "(Info) Font family : $font_family"
  puts "(Info) Font family : $font_size"
  puts "(Info) Tabs width : $file_tabswidth"
}
loadconfig
######################################################################## FUNCTIONS START ###########################################################################
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
  puts "(Info) New file."
  if { [askabort] == true} {
    global saved
    global filename
    .pan.mainf.textf.st delete 1.0 end
    set saved 1
    set filename "None"
    settitle
  }
}

proc open_f {  } {
  puts "(Info) Open."
  global filename
  global saved
  set filetypes {
    {{TCL Scripts}      {.tcl}        }
    {{Python Scripts}   {.py}         }
    {{Python Scripts}   {.pyw}        }
    {{Text Files}       {.txt}        }
    {{All Files}        *             }
  }
  if { [askabort] == true} {
    set temp_filename [tk_getOpenFile -filetypes $filetypes]
    if { $temp_filename != "" } {
      set filename $temp_filename
      set saved 1
      settitle
      set file_o [open $filename r]
      set file_content [read $file_o]
      close $file_o
      .pan.mainf.textf.st delete 1.0 end
      .pan.mainf.textf.st insert 1.0 $file_content
      update idletasks
      .pan.mainf.textf.st highlight 1.0 end
    }
  }
}
proc save_f {  } {
  puts "(Info) Save."
  global filename
  global saved
  if { $filename != "None" } {
    set saved 1
    settitle
    set file_o [open $filename w]
    puts $file_o [.pan.mainf.textf.st get 1.0 end]
    close $file_o
  } else {
    saveas_f
  }
}
proc saveas_f {  } {
  puts "(Info) Save as."
  global filename
  global saved
  set filetypes {
    {{TCL Scripts}      {.tcl}        }
    {{Python Scripts}   {.py}         }
    {{Python Scripts}   {.pyw}        }
    {{Text Files}       {.txt}        }
    {{All Files}        *             }
  }
  set temp_filename [tk_getSaveFile -filetypes $filetypes -confirmoverwrite true]
  if { $temp_filename != "" } {
    set filename $temp_filename
    set saved 1
    settitle
    set file_o [open $filename w]
    puts $file_o [.pan.mainf.textf.st get 1.0 end]
    close $file_o
    set saved 1
    settitle
  }
}
proc settitle {  } {
  global saved
  global filename
  if {$saved == 1} {
    wm title . "Mibi's Tcl Editor - $filename"
  } elseif { $saved == 0 } {
    wm title . "* Mibi's Tcl Editor - $filename *"
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
  global tcl_platform
  set tclv [info patchlevel]
  set os_t $tcl_platform(os)
  set osv $tcl_platform(osVersion)
  set processor $tcl_platform(machine)
  set textvar "Mibi's Tcl Editor v.0.5\nby mibi88\nLicense : GNU GPL v2 or later\nCodename : v15\n2021-2021\n\nTcl version : $tclv\nOperating system : $os_t $osv\nProcessor : $processor"
  toplevel .about
  wm transient .about .
  text .about.info
  .about.info insert end $textvar
  .about.info configure -state disabled
   pack .about.info -fill both -expand true
}
proc settings_w {  } {
  global font_family
  global font_size
  global fontconfig_path
  global tabswidth
  global file_tabswidth
  global cmd
  global tclsh_cmd
  global .pan.mainf.textf
  global language
  global langs_names
  global langs_path
  global lang_names
  global langpath
  set lang_path $langpath
  toplevel .settings
  wm transient .settings .
  wm title .settings "Settings"
  label .settings.font_i -text "Font family :"
  ttk::combobox .settings.font -values [font families] -state normal
  .settings.font set $font_family
  label .settings.fontsize_i -text "Font size :"
  spinbox .settings.fontsize -from 9 -to 96 -state readonly
  .settings.fontsize set $font_size
  label .settings.tabw_i -text "Tab width\n(1 = tabs will be shown with\na width of 4 spaces) :"
  spinbox .settings.tabw -from 1 -to 12 -state readonly
  .settings.tabw set $file_tabswidth
  label .settings.lang_i -text "Programming language :"
  ttk::combobox .settings.lang -values $langs_names -state readonly
  bind .settings.lang <<ComboboxSelected>> {
    set language [.settings.lang get]
    set langnum [lsearch $langs_names $language]
    set lang_path [lindex $langs_path $langnum]
    set cmdconfig_path "$lang_path/langconf.mibiconfig"
    set cmd_o [open $cmdconfig_path r]
    set cmd_data [read $cmd_o]
    set cmd_data_list [split $cmd_data "\n"]
    set language [lindex $cmd_data_list 0]
    set cmd [lindex $cmd_data_list 1]
    set tclsh_cmd [lindex $cmd_data_list 2]
    close $cmd_o
    .settings.cmd delete 0 end
    .settings.cmd insert 0 $cmd
    .settings.cmd_tclsh delete 0 end
    .settings.cmd_tclsh insert 0 $tclsh_cmd }
  .settings.lang set $language
  label .settings.cmd_i -text "Run command\n(\"<f>\" will be\nreplaced with the\nname of the file\nto run) :"
  entry .settings.cmd
  label .settings.cmd_tclsh_i -text "Console command :"
  entry .settings.cmd_tclsh
  .settings.cmd delete 0 end
  .settings.cmd insert 0 $cmd
  .settings.cmd_tclsh delete 0 end
  .settings.cmd_tclsh insert 0 $tclsh_cmd
  button .settings.refresh -text "Refresh" -command { loadconfig
    .settings.font set $font_family
    .settings.font configure -values [font families]
    .settings.fontsize set $font_size
    .settings.tabw set $file_tabswidth
    .settings.lang set $language
    .settings.lang configure -values $langs_names
    .settings.cmd delete 0 end
    .settings.cmd insert 0 $cmd
    .settings.cmd_tclsh delete 0 end
    .settings.cmd_tclsh insert 0 $tclsh_cmd
  }
  button .settings.apply -text "Apply" -command { set font_size [.settings.fontsize get]
    set font_family [.settings.font get]
    set file_tabswidth [.settings.tabw get]
    set tabswidth "{ $file_tabswidth c numeric 1c }"
    set cmd [.settings.cmd get]
    set tclsh_cmd [.settings.cmd_tclsh get]
    set font_o [open $fontconfig_path w]
    set language [.settings.lang get]
    set langnum [lsearch $langs_names $language]
    set langpath [lindex $langs_path $langnum]
    set cmdconfig_path "$lang_path/langconf.mibiconfig"
    puts $font_o $font_family
    puts $font_o $font_size
    puts $font_o $file_tabswidth
    close $font_o
    font configure textboxfont -family $font_family -size $font_size
    .pan.mainf.textf.st configure -tabs $tabswidth
    set mainconfig_o [open $mainconfig_path w]
    puts $mainconfig_o $language
    close $mainconfig_o
    set cmd_o [open $cmdconfig_path w]
    puts $cmd_o $language
    puts $cmd_o $cmd
    puts $cmd_o $tclsh_cmd
    close $cmd_o
    removehighlight_c
    highlight_c
    .pan.mainf.textf.st highlight 1.0 end }
  pack .settings.font_i -fill x -expand true
  pack .settings.font -fill x -expand true
  pack .settings.fontsize_i -fill x -expand true
  pack .settings.fontsize -fill x -expand true
  pack .settings.tabw_i -fill x -expand true
  pack .settings.tabw -fill x -expand true
  pack .settings.lang_i -fill x -expand true
  pack .settings.lang -fill x -expand true
  pack .settings.cmd_i -fill x -expand true
  pack .settings.cmd -fill x -expand true
  pack .settings.cmd_tclsh_i -fill x -expand true
  pack .settings.cmd_tclsh -fill x -expand true
  pack .settings.apply -fill x -expand true
  pack .settings.refresh -fill x -expand true
}
proc runinfo {  } {
  global filename
  set systemTime [clock seconds]
  set strinfo [clock format $systemTime -format "== Running $filename | %A %d %B %Y at %I:%M:%S %p ==\n"]
  puts $strinfo
  return $strinfo
}
proc run_f {  } {
  puts "(Info) Running file."
  global saved
  global filename
  global tclfile_path
  global chan
  global cmd
  .pan.outf.out configure -state normal
  .pan.outf.out insert end [runinfo]
  .pan.outf.out tag configure errort -foreground red
  .pan.outf.out configure -state disabled
    if { $saved == 1 } {
      if { $filename != "None" } {
        set cmdstr [regsub "<f>" $cmd $filename]
        set command $cmdstr
        proc receive {chan} {
          .pan.outf.out configure -state normal
          .pan.outf.out insert end [read $chan]
          .pan.outf.out configure -state disabled
          .pan.outf.out see end
          if {[eof $chan]} {
            close $chan
          }
        }
        set chan [open |[concat $command 2>@1] a+]
        fconfigure $chan -blocking 0
        fileevent $chan readable [list receive $chan]
      } else {
        .pan.outf.out configure -state normal
        .pan.outf.out insert end "Error : No filename" errort
        .pan.outf.out configure -state disabled
    }
  } else {
    tk_messageBox -icon warning -message "An important warning" -type ok -detail "To run a script, save before ;-)."
    .pan.outf.out configure -state normal
    .pan.outf.out insert end "Error : Not Saved" errort
    .pan.outf.out configure -state disabled
  }
}
proc consoleshow_w {  } {
  global tclsh_cmd
  global tclfile_path
  puts [regsub "<f>" $tclsh_cmd "tkcon.tcl"]
  set console [open |[regsub "<f>" $tclsh_cmd "$tclfile_path/tkcon.tcl"]]
}
proc replace {  } {
  global .pan.mainf.textf.st
  toplevel .replace
  wm transient .replace .
  wm title .replace "Replace"
  label .replace.orgstr_i -text "To replace :"
  entry .replace.orgstr
  label .replace.newstr_i -text "With :"
  entry .replace.newstr
  button .replace.replaceb -text "Replace next" -command { set org [.replace.orgstr get]
    set new [.replace.newstr get]
    set text [.pan.mainf.textf.st get 1.0 end]
    set text_a [regsub $org $text $new]
    .pan.mainf.textf.st delete 1.0 end
    .pan.mainf.textf.st insert end $text_a }
  pack .replace.orgstr_i -fill x -expand true
  pack .replace.orgstr -fill x -expand true
  pack .replace.newstr_i -fill x -expand true
  pack .replace.newstr -fill x -expand true
  pack .replace.replaceb -fill x -expand true
}
proc search {  } {
  global .pan.mainf.textf.st
  global index
  set index 1.0
  toplevel .search
  wm transient .search .
  wm title .search "Search"
  label .search.str_i -text "To search :"
  entry .search.str
  button .search.searchb -text "Find next\n(click more than\none time to highlight\nalso the next word)" -command { puts $index
    set str [.search.str get]
    set position [.pan.mainf.textf.st  search -count n -- $str $index+2c]
    set index $position+${n}c
    .pan.mainf.textf.st tag add thing $position $position+${n}c
    .pan.mainf.textf.st tag configure thing -background yellow }
  pack .search.str_i -fill x -expand true
  pack .search.str -fill x -expand true
  pack .search.searchb -fill x -expand true
}
proc removesearchhighlight {  } {
  .pan.mainf.textf.st tag remove thing 1.0 end
}
proc copy_t {  } {
  clipboard clear
  selection own
  set text [selection get]
  clipboard append $text
}
proc cut_t {  } {
  clipboard clear
  set sel [selection own]
  set text [selection get]
  clipboard append $text
  catch {
    $sel delete sel.first sel.last
  }
}
proc paste_t {  } {
  puts "(Info) Paste."
  if {[catch {clipboard get} contents]} {
    puts "(Error) Error when trying to get the content of the clipboard."
  } else {
    selection own
    set text [clipboard get]
    set position [.pan.mainf.textf.st index insert]
    .pan.mainf.textf.st insert $position [clipboard get]
  }
}
####### SYNTAX HIGHLIGHTING #######
proc removehighlight_c {  } {
  set highlightclasses [::ctext::getHighlightClasses .pan.mainf.textf.st]
  puts "(Info) Removing highlight classes : $highlightclasses"
  ::ctext::clearHighlightClasses .pan.mainf.textf.st
  .pan.mainf.textf.st highlight 1.0 end
  update idletasks
}
proc highlight_c {  } {
  global langpath
  set highlight_o [open "$langpath/highlight.tcl" "r"]
  set highlight_script [read $highlight_o]
  close $highlight_o
  eval $highlight_script
  .pan.mainf.textf.st highlight 1.0 end
  update idletasks
}
###################################
######################################################################## FUNCTIONS END #############################################################################
settitle
panedwindow .pan -orient vertical -showhandle 1 -sashwidth 3 -sashrelief groove
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
menu .mb.edit -tearoff 0
.mb.edit add command -label "Copy            Ctrl-C" -command { copy_t }
.mb.edit add command -label "Cut               Ctrl-X" -command { cut_t }
.mb.edit add command -label "Paste            Ctrl-V" -command { paste_t }
.mb.edit add separator
.mb.edit add command -label "Search ...     Ctrl-F" -command { search }
.mb.edit add command -label "Replace ...   Ctrl-H" -command { replace }
.mb.edit add command -label "Remove search tags ..." -command { removesearchhighlight }
.mb.edit add separator
.mb.edit add command -label "Undo            Ctrl-Z" -command { .pan.mainf.textf.st edit undo }
.mb.edit add command -label "Redo            Ctrl-Y" -command { .pan.mainf.textf.st edit redo }
.mb add cascade -label "Edit" -menu .mb.edit
menu .mb.tools -tearoff 0
.mb.tools add command -label "Settings" -command { settings_w }
.mb.tools add separator
.mb.tools add command -label "Highlight code" -command { highlight_c }
.mb.tools add command -label "Remove syntax highlighting" -command { removehighlight_c }
.mb.tools add separator
.mb.tools add command -label "Run           F5" -command { run_f }
.mb.tools add separator
.mb.tools add command -label "Show Console" -command { consoleshow_w }
.mb add cascade -label "Tools" -menu .mb.tools
menu .mb.about -tearoff 0
.mb.about add command -label "About" -command { about_w }
.mb add cascade -label "About" -menu .mb.about

frame .pan.mainf
frame .pan.mainf.textf
scrollbar .pan.mainf.scroll -command {.pan.mainf.textf.st yview} -orient vertical -width 8
scrollbar .pan.mainf.textf.scrollh -command {.pan.mainf.textf.st xview} -orient horizontal  -width 8
font create textboxfont -family $font_family -size $font_size
ctext .pan.mainf.textf.st -yscrollcommand {.pan.mainf.scroll set} -xscrollcommand {.pan.mainf.textf.scrollh set} -wrap none -tabs $tabswidth -undo true -font textboxfont
pack .pan.mainf.textf -fill both -expand yes -side left
pack .pan.mainf.textf.st -fill both -expand yes
pack .pan.mainf.scroll -fill y -side left
pack .pan.mainf.textf.scrollh -fill x
# syntax hightlighting #
highlight_c
########################

#### Output text box ####
frame .pan.outf
text .pan.outf.out -wrap word  -tabs $tabswidth -state disabled -yscrollcommand { .pan.outf.outscroll set } -font textboxfont
scrollbar .pan.outf.outscroll -orient vertical -command { .pan.outf.out yview } -width 8
.pan add .pan.mainf
.pan add .pan.outf
pack .pan -fill both -expand true
pack .pan.outf.out -expand true -fill both -side left
pack .pan.outf.outscroll -fill y -side left
#########################

###### Input menu ######
frame .pan.input
entry .pan.input.entry
button .pan.input.enterb -text ">>>" -command { if { $chan != "none"} {
    puts $chan [.pan.input.entry get]
  }
  flush $chan
  .pan.outf.out configure -state normal
  .pan.outf.out insert end [gets $chan]
  .pan.outf.out configure -state disabled }
pack .pan.input.entry -fill both -side left
pack .pan.input.enterb -side left -fill y
.pan add .pan.input
########################
image create photo icon -file "$tclfile_path/icon.png"
wm iconphoto . icon
#=====================
bind .pan.mainf.textf.st <<Modified>> {  textismodified  }
bind . <Control-s> {  save_f  }
bind . <Control-S> {  saveas_f  }
bind . <Control-o> {  open_f  }
bind . <Control-n> {  new_f  }
bind . <Control-q> {  quit_w  }
bind . <F5> {  run_f  }
bind . <Control-f> {  search  }
bind . <Control-h> {  replace  }

wm protocol . WM_DELETE_WINDOW { quit_w }
