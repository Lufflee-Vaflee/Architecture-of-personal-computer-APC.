;           !!Warning!! this is not my code, it tooked from the frolov library, like an example and template for lab8 see: https://frolov-lib.ru/books/bsp.old/v06/ch2.htm

IDEAL
RADIX   16
P286

; Используем модель памяти LARGE, при этом мы организуем
; несколько отдельных сегментов и для каждого сегмента
; создадим дескриптор в таблице GDT.

MODEL   LARGE

; ------------------------------------------------------------
; Определения структур данных и констант
; ------------------------------------------------------------

STRUC   desc_struc              ; структура дескриптора
        limit   dw      0       ; предел
        base_l  dw      0       ; мл. слово физического адреса
        base_h  db      0       ; ст. байт физического адреса
        access  db      0       ; байт доступа
        rsrv    dw      0       ; зарезервировано
ENDS    desc_struc

; Биты байта доступа

ACC_PRESENT     EQU     10000000b ; сегмент есть в памяти
ACC_CSEG        EQU     00011000b ; сегмент кода
ACC_DSEG        EQU     00010000b ; сегмент данных
ACC_EXPDOWN     EQU     00000100b ; сегмент расширяется вниз
ACC_CONFORM     EQU     00000100b ; согласованный сегмент
ACC_DATAWR      EQU     00000010b ; разрешена запись

; Типы сегментов

; сегмент данных
DATA_ACC = ACC_PRESENT OR ACC_DSEG OR ACC_DATAWR

; сегмент кода
CODE_ACC = ACC_PRESENT OR ACC_CSEG OR ACC_CONFORM

; сегмент стека
STACK_ACC = ACC_PRESENT OR ACC_DSEG OR ACC_DATAWR OR ACC_EXPDOWN


; Константы

STACK_SIZE      EQU     0400    ; размер стека
B_DATA_SIZE     EQU     0300    ; размер области данных BIOS
B_DATA_ADDR     EQU     0400    ; адрес области данных BIOS
MONO_SEG        EQU     0b000   ; сегмент видеопамяти 
                                ;  монохромного видеоадаптера
COLOR_SEG       EQU     0b800   ; сегмент видеопамяти
                                ; цветного видеоадаптера
CRT_SIZE        EQU     4000    ; размер сегмента видеопамяти
                                ;  цветного видеоадаптера
MONO_SIZE       EQU     1000    ; размер сегмента видеопамяти
                                ;  монохромного видеоадаптера

CRT_LOW         EQU     8000    ; мл. байт физического адреса
                                ;  сегмента видеопамяти
                                ;  цветного видеоадаптера
MONO_LOW        EQU     0000    ; мл. байт физического адреса
                                ;  сегмента видеопамяти
                                ;  монохромного видеоадаптера

CRT_SEG         EQU     0Bh     ; ст. байт физического адреса
                                ;  сегмента видеопамяти

; Селекторы, определённые в таблице GDT

DS_DESCR        =       (gdt_ds - gdt_0)
CS_DESCR        =       (gdt_cs - gdt_0)
SS_DESCR        =       (gdt_ss - gdt_0)
BIOS_DESCR      =       (gdt_bio - gdt_0)
CRT_DESCR       =       (gdt_crt - gdt_0)
MDA_DESCR       =       (gdt_mda - gdt_0)

CMOS_PORT       EQU     70h     ; порт для доступа к CMOS-памяти
PORT_6845       EQU     0063h   ; адрес области данных BIOS,
                                ; где записано значение адреса
                                ; порта контроллера 6845
COLOR_PORT      EQU     03d4h   ; порт цветного видеоконтроллера
MONO_PORT       EQU     03b4h   ; порт монохромного видеоконтроллера
STATUS_PORT     EQU     64h     ; порт состояния клавиатуры
SHUT_DOWN       EQU     0feh    ; команда сброса процессора
VIRTUAL_MODE    EQU     0001h   ; бит перехода в защищённый режим
A20_PORT        EQU     0d1h    ; команда управления линией A20
A20_ON          EQU     0dfh    ; открыть A20
A20_OFF         EQU     0ddh    ; закрыть A20
KBD_PORT_A      EQU     60h     ; адреса клавиатурных
KBD_PORT_B      EQU     61h     ;   портов
INT_MASK_PORT   EQU     21h     ; порт для маскирования прерываний

STACK   STACK_SIZE      ; сегмент стека

