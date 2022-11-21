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
snake       dw 2000,2002,2004,0,2000 dup(?)
direction   db 4 ; 1-up 2-down 3-left 4-right
snakeLength dw 3
key         db ?
canmove     db 1
delaytime   db 2
applepos    dw ?
lengthen    db 0
insidesnake db 0
CODESEG

proc endprogram ; exits program
    mov ax, 4c00h ; exit program
    int 21h
    ret
endp endprogram

proc getinput ; retreives user input if exists and inserts into key memory
    ;; Recieves key offset as parameter
    push bp
    mov bp,sp
    push ax
    push di
    mov di,[bp+4] ; move di offset key
    xor ax,ax
    mov ah,01 ; check if there is a keystroke
    int 16h
    jz noinput ; if not return
    mov ah,0
    int 16h ; if there is a keystroke check its value and move it to key
    mov [di],al
    pop di
    pop ax
    pop bp
    ret
    noinput:
        pop di
        pop ax
        pop bp
        ret
endp getinput

proc apple ; spawns apple using random function from 0-4000
    ;; Recieves offset insidesnake, applepos 
    push bp
    mov bp,sp
    push ax
    push cx
    push dx
    push di
    push si

    push di
    mov di,[bp+10] ; move di offset insidesnake
    mov [BYTE PTR di],0
    pop di

    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    mov  ax, dx
    xor  dx, dx
    mov cx,2000
    div cx       ; divide the ticks since midnight by 2000
    add dx,dx    ; multiply the remainder by two
    mov di, dx   ;place apple in the random position
    push ax
    mov ah, 150 ; make blue and flickering
    mov al, 'u' ; make apple u letter
    mov [es:di],ax
    push si
    mov si,[bp+6] ;move offset applepos
    mov [si],di ; move the position of the apple to memory
    pop si
    pop ax

    push [bp+4] ; call applespawn function to check if apple is inside snake
    call applespawn
    pop dx

    pop si
    pop di
    pop dx
    pop cx
    pop ax
    pop bp
    ret
endp apple

proc collision ; checks if there is collision between apple and head
    ;; Recieves offset of applepos,tail and snakelength as parameters
    push bp
    mov bp,sp
    push ax
    push bx
    push si
    push di
    mov di,[bp+6] ; move di to the offset of the position of the apple
    mov ax,[di] ; mov ax applepos
    mov si,[bp+4] ; move si offset of tail
    mov di,[bp+8] ; move di offset of snakelength
    add si,[di] 
    add si,[di]
    sub si,2 ; move si the offset of head
    mov bx,[si] ; move bx head position

    cmp ax,bx ; check if apple position == head position 
    jne exit3
    push [bp+6] ; push offset applepos
    push [bp+10] ; push offset inside snake
    push [bp+8] ; push offset snakelength
    push [bp+4] ; push offset snake
    call appleeaten ; if equal call appleeaten function
    pop di
    pop di
    pop di
    pop di
    exit3:
        pop di
        pop si
        pop bx
        pop ax
        pop bp
    ret
endp collision

proc appleeaten ; lengthens snake
    ;; Recieves offset of tail, snakelength
    push bp
    mov bp,sp
    push ax
    push bx
    push dx
    push di
    push cx
    push si
    mov bx,[bp+4] ; move bx offset tail
    mov si,[bp+6] ; move offset snakelength
    add bx,[si]
    add bx,[si] ; set bx to offset new head
    mov ax,[bx-2] ; move ax former head
    mov [bx],ax ; move new head former head
    mov cx,[si]
    swapforward: ; take everything forward by one element
        mov di,[bx-4]
        mov [bx-2],di
        sub bx,2
        loop swapforward
    inc [WORD PTR si] ; increase snake length
    push [bp+8] ; push offset inside snake
    push [bp+6] ; push offset snakelength
    push [bp+10] ; push offset applepos
    push [bp+4] ; push offset snake
    call apple ; generate another apple
    pop dx
    pop dx
    pop dx
    pop dx
    mov si,[bp+8] ; move si offset insidesnake
    cmp [WORD PTR si],1
    je isin
    poplabel:
        pop si
        pop cx
        pop di
        pop dx
        pop bx
        pop ax
        pop bp
        ret
    isin:
    call apple
    cmp [WORD PTR si],1
    je isin
    mov [WORD PTR si],0
    jmp poplabel
endp appleeaten

