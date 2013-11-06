
proc show_dafk_window {} {
    toplevel  .dafk
    
    button .dafk.b1 -text "Recompile all" -command {set make_output [make];echo $make_output} 
    button .dafk.b2 -text "Clock and reset" -command {do clkrst.do} 
    button .dafk.b3 -text "Outputs (Parport/UART)" -command {do outputs.do} 
    button .dafk.b4 -text "Add pipeline signals" -command {do pipe.do} 
    button .dafk.b5 -text "Slave 0 (SDRAM)" -command {do slave0.do} 
    button .dafk.b6 -text "Slave 1 (Boot ROM/RAM)" -command {do slave1.do} 
    button .dafk.b7 -text "Slave 2 (UART)" -command {do slave2.do} 
    button .dafk.b8 -text "Slave 3 (Boot ROM/RAM)" -command {do slave3.do} 
    button .dafk.b9 -text "Slave 5 (VGA)" -command {do slave5.do} 
    button .dafk.ba -text "Slave 6 (DCT)" -command {do slave6.do} 
    button .dafk.bb -text "Slave 7 (Parport)" -command {do slave7.do} 
    button .dafk.bc -text "Slave 8 (Leela)" -command {do slave8.do} 
    button .dafk.bd -text "Slave 9 (Perf counters)" -command {do slave9.do} 
    button .dafk.be -text "Master 0 (ICache)" -command {do master0.do} 
    button .dafk.bf -text "Master 1 (DCache)" -command {do master1.do} 
    button .dafk.bg -text "Master 6 (DCT)" -command {do master6.do} 
    button .dafk.bh -text "Add dct signals" -command {do dcttest.do} 
    
    pack .dafk.b1 .dafk.b2 .dafk.b3 .dafk.b4 .dafk.b5 .dafk.b6 .dafk.b7 .dafk.b8 .dafk.b9 .dafk.ba .dafk.bb .dafk.bc .dafk.bd .dafk.be  .dafk.bf .dafk.bg .dafk.bh -side top -fill x
}



proc AddButtonsWave wname {
    _add_menu $wname controls right \#d9d9d9 black {Show Dafk Window} {show_dafk_window}
}



lappend PrefWave(user_hook) "AddButtonsWave"
