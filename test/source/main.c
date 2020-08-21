#include <stdio.h>
#include <calc.h>
#include <main.c.decl>

int main()
{
    print("add", calc_add, 10, 12);
    print("sub", calc_sub, 10, 12);
    print("mul", calc_mul, 10, 12);
    print("div", calc_div, 10, 12);
    print("div", calc_div, 10, 0);
    return 0;
}

static void print(char *name, calc_function function, double a, double b)
{
    calc_result r = function(a, b);
    if (r.code == CALC_OK)
    {
        printf("%s(%.2lf, %.2lf) => %.2lf\n", name, a, b, r.value);
    }
    else
    {
        printf("%s(%.2lf, %.2lf) => error %d\n", name, a, b, r.code);
    }
}