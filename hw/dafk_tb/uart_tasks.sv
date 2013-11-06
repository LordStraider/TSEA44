`include "include/timescale.v"

module uart_tasks(input clk, uart_tx, 
		 output logic uart_rx);

   initial begin
      uart_rx = 1'b1;
   end

   task getch();
      reg [7:0] char;

      begin
	 @(negedge uart_tx);
	 #4340;
	 #8680;
	 for (int i=0; i<8; i++) begin
	    char[i] = uart_tx;
	    #8680;
	 end
	 $fwrite(32'h1,"%c", char);
      end
   endtask // getch
      
   task putch(input  byte char);
      begin
	 uart_rx = 1'b0;
	 for (int i=0; i<8; i++)
	   #8680 uart_rx = char[i];
	 #8680 uart_rx = 1'b1;
	 #8680;
      end	  
   endtask // putch	

   task putstr(input  string str);
      byte     ch;
      begin
	 for (int i=0; i<str.len; i++) begin
	    ch = str[i];
	    if (ch)
	      putch(ch);
	 end
	 putch(8'h0d);
      end
   endtask // putstr
endmodule // uart_tb

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
