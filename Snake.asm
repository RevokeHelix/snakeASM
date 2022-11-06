IDEAL
MODEL small
STACK 100h
DATASEG
; constants
VIDMEM      equ 0B800h
SCREENW     equ 80
SCREENH     equ 25
SNAKECOLOR  equ 0C82Ah

; variables
snake dw 2000,2002,2004,0,2000 dup(?)
direction    db 4 ; 1-up 2-down 3-left 4-right
snakeLength dw 3
key db ?
canmove db 1
delaytime db 4
applepos dw ?
lengthen db 0
insidesnake db 0
CODESEG

proc endprogram
    mov ax, 4c00h ; exit program
    int 21h
    ret
endp endprogram

proc getinput
    push bp
    mov bp,sp
    push ax
    xor ax,ax
    mov ah,01 ; check if there is a keystroke
    int 16h
    jz noinput ; if not return
    mov ah,0
    int 16h ; if there is a keystroke check its value and move it to key
    mov [key],al
    pop ax
    pop bp
    ret
    noinput:
        pop ax
        pop bp
        ret
endp getinput

proc apple
    push bp
    mov bp,sp
    push ax
    push cx
    push dx
    push di

    mov [insidesnake],0

    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    mov  ax, dx
    xor  dx, dx
    mov cx,2000
    div cx       ; divide the ticks since midnight by 2000
    add dx,dx    ; multiply the remainder by two
    mov di, dx   ;place apple in the random position
    push ax
    mov ah, 150                                         ;making the dot's background red and flickering
    mov al, 'u'
    mov [es:di],ax
    mov [applepos],di
    pop ax

    push [bp+4]
    call applespawn
    pop dx

    pop di
    pop dx
    pop cx
    pop ax
    pop bp
    ret
endp apple

proc collision
    push bp
    mov bp,sp
    push ax
    push bx
    push si
    mov ax,[applepos]
    mov si,[bp+4]
    add si,[snakeLength]
    add si,[snakeLength]
    sub si,2
    mov bx,[si]

    cmp ax,bx ; check if apple position == head position 
    jne exit3
    call appleeaten ; if equal call appleeaten function
    exit3:
        pop si
        pop bx
        pop ax
        pop bp
    ret
endp collision

proc appleeaten
    push bp
    mov bp,sp
    push ax
    push bx
    push dx
    push di
    push cx 
    mov bx,offset snake ; move bx offset tail
    add bx,[snakeLength]
    add bx,[snakeLength] ; set bx to offset new head
    mov ax,[bx-2] ; move ax former head
    mov [bx],ax ; move new head former head
    mov cx,[snakeLength]
    swapforward: ; take everything forward by one element
        mov di,[bx-4]
        mov [bx-2],di
        sub bx,2
        loop swapforward
    inc [snakeLength] ; increase snake length
    call apple ; generate another apple
    cmp [insidesnake],1
    je isin
    poplabel:
        pop cx
        pop di
        pop dx
        pop bx
        pop ax
        pop bp
        ret
    isin:
    call apple
    cmp [insidesnake],1
    je isin
    mov [insidesnake],0
    jmp poplabel
endp appleeaten

proc delay
    push bp
    mov bp,sp
    push ax
    push dx
    push bx
    mov ah, 00
    int 1Ah
    mov bx, dx
    
    jmp_delay:
        int 1Ah
        sub dx, bx
        cmp dl, [delaytime]
        jl jmp_delay    
        pop bx
        pop dx
        pop ax

    pop bp
    ret
endp delay

proc clear
    push bp
    mov bp,sp
    ;; clear the screen using a loop that incs di and clears [ES:DI]
    mov ax, 0
    xor di, di
    mov cx, SCREENW*SCREENH
    rep stosw               ; mov [ES:DI], AX & inc di
    pop bp
    ret
endp clear

proc drawbody
    push bp
    mov bp,sp
    push cx
    push ax
    push bx
    push di

    mov ax,SNAKECOLOR ; snake design
    mov bx,[bp+4] ; move bx offset snake
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2
    mov di,[bx]
    stosw
    pop di
    pop bx
    pop ax
    pop cx
    pop bp
    ret
endp drawbody

