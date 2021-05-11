IDEAL
RADIX   16
P286
MODEL   LARGE

STRUC   desc_struc      ; структура дескриптора
        limit   dw      0       ; предел
        base_l  dw      0       ; мл. слово физического адреса
        base_h  db      0       ; ст. байт физического адреса
        access  db      0       ; байт доступа
        rsrv            dw      0       ; зарезервировано
ENDS            desc_struc

STRUC   idt_struc               ; вентиль прерывания
        destoff dw      0       ; смещение обработчика
        destsel dw      0       ; селектор обработчика
        nparams db      0       ; кол-во параметров
        assess  db       0       ; байт доступа
        rsrv       dw     0       ; зарезервировано
ENDS            idt_struc

STRUC   idtr_struc              ; регистр IDTR
        idt_lim dw      0       ; предел IDT
        idt_l   dw      0       ; мл. слово физического адреса
        idt_h   db      0       ; ст. байт физического адреса
        rsrv            db      0       ; зарезервировано
ENDS            idtr_struc

; ---------------------------------------------------------------
; Биты байта доступа

ACC_PRESENT     EQU     10000000b ; сегмент есть в памяти
ACC_CSEG                EQU     00011000b ; сегмент кода
ACC_DSEG                EQU     00010000b ; сегмент данных
ACC_EXPDOWN     EQU     00000100b ; сегмент расширяется вниз
ACC_CONFORM     EQU     00000100b ; согласованный сегмент
ACC_DATAWR      EQU     00000010b ; разрешена запись
ACC_INT_GATE    EQU     00000110b ; вентиль прерывания
ACC_TRAP_GATE   EQU     00000111b ; вентиль исключения

; ------------------------------------------------------------
; Типы сегментов

; сегмент данных

DATA_ACC = ACC_PRESENT OR ACC_DSEG OR ACC_DATAWR

; сегмент кода

CODE_ACC = ACC_PRESENT OR ACC_CSEG OR ACC_CONFORM

; сегмент стека

STACK_ACC = ACC_PRESENT OR ACC_DSEG OR ACC_DATAWR OR ACC_EXPDOWN

; байт доступа сегмента таблицы IDT

IDT_ACC         =       DATA_ACC

; байт доступа вентиля прерывания

INT_ACC         =       ACC_PRESENT OR ACC_INT_GATE

; байт доступа вентиля исключения

TRAP_ACC        =       ACC_PRESENT OR ACC_TRAP_GATE

; ------------------------------------------------------------
; Константы

STACK_SIZE      EQU     0800    ; размер стека
B_DATA_SIZE     EQU     0300    ; размер области данных BIOS
B_DATA_ADDR     EQU     0400    ; адрес области данных BIOS
MONO_SEG                EQU     0b000   ; сегмент видеопамяти 
                                                ;  монохромного видеоадаптера
COLOR_SEG               EQU     0b800   ; сегмент видеопамяти
                                                ; цветного видеоадаптера
CRT_SIZE                EQU     4000    ; размер сегмента видеопамяти
                                        ;  цветного видеоадаптера
MONO_SIZE               EQU     1000    ; размер сегмента видеопамяти
                                        ;  монохромного видеоадаптера

CRT_LOW         EQU     8000    ; мл. байт физического адреса
                                        ;  сегмента видеопамяти
                                        ;  цветного видеоадаптера
MONO_LOW                EQU     0000    ; мл. байт физического адреса
                                        ;  сегмента видеопамяти
                                        ;  монохромного видеоадаптера

CRT_SEG         EQU     0Bh     ; ст. байт физического адреса
                                        ;  сегмента видеопамяти
CMOS_PORT               EQU     70h     ; порт для доступа к CMOS-памяти
PORT_6845               EQU     0063h   ; адрес области данных BIOS,
                                                ; где записано значение адреса
                                                ; порта контроллера 6845
