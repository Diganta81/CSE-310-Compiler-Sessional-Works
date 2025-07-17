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
L5:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-2], AX
L1:
L6:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 6
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L7
    JMP L8
L7:
    MOV AX, 1
    JMP L9
L8:
    MOV AX, 0
L9:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L4
    JMP L3
L2:
    MOV AX, [BP - 2]
    PUSH AX
    INC AX
    MOV [BP - 2], AX
    POP AX
    JMP L1
L3:
L10:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    JMP L2
L4:
L11:
    MOV AX, 4
    PUSH AX
    POP AX
    MOV [BP-6], AX
L12:
    MOV AX, 6
    PUSH AX
    POP AX
    MOV [BP-8], AX
L13:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L15
    JMP L16
L15:
    MOV AX, 1
    JMP L17
L16:
    MOV AX, 0
L17:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L14
L18:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-8], AX
L19:
    MOV AX, [BP - 6]
    PUSH AX
    DEC AX
    MOV [BP - 6], AX
    POP AX
    JMP L13
L14:
L20:
    MOV AX, [BP - 8]
    CALL print_output
    CALL new_line
L21:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L22:
    MOV AX, 4
    PUSH AX
    POP AX
    MOV [BP-6], AX
L23:
    MOV AX, 6
    PUSH AX
    POP AX
    MOV [BP-8], AX
L24:
    MOV AX, [BP - 6]
    PUSH AX
    DEC AX
    MOV [BP - 6], AX
    POP AX
    PUSH AX
    POP AX
    CMP AX, 0
    JE L25
L26:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-8], AX
    JMP L24
L25:
L27:
    MOV AX, [BP - 8]
    CALL print_output
    CALL new_line
L28:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L29:
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