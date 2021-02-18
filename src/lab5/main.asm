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
        
    ;////////////////////////////////////////////////////// string standart time buffer ////////////////////////////////////////////////////////////////////// 
         
      
    
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
            
            output_str      msgSTART;
            endl;
            
            mov     CX,     200;
            call    RTC_TIME_DATE;
            
            
            exit    msgEND;
            
        
    ;////////////////////////////////////////////////////////////     Proc     //////////////////////////////////////////////////////////// 
        
        RTC_TIME_DATE           proc;
            
            push    AX;
            push    DX;
            xor     AH,     AH;
            
            mov     AL,     0Bh;
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            or      AL,     00000110b;
            out     71h,    AL;
            
            mov     AL,     00h;       seconds
            out     70h,    AL;
            jmp     $ + 2;
            in      AL,     71h;
            push    AX;
                
            mov     AL,     02h;       minutes
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
            call    Unsigned16Output ;
            mov     AH,     02h;
            int     21h;
            
            pop     AX;    
            call    Unsigned16Output ;
            mov     AH,     02h;
            int     21h;
            
            pop     AX;
            call    Unsigned16Output ;
            
            endl;
            output_str      msgCurrentTime;
            endl;
            
            pop     AX;
            call    Unsigned16Output ;
            mov     AH,     02h;
            int     21h;
            
            pop     AX;
            call    Unsigned16Output ;
            mov     AH,     02h;
            int     21h;
            
            pop     AX;
            call    Unsigned16Output;
            
            
            pop     DX;
            pop     AX;
            endl;
            ret;
            
        RTC_TIME_DATE           endp;
                                    
                                    
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
                
                
        Sleep                   proc;               CX - miliseconds num
            
            push    AX;
            push    ES;
            push    DI;
            push    CX;                             
            
            mov     DI,     0h;
            mov     ES,     DI;
            mov     DI,     70h;                    adress 70h interruption vector(0000:0070h); not sure, maybe better use ICW2       
            
            push    [DI];                           save standart vector
            push    CX;                             save num of miliseconds -------------------------------------------            
            
            cli;                                    disable interruptions 
            mov     word ptr DI,   0;
            inc     DI;                                            | 
            mov     word ptr DI,   offset word ptr IRQ8_70h;        set new 70h interruption vector                          |
            sti;                                    enable interruptions                                              |
            
            xor     AL,     AL;                                                                                       |
            in      AL,     0A1h;                   read mask by OCW1 command                                         |
            and     AL,     11111110b;              enable IRQ8(70h) interruptions in interruption controller         |
            jmp     $ + 2;
            out     0A1h,    AL;                    write new mask by OCW1 command                                    |
            
            mov     AL,     0Bh;                    set B register for CMOS                                           |
            out     70h,    AL;                     write B register to controll port                                 |
            jmp     $ + 2;                          pause                                                             |
            in      AL,     71h;                    read B register                                                   |
            or      AL,     01000000b;              enable IRQ8(70h) interruptions in RTC                             |
            out     71h,    AL;                     write B register                                                  |
            
            pop     CX;                             get back num of miliseconds ---------------------------------------
            CYCLE_SLEEP:                           
                cmp     CX,     0;
            jg CYCLE_SlEEP;                        wait for enouth IRQ8 interruptions midly called per 1 sec
                
            pop     CX;
            cli;
            mov     [DI],   CX;
            sti;
            
            pop     CX;
            pop     DI;
            pop     ES;
            pop     AX;
            ret;
            
        Sleep                   endp; 
        
        
    ;////////////////////////////////////////////////////////////   interruptions     ////////////////////////////////////////////////////////////
    
        IRQ8_70h                proc;
            
            dec      CX; 
            iret;    
            
        IRQ8_70h                endp;        
        
        end main;        
    code    ends    