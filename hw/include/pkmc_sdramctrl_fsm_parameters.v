//States for the FSM
localparam init0 = `STATE_LEN'd0;
localparam init1 = `STATE_LEN'd1;
localparam init2 = `STATE_LEN'd2;
localparam init3 = `STATE_LEN'd3;
localparam init4 = `STATE_LEN'd4;
localparam init5 = `STATE_LEN'd5;
localparam waitState = `STATE_LEN'd6;
localparam write = `STATE_LEN'd7;
localparam read = `STATE_LEN'd8;
localparam prech = `STATE_LEN'd9;
localparam prech2 = `STATE_LEN'd10;
localparam active1 = `STATE_LEN'd11;
localparam nop0 = `STATE_LEN'd12;
localparam nop1 = `STATE_LEN'd13;
localparam active2 = `STATE_LEN'd14;
localparam init6 = `STATE_LEN'd15;
localparam nop3 = `STATE_LEN'd16;
localparam nop5 = `STATE_LEN'd19;
localparam ackWait = `STATE_LEN'd20;


//Precharge one or all banks
localparam PCH_ALL = 1'b1;
localparam PCH_ONE = 1'b0;

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
