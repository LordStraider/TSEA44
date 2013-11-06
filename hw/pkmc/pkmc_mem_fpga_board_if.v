`include "include/pkmc_sram_defines.v"
`include "include/pkmc_flash_defines.v"
`include "include/pkmc_sdram_defines.v"
`include "include/pkmc_memctrl_defines.v"

  
module mem_fpga_board_if(clk,
                         //Memory controler interface fi := Fpga Interface
                         //SRAM
                         sramAddr_o_fi,
                         sramData_o_fi,
                         sramData_i_fi,
                         sramByteSel_o_fi,
                         sramCE_fi,
                         sramWE_fi,
                         sramOE_fi,
                         sramBuffDir_fi,
                         sramBuffOE_fi,
                         //FLASH
                         flashAddr_o_fi,
                         flashData_o_fi,
                         flashData_i_fi,
                         flashCE_fi,
                         flashWE_fi,
                         flashOE_fi,
                         flashBuffDir_fi,
                         flashBuffOE_fi,
                         //SDRAM
                         sdramAddr_o_fi,
                         sdramBank_o_fi,
                         sdramData_o_fi,
                         sdramData_i_fi,
                         sdramCommand_o_fi,
                         sdramCke_o_fi,
                         sdramByteSel_o_fi,
                         //Controll
                         memSelect_fi, //0 -> SRAM, 1 -> SDRAM, 2-> FLASH
                         we_o_fi,

                         //Board infterface, bi := Board Interface
                         //SRAM
                         sramCE_bi,
                         sramOE_bi,
                         sramBuffDir_bi,
                         sramBuffOE_bi,
                         //FLASH
                         flashCE_bi,                     
                         //SDRAM
                         sdramCke_o_bi,
                         //Common interface
                         sdramCommand_o_bi,
                         data_io_bi,
                         addr_o_bi,
                         byteSel_o_bi
                         );

   //
   //FPGA interface
   //
   input clk;
   //SRAM
   input [`SRAM_ADDR_WIDTH-1:0] sramAddr_o_fi;
   input [`SRAM_DATA_WIDTH-1:0] sramData_o_fi;
   output [`SRAM_DATA_WIDTH-1:0] sramData_i_fi;
   input [`SEL_I_WIDTH-1:0]      sramByteSel_o_fi;   
   input                         sramCE_fi;
   input                         sramWE_fi;
   input                         sramOE_fi;
   input                         sramBuffDir_fi;
   input                         sramBuffOE_fi;

   //FLASH
   input [`FLASH_ADDR_WIDTH-1:0]  flashAddr_o_fi;
   input [`FLASH_DATA_WIDTH-1:0]  flashData_o_fi;
   output [`FLASH_DATA_WIDTH-1:0] flashData_i_fi;
   input                         flashCE_fi;
   input                         flashWE_fi;
   input                         flashOE_fi;
   input                         flashBuffDir_fi;
   input                         flashBuffOE_fi;

   //SDRAM
   input [`SDRAM_ADDRLEN-1:0]    sdramAddr_o_fi;
   input [`BANKLEN-1:0]          sdramBank_o_fi;
   input [`DATALEN-1:0]          sdramData_o_fi;
   output [`DATALEN-1:0]         sdramData_i_fi;
   input [`COMMAND_LEN-1:0]      sdramCommand_o_fi;
   input                         sdramCke_o_fi;
   input [`SEL_I_WIDTH-1:0]      sdramByteSel_o_fi;

   //Controll
   input [1:0]                   memSelect_fi;
   input                         we_o_fi;
   
   //
   //Board interface
   //
   //SRAM
   output                        sramCE_bi;
   output                        sramOE_bi;
   output                        sramBuffDir_bi;
   output                        sramBuffOE_bi;

   //FLASH
   output                        flashCE_bi;
   
   //SDRAM
   output                        sdramCke_o_bi;

   //Common interface
   output [`COMMAND_LEN-1:0]     sdramCommand_o_bi;
   inout [`DATA_BUS_OUT-1:0]     data_io_bi;
   output [`ADDR_BUS_OUT-1:0]    addr_o_bi;
   reg [`ADDR_BUS_OUT-1:0]       addr_o_bi;
   output [`SEL_I_WIDTH-1:0]     byteSel_o_bi;

   //Internal wires and regs
   reg [`ADDR_BUS_OUT-1:0]       activeAddress;
   reg [`DATA_BUS_OUT-1:0]       activeDataOut;

   reg [`DATA_BUS_OUT-1:0]       data_o;
   reg [`DATA_BUS_OUT-1:0]       data_i;

   //{ flashCE, we_o, sramCE, sramOE, sramBuffDir, sramBuffOE, sdramCommand, sdramCke, byteSel}
   //   14 14  13 13  12  12  11  11  10       10  9        9  8          5  4      4  3     0
   wire [6+`COMMAND_LEN+1+`SEL_I_WIDTH-1:0] ctrlSig;
   reg [6+`COMMAND_LEN+1+`SEL_I_WIDTH-1:0]  ctrlSig_o;

   reg [2:0]                                tmp;
   

   localparam flashCE_pos = 6+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam we_o_pos = 5+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sramCE_pos = 4+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sramOE_pos = 3+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sramBuffDir_pos = 2+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sramBuffOE_pos = 1+`COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sdramCommand_posH = `COMMAND_LEN+1+`SEL_I_WIDTH-1;
   localparam sdramCommand_posL = 2+`SEL_I_WIDTH-1;
   localparam sdramCke_pos = 1+`SEL_I_WIDTH-1;
   localparam byteSel_posH = `SEL_I_WIDTH-1;
   localparam byteSel_posL = 0;
   

   always@(posedge clk) begin
      addr_o_bi[29:0] <= #3 activeAddress[31:2];
      data_i <= #3 data_io_bi;
      data_o <= #3 activeDataOut;
      ctrlSig_o <= #3 ctrlSig;
   end

   assign #3                     flashCE_bi = ctrlSig_o[flashCE_pos];
   assign #3                     sramCE_bi = ctrlSig_o[sramCE_pos];
   assign #3                     sramOE_bi = ctrlSig_o[sramOE_pos];
   assign #3                     sramBuffDir_bi = ctrlSig_o[sramBuffDir_pos];
   assign #3                     sramBuffOE_bi = ctrlSig_o[sramBuffOE_pos];
   assign #3                     sdramCommand_o_bi = ctrlSig_o[sdramCommand_posH:sdramCommand_posL];
   assign #3                     sdramCke_o_bi = ctrlSig_o[sdramCke_pos];

   assign #3                     byteSel_o_bi[3] = ctrlSig_o[byteSel_posL+3];
   assign #3                     byteSel_o_bi[2] = ctrlSig_o[byteSel_posL+2];
   assign #3                     byteSel_o_bi[1] = ctrlSig_o[byteSel_posL+1];
   assign #3                     byteSel_o_bi[0] = ctrlSig_o[byteSel_posL];
   
   
