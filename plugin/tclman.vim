" vim:ts=4:sw=4

if !has("tcl")
	finish
endif

if exists("*Tcl_EventLoop")   
	finish
endif

function! Tcl_EventLoop(tid)
	tcl update
endfunc

call timer_start(0, "Tcl_EventLoop", {"repeat":-1}) 

function s:tk_init()
	tcl package require Tk ; wm withdraw .
	call foreground()
endfunc

command Tk call <SID>tk_init()
