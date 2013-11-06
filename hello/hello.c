#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc,char **argv)
{
	int i;
	for(i = 3; i > 0; i--) {
		printf("%d\n",i);
		sleep(1);
	}

	printf("Hello uClinux!\n");

	return 0;
}