DATASEG                 ; начало сегмента данных

DSEG_BEG        =       THIS WORD

; Память для хранения регистров SS, SP, ES. Содержимое
; этих регистров будет записано здесь перед входом в
; защищённый режим и восстановлено отсюда после возврата
; из защищённого режима в реальный.

        real_ss dw      ?
        real_sp dw      ?
        real_es dw      ?

; Глобальная таблица дескрипторов GDT,
; содержит следующие дескрипторы:
;
;       gdt_0   - дескриптор для пустого селектора
;       gdt_gdt - дескриптор для GDT
;       gdt_ds  - дескриптор для сегмента, адресуемого DS
;       gdt_cs  - дескриптор для сегмента кода
;       gdt_ss  - дескриптор для сегмента стека
;       gdt_bio         - дескриптор для области данных BIOS
;       gdt_crt         - дескриптор для видеопамяти цветного дисплея
;       gdt_mda         - дескриптор для видеопамяти монохромного дисплея

GDT_BEG         = $
LABEL   gdtr            WORD

        gdt_0   desc_struc      <0,0,0,0,0> 
        gdt_gdt desc_struc      <GDT_SIZE-1,,,DATA_ACC,0>
        gdt_ds  desc_struc      <DSEG_SIZE-1,,,DATA_ACC,0>
        gdt_cs  desc_struc      <CSEG_SIZE-1,,,CODE_ACC,0>
        gdt_ss  desc_struc      <STACK_SIZE-1,,,DATA_ACC,0>
        gdt_bio         desc_struc      <B_DATA_SIZE-1,B_DATA_ADDR,0,DATA_ACC,0>
        gdt_crt         desc_struc      <CRT_SIZE-1,CRT_LOW,CRT_SEG,DATA_ACC,0>
        gdt_mda         desc_struc      <MONO_SIZE-1,MONO_LOW,CRT_SEG,DATA_ACC,0>

GDT_SIZE        = ($ - GDT_BEG) ; размер таблицы дескрипторов

CODESEG         ; сегмент кода

PROC    start

; Инициализируем регистр сегмента данных
; для реального режима

        mov     ax,DGROUP
        mov     ds,ax

; Определяем базовый адрес видеопамяти

        call    set_crt_base

; Стираем экран дисплея (устанавливаем серый фон)

        mov     bh, 77h
        call    clrscr

; Выполняем все подготовительные действия для перехода
; в защищённый режим и обеспечения возможности возврата
; в реальный режим

        call    init_protected_mode

; Переключаемся в защищённый режим

        call    set_protected_mode

; --------- * Программа работает в защищённом режиме! * ---------

        call    write_hello_msg ; выводим сообщение на экран
;        call    pause           ; ждём некоторое время

; Возвращаемся в реальный режим

        call    set_real_mode

; --------- * Программа работает в реальном режиме! * ---------

; Стираем экран и возвращаемся в DOS
        mov     bh, 07h
        call    clrscr
        mov     ah,4Ch
        int     21h

ENDP    start


; ------------------------------------------------------------
; Макрокоманда для записи в дескриптор 24-битового
; базового адреса сегмента
; ------------------------------------------------------------

MACRO setgdtentry
        mov     [(desc_struc bx).base_l],ax
        mov     [(desc_struc bx).base_h],dl
ENDM

; ------------------------------------------------------------
; Процедура подготовки процессора к переходу в защищённый
; режим с последующим возвратом в реальный режим
; ------------------------------------------------------------

PROC    init_protected_mode     NEAR

; Заполняем глобальную таблицу дескрипторов GDT

; Вычисляем 24-битовый базовый адрес сегмента данных

        mov     ax,DGROUP
        mov     dl,ah
        shr     dl,4
        shl     ax,4

; Регистры dl:ax содержат базовый адрес, сохраняем его в di:si

        mov     si,ax
        mov     di,dx

; Подготавливаем дескриптор для GDT

        add     ax,OFFSET gdtr
        adc     dl,0
        mov     bx,OFFSET gdt_gdt
        setgdtentry

; Подготавливаем дескриптор для сегмента ds

        mov     bx,OFFSET gdt_ds
        mov     ax,si
        mov     dx,di
        setgdtentry

; Подготавливаем дескриптор для сегмента cs

        mov     bx,OFFSET gdt_cs
        mov     ax,cs
        mov     dl,ah
        shr     dl,4
        shl     ax,4
        setgdtentry