proc deletesnake
    push bp
    mov bp,sp
    push cx
    push ax
    push bx
    push di
    cmp [lengthen],1
    je exit5
    mov cx, [snakeLength] ; number of times to loop
    xor ax,ax ; snake design
    mov bx,[bp+4] ; move bx offset snake
    mov di,[bx]
    mov [es:di],ax
    exit5:
        pop di
        pop bx
        pop ax
        pop cx
        pop bp
    ret
endp deletesnake

proc moveup
    push bp
    mov bp,sp
    push bx
    push ax

    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2
    mov ax,[bx]
    sub ax,160 ; sub 160 head
    mov [bx],ax
    pop ax
    pop bx
    pop bp
    ret
endp moveup

proc movedown
    push bp
    mov bp,sp
    push bx
    push ax

    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2
    
    mov ax,[bx]
    add ax,160 ; add 160 head
    mov [bx],ax

    pop ax
    pop bx
    pop bp
    ret
endp movedown

proc moveleft
    push bp
    mov bp,sp
    push bx
    push ax

    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2
    
    mov ax,[bx]
    sub ax,2 ; sub 2 head
    mov [bx],ax

    pop ax
    pop bx
    pop bp
    ret
endp moveleft

proc moveright
    push bp
    mov bp,sp
    push bx
    push ax

    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2

    mov ax,[bx]
    add ax,2 ; add 2 head
    mov [bx],ax

    pop ax
    pop bx
    pop bp
    ret
endp moveright

proc bordercontrol
    ;; function gets snake offset as parameter
    push bp
    mov bp,sp
    push dx
    push bx
    push ax
    xor ax,ax
    xor dx,dx
    xor bx,bx
    ;; Check key and send to matching function
    cmp [key],'w'
    je w
    cmp [key],'s'
    je s
    cmp [key],'d'
    je d
    cmp [key],'a'
    je a
    ;; Functions check if head's next movement is outside of border
    d: ; divide by 160 and check if remainder is 158 (on border)
        mov bx,[bp+4]
        add bx,[snakeLength]
        add bx,[snakeLength]
        sub bx,2
        mov bx,[bx]
        mov ax,bx
        mov dl,160
        div dl
        cmp ah,158
        jne approve
        jmp exitprogram
    a: ; divide by 160 and check if remainder is 0 (on border)
        mov bx,[bp+4]
        add bx,[snakeLength]
        add bx,[snakeLength]
        sub bx,2
        mov bx,[bx]
        mov ax,bx
        mov dl,160
        div dl
        cmp ah,0
        jne approve
        jmp exitprogram
    s: ; check if point plus 160 is outside of range
        mov bx,[bp+4]
        add bx,[snakeLength]
        add bx,[snakeLength]
        sub bx,2
        mov bx,[bx]
        add bx,160
        cmp bx,4000
        jl approve
        jmp exitprogram
    w: ; check if point minus 160 is outside of range
        mov bx,[bp+4]
        add bx,[snakeLength]
        add bx,[snakeLength]
        sub bx,2
        mov bx,[bx]
        sub bx,160
        cmp bx,0
        jg approve
        jmp exitprogram
    approve:
        mov [canmove],1
    exit1:
        pop ax
        pop dx
        pop bx
        pop bp
        ret
    exitprogram:
        mov ax, 4c00h
        int 21h
endp bordercontrol

proc directioncontrol
    push bp
    mov bp,sp

    ;; Check key and send to matching function
    cmp [key],'w'
    je dirup
    cmp [key],'s'
    je dirdown
    cmp [key],'d'
    je dirright
    cmp [key],'a'
    je dirleft
    ;; checks if current direction is opposite to new. If it is it changes the key back to previous and reverses direction
    dirup:
        cmp [direction], 2
        je disapprove1
        jmp approve2
        disapprove1:
            mov [key],'s'
            mov [direction],2
            jmp exit2
    dirdown:
        cmp [direction], 1
        je disapprove2
        jmp approve2
        disapprove2:
            mov [key],'w'
            mov [direction],1
            jmp exit2
    dirleft:
        cmp [direction], 4
        je disapprove3
        jmp approve2
        disapprove3:
            mov [key],'d'
            mov [direction],4
            jmp exit2
    dirright:
        cmp [direction], 3
        je disapprove4
        jmp approve2
        disapprove4:
            mov [key],'a'
            mov [direction],3
            jmp exit2
    approve2:
        jmp exit2
    exit2:
        pop bp
        ret
endp directioncontrol


