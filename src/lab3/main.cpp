#include <dos.h>

#define BUFF_WIDTH 80
#define CENTER_OFFSET 12
#define LEFT_OFFSET 25
#define REG_SCREEN_SIZE 9

struct VIDEO
{
    unsigned char symb;
    unsigned char attr;
};

int attribute = 0x6e; //color

void print(int offset, int value);
void getRegisterValue();



void interrupt(*oldHandle60) (...);
void interrupt(*oldHandle61) (...);
void interrupt(*oldHandle62) (...);
void interrupt(*oldHandle63) (...);
void interrupt(*oldHandle64) (...);
void interrupt(*oldHandle65) (...);
void interrupt(*oldHandle66) (...);
void interrupt(*oldHandle67) (...);

void interrupt(*oldHandle08) (...);
void interrupt(*oldHandle09) (...);
void interrupt(*oldHandle0A) (...);
void interrupt(*oldHandle0B) (...);
void interrupt(*oldHandle0C) (...);
void interrupt(*oldHandle0D) (...);
void interrupt(*oldHandle0E) (...);
void interrupt(*oldHandle0F) (...);



void interrupt newHandle60(...) { getRegisterValue(); oldHandle60(); }
void interrupt newHandle61(...) { attribute++; getRegisterValue(); oldHandle61(); }
void interrupt newHandle62(...) { getRegisterValue(); oldHandle62(); }
void interrupt newHandle63(...) { getRegisterValue(); oldHandle63(); }
void interrupt newHandle64(...) { getRegisterValue(); oldHandle64(); }
void interrupt newHandle65(...) { getRegisterValue(); oldHandle65(); }
void interrupt newHandle66(...) { getRegisterValue(); oldHandle66(); }
void interrupt newHandle67(...) { getRegisterValue(); oldHandle67(); }

void interrupt newHandle08(...) { getRegisterValue(); oldHandle08(); }
void interrupt newHandle09(...) { getRegisterValue(); oldHandle09(); }
void interrupt newHandle0A(...) { getRegisterValue(); oldHandle0A(); }
void interrupt newHandle0B(...) { getRegisterValue(); oldHandle0B(); }
void interrupt newHandle0C(...) { getRegisterValue(); oldHandle0C(); }
void interrupt newHandle0D(...) { getRegisterValue(); oldHandle0D(); }
void interrupt newHandle0E(...) { getRegisterValue(); oldHandle0E(); }
void interrupt newHandle0F(...) { getRegisterValue(); oldHandle0F(); }



void print(int offset, int value)
{
    char temp;

    VIDEO far* screen = (VIDEO far*)MK_FP(0xB800, 0);
    screen += CENTER_OFFSET * BUFF_WIDTH + offset;

    for (int i = 7; i >= 0; i--)
    {
        temp = value % 2;
        value /= 2;
        screen->symb = temp + '0';
        screen->attr = attribute;
        screen++;
    }
}

void getRegisterValue()
{
    print(0 + LEFT_OFFSET, inp(0x21));

    outp(0x20, 0x0B);
    print(REG_SCREEN_SIZE + LEFT_OFFSET, inp(0x20));

    outp(0x20, 0x0A);
    print(REG_SCREEN_SIZE * 2 + LEFT_OFFSET, inp(0x20));

    print(BUFF_WIDTH + LEFT_OFFSET, inp(0xA1));

    outp(0xA0, 0x0B);
    print(BUFF_WIDTH + REG_SCREEN_SIZE + LEFT_OFFSET, inp(0xA0));

    outp(0xA0, 0x0A);
    print(BUFF_WIDTH + REG_SCREEN_SIZE * 2 + LEFT_OFFSET, inp(0xA0));
}

void init()
{
    oldHandle60 = getvect(0x08); // Timer
    oldHandle61 = getvect(0x09); // Keyboard
    oldHandle62 = getvect(0x0A); // Slave IRQ
    oldHandle63 = getvect(0x0B); // Random deviece
    oldHandle64 = getvect(0x0C); // Random deviece
    oldHandle65 = getvect(0x0D); // Random deviece
    oldHandle66 = getvect(0x0E); // Random deviece
    oldHandle67 = getvect(0x0F); // Random deviece

    // IRQ 8-15
    oldHandle08 = getvect(0x70); // Real time clock
    oldHandle09 = getvect(0x71); // Random deviece
    oldHandle0A = getvect(0x72); // Random deviece
    oldHandle0B = getvect(0x73); // Random deviece or timer
    oldHandle0C = getvect(0x74); // PS/2 mouse
    oldHandle0D = getvect(0x75); // FPU error
    oldHandle0E = getvect(0x76); // Random deviece or first ATA controller
    oldHandle0F = getvect(0x77); // Random deviece or second ATA controller

    setvect(0x60, newHandle60);
    setvect(0x61, newHandle61);
    setvect(0x62, newHandle62);
    setvect(0x63, newHandle63);
    setvect(0x64, newHandle64);
    setvect(0x65, newHandle65);
    setvect(0x66, newHandle66);
    setvect(0x67, newHandle67);

    setvect(0x08, newHandle08);
    setvect(0x09, newHandle09);
    setvect(0x0A, newHandle0A);
    setvect(0x0B, newHandle0B);
    setvect(0x0C, newHandle0C);
    setvect(0x0D, newHandle0D);
    setvect(0x0E, newHandle0E);
    setvect(0x0F, newHandle0F);

    _disable();

    outp(0x20, 0x11); // ICW1                           00010001b
    outp(0x21, 0x60); // ICW2                           01001100b
    outp(0x21, 0x04); // ICW3                           00000100b
    outp(0x21, 0x01); // ICW4                           00000001b

    // Slave
    outp(0xA0, 0x11); // ICW1                           00010001b
    outp(0xA1, 0x08); // ICW2                           00001000b
    outp(0xA1, 0x02); // ICW3                           00000010b
    outp(0xA1, 0x01); // ICW4                           00000001b

    _enable();
}

int main()
{
    unsigned far* fp;

    init();

    FP_SEG(fp) = _psp;
    FP_OFF(fp) = 0x2c;
    _dos_freemem(*fp);

    _dos_keep(0, (_DS - _CS) + (_SP / 16) + 1);
    return 0;
}