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
L1:
    MOV AX, 3
    PUSH AX
    POP AX
    MOV [BP-2], AX
L2:
    MOV AX, 8
    PUSH AX
    POP AX
    MOV [BP-4], AX
L3:
    MOV AX, 6
    PUSH AX
    POP AX
    MOV [BP-6], AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JE L4
    JMP L5
L4:
    MOV AX, 1
    JMP L6
L5:
    MOV AX, 0
L6:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L7
L8:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
L7:
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, 8
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
    CMP AX, 1
    JNE L12
L14:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    JMP L13
L12:
L15:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L13:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, 6
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JNE L16
    JMP L17
L16:
    MOV AX, 1
    JMP L18
L17:
    MOV AX, 0
L18:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L19
L21:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
    JMP L20
L19:
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, 8
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L22
    JMP L23
L22:
    MOV AX, 1
    JMP L24
L23:
    MOV AX, 0
L24:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L25
L27:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
    JMP L26
L25:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 5
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L28
    JMP L29
L28:
    MOV AX, 1
    JMP L30
L29:
    MOV AX, 0
L30:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L31
L33:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    JMP L32
L31:
L34:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-6], AX
L35:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L32:
L26:
L20:
    MOV AX, 0
    PUSH AX
    POP AX
L36:
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