; Подготавливаем дескриптор для сегмента стека

        mov     bx,OFFSET gdt_ss
        mov     ax,ss
        mov     dl,ah
        shr     dl,4
        shl     ax,4
        setgdtentry

; Записываем адрес возврата в реальный режим в область
; данных BIOS по адресу 0040h:0067h

        push    ds
        mov     ax,40
        mov     ds,ax
        mov     [WORD 67],OFFSET shutdown_return
        mov     [WORD 69],cs
        pop     ds

; Маскируем все прерывания, в том числе немаскируемые.
; Записываем в CMOS-память в ячейку 0Fh код 5,
; этот код обеспечит после выполнения сброса процессора
; передачу управления по адресу, подготовленному нами
; в области данных BIOS по адресу 0040h:0067h.
; Для того, чтобы немаскируемые прерывания были запрещены,
; устанавливаем в 1 старший бит при определении ячейки CMOS.

        cli
        mov     al,8f
        out     CMOS_PORT,al
        jmp     next1           ; небольшая задержка
next1:

        mov     al,5
        out     CMOS_PORT+1,al  ; код возврата

        ret

ENDP    init_protected_mode

; ------------------------------------------------------------
; Процедура переключает процессор в защищённый режим
; ------------------------------------------------------------

PROC    set_protected_mode      NEAR

        mov     ax,[rl_crt]     ; записываем в es сегментный
        mov     es,ax           ; адрес видеопамяти

        call    enable_a20      ; открываем адресную линию A20

        mov     [real_ss],ss    ; запоминаем указатель стека
        mov     [real_es],es    ; для реального режима

; Загружаем регистр GDTR

        lgdt    [QWORD gdt_gdt]

; Устанавливаем защищённый режим работы процессора

        mov     ax,VIRTUAL_MODE
        lmsw    ax

; Мы находимся в защищённом режиме

; Очищаем внутреннюю очередь команд процессора
; Выполняем команду межсегментного пehехода,
; в качестве селектора указываем селектор текущего
; сегмента кода, в качестве смещения - метку flush

;       jmp     far flush
        db      0ea
        dw      OFFSET flush
        dw      CS_DESCR

LABEL   flush   FAR

; Загружаем сегментные регистры SS и DS селекторами

        mov     ax,SS_DESCR
        mov     ss,ax
        mov     ax,DS_DESCR
        mov     ds,ax
        ret

ENDP    set_protected_mode

; ------------------------------------------------------------
; Процедура возвращает процессор в реальный режим
; ------------------------------------------------------------

PROC    set_real_mode   NEAR

; Запоминаем содержимое указателя стека, так как после
; сброса процессора оно будет потеряно

        mov     [real_sp],sp

; Выполняем сброс процессора

        mov     al,SHUT_DOWN
        out     STATUS_PORT,al

; Ожидаем сброса процессора

wait_reset:
        hlt
        jmp     wait_reset

; ------->> В это место мы попадём после сброса процессора,
; теперь мы снова в реальном режиме

LABEL   shutdown_return FAR

; Инициализируем ds адресом сегмента данных

        mov     ax,DGROUP
        mov     ds,ax
        assume  ds:DGROUP

; Восстанавливаем указатель стека

        mov     ss,[real_ss]
        mov     sp,[real_sp]

; Восстанавливаем содержимое регистра es

        mov     es,[real_es]

; Закрываем адресную линию A20

        call    disable_a20

; Разрешаем все прерывания

        mov     ax,000dh        ; разрешаем немаскируемые прерывания
        out     CMOS_PORT,al

        in      al,INT_MASK_PORT ; разрешаем маскируемые прерывания
        and     al,0
        out     INT_MASK_PORT,al
        sti

        ret
ENDP    set_real_mode

; ------------------------------------------------------------
; Процедура открывает адресную линию A20
; ------------------------------------------------------------

PROC    enable_a20      NEAR
        mov     al,A20_PORT
        out     STATUS_PORT,al
        mov     al,A20_ON
        out     KBD_PORT_A,al
        ret
ENDP    enable_a20

; ------------------------------------------------------------
; Процедура закрывает адресную линию A20
; ------------------------------------------------------------

PROC    disable_a20     NEAR
        mov     al,A20_PORT
        out     STATUS_PORT,al
        mov     al,A20_OFF
        out     KBD_PORT_A,al
        ret
