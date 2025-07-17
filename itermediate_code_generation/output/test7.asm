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
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L1
    JMP L2
L1:
    MOV AX, 1
    JMP L3
L2:
    MOV AX, 0
L3:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 10
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L4
    JMP L5
L4:
    MOV AX, 1
    JMP L6
L5:
    MOV AX, 0
L6:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 1
    JE L7
    CMP DX, 1
    JE L7
    JMP L8
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
    MOV AX, 100
    PUSH AX
    POP AX
    MOV [BP-2], AX
    JMP L11
L10:
L13:
    MOV AX, 200
    PUSH AX
    POP AX
    MOV [BP-2], AX
L11:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 20
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
    MOV AX, 30
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
    POP AX
    CMP AX, 1
    JNE L23
L25:
    MOV AX, 300
    PUSH AX
    POP AX
    MOV [BP-2], AX
    JMP L24
L23:
L26:
    MOV AX, 400
    PUSH AX
    POP AX
    MOV [BP-2], AX
L24:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 40
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L27
    JMP L28
L27:
    MOV AX, 1
    JMP L29
L28:
    MOV AX, 0
L29:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 50
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L30
    JMP L31
L30:
    MOV AX, 1
    JMP L32
L31:
    MOV AX, 0
L32:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L34
    CMP DX, 0
    JE L34
L33:
    MOV AX, 1
    JMP L35
L34:
    MOV AX, 0
L35:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 60
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JL L36
    JMP L37
L36:
    MOV AX, 1
    JMP L38
L37:
    MOV AX, 0
L38:
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 70
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JG L39
    JMP L40
L39:
    MOV AX, 1
    JMP L41
L40:
    MOV AX, 0
L41:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 0
    JE L43
    CMP DX, 0
    JE L43
L42:
    MOV AX, 1
    JMP L44
L43:
    MOV AX, 0
L44:
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, 1
    JE L45
    CMP DX, 1
    JE L45
    JMP L46
L45:
    MOV AX, 1
    JMP L47
L46:
    MOV AX, 0
L47:
    PUSH AX
    POP AX
    CMP AX, 1
    JNE L48
L50:
    MOV AX, 500
    PUSH AX
    POP AX
    MOV [BP-2], AX
    JMP L49
L48:
L51:
    MOV AX, 600
    PUSH AX
    POP AX
    MOV [BP-2], AX
L49:
L52:
    MOV AX, [BP - 2]
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