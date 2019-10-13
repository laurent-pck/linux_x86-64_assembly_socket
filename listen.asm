; Compile with: yasm -f elf64 filename.asm
; Link with: ld filename.o -o executablename
; Run with: ./executablename


; Conventions for registers:
; Arguments: rdi,rsi,rdx,rcx,r8,r9
; Return: rax
; Modified: rax,rcx,r11


; useful functions:

; void quit()
; Exit the program with code 0
quit:
    mov rax, 60
    mov rdi, 0
    syscall
    ret

; int slen(string msg)
; Calculate string length
slen:
    push rbx
    mov rbx, rax

nextchar:
    cmp byte [rax], 0
    je finished
    inc rax
    jmp nextchar

finished:
    sub rax, rbx
    pop rbx
    ret

; void sprint(string msg)
; String print function
sprint:
    push rcx
    push rdx
    push rsi
    push rdi
    push rax
    call slen

    mov rdx, rax
    pop rax

    mov rsi, rax
    mov rdi, 1
    mov rax, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    ret


global _start

section .bss
buffer resb 255 ; reserve space for 255 bytes

section .text
_start:
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

_socket_create:
    mov rax, 41 ; sys_socket call
    mov rdi, 2 ; PF_INET domain
    mov rsi, 1 ; SOCK_STREAM type
    mov rdx, 6 ; TCP protocol
    syscall ; socket file descriptior is now in rax

_socket_bind:
    mov rdi, rax ; fd
    push dword 0x00000000 ; put ip add 0.0.0.0 on stack
    push word 0x901F ; put port 8080 on stack (little endian)
    push word 2 ; put domain PF_INET on stack
    mov rsi, rsp ; *sokaddr
    mov rdx, 16 ; addrlen in bytes
    mov rax, 49 ; sys_bind call
    syscall

_socket_listen:
    ; file descriptor is already in rdi
    mov rsi, 1 ; backlog
    mov rax, 50 ; sys_listen call
    syscall

_socket_accept:
    ; file descripor is already in rdi
    push byte 0
    mov rsi, rsp ; *upeer_sockaddr
    mov rdx, rsp ; *upeer_addrlen
    mov rax, 43 ; sys_accept call
    syscall ; incoming socket file descripor is now in rax

_fork:
    mov rsi, rax ; incoming socket fd
    mov rax, 57 ; sys_fork call
    syscall
    cmp rax, 0
    je _incoming_socket_read ; child process jump to _incoming_socket_read
    jmp _socket_accept ; parent process jump to _socket_accept

_incoming_socket_read:
    mov rdi, rsi ; incoming socket fd
    mov rsi, buffer ; *buf
    mov rdx, 255 ; count
    mov rax, 0 ; sys_read call
    syscall
    mov rax, buffer
    call sprint

_incoming_socket_close:
    ; incoming socket fd already in rdi
    mov rax, 3 ; sys_close call
    syscall

_exit:
    call quit
