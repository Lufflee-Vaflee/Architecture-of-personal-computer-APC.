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
{
    _asm
    {
        FLD x;
        FLD x;
        FMUL ST(0), ST(1);
        FADD ST(0), ST(1);
        FLD1;
        FSUBP ST(2), ST(0);
        FXCH ST(1);
        FABS;
        FDIV ST(1), ST(0);
        FSTP x;
        FSTP x;
    };
    return x;
}

int main()
{
    double a = 0.1, b = 0.2, d = 0.2;
    char answer;
    while(true)
    {
        cout << " Enter a b d" << endl;
        cin >> a >> b >> d;
        cout << "Func: (x^2 + x) / |x - 1| , (x != 1), Variant 5" << endl;
        cout << "X" << setw(10) << "math.h" << setw(10) << "asm" << endl;
        while (a <= b)
        {
            if (a != 1)
                cout << a << setw(10) << func_math(a) << setw(10) << func_asm(a) << endl;
            else
                cout << "x == 1" << endl;
            a += d;
        }
        cout  << "Enter q or any other to continue to exit:" << endl;
        cin >> answer;
        system("cls");
        if(answer == 'q')
            break;
        else
            cin.clear();
    }
    return 0;
}