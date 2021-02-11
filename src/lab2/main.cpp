#include <iostream>
#include <iomanip>
#include <string>
#include "time.h"
#include <random>

const unsigned int X_SIZE = 16;
const unsigned int Y_SIZE = 16;

using namespace std;

typedef void (*matrix_mov)(int in[X_SIZE][Y_SIZE], int out[X_SIZE][Y_SIZE]);

void asm_mov(int m_in[X_SIZE][Y_SIZE], int m_out[X_SIZE][Y_SIZE])
{
    _asm{
        mov ECX, X_SIZE;
        mov EAX, Y_SIZE;
        MUL ECX;
        MOV ECX, EAX;
        MOV EDX, m_in;
        MOV EBX, m_out;
    CYCLE_ASM:
        MOV EAX, [EDX];
        MOV[EBX], EAX;
        ADD EDX, 4;
        ADD EBX, 4;
        LOOP CYCLE_ASM;
    };
    return;
}

void MMX_mov(int m_in[X_SIZE][Y_SIZE], int m_out[X_SIZE][Y_SIZE])
{
    _asm{
        mov ECX, X_SIZE;
        mov EAX, Y_SIZE;
        MUL ECX;
        MOV ECX, EAX;
        SHR ECX, 1;
        MOV EDX, m_in;
        MOV EBX, m_out;
    CYCLE_ASM:
        MOVQ MM1, [EDX];
        MOVQ[EBX], MM1;
        ADD EDX, 8;
        ADD EBX, 8;
        LOOP CYCLE_ASM;
        EMMS
    };
    return;
}

void c_mov(int in[X_SIZE][Y_SIZE], int out[X_SIZE][Y_SIZE])
{
    for (int i = 0; i < X_SIZE; i++)
        for (int k = 0; k < Y_SIZE; k++)
            out[i][k] = in[i][k];
}
void empty(int in[X_SIZE][Y_SIZE], int out[X_SIZE][Y_SIZE]) {}

void matrix_output(int matrix[X_SIZE][Y_SIZE])
{
    for (int i = 0; i < X_SIZE; i++)
    {
        for (int k = 0; k < Y_SIZE; k++)
            cout << setw(4) << matrix[i][k];
        cout << endl;
    }
}

string check_(matrix_mov func, int m_in[X_SIZE][Y_SIZE], int m_out[X_SIZE][Y_SIZE])
{
    func(m_in, m_out);
    for (int i = 0; i < X_SIZE; i++)
        for (int j = 0; j < Y_SIZE; j++)
            if (m_in[i][j] != m_out[i][j])
                return "False";
    return "True";
}

bool check_size(int X, int Y)
{
    return (X * Y) % 4 == 0;
}

clock_t measure_time(matrix_mov func, int in[X_SIZE][Y_SIZE], int out[X_SIZE][Y_SIZE], int count)
{
    clock_t t;
    clock_t func_calling_delay;
    t = clock();
    for(int i = 0; i < count; i++)
        for(int j = 0; j < count; j++)
            func(in, out);
    t = (clock() - t);

    func_calling_delay = clock();
    for (int i = 0; i < count; i++)
        for (int j = 0; j < count; j++)
            empty(in, out);
    func_calling_delay = (clock() - func_calling_delay);

    t -= func_calling_delay;
    return t;
}


int main()
{
    long long int count = 100;
    int m_in[X_SIZE][Y_SIZE];
    int m_out[X_SIZE][Y_SIZE];

    if (check_size(X_SIZE, Y_SIZE) == false)
    {
        cout << "Incorrect matrix size." << endl;
        return -1;
    }

    cout << "Enter count:" << endl;
    cin >> count;

    srand(clock());
    for (int i = 0; i < X_SIZE; i++)
        for (int k = 0; k < Y_SIZE; k++)
            m_in[i][k] = rand() % 100;
    cout << "matrix in: " << endl;
    matrix_output(m_in);

    cout << endl;
    cout << setw(6) << "" << setw(10) << "CXX" << setw(10) << "ASM" << setw(10) << "MMX" << endl;
    cout << setw(6) << "Check:" << setw(10) << check_(c_mov, m_in, m_out) << setw(10) << check_(asm_mov, m_in, m_out) << setw(10) << check_(MMX_mov, m_in, m_out) << endl;
    cout << setw(6) << "Time:" << setw(10) << measure_time(c_mov, m_in, m_out, count) << setw(10) << measure_time(asm_mov, m_in, m_out, count) << setw(10) << measure_time(MMX_mov, m_in, m_out, count) << endl;
    return 0;
}