proc delay ; makes the snake move slower 
    push cx
    mov cx,0ff1h ; number of times outer loop must run
    delayy:
    push cx
    mov cx,0 
    lopcx:
    inc cx 
    cmp cx,25   ; number of times inner loop must run
    jnz lopcx
    pop cx
    loop delayy
    pop cx 
    ret
endp delay

proc clear ; clear screen
    push bp
    mov bp,sp
    ;; clear the screen using a loop that incs di and clears [ES:DI]
    mov ax, 0
    xor di, di
    mov cx, SCREENW*SCREENH ; loop for screen width x screen height times
    rep stosw               ; mov [ES:DI], AX & inc di
    pop bp
    ret
endp clear

proc drawbody ; draw head
    ;; Recieves offset snakelength and snake as parameters
    push bp
    mov bp,sp
    push cx
    push ax
    push bx
    push di
    push si
    mov si,[bp+6] ; move si offset snakelength
    mov ax,SNAKECOLOR ; snake design
    mov bx,[bp+4] ; move bx offset snake
    add bx,[si]
    add bx,[si]
    sub bx,2 ; move bx offset head
    mov di,[bx] ; move di head position
    stosw
    pop si
    pop di
    pop bx
    pop ax
    pop cx
    pop bp
    ret
endp drawbody

proc deletesnake ; delete tail
    ;; Recieves offset snakelength, snake and lengthen as parameters
    push bp
    mov bp,sp
    push cx
    push ax
    push bx
    push di
    push si

    mov si,[bp+6] ; move si offset lengthen
    cmp [BYTE PTR si],1 ; check if need to lengthn
    je exit5 ; if true dont delete last
    mov si,[bp+8] ; move si offset snakeLength
    mov cx, [si] ; number of times to loop
    xor ax,ax ; snake design
    mov bx,[bp+4] ; move bx offset snake
    mov di,[bx]
    mov [es:di],ax
    exit5:
        pop si
        pop di
        pop bx
        pop ax
        pop cx
        pop bp
    ret
endp deletesnake

proc moveup ; move head by -160
    ;; Recieves offset of snakelength and snake as parameters
    push bp
    mov bp,sp
    push bx
    push ax
    push si

    mov si,[bp+6] ; move si offset snakelength
    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[si]
    add bx,[si]
    sub bx,2
    mov ax,[bx]
    sub ax,160 ; sub 160 head
    mov [bx],ax

    pop si
    pop ax
    pop bx
    pop bp
    ret
endp moveup

proc movedown  ; move head by 160
    ;; Recieves offset of snake and snakelength
    push bp
    mov bp,sp
    push bx
    push ax
    push si

    mov si,[bp+6] ; move si offset snakelength
    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[si]
    add bx,[si]
    sub bx,2
    
    mov ax,[bx]
    add ax,160 ; add 160 head
    mov [bx],ax

    pop si
    pop ax
    pop bx
    pop bp
    ret
endp movedown

proc moveleft  ; move head by -1
    push bp
    mov bp,sp
    push bx
    push ax
    push si

    mov si,[bp+6] ; move si offset snakelength
    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[si]
    add bx,[si]
    sub bx,2
    
    mov ax,[bx]
    sub ax,2 ; sub 2 head
    mov [bx],ax

    pop si
    pop ax
    pop bx
    pop bp
    ret
endp moveleft

proc moveright  ; move head by 1
    push bp
    mov bp,sp
    push bx
    push ax
    push si

    mov si,[bp+6] ; move si offset snakelength
    mov bx,[bp+4] ; offset snake + offset of head
    add bx,[si]
    add bx,[si]
    sub bx,2

    mov ax,[bx]
    add ax,2 ; add 2 head
    mov [bx],ax

    pop si
    pop ax
    pop bx
    pop bp
    ret
endp moveright

proc bordercontrol ; checks if the snake is colliding with border
    ;; function gets snake offset,key,snakelength as parameters
    push bp
    mov bp,sp
    push dx
    push bx
    push ax
    push si
    push di
    mov si,[bp+6] ; move si offset key
    mov di,[bp+8] ; move di offset snakelength
    xor ax,ax
    xor dx,dx
    xor bx,bx
    ;; Check key and send to matching function
    cmp [WORD PTR si],'w'
    je w
    cmp [WORD PTR si],'s'
    je s
    cmp [WORD PTR si],'d'
    je d
    cmp [WORD PTR si],'a'
    je a
    ;; Functions check if head's next movement is outside of border
    d: ; divide by 160 and check if remainder is 158 (on border)
        mov bx,[bp+4]
        add bx,[di]
        add bx,[di]
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
        add bx,[di]
        add bx,[di]
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
        add bx,[di]
        add bx,[di]
        sub bx,2
        mov bx,[bx]
        add bx,160
        cmp bx,4000
        jl approve
        jmp exitprogram
    w: ; check if point minus 160 is outside of range
        mov bx,[bp+4]
        add bx,[di]
        add bx,[di]
        sub bx,2
        mov bx,[bx]
        sub bx,160
        cmp bx,0
        jg approve
        jmp exitprogram
    approve:
        mov di,offset canmove
        mov [BYTE PTR di],1
    exit1:
        pop di
        pop si
        pop ax
        pop dx
        pop bx
        pop bp
        ret
    exitprogram:
        mov ax, 4c00h
        int 21h
