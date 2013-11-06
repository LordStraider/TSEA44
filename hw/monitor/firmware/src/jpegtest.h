#define MEM_ADDR 0x01000000

#define WIDTH 32
#define HEIGHT 8

#define WHI WIDTH/256
#define WLO WIDTH%256
#define HHI HEIGHT/256
#define HLO HEIGHT%256
#define MCU_COUNT (WIDTH * HEIGHT / DCTSIZE2)

void jpegtest(void);
