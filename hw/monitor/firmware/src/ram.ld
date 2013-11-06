MEMORY
        {
	        vectors   : ORIGIN = 0x00000000, LENGTH = 0x00002000
	        sdram     : ORIGIN = 0x00002000, LENGTH = 0x03ffe000
	        sram      : ORIGIN = 0x20000000, LENGTH = 0x00100000
	        boot_rom  : ORIGIN = 0x40000000, LENGTH = 0x00006000
	        boot_ram  : ORIGIN = 0x40010000, LENGTH = 0x00002000
		NO_DATA_REGION_ALLOWED     : ORIGIN = 0, LENGTH = 0
        }

SECTIONS
{
        .vectors :
        {
        *(.vectors)
        } > vectors

        .text :
        {
        *(.text)
        } > boot_rom

        .rodata ALIGN(4):
        {
        *(.rodata)
        } > boot_rom

        .rodata.str1.1 ALIGN(4):
        {
        *(.rodata.str1.1)
        } > boot_rom

        .bss :
        {
        *(.bss)
        } > boot_ram

	.data :
	{
	*(.data)
	} > NO_DATA_REGION_ALLOWED
}