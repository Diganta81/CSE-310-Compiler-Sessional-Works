    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

.CODE
func PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
    SUB SP, 2
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
    JE L1
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
    MOV AX, 0
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L4:
L5:
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    MOV [BP-4], AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    CALL func
    ADD SP, 2
    PUSH AX
    MOV AX, [BP - 4]
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
L6:
    ADD SP, 4
    POP BP
    RET
func ENDP
func2 PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
    SUB SP, 2
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 0
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    CMP AX, DX
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
    MOV AX, 0
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L10:
L11:
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    MOV [BP-4], AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 1
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    SUB AX, DX
    PUSH AX
    CALL func
    ADD SP, 2
    PUSH AX
    MOV AX, [BP - 4]
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
L12:
    ADD SP, 4
    POP BP
    RET
func2 ENDP
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
L13:
    MOV AX, 7
    PUSH AX
    CALL func
    ADD SP, 2
    PUSH AX
    POP AX
    MOV [BP-2], AX
L14:
    MOV AX, [BP - 2]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L15:
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