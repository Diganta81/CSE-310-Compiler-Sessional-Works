    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

w DW 10 DUP 0000H
.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    SUB SP, 20
L1:
    MOV AX, 0
    PUSH AX
    MOV AX, 2
    PUSH AX
    POP AX
    NEG AX
    PUSH AX
    POP AX
    POP BX
    SHL BX, 1
    MOV w[BX], AX
L2:
    MOV AX, 0
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    MOV AX, w[BX]
    PUSH AX
    POP AX
    POP BX
    SHL BX, 1
    SUB BX, 22
    MOV SI, BX
    MOV [BP+SI], AX
L3:
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    SUB BX, 22
    MOV SI, BX
    MOV AX, [BP + SI]
    PUSH AX
    POP AX
    MOV [BP-2], AX
L4:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L5:
    MOV AX, 1
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    MOV AX, w[BX]
    INC AX
    MOV w[BX], AX
    PUSH AX
    POP AX
    POP BX
    SHL BX, 1
    SUB BX, 22
    MOV SI, BX
    MOV [BP+SI], AX
L6:
    MOV AX, 1
    PUSH AX
    POP BX
    SHL BX, 1
    SUB BX, 22
    MOV SI, BX
    MOV AX, [BP + SI]
    PUSH AX
    POP AX
    MOV [BP-2], AX
L7:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L8:
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    MOV AX, w[BX]
    PUSH AX
    POP AX
    MOV [BP-2], AX
L9:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L10:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-2], AX
L11:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    POP AX
    MOV [BP-2], AX
L12:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    POP AX
    MOV [BP-2], AX
L13:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L14
    JMP L15
L14:
    MOV AX, 1
    JMP L16
L15:
    MOV AX, 0
L16:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 10
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L17
    JMP L18
L17:
    MOV AX, 1
    JMP L19
L18:
    MOV AX, 0
L19:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L21
    CMP DX, 0
    JE L21
L20:
    MOV AX, 1
    JMP L22
L21:
    MOV AX, 0
L22:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L23
    JMP L24
L23:
    MOV AX, 1
    JMP L25
L24:
    MOV AX, 0
L25:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 10
    PUSH AX
    POP AX
    NEG AX
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L26
    JMP L27
L26:
    MOV AX, 1
    JMP L28
L27:
    MOV AX, 0
L28:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L30
    CMP DX, 0
    JE L30
L29:
    MOV AX, 1
    JMP L31
L30:
    MOV AX, 0
L31:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 1
    JE L32
    CMP DX, 1
    JE L32
    JMP L33
L32:
    MOV AX, 1
    JMP L34
L33:
    MOV AX, 0
L34:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L35
L37:
    MOV AX, 100
    PUSH AX
    POP AX
    MOV [BP-2], AX
    JMP L36
L35:
L38:
    MOV AX, 200
    PUSH AX
    POP AX
    MOV [BP-2], AX
L36:
L39:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L40:
    ADD SP, 0
    POP BP
    MOV AX, 4C00H
    INT 21H
main ENDP


new_line proc
    push ax
    push dx
    mov ah,2
    mov dl,0Dh
    int 21h
    mov ah,2
    mov dl,0Ah
    int 21h
    pop dx
    pop ax
    ret
new_line endp
print_output proc  ;print what is in ax
    push ax
    push bx
    push cx
    push dx
    push si
    lea si,number
    mov bx,10
    add si,4
    cmp ax,0
    jnge negate
    print:
    xor dx,dx
    div bx
    mov [si],dl
    add [si],'0'
    dec si
    cmp ax,0
    jne print
    inc si
    lea dx,si
    mov ah,9
    int 21h
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    negate:
    push ax
    mov ah,2
    mov dl,'-'
    int 21h
    pop ax
    neg ax
    jmp print
print_output endp
END MAIN