MEMORY
        {
	vectors	 : ORIGIN = 0x00000000, LENGTH = 0x00002000	
	dram	 : ORIGIN = 0x00002000, LENGTH = 0x03ffe000	
	sram	 : ORIGIN = 0x20000000, LENGTH = 0x00100000	
	bootrom	 : ORIGIN = 0x40000000, LENGTH = 0x00006000	
        bootram  : ORIGIN = 0x40010000, LENGTH = 0x00002000	
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
        } > dram

        .data :
        {
        *(.data)
        } > dram

        .rodata :
        {
        *(.rodata)
        } > dram

        .rodata.str1.1 :
        {
        *(.rodata.str1.1)
        } > dram

        .bss :
        {
        *(.bss)
        } > dram

}
