    .model large

    .stack 100h

    .data


    ;////////////////////////////////////////////// 16 Signed num (string decimal form) buffer ///////////////////////////////////////////////////////////////
        NumBuf16        db  8;
        NumSize16       db  ?;
        NumSign16       db  ?;
        NumMod16        db  9   DUP ('$');

    ;///////////////////////////////////////////// 16 Unsigned num (string decimal form) buffer ///////////////////////////////////////////////////////////////
        UNumBuf16        db  8;
        UNumSize16       db  ?;
        UNumMod16        db  9   DUP ('$');

    ;//////////////////////////////////////////////////////////    Word buffers    ///////////////////////////////////////////////////////////////////////////
        WordBuffer1     dw  ?;
        WordBuffer2     dw  ?;
        WordBuffer3     dw  ?;
        WordBuffer4     dw  ?;

    ;//////////////////////////////////////////////////////////      Messages      ///////////////////////////////////////////////////////////////////////////
        msgSTART        db  "  ================================ Program Start =================================$";
        msgSpace        db  "                                                                                  $";
        msgCurrentTime  db  "  Current time: $";
        msgCurrentDate  db  "  Current date: $";
        msgEnterTime    db  "  Enter new time(Hours, minutes, seconds): $";
        msgALARM        db  "  ALARM!, ALARM! $";
        msgEnterAlarm   db  "  Enter alarm time(Hours, minutes, seconds, 0xFF - will enable every h/m/s alarm):$";
        msgIncorrecTime db  "  Incorrect input for time format, $";
        msgPAUSE        db  "  Press any buttom to continue...$"
        ENDLstr         db  0Ah, 0Dh, '$';
        msgEND          db  "  ================================= Program End ==================================$";

    ;////////////////////////////////////////////////////////////    Macross   ////////////////////////////////////////////////////////////
        enter_str   macro   enterAdress;

            push    AX;
            push    DX;

            mov     AH,     0Ah;
            lea     DX,     enterAdress;  
            int     21h;  

            pop     DX;
            pop     AX;

        endm

        output_str  macro   outputAdress;

            push    AX;
            push    DX;

            mov     AH,     09h;
            lea     DX,     [outputAdress + 2];
            int     21h;

            pop     DX;
            pop     AX;

        endm

        output_msg  macro   outputAdress, size;

            push    AX;
            push    BX;
            push    SI;
            push    DI;

            mov     SI,     size;
            lea     DI,     outputAdress + SI + 2;
            mov     SI,     DI;
            lodsb;
            mov     BL,     AL;
            mov     AL,     '$';
            stosb;
            dec     DI;

            mov     AH,     09h;
            lea     DX,     [outputAdress + 2];
            int     21h;

            mov     AL,     BL;
            stosb;

            pop     DI;
            pop     SI;
            pop     BX;
            pop     AX;

        endm

        endl        macro
             
            push    AX;
            push    DX;

            mov     AH,     09h;
            lea     DX,     ENDLstr;
            int     21h; 

            pop     DX;
            pop     AX;

        endm

        exit        macro   endMsg

            output_str      endMsg;
            mov     AX,     4c00h;
            int     21h;

        endm

        pause       macro   pauseMsg

            push    AX;

            output_str      pauseMsg;
            mov     AH,     01h;
            int     21h;

            pop     AX;

        endm
        
        clearBuf    macro   strBuf

            push    CX;
            push    AX;
            push    DI;

            xor     CX,     CX;
            xor     AX,     AX;


            mov     CL,     strBuf;
            lea     DI,     strBuf + 1;
            mov     AL,     '$';

            rep    stosb;


            pop     DI;
            pop     AX;
            pop     CX;

         endm;


    ;////////////////////////////////////////////////////////////     Main     ////////////////////////////////////////////////////////////   
    .code

        main:

            mov     AX,     @data;
            mov     DS,     AX;
            mov     ES,     AX;

