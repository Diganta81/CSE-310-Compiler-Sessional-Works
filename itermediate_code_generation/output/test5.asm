    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

.CODE
f PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
    SUB SP, 2
L1:
    MOV AX, 5
    PUSH AX
    POP AX
    MOV [BP-4], AX
L2:
    MOV AX, [BP - 4]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L4
    JMP L5
L4:
    MOV AX, 1
    JMP L6
L5:
    MOV AX, 0
L6:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L3
L7:
    MOV AX, [BP - 2]
    PUSH AX
    INC AX
    MOV [BP - 2], AX
    POP AX
L8:
    MOV AX, [BP - 4]
    PUSH AX
    DEC AX
    MOV [BP - 4], AX
    POP AX
    JMP L2
L3:
    MOV AX, 3
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    MOV AX, 7
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L9:
    MOV AX, 9
    PUSH AX
    POP AX
    MOV [BP-2], AX
L10:
    ADD SP, 4
    POP BP
    RET
f ENDP
g PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+6]
	MOV [BP-4], AX
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
    SUB SP, 2
    SUB SP, 2
L11:
    MOV AX, [BP - 4]
    PUSH AX
    CALL f
    ADD SP, 2
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-6], AX
L16:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-8], AX
L12:
L17:
    MOV AX, [BP - 8]
    PUSH AX
    MOV AX, 7
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L18
    JMP L19
L18:
    MOV AX, 1
    JMP L20
L19:
    MOV AX, 0
L20:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L15
    JMP L14
L13:
    MOV AX, [BP - 8]
    PUSH AX
    INC AX
    MOV [BP - 8], AX
    POP AX
    JMP L12
L14:
    MOV AX, [BP - 8]
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
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JE L21
    JMP L22
L21:
    MOV AX, 1
    JMP L23
L22:
    MOV AX, 0
L23:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L24
L26:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, 5
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-6], AX
    JMP L25
L24:
L27:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    POP AX
    MOV [BP-6], AX
L25:
    JMP L13
L15:
    MOV AX, [BP - 6]
    PUSH AX
    POP AX
    ADD SP, 8
    POP BP
    RET
L28:
    ADD SP, 8
    POP BP
    RET
g ENDP
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    SUB SP, 2
    SUB SP, 2
L29:
    MOV AX, 1
    PUSH AX
    POP AX
    MOV [BP-2], AX
L30:
    MOV AX, 2
    PUSH AX
    POP AX
    MOV [BP-4], AX
L31:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    CALL g
    ADD SP, 4
    PUSH AX
    POP AX
    MOV [BP-2], AX
L32:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L37:
    MOV AX, 0
    PUSH AX
    POP AX
    MOV [BP-6], AX
L33:
L38:
    MOV AX, [BP - 6]
    PUSH AX
    MOV AX, 4
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L39
    JMP L40
L39:
    MOV AX, 1
    JMP L41
L40:
    MOV AX, 0
L41:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L36
    JMP L35
L34:
    MOV AX, [BP - 6]
    PUSH AX
    INC AX
    MOV [BP - 6], AX
    POP AX
    JMP L33
L35:
L42:
    MOV AX, 3
    PUSH AX
    POP AX
    MOV [BP-2], AX
L43:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L45
    JMP L46
L45:
    MOV AX, 1
    JMP L47
L46:
    MOV AX, 0
L47:
    PUSH AX
    POP AX
    CMP AX, 0
    JE L44
L48:
    MOV AX, [BP - 4]
    PUSH AX
    INC AX
    MOV [BP - 4], AX
    POP AX
L49:
    MOV AX, [BP - 2]
    PUSH AX
    DEC AX
    MOV [BP - 2], AX
    POP AX
    JMP L43
L44:
    JMP L34
L36:
L50:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
L51:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
L52:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L53:
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