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
    SUB SP, 2
    SUB SP, 2
L1:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-4], AX
L2:
    MOV AX, 1
    PUSH AX
    POP AX
    MOV [BP-6], AX
L7:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-8], AX
L3:
L8:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, 4
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L9
    JMP L10
L9:
    MOV AX, 1
    JMP L11
L10:
    MOV AX, 0
L11:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L6
    JMP L5
L4:
    MOV AX, [BP - 8]
    PUSH AX
    INC AX
    MOV [BP - 8], AX
    POP AX
    JMP L3
L5:
L12:
    MOV AX, 3
    PUSH AX
    POP AX
    MOV [BP-2], AX
L13:
    MOV AX, [BP - 2]
    PUSH AX
    DEC AX
    MOV [BP - 2], AX
    POP AX
    PUSH AX
    POP AX
    CMP AX, 0
    JE L14
L15:
    MOV AX, [BP - 4]
    PUSH AX
    INC AX
    MOV [BP - 4], AX
    POP AX
    JMP L13
L14:
    JMP L4
L6:
L16:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L17:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
L18:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L19:
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