;           TODO: add complete menu for all functionality
            output_str      msgSTART;
            endl;

            call    RTC_TIME_DATE_OUT;
            call    RTC_TIME_INPUT;
            call    RTC_TIME_DATE_OUT;



            exit    msgEND;


    ;////////////////////////////////////////////////////////////     Proc     //////////////////////////////////////////////////////////// 

        RTC_TIME_DATE_OUT           proc;

            push    AX;
            push    DX;
            pushf;

            xor     AH,     AH;

            mov     AL,     00h;       seconds
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;

            mov     AX,     02h;       minutes
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;

            mov     AL,     04h;       hours
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;

            mov     AL,     09h;       year
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;

            mov     AL,     08h;       month
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;

            mov     AL,     07h;       day
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;


            output_str      msgCurrentDate;
            endl;
            mov     DL,     3Ah;

            pop     AX;
            call    UBCD16Output;
            mov     AH,     02h;
            int     21h;

            pop     AX;    
            call    UBCD16Output;
            mov     AH,     02h;
            int     21h;

            pop     AX;
            call    UBCD16Output;

            endl;
            output_str      msgCurrentTime;
            endl;

            pop     AX;
            call    UBCD16Output;
            mov     AH,     02h;
            int     21h;

            pop     AX;
            call    UBCD16Output;
            mov     AH,     02h;
            int     21h;

            pop     AX;
            call    UBCD16Output;

            popf;
            pop     DX;
            pop     AX;
            endl;
            ret;

        RTC_TIME_DATE_OUT           endp;

        RTC_TIME_INPUT              proc;

            push    AX;
            push    DX;
            pushf;

            endl;
            output_str      msgEnterTime;
            endl;
            mov     DL,     3Ah;

            call    UBCD16Input;
            push    AX;
            endl;

            call    UBCD16Input;
            push    AX;
            endl;

            call    UBCD16Input;
            push    AX;
            endl;


            cli;

            mov     AL,     00h;       seconds
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;

            mov     AL,     02h;       minutes
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;

            mov     AL,     04h;       hours
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;

            sti;


            popf;
            pop     DX;
            pop     AX;
            ret;

        RTC_TIME_INPUT         endp;


        Unsigned16Output            proc;           AX - output num

            push    AX;
            push    CX;
            push    DX;
            push    DI;
            push    SI;

            cld;
            xor     BX,     BX;
            xor     DI,     DI;
            xor     DX,     DX;
            mov     SI,     10;
            mov     CX,     1; 
            CYCLE_16USO_1:

                xor     DX,     DX;
                div     SI;
                add     DL,     '0';
                push    DX;
                inc     DI;
            
            mov     CX,     AX;
            inc     CX;
            loop    CYCLE_16USO_1; 

            mov     CX,     DI;
            inc     CX;
            mov     byte ptr UNumSize16,    CL;

            dec     CX;
            lea     DI,     UNumMod16;
            CYCLE_16USO_2:

                pop     AX;
                stosb;

            loop    CYCLE_16USO_2;


            output_str UNumBuf16;
            clearBuf   UNumBuf16; 
            pop     SI;
            pop     DI;
            pop     DX;
            pop     CX;
            pop     AX;

            ret;

        Unsigned16Output            endp;

        UBCD16Output                proc;

            push    DX;
            push    AX;
            push    CX;

            xor     AH,     AH;
            xor     DX,     DX;
            mov     CX,     16;
            div     CX;
            push    DX;
            mov     DL,     AL;
            add     DL,     '0';
            mov     AH,     02h;
            int     21h;
            pop     DX;
            add     DL,     '0';
            int     21h;

            pop     CX; 
            pop     AX;
            pop     DX;
            ret;


        UBCD16Output                endp;


        UBCD16Input             proc;hardcoded from unsigned16 to ubcd16, no checks for errors
