`ifndef SDRAM_DEFINES
 `define SDRAM_DEFINES

 `define COMMAND_LEN 4

//Byte select length and start position in address
 `define BSLEN 2
 `define BS_STRAT 0

//Column address length and start position in address
 `define COLLEN 9
 `define COL_START 2
//Bitst left to fill the addressbus whan addrissing columns
//Should be SDRAM_ADDRLEN - COLLEN
 `define COL_FILL_LEN 4



//Row address length and start position in address
 `define ROWLEN 13
 `define ROW_START 11

//Bank address length and start position in address
 `define BANKLEN 2
 `define BANK_START 24
 `define BANKS 4 //Should be 2^`BANKLEN

//Total address length
 `define ADDRLEN 26 //`BANKLEN + `ROWLEN + `COLLEN + `BSLEN

//SDRAM addressbus length
 `define SDRAM_ADDRLEN 13

//Maximum data size
 `define DATALEN 32

//Address values for various commands
 `define PRECH_ALL  `SDRAM_ADDRLEN'bx_x1xx_xxxx_xxxx;
 `define PRECH_ONE  `SDRAM_ADDRLEN'bx_x0xx_xxxx_xxxx;
 `define PRECH_POS   10

 `define AUTO_PRECH    `SDRAM_ADDRLEN'b0_0100_0000_0000;
 `define NO_AUTO_PRECH `SDRAM_ADDRLEN'b0_0000_0000_0000;

//Moderegister setup
 `define RESERVED     3'b000
 `define WB           1'b1   //No write burst
 `define OP_MODE      2'b00  //Standard operation
 `define CAS_LATENCY  3'b010 //cas latency = 2 ok for clk <= 133Mhz
 `define BT           1'b0   //Sequentil Burst
 `define BURST_LEN    3'b000 //Singel cell access


//Define to get cas latency of three
//`define CAS_LATENCY_3

//Commands {cs,ras,cas,we}
 `define COMMAND_INHIBIT  1000;
 `define NOP              0111;
 `define ACTIVE           0011;
 `define READ             0101;
 `define WRITE            0100;
 `define BURST_TERM       0110;
 `define PRECHARGE        0010;
 `define AUTO_REFR        0001;
 `define LMR              0000;


//Refresh count logic. The refresh is issued when the 
//MSB and bit1 and bit2 is one. Bit1 and bit2 assumes 
//MSB has index REF_COUNT_LEN-1
//This setup is OK for a 25Mhz clk
 `define REF_COUNT_LEN 8
  `define REF_COUNT_BIT_1 5
  `define REF_COUNT_BIT_2 4
//For testing, many refreshs
/* -----\/----- EXCLUDED -----\/-----
  `define REF_COUNT_LEN 5
  `define REF_COUNT_BIT_1 1
  `define REF_COUNT_BIT_2 0
 -----/\----- EXCLUDED -----/\----- */
//Using 8Mhz
/* -----\/----- EXCLUDED -----\/-----
  `define REF_COUNT_LEN 6
  `define REF_COUNT_BIT_1 4
  `define REF_COUNT_BIT_2 3
 -----/\----- EXCLUDED -----/\----- */



//Length of state vector in controlling FSM.
  `define STATE_LEN 5


//Initialization count logic. The init signal is negated  when the 
//MSB and bit1 and bit2 is one. Bit1 and bit2 assumes 
//MSB has index INIT_COUNT_LEN-1
//This setup is OK for a 25Mhz clk
 `define INIT_COUNT_LEN 12
 `define INIT_COUNT_BIT_1 9
 `define INIT_COUNT_BIT_2 0
//Using 8Mhz
/* -----\/----- EXCLUDED -----\/-----
 `define INIT_COUNT_LEN 10
 `define INIT_COUNT_BIT_1 8
 `define INIT_COUNT_BIT_2 6
 -----/\----- EXCLUDED -----/\----- */

 `define INIT_TIME 100000 //100us in 1ns


//Limits on clockfrequency
//Currently 40-44 ns => 25 - 22.7 Mhz

//Max period from refreshcount limit
 `define MAX_CLK_HP 22 //High period
 `define MAX_CLK_LP 22 //Low period

//Min period from inititialization count
 `define MIN_CLK_HP 20
 `define MIN_CLK_LP 20

`endif// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
