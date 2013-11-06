function automatic new;
    input old;
    input bankActive;
    input all_one;
    input prech;
    input apc;
    input active;

      
      new = bankActive & active
	    | old & ~bankActive & ~all_one 
	    | old & ~bankActive & all_one & ~prech & ~apc
	    | old & bankActive & ~all_one & ~prech & ~apc
	    | old & bankActive & all_one & ~prech & ~apc; 
      
endfunction
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
