    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    SUB SP, 2
    SUB SP, 6
L1:
    MOV AX, 1
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    DIV CX
    MOV AX, DX
    PUSH AX
    POP AX
    MOV [BP-2], AX
L2:
    MOV AX, 1
    PUSH AX
    MOV AX, 5
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L3
    JMP L4
L3:
    MOV AX, 1
    JMP L5
L4:
    MOV AX, 0
L5:
    PUSH AX
    POP AX
    MOV [BP-4], AX
L6:
    MOV AX, 0
    PUSH AX
    MOV AX, 2
    PUSH AX
    POP AX
    POP BX
    SHL BX, 1
    SUB BX, 10
    MOV SI, BX
    MOV [BP+SI], AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L8
    CMP DX, 0
    JE L8
L7:
    MOV AX, 1
    JMP L9
L8:
    MOV AX, 0
L9:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L10
L12:
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    SUB BX, 10
    MOV SI, BX
    MOV AX, [BP + SI]
    PUSH AX
    JMP L11
L10:
L13:
    MOV AX, 1
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP BX
    SHL BX, 1
    SUB BX, 10
    MOV SI, BX
    MOV AX, [BP + SI]
    PUSH AX
    POP AX
    POP BX
    SHL BX, 1
    SUB BX, 10
    MOV SI, BX
    MOV [BP+SI], AX
L11:
L14:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L15:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
L16:
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