ENDP    disable_a20

; ------------------------------------------------------------
; Процедура выполняет небольшую временную задержку
; ------------------------------------------------------------

PROC    pause           NEAR
        push    cx
        mov     cx, 6000
ploop0:
        push    cx
        xor     cx,cx
ploop1:
        loop    ploop1
        pop     cx
        loop    ploop0

        pop     cx
        ret
ENDP    pause

; ------------------------------------------------------------
; Сегмент данных для процедур обслуживания видеоадаптера
; ------------------------------------------------------------

DATASEG
        columns db      80d     ; количество столбцов на экране
        rows    db      25d     ; количество строк на экране

        rl_crt  dw      COLOR_SEG       ; сегментный адрес видеобуфера
        vir_crt dw      CRT_DESCR       ; селектор видеобуфера

        curr_line       dw      0d      ; номер текущей строки

CODESEG

; ------------------------------------------------------------
; Определение базового адреса видеобуфера
; ------------------------------------------------------------

PROC    set_crt_base    NEAR

; Определяем количество столбцов на экране и записываем 
; в переменную columns

        mov     ax,40
        mov     es,ax
        mov     bx,[WORD es:4a]
        mov     [columns],bl

; То же для количества строк, записываем в переменную rows

        mov     bl,[BYTE es:84]
        inc     bl
        mov     [rows],bl

; Для того чтобы определить тип видеоконтроллера (цветной
; или монохромный), считываем адрес микросхемы 6845

        mov     bx,[WORD es:PORT_6845]
        cmp     bx,COLOR_PORT
        je      set_crt_exit

; Если видеоконтроллер монохромный, изменяем адрес сегмента
; и селектор, заданные по умолчанию

        mov     [rl_crt],MONO_SEG
        mov     [vir_crt],MDA_DESCR

set_crt_exit:
        ret
ENDP    set_crt_base

; ------------------------------------------------------------
; Вывод строки на экран
; Параметры:
;       (ax, bx) - координаты (x, y) выводимой строки
;       ds:si   - адрес выводимой строки
;       cx      - длина выводимой строки
;       dh      - атрибут выводимой строки
;       es      - сегмент или селектор видеопамяти
; ------------------------------------------------------------

PROC    writexy         NEAR
        push    si
        push    di

; Вычисляем смещение в видеобуфере для записи строки,
; используем формулу ((y * columns) + x) * 2

        mov     dl,[columns]
        mul     dl
        add     ax,bx
        shl     ax,1
        mov     di,ax
        mov     ah,dh   ; записываем в ah байт атрибута

; Выполняем запись в видеобуфер

wxy_write:
        lodsb   ; очередной символ в al
        stosw   ; записываем его в видеопамять
        loop    wxy_write       ; цикл до конца строки

        pop     di
        pop     si
        ret
ENDP    writexy

; ------------------------------------------------------------
; Процедура стирания экрана
;       Параметр: bh - атрибут для заполнения экрана
; ------------------------------------------------------------


PROC    clrscr          NEAR
        xor     cx,cx
        mov     dl,[columns]
        mov     dh,[rows]
        mov     ax,0600h        
        int     10h
        ret
ENDP    clrscr

DATASEG

hello_msg db " Protected mode monitor *TINY/OS*, v.1.0 for CPU 80286  ¦ © Frolov A.V., 1992 "

CODESEG

; ------------------------------------------------------------
; Процедура выводит сообщение в защищённом режиме
; ------------------------------------------------------------

PROC    write_hello_msg NEAR

        mov     ax,[vir_crt]    ; загружаем селектор видеопамяти 
        mov     es,ax           ; в регистр es

; Выводим сообщение в верхний левый угол экрана (x=y=0)

        mov     bx,0            ;(X,Y) = (AX,BX)
        mov     ax,[curr_line]
        inc     [curr_line]     ; увеличиваем номер текущей строки

; Загружаем адрес выводимой строки и её длину

        mov     si,OFFSET hello_msg
        mov     cx,SIZE hello_msg

        mov     dh,30h  ; аттрибут - черный текст на голубом фоне

        call    writexy ; выводим строку

        ret
ENDP    write_hello_msg


CSEG_SIZE       = ($ - start) ; размер сегмента кода

DATASEG

DSEG_SIZE       = ($ - DSEG_BEG) ; размер сегмента данных

        END     start