    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

i DW 1 DUP 0000H 
j DW 1 DUP 0000H 
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
    SUB SP, 2
    SUB SP, 2
L1:
    MOV AX, 1
    PUSH AX
    POP AX
    MOV i, AX
L2:
    MOV AX, i
    CALL print_output
    CALL new_line
L3:
    MOV AX, 5
    PUSH AX
    MOV AX, 8
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV j, AX
L4:
    MOV AX, j
    CALL print_output
    CALL new_line
L5:
    MOV AX, i
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, j
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
    MOV [BP-2], AX
L6:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L7:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 9
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    DIV CX
    MOV AX, DX
    PUSH AX
    POP AX
    MOV [BP-6], AX
L8:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L9:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JLE L10
    JMP L11
L10:
    MOV AX, 1
    JMP L12
L11:
    MOV AX, 0
L12:
    PUSH AX
    POP AX
    MOV [BP-8], AX
L13:
    MOV AX, [BP - 8]
    CALL print_output
    CALL new_line
L14:
    MOV AX, i
    PUSH AX
    MOV AX, j
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JNE L15
    JMP L16
L15:
    MOV AX, 1
    JMP L17
L16:
    MOV AX, 0
L17:
    PUSH AX
    POP AX
    MOV [BP-10], AX
L18:
    MOV AX, [BP - 10]
    CALL print_output
    CALL new_line
L19:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, [BP - 10]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 1
    JE L20
    CMP DX, 1
    JE L20
    JMP L21
L20:
    MOV AX, 1
    JMP L22
L21:
    MOV AX, 0
L22:
    PUSH AX
    POP AX
    MOV [BP-12], AX
L23:
    MOV AX, [BP - 12]
    CALL print_output
    CALL new_line
L24:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, [BP - 10]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L26
    CMP DX, 0
    JE L26
L25:
    MOV AX, 1
    JMP L27
L26:
    MOV AX, 0
L27:
    PUSH AX
    POP AX
    MOV [BP-12], AX
L28:
    MOV AX, [BP - 12]
    CALL print_output
    CALL new_line
L29:
    MOV AX, [BP - 12]
    PUSH AX
    INC AX
    MOV [BP - 12], AX
    POP AX
L30:
    MOV AX, [BP - 12]
    CALL print_output
    CALL new_line
L31:
    MOV AX, [BP - 12]
    PUSH AX
    POP AX
    NEG AX
    PUSH AX
    POP AX
    MOV [BP-2], AX
L32:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L33:
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