;                                       TODO: refact and better debug of this
            push    BX;
            push    CX;
            push    DI;
            push    SI;

            xor     AX,     AX;
            xor     BX,     BX;
            xor     CX,     CX;
            xor     DI,     DI
            mov     SI,     10;

            enter_str       UNumBuf16;
            mov     CL,     UNumSize16;

            CYCLE_16UI_1:

                mov     BL,     UNumMod16 + DI;
                sub     BL,     '0';
                add     AL,     BL;
                dec     CX;
                jcxz    exit_CYCLE_16UI_1;
                inc     CX;
                rcl     AX,     4;
                inc     DI;

            loop    CYCLE_16UI_1;
            exit_CYCLE_16UI_1:

            jmp     end_16UI;
               
            undefined_16UI:
            xor     AX,     AX;
            jmp     end_16UI; 

            end_16UI:
            clearBuf   UNumBuf16; 
            pop     SI;
            pop     DI;
            pop     CX;
            pop     BX;
            ret;

        UBCD16Input             endp;


        Sleep                       proc;               CX - miliseconds num

            push    AX;
            push    ES;
            push    DI;
            push    DX;
            pushf;

            mov     DI,     0h;
            mov     ES,     DI;
            mov     DI,     1c0h;                    adress 70h interruption vector(0000:01c0h);

            push    [DI];                           save standart vector
            push    CX;                             save num of miliseconds -------------------------------------------

            mov     AH,     25h;
            mov     AL,     70h;
            mov     DX,     @code;
            push    DS;
            mov     DS,     DX;
            mov     DX,     offset word ptr IRQ8_70h;
            int     21h;

            pop     DS;

            cli;
            xor     AL,     AL;
            in      AL,     021h;
            and     AL,     11111011b;
            jmp     $ + 2;
            out     021h,   AL;
            xor     AL,     AL;                                                                                       |
            in      AL,     0A1h;                   read mask by OCW1 command                                         |
            and     AL,     11111110b;              enable IRQ8(70h) interruptions in interruption controller         |
            jmp     $ + 2;
            out     0A1h,    AL;                    write new mask by OCW1 command                                    |

            mov     AL,     8Bh;                    set B register for CMOS                                           |
            out     70h,    AL;                     write B register to controll port                                 |
            jmp     $ + 2;                          pause                                                             |
            in      AL,     71h;                    read B register                                                   |
            or      AL,     01000000b;              enable IRQ8(70h) interruptions in RTC                             |
            push    AX;
            mov     AL,     8Bh;                    set B register for CMOS                                           |
            out     70h,    AL;                     write B register to controll port                                 |
            pop     AX;
            jmp     $ + 2;
            out     71h,    AL;                     write B register                                                  |

            pop     CX;                             get back num of miliseconds ---------------------------------------
            xor     AX,     AX;

            sti;
            CYCLE_SLEEP:
                cmp     CX,     0;
            jg CYCLE_SlEEP;                        wait for enouth IRQ8 interruptions midly called per 1 sec
                
            cli;
            pop     [DI];
            sti;

            popf;
            pop     DX;
            pop     DI;
            pop     ES;
            pop     AX;
            ret;

        Sleep                       endp;

        RTC_SET_ALARM               proc;

            push    AX;
            push    DX;
            pushf;


            mov     AL,     0Bh;
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;
            mov     AL,     0Bh;
            out     70h,    AL;
            pop     AX;
            or      AL,     00000110b;
            out     71h,    AL;

            endl;
            output_str      msgEnterALarm;
            endl;
            mov     DL,     3Ah;

            call    Unsigned16Input;
            push    AX;
            
            call    Unsigned16Input;
            push    AX;
            
            call    Unsigned16Input;
            push    AX;


            cli;

            mov     AL,     01h;       seconds
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;
                
            mov     AL,     03h;       minutes
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;
            
            mov     AL,     05h;       hours
            out     70h,    AL;
            jmp     $ + 2;
            pop     AX;
            out     71h,    AL;


            mov     AH,     25h;
            mov     AL,     4ah;
            mov     DX,     @code;
            push    DS;
            mov     DS,     DX;
            mov     DX,     offset word ptr RTC_4ah;
            int     21h;
            pop     DS;

            mov     AL,     0Bh;
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;
            mov     AL,     0Bh;
            out     70h,    AL;
            pop     AX;
            or      AL,     00100000b;
            out     71h,    AL;

            sti;

            popf;
            pop     DX;
            pop     AX;
            ret;

        RTC_SET_ALARM               endp;

        RTC_RESET_ALARM             proc;

            push    AX;
            pushf;


            mov     AL,     0Bh;
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            and     AL,     11011111b;
            out     71h,    AL;

            popf;
            pop     AX;
            ret;

        RTC_RESET_ALARM             endp;


    ;////////////////////////////////////////////////////////////   interruptions     ////////////////////////////////////////////////////////////

        IRQ8_70h                    proc;

            push    AX;
            pushf;

            dec     CX;

            mov     AL,     0ch;
            out     70h,    AL;
            in      AL,     71h;

            popf;
            pop     AX;
            IRET;

        IRQ8_70h                    endp;

        RTC_4ah                     proc;

            push    AX;
            push    DS;
            pushf;

            mov     AX,     @data;
            mov     DS,     AX;
            output_str      msgALARM;
            endl;

            popf;
            pop     DS;
            pop     AX;
            IRET;

        RTC_4ah                     endp;

        end main;
    code    ends