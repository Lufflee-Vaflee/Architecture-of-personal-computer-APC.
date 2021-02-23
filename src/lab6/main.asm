    .model large

    .stack 100h

    .data


    ;////////////////////////////////////////////// 16 Signed num (string decimal form) buffer ///////////////////////////////////////////////////////////////
        NumBuf16        db  8;
        NumSize16       db  ?;
        NumSign16       db  ?;
        NumMod16        db  9   DUP ('$');

    ;///////////////////////////////////////////// 16 Unsigned num (string decimal form) buffer ///////////////////////////////////////////////////////////////
        UNumBuf16       db  8;
        UNumSize16      db  ?;
        UNumMod16       db  9   DUP ('$');

    ;//////////////////////////////////////////////////////////    Word buffers    ///////////////////////////////////////////////////////////////////////////
        TimeOut         dw  20000;
        TimeOut_flag    db  0;
        Esc_flag        db  0;

    ;//////////////////////////////////////////////////////////      Messages      ///////////////////////////////////////////////////////////////////////////
        msgSTART        db  "  ================================ Program Start =================================$";
        msgSpace        db  "                                                                                  $";
        msgScanCodes    db  "  Keyboard scan codes (Enter Esc to exit): $";
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

            output_str      msgSTART;
            endl;

            call    Scan_codes_output;


            exit    msgEND;


     ;////////////////////////////////////////////////////////////     Proc     //////////////////////////////////////////////////////////// 

         Unsigned16Output        proc;           AX - output num
            
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
        
        Unsigned16Output        endp;


        kbd_in_ready            proc;

            push    AX;
            push    CX;

            mov     CX,     TimeOut;

            kbd_in_wait_loop:

                in      AL,     64h;
                test    AL,     00000010b;
                jz      kbd_in_exit;
        
            loop    kbd_in_wait_loop;

            mov     TimeOut_flag,   1;

            kbd_in_exit:
            pop     CX;
            pop     AX;
            ret;

        kbd_in_ready            endp;


        kbd_out_ready           proc;

            push    AX;

            kbd_out_wait_loop:

                in      AL,     64h;
                test    AL,     00000001b;
                jnz     kbd_out_exit;
        
            loop    kbd_out_wait_loop;


            kbd_out_exit:
            pop     AX;
            ret;

        kbd_out_ready           endp;


        Scan_codes_output       proc;

            push    AX;
            push    DI;
            push    ES;
            push    DX;

            output_str  msgScanCodes;
            endl;

            cli;

            mov     DI,     0h;
            mov     ES,     DI;
            mov     DI,     24h;

            push    [DI];                           save standart vector

            mov     AH,     25h;
            mov     AL,     09h;
            mov     DX,     @code;
            push    DS;
            mov     DS,     DX;
            mov     DX,     offset word ptr IRQ1_09h;
            int     21h;
            pop     DS;

            mov     AL,     1;
            sti;
            Scodes_CYCLE:

                cmp     AL,     Esc_flag;

            jne     Scodes_CYCLE;

            cli;
            pop     [DI];
            sti;

            pop     DX;
            pop     ES;
            pop     DI;
            pop     AX;
            ret;

        Scan_codes_output       endp;


     ;////////////////////////////////////////////////////////////   interruptions     ////////////////////////////////////////////////////////////

        IRQ1_09h                proc;

            push    AX;

            in      AL,     60h;
            mov     CX,     01;

            cmp     AL,     1;
            jne     IRQ1_continue;
            mov     Esc_flag,   AL;

            IRQ1_continue:
            call    Unsigned16Output;
            endl;

            pop     AX;
            iret;

        IRQ1_09h                endp;

        end main;
    code    ends