COLOR_PORT      EQU     03d4h   ; порт цветного видеоконтроллера
MONO_PORT               EQU     03b4h   ; порт монохромного видеоконтроллера
STATUS_PORT     EQU     64h             ; порт состояния клавиатуры
SHUT_DOWN               EQU     0feh            ; команда сброса процессора
VIRTUAL_MODE    EQU     0001h   ; бит перехода в защищённый режим
A20_PORT                EQU     0d1h    ; команда управления линией A20
A20_ON          EQU     0dfh    ; открыть A20
A20_OFF         EQU     0ddh    ; закрыть A20
KBD_PORT_A      EQU     60h     ; адреса клавиатурных
KBD_PORT_B      EQU     61h     ;   портов
INT_MASK_PORT   EQU     21h     ; порт для маскирования прерываний
EOI                     EQU     20      ; команда конца прерывания
MASTER8259A     EQU     20      ; первый контроллер прерываний
SLAVE8259A      EQU     0a0     ; второй контроллер прерываний

; ------------------------------------------------------------
; Селекторы, определённые в таблице GDT

DS_DESCR                =       (gdt_ds - gdt_0)
CS_DESCR                =       (gdt_cs - gdt_0)
SS_DESCR                =       (gdt_ss - gdt_0)
BIOS_DESCR              =       (gdt_bio - gdt_0)
CRT_DESCR               =       (gdt_crt - gdt_0)
MDA_DESCR               =       (gdt_mda - gdt_0)

; ------------------------------------------------------------
; Маски и инверсные маски для клавиш

STACK   STACK_SIZE

DATASEG
DSEG_BEG = THIS WORD

        real_ss dw      ?
        real_sp dw      ?
        real_es dw      ?

GDT_BEG = $
LABEL   gdtr            WORD

gdt_0           desc_struc <0,0,0,0,0>
gdt_gdt         desc_struc <GDT_SIZE-1,,,DATA_ACC,0>
gdt_idt         desc_struc <IDT_SIZE-1,,,IDT_ACC,0>
gdt_ds          desc_struc <DSEG_SIZE-1,,,DATA_ACC,0>
gdt_cs          desc_struc <CSEG_SIZE-1,,,CODE_ACC,0>
gdt_ss          desc_struc <STACK_SIZE-1,,,DATA_ACC,0>
gdt_bio         desc_struc <B_DATA_SIZE-1,B_DATA_ADDR,0,DATA_ACC,0>
gdt_crt         desc_struc <CRT_SIZE-1,CRT_LOW,CRT_SEG,DATA_ACC,0>
gdt_mda         desc_struc <MONO_SIZE-1,MONO_LOW,CRT_SEG,DATA_ACC,0>

GDT_SIZE = ($ - GDT_BEG)

; Область памяти для загрузки регистра IDTR

idtr    idtr_struc      <IDT_SIZE,,,0>

; Таблица дескрипторов прерываний

IDT_BEG = $

; ---------------------- Вентили исключений --------------------

idt     idt_struc 020h dup(<OFFSET shutdown,CS_DESCR,0,TRAP_ACC,0>)

; --------------- Вентили аппаратных прерываний ---------------

; int 20h-IRQ0

        idt_struc <OFFSET Timer_int,CS_DESCR,0,INT_ACC,0>

; int 21h-IRQ1s

        idt_struc <OFFSET Keyb_int,CS_DESCR,0,INT_ACC,0>

; int 22h, 23h, 24h, 25h, 26h, 27h-IRQ2-IRQ7

        idt_struc 6 dup (<OFFSET dummy_iret0,CS_DESCR,0,INT_ACC,0>)

; int 28h, 29h, 2ah, 2bh, 2ch, 2dh, 2eh, 2fh-IRQ8-IRQ15

        idt_struc <OFFSET rtc_cnt_int,CS_DESCR,0,INT_ACC,0>
        idt_struc 7 dup (<OFFSET dummy_iret1,CS_DESCR,0,INT_ACC,0>)