/* -----\/----- EXCLUDED -----\/-----
   OFDDRRSE ddr0 (
     .CE(1'b1), 
     .S(1'b0),
     .R(1'b0),
     .C0(sdram_clk_int),
     .C1(!sdram_clk_int),
     .D0(1'b0),
     .D1(1'b1),
     .Q(byteSel_o_bi[2])
   );
 -----/\----- EXCLUDED -----/\----- */



/* -----\/----- EXCLUDED -----\/-----
   assign                        activeAddress[1:0] = 2'b0;
   assign #1                     activeAddress[(`SDRAM_ADDRLEN+`BANKLEN)-1+2:2] = memSelect_fi ? 
          {sdramBank_o_fi, sdramAddr_o_fi} 
          : sramAddr_o_fi[(`SDRAM_ADDRLEN+`BANKLEN)-1:0];
   
   assign        activeAddress[`SRAM_ADDR_WIDTH-1+2:(`SDRAM_ADDRLEN+`BANKLEN)+2] = sramAddr_o_fi[`SRAM_ADDR_WIDTH-1:(`SDRAM_ADDRLEN+`BANKLEN)];
   assign        activeAddress[`ADDR_BUS_OUT-1:`SRAM_ADDR_WIDTH+2] = 12'b0;
 -----/\----- EXCLUDED -----/\----- */

   always @(*) begin
      case (memSelect_fi) 
        2'h0: begin //SRAM
           activeAddress[`SRAM_ADDR_WIDTH-1+2:0] = {sramAddr_o_fi, 2'b00};
           activeAddress[`ADDR_BUS_OUT-1:`SRAM_ADDR_WIDTH-1+3] = 0;
        end
        2'h1: begin
           activeAddress[(`SDRAM_ADDRLEN+`BANKLEN)-1+2:0] = {sdramBank_o_fi, sdramAddr_o_fi, 2'b00} ;
           activeAddress[`ADDR_BUS_OUT-1:(`SDRAM_ADDRLEN+`BANKLEN)-1+3] = 0;
        end
        default: begin
           activeAddress[`FLASH_ADDR_WIDTH-1+2:0] = {flashAddr_o_fi, 2'b00};
           activeAddress[`ADDR_BUS_OUT-1:`FLASH_ADDR_WIDTH-1+3] = 0;
        end
      endcase
   end

   
   // assign #1                          activeDataOut = memSelect_fi ? sdramData_o_fi : sramData_o_fi;
   always @(*) begin
      case (memSelect_fi) 
        2'h0: begin
           activeDataOut = sramData_o_fi;
        end
        2'h1: begin
           activeDataOut = sdramData_o_fi;
        end
        default: begin
           activeDataOut = flashData_o_fi;
        end
      endcase
   end


   assign #1                     data_io_bi = ctrlSig_o[we_o_pos] ? 32'bz : data_o;

   assign                        sramData_i_fi = data_i;
   assign                        sdramData_i_fi = data_i;
   assign                        flashData_i_fi = data_i;

   assign                        ctrlSig[flashCE_pos] = flashCE_fi;
   assign                        ctrlSig[we_o_pos] = ~we_o_fi; 
   assign                        ctrlSig[sramCE_pos] = sramCE_fi;
   assign                        ctrlSig[sramOE_pos] = |memSelect_fi ? flashOE_fi : sramOE_fi;
   
   // assign #1                          ctrlSig[sdramCommand_posL] = memSelect_fi ? sdramCommand_o_fi[0] : sramWE_fi;
   always @(*) begin
      case (memSelect_fi) 
        2'h0: begin
           tmp[0] = sramWE_fi;
           tmp[1] = sramBuffDir_fi;
           tmp[2] = sramBuffOE_fi;
        end
        2'h1: begin
           tmp[0] = sdramCommand_o_fi[0];
           tmp[1] = 1'bx;
           tmp[2] = 1'b1;
        end
        default: begin
          tmp[0]  = flashWE_fi;
          tmp[1]  = flashBuffDir_fi;
          tmp[2]  = flashBuffOE_fi;
        end
      endcase
   end

   assign ctrlSig[sdramCommand_posL] = tmp[0];
   assign ctrlSig[sramBuffDir_pos] = tmp[1];
   assign ctrlSig[sramBuffOE_pos] = tmp[2];
   
   assign                        ctrlSig[sdramCommand_posH:sdramCommand_posL+1] =  sdramCommand_o_fi[3:1];
   assign                        ctrlSig[sdramCke_pos] = sdramCke_o_fi;
   assign #1                     ctrlSig[byteSel_posH:byteSel_posL] = memSelect_fi ? sdramByteSel_o_fi : sramByteSel_o_fi;


endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
