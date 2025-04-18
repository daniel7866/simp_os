[BITS 16]
[ORG 0x7C00]

; write to the screen in VGA text mode (mode 03)
VGA_MEMORY equ 0xB8000
VGA_MEMORY_SIZE equ 4000 ; this mode is 80x25 where each one is two bytes (ascii + color)
;

REAL_MODE_START: ; 0x7C00

    CLI ; no interrupts
    LGDT[GDT_DESC]
    MOV EAX, 0x1
    MOV CR0, EAX ; PROTECTED MODE
    
    MOV AX, 0x10 ; index=2, TI=0(GDT), CPL=0
    MOV DS, AX

    MOV AX, 0x18 ; index=3, TI=0(GDT), CPL=0
    MOV SS, AX

    MOV ESP, PM_CPL_0_STACK + 50
    MOV EBP, PM_CPL_0_STACK

    JMP 0x8:PM_CPL_0_CODE


[BITS 32]

PM_CPL_0_STACK:
    times 50 db 0;

PM_CPL_0_CODE:
    MOV ECX, VGA_MEMORY_SIZE

    TOP:
        MOV byte [VGA_MEMORY + ECX], 0x0
    LOOP TOP

    MOV word [VGA_MEMORY +  0], 0x0F53 ; S
    MOV word [VGA_MEMORY +  2], 0x0F69 ; i
    MOV word [VGA_MEMORY +  4], 0x0F6D ; m
    MOV word [VGA_MEMORY +  6], 0x0F70 ; p

    MOV word [VGA_MEMORY +  8], 0x0F20 ; 

    MOV word [VGA_MEMORY + 10], 0x0F4F ; O
    MOV word [VGA_MEMORY + 12], 0x0F53 ; S

    HLT ; Stop execution


align 8 ; intel recommends 8 byte alignemnt of the GDT for best performance
GDT_:
    dq 0x0 ; null descriptor should contain base and limit of lgdt, x86 mention should be aligned to 8 byte for best performance

    ; (0x8) PM CODE
    dw 0xFFFF ; limit[15:0]
    dw 0x0000 ; base[15:0]
    db 0x0    ; base[16:23]
    db 0x9A   ; TYPE(CODE), S=1(CODE/DATA),DPL=0,P=1(PRESENT)
    db 0xCF   ; LIMIT[19:16], AVL=1,L=0(32 bit),D/B=1(32 bit),G=1
    db 0x0    ; BASE[31:24]

    ; (0x10) PM DATA
    dw 0xFFFF ; limit[15:0]
    dw 0x0000 ; base[15:0]
    db 0x0    ; base[16:23]
    db 0x92   ; TYPE(DATA), S=1(CODE/DATA),DPL=0,P=1(PRESENT)
    db 0xCF   ; LIMIT[19:16], AVL=1,L=0(32 bit),D/B=1(32 bit),G=1
    db 0x0    ; BASE[31:24]

    ; (0x18) PM STACK
    dw 0xFFFF ; limit[15:0]
    dw 0x0000 ; base[15:0]
    db 0x0    ; base[16:23]
    db 0x92   ; TYPE(DATA), S=1(CODE/DATA),DPL=0,P=1(PRESENT)
    db 0xCF   ; LIMIT[19:16], AVL=1,L=0(32 bit),D/B=1(32 bit),G=1
    db 0x0    ; BASE[31:24]

    ; (0x20)
    GDT_DESC:
    dw $ - GDT_ - 1   ; limit
    dd GDT_                 ; base

times 510 - ($ - $$) db 0  ; padding to make 510 bytes
dw 0xAA55                  ; signature
