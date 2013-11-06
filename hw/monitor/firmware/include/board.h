#ifndef _BOARD_H_
#define _BOARD_H_

#define MC_ENABLED      0

#define IC_ENABLE       0
#define IC_SIZE         8192
#define DC_ENABLE       0
#define DC_SIZE         8192

#define MC_CSR_VAL      0x0B000400
#define MC_MASK_VAL     0x000000e0

#define SRAM_BASE_ADDR 0x20000000
#define SRAM_CSC_VAL   0x00000025
#define SRAM_TMS_VAL   0x00010000

#define FLASH_BASE_ADDR 0xf0000000
#define FLASH_CSC_VAL   0x00200025
#define FLASH_TMS_VAL   0x00000103

#define SDRAM_BASE_ADDR 0x00000000
#define SDRAM_CSC_VAL   0x00400491
//#define SDRAM_TMS_VAL   0x07250027
#define SDRAM_TMS_VAL   0x07250020 /* CAS latency=2,burst=1 */

#define FLASH_BLOCK_SIZE 0x00040000
#define FLASH_SIZE       0x01000000

#define IN_CLK          25000000

#define UART_BAUD_RATE  115200

#define TICKS_PER_SEC   100

#define STACK_SIZE      0x10000

#define MC_BASE_ADDR    0x93000000
#define UART_BASE       0x90000000
#define UART_IRQ        2
#define ETH_BASE        0x92000000
#define ETH_IRQ         4

#define KBD_BASE_ADD    0x94000000
#define KBD_IRQ         5
#define CRT_BASE_ADDR   0x97000000
#define PAR_BASE_ADDR   0x91000000

#define SPI_BASE        0x95000000
#define ATA_BASE_ADDR   0x97000000

#define JPG_BASE_ADDR   0x96000000

#define PERF_BASE_ADDR  0x99000000


/* #define ETH_DATA_BASE  0x20080000   Address for ETH_DATA */

#define BOARD_DEF_IP     0xc0a8000c /* 192.168.0.12 */
#define BOARD_DEF_MASK   0xffffff00 /* 255.255.255.0 */
#define BOARD_DEF_GW     0xc0a80001 /* 192.168.0.1 */
#define BOARD_DEF_SRV_IP 0xc0a8000a /* 192.168.0.10 */
#define ETH_MACADDR0      0x00
#define ETH_MACADDR1      0x12
#define ETH_MACADDR2      0x34
#define ETH_MACADDR3      0x56
#define ETH_MACADDR4      0x78
#define ETH_MACADDR5      0x9a

#define CRT_ENABLED	    1
#define FB_BASE_ADDR    0x28000000 

/* Whether online help is available -- saves space */
#define HELP_ENABLED    1

/* Whether self check is enabled */
#define SELF_CHECK     0

/* Whether we have keyboard suppport */
#define KBD_ENABLED    1

/* Keyboard buffer size */
#define KBDBUF_SIZE    256

/* Which console is used (CT_NONE, CT_SIM, CT_UART, CT_CRT) */
#define CONSOLE_TYPE   CT_UART

#endif
