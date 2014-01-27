`include "include/timescale.v"

module suart_tb();
   logic       clk = 1'b0;
   logic       rst = 1'b1;
   logic       int_o, rx_tx;
       
   wishbone wb(clk,rst);

   initial begin
      #75 rst = 1'b0;
   end
   
   always #20 clk = ~clk;

   // Instantiate the DUT
   lab1_uart_top dut(wb, int_o, rx_tx, rx_tx);
   
   wishbone_tasks wb0(wb);
   
   // Instantiate the tester
   test_uart test_uart0();
endmodule // jpeg_top_tb

program test_uart();
   int A = 32'h41000000;
   int result = 0;
   int i;
   
   initial begin
      for (i=0;i<25;i++) begin
         suart_tb.wb0.m_write(32'h90000000, A);
         #400;
         //wait untill full
         while (result != 32'h00010000) begin
            suart_tb.wb0.m_read(32'h90000004, result);
            result = result & 32'h00010000;
            #400;
         end
         suart_tb.wb0.m_read(32'h90000000, result);
         #400;
         result = 0;
         A = A + 32'h01000000;
      end
   end

endprogram // test_uart
   