; -------------------- Вентиль прерывания --------------------

; int 30h 
        ;idt_struc       <OFFSET Int_30h_Entry,CS_DESCR,0,INT_ACC,0>


IDT_SIZE        = ($ - IDT_BEG)

sec     dw      20;

CODESEG

PROC    start

        mov     ax,DGROUP
        mov     ds,ax

        call    set_crt_base
        mov     bh, 77h
        call    clrscr;

; Устанавливаем защищённый ржим

        call    set_pmode       
        call    write_hello_msg 

; Размаскируем прерывания от таймера и клавиатуры и RTC

        in      al,INT_MASK_PORT
        and     al,0f8h
        out     INT_MASK_PORT,al

        in      AL,     0A1h;                   read mask by OCW1 command                                         |
        and     AL,     11111110b;              enable IRQ8(70h) interruptions in interruption controller         |
        jmp     $ + 2;
        out     0A1h,    AL;                    write new mask by OCW1 command 
 

; Ожидаем нажатия на клавишу <ESC>

charin:

        mov     al, 1;
        cmp     al, [Esc_flag]   ; если <ESC> - выход из цикла
        je      continue


        jmp     charin

; Следующий байт находится в сегменте кода.
; Он используется нами для демонстрации возникновения
; исключения при попытке записи в сегмент кода.

wrong1  db ?

continue:

; После нажатия на клавишу <ESC> выходим в это место
; программы. Следующие несколько строк демонстрируют
; команды, которые вызывают исключение. Вы можете
; попробовать их, если уберёте символ комментария
; из соответствующей строки.

; Попытка записи за конец сегмента данных. Метка wrong
; находится в самом конце программы.
        ;mov     [wrong], al

; Попытка записи в сегмент кода.
;       mov     [wrong1], al

; Попытка извлечения из пустого стека.
;       pop     ax

; Загрузка в сегментный регистр неправильного селектора.
;       mov     ax, 1280h
;       mov     ds, ax

; Прямой вызов исключения при помощи команды прерывания.
;       int     1


        call    set_rmode       ; установка реального режима

        mov     bh, 07h         ; стираем экран и
        call    clrscr          ; выходим в DOS
        mov     ah,4c
        int     21h

ENDP    start


MACRO setgdtentry
        mov     [(desc_struc bx).base_l],ax
        mov     [(desc_struc bx).base_h],dl
ENDM

; -------------------------------------------
; Установка защищённого режима
; -------------------------------------------

PROC    set_pmode       NEAR

        mov     ax,DGROUP
        mov     dl,ah
        shr     dl,4
        shl     ax,4
        mov     si,ax
        mov     di,dx
        add     ax,OFFSET gdtr
        adc     dl,0
        mov     bx,OFFSET gdt_gdt
        setgdtentry

; Заполняем дескриптор в GDT, указывающий на
; дескрипторную таблицу прерываний

        mov     ax,si   ; загружаем 24-битовый адрес сегмента
        mov     dx,di   ; данных
        add     ax,OFFSET idt   ; адрес дескриптора для IDT
        adc     dl,0
        mov     bx,OFFSET gdt_idt
        setgdtentry

; Заполняем структуру для загрузки регистра IDTR

        mov     bx,OFFSET idtr
        mov     [(idtr_struc bx).idt_l],ax
        mov     [(idtr_struc bx).idt_h],dl

        mov     bx,OFFSET gdt_ds
        mov     ax,si
        mov     dx,di
        setgdtentry

        mov     bx,OFFSET gdt_cs
        mov     ax,cs
        mov     dl,ah
        shr     dl,4
        shl     ax,4
        setgdtentry

        mov     bx,OFFSET gdt_ss
        mov     ax,ss
        mov     dl,ah
        shr     dl,4
        shl     ax,4
        setgdtentry

