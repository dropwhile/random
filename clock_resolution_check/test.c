#include <stdio.h>
#include <errno.h>
#include <time.h>


int main(void) {
    struct timespec ts;
    time_t tm;

    time(&tm); 
    printf("time() Time: %1d secs.\n", (long)tm);
    printf("CLOCK_REALTIME:\n");
    clock_gettime(CLOCK_REALTIME, &ts);
    printf("Time: %1d.%09d secs.\n", (long)ts.tv_sec, (long)ts.tv_nsec);
    clock_getres(CLOCK_REALTIME, &ts);
    printf("Res.: %1d.%09d secs.\n", (long)ts.tv_sec, (long)ts.tv_nsec);
    return 0;
}

