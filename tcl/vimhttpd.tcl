# vim:set ts=4 sw=4: #



namespace eval vimhttpd {
	variable server_tid
	variable script_dir [file normalize [file dir [info script]]]


	# proc reply {token message} {
	# 	variable servers
	# 	thread::send -async $server_tid [list uhttpd::echo $message]
	# }
}

proc vimhttpd::start {{port 8332}} {
	package require Thread

	variable server_tid
	variable script_dir

    if [info exists server_tid] {
		puts "vimhttpd listen at http://127.0.0.1:$port/"
		return
	} else {
		set tid [thread::create]   ;#% create httpd thread

		set server_tid $tid

		thread::send -async $tid [list set ::vimtid [thread::id]]
		thread::send -async $tid [list source $script_dir/uhttpd.tcl]
		thread::send -async $tid [list uhttpd::create $port ]

		puts "vimhttpd listen at http://127.0.0.1:$port/"

		setup $tid
	}
}

proc vimhttpd::setup {tid} {
	thread::send -async $tid {
		proc uhttpd::echo {token text} {
			upvar $token data
	        ::puts $data(sock) $text
		}

		namespace eval ::vim {
			proc expr {cmd} {
				thread::send $::vimtid [list vim::expr "execute('$cmd')"] result
				return $result
			}
			proc command {cmd} {
				thread::send $::vimtid [list vim::command $cmd] result
				return $result
			}
		}
	}

	thread::send -async $tid {
		proc / {token} {
			upvar $token data ; # Holds the socket to remote client

			puts $data(sock) "HTTP/1.0 200 OK"
			puts $data(sock) "Date: [uhttpd::Date]"
			puts $data(sock) "Content-Type: text/html"
			puts $data(sock) ""
			puts $data(sock) "<h1>VimHttpd</h1>"
				
			puts $data(sock) "Date: [uhttpd::Date]"
			puts $data(sock) [::vim::expr "ls"]
	    }
	}

}

