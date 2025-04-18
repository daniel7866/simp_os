[BITS 16]
[ORG 0x7C00]

REAL_MODE_START: ; 0x7C00

    CLI ; no interrupts
    LGDT[GDT_DESC]
    MOV EAX, 0x1
    MOV CR0, EAX ; PROTECTED MODE
    
    JMP 0x8:PROTECTED_MODE_CODE

[BITS 32]
PROTECTED_MODE_CODE: ; 0x9000
    HLT ; Stop execution


align 8 ; intel recommends 8 byte alignemnt of the GDT for best performance
GDT_:
    dq 0x0 ; null descriptor should contain base and limit of lgdt, x86 mention should be aligned to 8 byte for best performance

    ; (0x8) PM CODE
    dw 0xFFFF ; limit[15:0]
    dw 0x0000 ; base[15:0]
    db 0x0    ; base[16:23]
    db 0x9A   ; TYPE(CODE), S=1(CODE),DPL=0,P=1(PRESENT)
    db 0xCF   ; LIMIT[19:16], AVL=1,L=0(32 bit),D/B=1(32 bit),G=1
    db 0x0    ; BASE[31:24]

    ; (0x10)
    GDT_DESC:
    dw $ - GDT_ - 1   ; limit
    dd GDT_                 ; base

times 510 - ($ - $$) db 0  ; padding to make 510 bytes
dw 0xAA55                  ; signature
