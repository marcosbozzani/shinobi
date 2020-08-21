#pragma once

#include <calc.h.decl>

enum calc_code
{
    CALC_OK,
    CALC_ERROR_DIVISION_BY_ZERO
};

struct calc_result
{
    double value;
    calc_code code;
};

typedef calc_result (*calc_function)(double, double);

