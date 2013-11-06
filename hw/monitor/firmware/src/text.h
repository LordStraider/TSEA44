
// Text input functions
int readnr(int n);
void readline(unsigned char *buf,int len);
int loadhex(void); // Load Intel HEX file

// Text output functions
void printnr(int nr);
void printnrp(int nr, int prec);
void printstr(char *ps);

// Conversion functions
unsigned char *getnumber(unsigned char *buf, unsigned long *number);
unsigned char *skip_ws(unsigned char *b);