; готовим возврат в реальный режим

        push    ds
        mov     ax,40
        mov     ds,ax
        mov     [WORD 67],OFFSET shutdown_return
        mov     [WORD 69],cs
        pop     ds

        cli
        mov     al,8f
        out     CMOS_PORT,al
        jmp     del1
del1:
        mov     al,5
        out     CMOS_PORT+1,al

        mov     ax,[rl_crt]     ; сегмент видеопамяти
        mov     es,ax

        call    enable_a20      ; открываем линию A20

        mov     [real_ss],ss    ; сохраняем сегментные
        mov     [real_es],es    ; регистры

; -------- Перепрограммируем контроллер прерываний --------

; Устанавливаем для IRQ0-IRQ7 номера прерываний 20h-27h

        mov     dx,MASTER8259A
        mov     ah,20h
        call    set_int_ctrlr

; Устанавливаем для IRQ8-IRQ15 номера прерываний 28h-2Fh

        mov     dx,SLAVE8259A
        mov     ah,28h
        call    set_int_ctrlr

; Включаем RTC прерывания
        cli;
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
        sti;

; Загружаем регистры IDTR и GDTR

        lidt    [FWORD idtr]
        lgdt    [QWORD gdt_gdt]

; Переключаемся в защищённый режим

        mov     ax,VIRTUAL_MODE
        lmsw    ax

;       jmp     far flush
        db      0ea
        dw      OFFSET flush
        dw      CS_DESCR
LABEL   flush   FAR

; Загружаем селекторы в сегментные регистры

        mov     ax,SS_DESCR
        mov     ss,ax
        mov     ax,DS_DESCR
        mov     ds,ax

; Разрешаем прерывания

        sti

        ret
ENDP    set_pmode

DATASEG

; Пустой дескриптор для выполнения возврата
; процессора в реальный режим через перевод
; его в состояние отключения.

null_idt idt_struc <> 

CODESEG

PROC    set_rmode       NEAR

        mov     [real_sp],sp

; Переводим процессор в состояние отключения,
; это эквивалентно аппаратному сбросу, но
; выполняется быстрее.
; Сначала мы загружаем IDTR нулями, затем
; выдаём команду прерывания.

        lidt    [FWORD null_idt]
        int     3

rwait:
        hlt
        jmp     rwait

LABEL   shutdown_return FAR

        in      al,INT_MASK_PORT
        and     al,0
        out     INT_MASK_PORT,al

        mov     ax,DGROUP
        mov     ds,ax
        assume  ds:DGROUP

        cli
        mov     ss,[real_ss]
        mov     sp,[real_sp]
        mov     ax,000dh
        out     CMOS_PORT,al
        sti
        mov     es,[real_es]
        call    disable_a20
        ret
ENDP    set_rmode


; -------------------------------------------------
; Обработка исключений
; -------------------------------------------------

; Обработчики исключений. Записываем в AX номер
; исключения и передаём управление процедуре
; shutdown


DATASEG

exc_msg db "Exception occures Press any key... "

CODESEG

PROC    shutdown        NEAR 

; Выводим сообщение об исключении

        mov     ax,[vir_crt]
        mov     es,ax
        mov     bx,1d
        mov     ax,4
        mov     si,OFFSET exc_msg
        mov     dh,74h
        mov     cx, SIZE exc_msg
        call    writexy

        call    set_rmode       ; возвращаемся в реальный режим

        mov     ax, 0   ; ожидаем нажатия на клавишу
        int     16h

        mov     bh, 07h
        call    clrscr
        mov     ah,4Ch
        int     21h

ENDP    shutdown

; -------------------------------------------------
; Перепрограммирование контроллера прерываний
;       На входе: DX - порт контроллера прерывания
;                 AH - начальный номер прерывания
; -------------------------------------------------

