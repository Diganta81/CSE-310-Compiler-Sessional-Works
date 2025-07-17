    .MODEL SMALL
    .STACK 1000H
    .DATA
    NUMBER DB '00000$'

a DW 1 DUP 0000H 
b DW 1 DUP 0000H 
c DW 1 DUP 0000H 
.CODE
func_a PROC
    PUSH BP
    MOV BP, SP
L1:
    MOV AX, 7
    PUSH AX
    POP AX
    MOV a, AX
L2:
    ADD SP, 0
    POP BP
    RET
func_a ENDP
foo PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
L3:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, 3
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    POP AX
    MOV [BP-2], AX
    MOV AX, [BP - 2]
    PUSH AX
    POP AX
    ADD SP, 2
    POP BP
    RET
L4:
    ADD SP, 2
    POP BP
    RET
foo ENDP
bar PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    MOV AX, [BP+6]
	MOV [BP-4], AX
    SUB SP, 2
    MOV AX, [BP+4]
	MOV [BP-2], AX
L5:
    MOV AX, 4
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, [BP - 2]
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
    MOV c, AX
    MOV AX, c
    PUSH AX
    POP AX
    ADD SP, 4
    POP BP
    RET
L6:
    ADD SP, 4
    POP BP
    RET
bar ENDP
main PROC
    MOV AX, @DATA
    MOV DS, AX
    PUSH BP
    MOV BP, SP
    SUB SP, 2
    SUB SP, 2
    SUB SP, 2
    SUB SP, 2
L7:
    MOV AX, 5
    PUSH AX
    POP AX
    MOV [BP-2], AX
L8:
    MOV AX, 6
    PUSH AX
    POP AX
    MOV [BP-4], AX
L9:
    CALL func_a
    ADD SP, 0
    PUSH AX
    POP AX
L10:
    MOV AX, a
    CALL print_output
    CALL new_line
L11:
    MOV AX, [BP - 2]
    PUSH AX
    CALL foo
    ADD SP, 2
    PUSH AX
    POP AX
    MOV [BP-6], AX
L12:
    MOV AX, [BP - 6]
    CALL print_output
    CALL new_line
L13:
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    CALL bar
    ADD SP, 4
    PUSH AX
    POP AX
    MOV [BP-8], AX
L14:
    MOV AX, [BP - 8]
    CALL print_output
    CALL new_line
L15:
    MOV AX, 6
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    MOV AX, [BP - 4]
    PUSH AX
    CALL bar
    ADD SP, 4
    PUSH AX
    POP AX
    MOV CX,AX
    POP AX
    CWD
    MUL CX
    PUSH AX
    MOV AX, 2
    PUSH AX
    POP AX
    MOV DX, AX
    POP AX
    ADD AX, DX
    PUSH AX
    MOV AX, 3
    PUSH AX
    MOV AX, [BP - 2]
    PUSH AX
    CALL foo
    ADD SP, 2
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
    SUB AX, DX
    PUSH AX
    POP AX
    MOV [BP-4], AX
L16:
    MOV AX, [BP - 4]
    CALL print_output
    CALL new_line
    MOV AX, 0
    PUSH AX
    POP AX
L17:
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