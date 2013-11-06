#include "common.h"

int main(void)
{
	int Begin_Time, User_Time;
	int i;

	printf("Hello world!\n");

	Begin_Time = get_timer(0);

	for (i=0; i<10; i++) {
		led(i); /* Set the led display on the card */
		printf("%d\n",i);
		sleep(1); /* sleep 1 s */
	}

	User_Time = get_timer(Begin_Time);
	printf("Time= %d s\n", User_Time);

	return(0);
}
