#include <iostream>
#include <iomanip>
#include "math.h"
#include "time.h"

using namespace std;

double func_math(double x)
{
    return (pow(x, 2) + x) / fabs(x - 1);
}

double func_asm(double x)
{//uses AT&T syntax 
    asm volatile(                   //very optimized asm code))
        "FLDL  %0\n"
        "FLDL  %0\n"
        "FMUL  %%ST(1), %%ST(0)\n"
        "FADD  %%ST(1), %%ST(0)\n"
        "FLD1  \n"                   //0: 1    1: x ^ 2 + x   2 - x
        "FSUBP %%ST(0), %%ST(2)\n"   //0: x ^ 2 + x   1: x - 1
        "FXCH  %%ST(1)\n"            //0: x - 1  1: x ^ 2 + x
        "FABS  \n"                   //0: |x - 1|  1: x ^ 2 + x
        "FXCH  %%ST(1)\n"
        "FDIV  %%ST(0), %%ST(1)\n"
        "FXCH  %%ST(1)\n"
        "FSTPL %0\n"
        "FSTPL %0\n"
        : "+m" (x)
    );
    return x;
}

int main()
{
    float a = 0.1, b = 0.2, d = 0.2;
    cout << " Enter a b d" << endl;
    cin >> a >> b >> d;
    cout << "Func: (x^2 + x) / |x - 1| , (x != 1), Variant 5" << endl;
    cout << "X"<< setw(10) << "math.h" << setw(10) << "asm" << endl; 
    while(a <= b)
    {
        if (a != 1)
            cout << a << setw(10) << func_math(a) << setw(10) << func_asm(a) << endl;
        else
            cout << "x == 1" << endl;
        a += d;
    }
    return 0;
}