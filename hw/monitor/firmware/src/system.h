#define NO_FLUSH 0x1
#define FLUSH 0x2

void fl_init (void);
void timer_init(void);

void dc_disable (void);
void ic_disable (void);
void dc_enable (int par);
void ic_enable (int par);

void mfspr(int addr);
void mtspr(int adr, int val);

int boot(int offset, int size);