PROC    set_int_ctrlr   NEAR

        mov     al,11
        out     dx,al
        jmp     SHORT $+2
        mov     al,ah
        inc     dx
        out     dx,al
        jmp     SHORT $+2
        mov     al,4
        out     dx,al
        jmp     SHORT $+2
        mov     al,1
        out     dx,al
        jmp     SHORT $+2
        mov     al,0ff
        out     dx,al
        dec     dx
        ret
ENDP    set_int_ctrlr

; -------------------------------
; Разрешение линии A20
; -------------------------------

PROC    enable_a20      NEAR
        mov     al,A20_PORT
        out     STATUS_PORT,al
        mov     al,A20_ON
        out     KBD_PORT_A,al
        ret
ENDP    enable_a20

; -------------------------------
; Запрещение линии A20
; -------------------------------

PROC    disable_a20     NEAR
        mov     al,A20_PORT
        out     STATUS_PORT,al
        mov     al,A20_OFF
        out     KBD_PORT_A,al
        ret
ENDP    disable_a20

; ---------- Обработчик аппаратных прерываний IRQ2-IRQ7

PROC    dummy_iret0      NEAR
        push    ax

; Посылаем сигнал конца прерывания в первый контроллер 8259A

        mov     al,EOI
        out     MASTER8259A,al
        pop     ax
        iret
ENDP    dummy_iret0

; ---------- Обработчик аппаратных прерываний IRQ8-IRQ15

PROC    dummy_iret1      NEAR
        push    ax

; Посылаем сигнал конца прерывания в первый 
; и второй контроллеры 8259A

        mov     al,EOI
        out     MASTER8259A,al
        out     SLAVE8259A,al
        pop     ax
        iret
ENDP    dummy_iret1

; ------------------------------------------
;       Процедуры для работы с клавиатурой
; ------------------------------------------


DATASEG

        Esc_flag        db      0
        key_flag        db      0
        key_code        dw      0
        ext_scan        db      0
        keyb_status     dw      0

CODESEG

; ----------------------------------------------
; Обработчик аппаратного прерывания клавиатуры
; ----------------------------------------------

PROC    Keyb_int         NEAR

            push    AX;
            push    DS;
            push    ES;


            in      AL,     60h;
            push    AX;

            pop     AX;
            IRQ1_continue_1:
            cmp     AL,     1;
            jne     IRQ1_continue_2;
            mov     [Esc_flag],   AL;

            IRQ1_continue_2:
            mov     bx, 0302h           ;!!!!!!
            call Print_Word;            ;!!!!!!

            mov     AL,     20h;        ;iret should do it by him self, but without this it doesnt work
            out     20h,    AL;

            IRQ1_exit:
            pop     ES;
            pop     DS;
            pop     AX;
            iret;

ENDP    Keyb_int

; -------------------------------------------
;       TIMER section
; -------------------------------------------

DATASEG

        timer_cnt dw    0
        rtc_cnt   dw    0

CODESEG

PROC    Timer_int        NEAR
        cli
        push    ax
        push    bx; !!!!!!!!

; Увеличиваем содержимое счётчика времени

        mov     ax, [timer_cnt]
        inc     ax
        mov     [timer_cnt], ax
        mov     bx,     0402;
        call    Print_Word;

; Примерно раз в секунду выдаём звуковой сигнал

        test    ax, 0fh
        jnz     timer_exit

        ;call    beep

timer_exit:

; Посылаем команду конца прерывания

        mov     al,EOI
        out     MASTER8259A,al

        pop     bx ;!!!!!!!!!
        pop     ax
        sti
        iret
ENDP    Timer_int

PROC    rtc_cnt_int     NEAR


        push    AX;

        mov     AX,     [rtc_cnt]
        inc     AX;
        mov     [rtc_cnt],      AX;
        mov     bx,     0502;
        call    Print_Word;

        mov     AL,     0ch;
        out     70h,    AL;
        in      AL,     71h;

        xor     AX, AX;
        mov     al, 20h          ; посылаем сигнал конца
        out     0a0h ,al  ; прерывания

        pop     AX;
        IRET;

