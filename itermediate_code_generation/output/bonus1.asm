    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

.CODE
foo PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+6]
	MOV [BP-4], AX
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    MOV AX, 5
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JLE L1
    JMP L2
L1:
    MOV AX, 1
    JMP L3
L2:
    MOV AX, 0
L3:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L4
    MOV AX, 7
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L4:
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, 2
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    CALL foo
    ADD SP, 4
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 2
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    CALL foo
    ADD SP, 4
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L5:
    ADD SP, 4
    POP BP
    RET
foo ENDP
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    SUB SP, 2
    SUB SP, 2
L6:
    MOV AX, 7
    PUSH AX
    POP AX
    MOV [BP-2], AX
L7:
    MOV AX, 3
    PUSH AX
    POP AX
    MOV [BP-4], AX
L8:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    CALL foo
    ADD SP, 4
    PUSH AX
    POP AX
    MOV [BP-6], AX
L9:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L10:
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