endp bordercontrol

proc directioncontrol ; controls that the snake doesn't go in opposite direction illegaly
    ;; function gets snake offset,key,direction as parameters
    push bp
    mov bp,sp
    push di
    push si
    mov di,[bp+8] ; move di, offset key
    mov si,[bp+6] ; move di, offset direction
    ;; Check key and send to matching function
    cmp [BYTE PTR di],'w'
    je dirup
    cmp [BYTE PTR di],'s'
    je dirdown
    cmp [BYTE PTR di],'d'
    je dirright
    cmp [BYTE PTR di],'a'
    je dirleft
    ;; checks if current direction is opposite to new. If it is it changes the key back to previous and reverses direction
    dirup:
        cmp [BYTE PTR si], 2
        je disapprove1
        jmp approve2
        disapprove1:
            mov [BYTE PTR di],'s'
            mov [BYTE PTR si],2
            jmp exit2
    dirdown:
        cmp [BYTE PTR si], 1
        je disapprove2
        jmp approve2
        disapprove2:
            mov [BYTE PTR di],'w'
            mov [BYTE PTR si],1
            jmp exit2
    dirleft:
        cmp [BYTE PTR si], 4
        je disapprove3
        jmp approve2
        disapprove3:
            mov [BYTE PTR di],'d'
            mov [direction],4
            jmp exit2
    dirright:
        cmp [BYTE PTR si], 3
        je disapprove4
        jmp approve2
        disapprove4:
            mov [BYTE PTR di],'a'
            mov [direction],3
            jmp exit2
    approve2:
        jmp exit2
    exit2:
        pop si
        pop di
        pop bp
        ret
endp directioncontrol

proc collideSelf ; checks if snake collides with itself
    ;; Recieves offset snakelength, snake, tail
    push bp
    mov bp,sp
    push cx
    push bx
    push di
    push dx
    push si
    mov si,[bp+6] ; move si SnakeLength
    mov cx, [si]; loop snakelength times
    dec cx
    mov bx,[bp+4] ; move bx offset of head
    add bx,[si]
    add bx,[si]
    sub bx,2
    mov di,[bp+4] ; move di tail position
    mov bx,[bx] ; move bx head position
    collisionloop: ;  check if head position is equal to any body position
        cmp bx,[di] ; check if the element di points at is equal to head position
        je exitprog ; exit if equal
        add di,2 ; increase element dx points to
        loop collisionloop ; loop for snakelength - 1 times
    pop si
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

proc applespawn ; checks if apple spawned on itself
    ;; receives snakelength,snake as parameters
    push bp
    mov bp,sp
    push cx
    push bx
    push di
    push dx
    push si
    mov di,offset snakeLength
    mov si,offset applepos
    mov cx, [di]; loop snakelength times
    mov bx,[si]
    mov di,[bp+4] ; move di tail position
    applespawnloop: ;  check if apple position is equal to any body position
        cmp bx,[di] ; check if the element di points at is equal to head position
        je insidesnake2 ; exit if equal
        add di,2 ; increase element dx points to
        loop applespawnloop ; loop for snakelength - 1 times
    pop si
    pop di
    pop dx
    pop bx
    pop cx
    pop bp
    ret
    insidesnake2:
        mov si,offset insidesnake
        mov [BYTE PTR si],1
        pop di
        pop dx
        pop bx
        pop cx
        pop bp
        ret
endp applespawn

proc swap ; take every element one back
    ;; recieves offset snakelength,snake as parameters
    push bp
    mov bp,sp
    push di
    push bx
    push ax
    push di
    mov di,[bp+6] ;move di offset snakeLength
    xor ax,ax
    mov ax,[di]
    add ax,[di]
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
    pop di
    pop dx
    pop ax
    pop bx
    pop di
    pop bp
    ret
