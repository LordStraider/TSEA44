// Some constants for characters
#define CTRL_C 3
#define BACKSPACE 8
#define DELETE 127
#define NEWLINE 0xa
#define RETURN 0xd

// Read one character from serial port
int readch(void);
// Write one character to serial port
void putch(int c);
// Initialize UART
void uart_init(void);
