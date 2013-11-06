//Commands {cs,ras,cas,we}
/* -----\/----- EXCLUDED -----\/-----
localparam COMMAND_INHIBIT  = 4'b1000;
localparam NOP              = 4'b0111;
 -----/\----- EXCLUDED -----/\----- */
localparam COMMAND_INHIBIT  = 4'b1xx1;
localparam NOP              = 4'b1xx1;
localparam ACTIVE           = 4'b0011;
localparam READ             = 4'b0101;
localparam WRITE            = 4'b0100;
localparam BURST_TERM       = 4'b0110;
localparam PRECHARGE        = 4'b0010;
localparam AUTO_REFR        = 4'b0001;
localparam LMR              = 4'b0000;// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
