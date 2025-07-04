#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

extern void ptest1(void);
extern void ptest2(void);


int main(int argc, char *argv[])
{
    struct timespec ts, rm;
    ts.tv_sec = 0;
    ts.tv_nsec = 500000000;


    for (double i=0; i<7.0; i+=0.73) 
    {
        printf("Hello world sin(%.2f)=%.2f!\n", i, sin(i));
        nanosleep(&ts, &rm);
    }
    ptest1();
    ptest2();
    return 0;
}