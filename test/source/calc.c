#include <calc.h>
#include <calc.c.decl>

calc_result calc_add(double a, double b)
{
    calc_result result = {.value = a + b, .code = CALC_OK};
    return result;
}

calc_result calc_sub(double a, double b)
{
    calc_result result = {.value = a - b, .code = CALC_OK};
    return result;
}

calc_result calc_mul(double a, double b)
{
    calc_result result = {.value = a * b, .code = CALC_OK};
    return result;
}

calc_result calc_div(double a, double b)
{
    if (b != 0.0)
    {
        calc_result result = {.value = a / b, .code = CALC_OK};
        return result;
    }
    else
    {
        calc_result result = {.value = 0, .code = CALC_ERROR_DIVISION_BY_ZERO};
        return result;
    }
}