ENDP    rtc_cnt_int

; --------------------------------------------------
; Процедуры обслуживания видеоконтроллера
; --------------------------------------------------

DATASEG
        columns db      80d
        rows    db      25d
        rl_crt  dw      COLOR_SEG
        vir_crt dw      CRT_DESCR
        curr_line       dw      0d
        text_buf        db      "          "
CODESEG

; -----------------------------------------
; Определение адреса видеопамяти
; -----------------------------------------

PROC    set_crt_base    NEAR
        mov     ax,40
        mov     es,ax
        mov     bx,[WORD es:4a]
        mov     [columns],bl
        mov     bl,[BYTE es:84]
        inc     bl
        mov     [rows],bl
        mov     bx,[WORD es:PORT_6845]
        cmp     bx,COLOR_PORT
        je      color_crt
        mov     [rl_crt],MONO_SEG
        mov     [vir_crt],MDA_DESCR
color_crt:
        ret
ENDP    set_crt_base

; -------------------------------------
; Запись строки в видеопамять
; -------------------------------------

PROC    writexy         NEAR
        push    si
        push    di
        mov     dl,[columns]
        mul     dl
        add     ax,bx
        shl     ax,1
        mov     di,ax
        mov     ah,dh
write_loop:
        lodsb   
        stosw
        loop    write_loop      
        pop     di
        pop     si
        ret
ENDP    writexy

; ---------------------------------------
; Стирание экрана (в реальном режиме)
; ---------------------------------------

PROC    clrscr          NEAR
        xor     cx,cx   
        mov     dl,[columns]
        mov     dh,[rows]
        mov     ax,0600
        int     10
        ret
ENDP    clrscr

DATASEG

hello_msg db " Protected mode monitor *TINY/OS*"

CODESEG

; ------------------------------------
; Вывод начального сообщения 
; в защищённом режиме
; ------------------------------------

PROC    write_hello_msg NEAR
        mov     ax,[vir_crt]
        mov     es,ax
        mov     si,OFFSET hello_msg
        mov     bx,0
        mov     ax,[curr_line]
        inc     [curr_line]
        mov     cx,SIZE hello_msg
        mov     dh,30h
        call    writexy
        ;call    beep
        ret
ENDP    write_hello_msg

; ----------------------------------------------
; Процедура выводит на экран содержимое AX
;       (x,y) = (bh, bl)
; ----------------------------------------------

PROC Print_Word near

        push ax
        push bx
        push dx

        push ax
        mov cl,8
        rol ax,cl
        call Byte_to_hex
        mov     [text_buf], dh
        mov     [text_buf+1], dl

        pop ax
        call Byte_to_hex
        mov     [text_buf+2], dh
        mov     [text_buf+3], dl

        mov     si, OFFSET text_buf
        mov     dh, 70h
        mov     cx, 4
        mov     al, bh
        mov     ah, 0

        mov     bh, 0
        call    writexy
        
        pop dx
        pop bx
        pop ax
        ret
ENDP Print_Word

DATASEG

tabl db '0123456789ABCDEF'

CODESEG

; -----------------------------------------
; Преобразование байта в шестнадцатеричный
; символьный формат
; al - входной байт
; dx - выходное слово
; -----------------------------------------

PROC Byte_to_hex near

        push    cx
        push    bx

        mov     bx, OFFSET tabl

        push    ax
        and     al,0fh
        xlat
        mov     dl,al

        pop     ax
        mov     cl,4
        shr     al,cl
        xlat
        mov     dh,al

        pop bx
        pop cx
        ret

ENDP Byte_to_hex

CSEG_SIZE       = ($ - start)

DATASEG

DSEG_SIZE       = ($ - DSEG_BEG)

wrong   db      ?
        END     start