
#include <stdio.h>

int fib(int n)
{
    if (n <= 1)
        return 0;
    else if (n == 2)
        return 1;
    else
        return fib(n - 1) + fib(n - 2);
}

int fib_opt(int n)
{
    static int fib_num[100];
    static char fib_num_valid[100];
    int n1, n2;

    if (n <= 1)
        return 0;
    if (n == 2)
        return 1;

    if (fib_num_valid[n - 1])
    {
        n1 = fib_num[n - 1];
    }
    else
    {
        n1 = fib_opt(n - 1);
        fib_num_valid[n - 1] = 1;
        fib_num[n - 1] = n1;
    }

    if (fib_num_valid[n - 2])
    {
        n2 = fib_num[n - 2];
    }
    else
    {
        n2 = fib_opt(n - 2);
        fib_num_valid[n - 2] = 1;
        fib_num[n - 2] = n2;
    }

    return n1 + n2;
}

int main()
{
    int i;
    printf("Hello world from NIOS II and SRAM controller!\n\n");

    for (i = 1; i <= 40; i++)
    {
        printf("fib number %d is %ld\n", i, fib_opt(i));
    }
}