endp swap

proc MovementHandler ; Handles all movement functions
    ; recieves snake,canmove,snakelength,key as parameters
    push bp
    mov bp,sp
    push di
    mov di,[bp+8] ; move di canmove
    call delay ; calls delay
    mov [BYTE PTR di],0

    push [bp+10] ; push offset key
    call getinput ; retrieves key pressed
    pop dx

    push [bp+6] ; push offset snakelength
    push [bp+10] ; push offset key
    push [bp+4] ; pushes offset of snake
    call bordercontrol ;activates border-control
    pop dx
    pop dx
    pop dx

    push [bp+10] ; pushes offset of key
    push [bp+12] ; pushes offset of direction
    push [bp+4]
    call directioncontrol ; activates direction control and checks you aren't trying to go in opposite direction
    pop dx
    pop dx

    pop di
    pop dx
    pop bp
    ret
endp MovementHandler

proc AppleHandler ; Handles all apple functions
    ; recieves insidesnake, snakelength, applepos, snake as parameters
    push bp
    mov bp,sp
    push [bp+10] ; push offset insidesnake
    push [bp+8] ; push offset snakelength
    push [bp+6] ; push offset applepos
    push [bp+4] ; push offset snake
    call collision ; check if apple has collided with snake
    pop dx
    pop dx
    pop dx
    pop dx
    pop bp
    ret
endp AppleHandler

proc win ; if the player wins  
    call clear
    ret
endp win
start:
    mov ax, @data
    mov ds, ax

    mov ax,VIDMEM
    mov es,ax

    call clear ; clear screen
    push ax
    mov ax,SNAKECOLOR
    mov di,2000 ; place first dot
    stosw
    mov di,2002 ; place second dot
    stosw
    mov di,2004 ; place third dot
    stosw
    push offset snakelength
    push offset snake
    call drawbody ; draw snake
    pop dx
    pop dx
    ;; PUSH ALL APPLE PARAMETERS
    push offset insidesnake
    push offset snakeLength
    push offset applepos
    push offset snake
    call apple  ; place apple
    pop dx
    pop dx
    pop dx
    pop dx
    mov [key],'d' ; move starting key to d
    pop ax
    jmp main
main:
    mov [lengthen],0
    ;; PUSH ALL MOVEMENT HANDLER PARAMETERS
    push offset direction
    push offset key
    push offset canmove
    push offset snakeLength
    push offset snake
    call collideSelf
    call MovementHandler ; handles borders and direction 
    pop dx
    pop dx
    pop dx
    pop dx
    pop dx

    ;: PUSH ALL APPLEHANDLER
    push offset insidesnake
    push offset snakeLength
    push offset applepos
    push offset snake
    call AppleHandler ; handles apple
    pop dx
    pop dx
    pop dx
    pop dx

    cmp [canmove],0 ; move if movement is legal
    je main
    cmp [snakeLength],2000
    jne check
    won:
        call win
    check: ; attach key to key-function
        mov al,[key]
        cmp al,'w'
        je up
        cmp al,'s'
        je down
        cmp al,'a'
        je left
        cmp al,'d'
        je middle
    jmp main ; infinte loop

up:
    ; change direction to up, push offset of snake as a parameter and call moving functions
    mov [direction],1
    push offset lengthen
    push offset snakeLength
    push offset snake
    call deletesnake
    call swap
    call moveup
    call drawbody
    pop dx
    pop dx
    pop dx
    jmp main
down:
    ; change direction to up, push offset of snake as a parameter and call moving functions
    mov [direction],2
    push offset lengthen
    push offset snakeLength
    push offset snake
    call deletesnake
    call swap
    call movedown
    call drawbody
    pop dx
    pop dx
    pop dx
    jmp main
middle:
    jmp right
left:
    ; change direction to up, push offset of snake as a parameter and call moving functions
    mov [direction],3
    push offset lengthen
    push offset snakeLength
    push offset snake
    call deletesnake
    call swap
    call moveleft
    call drawbody
    pop dx
    pop dx
    pop dx
    jmp main
right:
    ; change direction to up, push offset of snake as a parameter and call moving functions
    mov [direction],4
    push offset lengthen
    push offset snakeLength
    push offset snake
    call deletesnake
    call swap
    call moveright
    call drawbody
    pop dx
    pop dx
    pop dx
    jmp main
exit: ; exit the function
    mov ax, 4c00h
    int 21h
END start