proc collideSelf
    push bp
    mov bp,sp
    push cx
    push bx
    push di
    push dx
    mov cx, [snakeLength]; loop snakelength times
    dec cx
    mov bx,[bp+4] ; move bx offset of head
    add bx,[snakeLength]
    add bx,[snakeLength]
    sub bx,2
    mov di,[bp+4] ; move di tail position
    mov bx,[bx] ; move bx head position
    collisionloop: ;  check if head position is equal to any body position
        cmp bx,[di] ; check if the element di points at is equal to head position
        je exitprog ; exit if equal
        add di,2 ; increase element dx points to
        loop collisionloop ; loop for snakelength - 1 times
    pop di
    pop dx
    pop bx
    pop cx
    pop bp
    ret
    exitprog:
        mov ax, 4c00h
        int 21h
endp collideSelf

proc applespawn
    push bp
    mov bp,sp
    push cx
    push bx
    push di
    push dx
    mov cx, [snakeLength]; loop snakelength times
    mov bx,[applepos]
    mov di,[bp+4] ; move di tail position
    applespawnloop: ;  check if apple position is equal to any body position
        cmp bx,[di] ; check if the element di points at is equal to head position
        je insidesnake2 ; exit if equal
        add di,2 ; increase element dx points to
        loop applespawnloop ; loop for snakelength - 1 times
    pop di
    pop dx
    pop bx
    pop cx
    pop bp
    ret
    insidesnake2:
        mov [insidesnake],1
        pop di
        pop dx
        pop bx
        pop cx
        pop bp
        ret
endp applespawn

proc swap
    push bp
    mov bp,sp
    push di
    push bx
    push ax
    xor ax,ax
    mov ax,[snakeLength]
    add ax,[snakeLength]
    sub ax,2
    mov bx,[bp+4] ; move bx offset snake
    push dx
    xor dx,dx
    mov dx,bx
    add dx,ax
    switchloop: ;; take every element one element back
        add bx,2
        mov di,[bx]
        sub bx,2
        mov [bx],di
        add bx,2
        cmp dx,bx
        jne switchloop
    pop dx
    pop ax
    pop bx
    pop di
    pop bp
    ret
endp swap

proc MovementHandler
    push bp
    mov bp,sp
    call delay ; calls delay
    mov [canmove],0
    call getinput ; retrieves key pressed
    push [bp+4] ; pushes offset of snake
    call bordercontrol ;activates border-control
    pop dx
    push [bp+4] ; pushes offset of snake
    call directioncontrol ; activates direction control and checks you aren't trying to go in opposite direction
    pop dx
    pop bp
    ret
endp MovementHandler

proc AppleHandler
    push bp
    mov bp,sp
    push [bp+4]
    call collision ; check if apple has collided with snake
    pop dx
    pop bp
    ret
endp AppleHandler

start:
    mov ax, @data
    mov ds, ax

    mov ax,VIDMEM
    mov es,ax

    call clear ; clear screen

    push offset snake
    call drawbody ; draw snake
    pop dx
    push offset snake
    call apple  ; place apple
    pop dx
    mov [key],'d'
    jmp main
win:
    call clear
main:
    mov [lengthen],0
    push offset snake
    call collideSelf
    call MovementHandler ; handles borders and direction 
    pop dx
    push offset snake
    call AppleHandler ; handles apple
    pop dx
    cmp [canmove],0 ; move if movement is legal
    je main
    cmp [snakeLength],2000
    je win
    check: ; attach key to key-function
        mov al,[key]
        cmp al,'w'
        je up
        cmp al,'s'
        je down
        cmp al,'a'
        je left
        cmp al,'d'
        je right
    jmp main ; infinte loop

up:
    mov [direction],1
    push offset snake
    call deletesnake
    call swap
    call moveup
    call drawbody
    pop dx
    jmp main
down:
    mov [direction],2
    push offset snake
    call deletesnake
    call swap
    call movedown
    call drawbody
    pop dx
    jmp main
left:
    mov [direction],3
    push offset snake
    call deletesnake
    call swap
    call moveleft
    call drawbody
    pop dx
    jmp main
right:
    mov [direction],4
    push offset snake
    call deletesnake
    call swap
    call moveright
    call drawbody
    pop dx
    jmp main
exit:
    mov ax, 4c00h
    int 21h
END start