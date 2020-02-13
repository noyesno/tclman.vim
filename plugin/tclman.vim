" vim:ts=4:sw=4

if exists("g:loaded_tclman")
    finish
else
    let g:loaded_tclman= 1
endif

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

tclfile <sfile>:p:h:h/tcl/vimhttpd.tcl

" execute "command VimHttpd tclfile" expand("<sfile>:p:h:h")."/tcl/vimhttpd.tcl"
command VimHttpd tcl vimhttpd::start


amenu <silent> Tclman.Http\ Server<Tab>:VimHttpd :tcl vimhttpd::start<CR>


