// Define current version
#define BUILDTIME __DATE__" ("__TIME__")"

// Direct memory access macros
#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

//
// Functions in crt.S
//
void crt(void);

//
// Functions in monitor.c
//
void reset(void);
void exception_init(void);

void memcpy(void * dst, const void * src, unsigned long len);

int checkvalues(unsigned char *buf,int num_values);
int checksyntax(unsigned char *buf,char cmd,int debug);

void display(int *adr);


