IDEAL
MODEL small
STACK 100h
DATASEG
BorderCheck db 0
stars dw 2000,2002,2004,2006,2008
len_times_two dw $ -stars
dirleft db 0
dirright db 0
dirup db 0
dirdown db 0
applepos dw 2100
delaytime db 5
CODESEG
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

proc apple
    push bp
    mov bp,sp
    push ax
    push cx
    push dx
    push di

    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    mov  ax, dx
    xor  dx, dx
    mov cx,2000
    div cx
    add dx,dx
    mov di, dx
    push ax
    mov ah, 150											;making the dot's background red and flickering
    mov al, 'u'
    mov [es:di],ax
    mov [applepos],di
    pop ax

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
    mov si,offset stars
    mov bx,[si+len_times_two-3]

    cmp ax,bx
    jne endcol
    call appleeaten
    endcol:
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
    mov ax,[si+len_times_two-3]
    add ax,2
    add [len_times_two],2
    mov [si+len_times_two-2], 3000
    pop ax
    pop bp
    ret
endp appleeaten

proc resetdir
    push bp
    mov bp,sp
    mov [dirleft],0
    mov [dirright],0
    mov [dirup],0
    mov [dirdown],0
    pop bp
    ret
endp resetdir

proc callupfuncs1
    push bp
    mov bp,sp

    push bx
    push [bx+len_times_two-3]
    call borderup
    pop bx
    pop bx

    pop bp
    ret
endp callupfuncs1

proc calldownfuncs1
    push bp
    mov bp,sp

    push bx
    push [bx+len_times_two-3]
    call borderdown
    pop bx
    pop bx

    pop bp
    ret
endp calldownfuncs1

proc callleftfuncs1
    push bp
    mov bp,sp

    push bx
    push [bx+len_times_two-3]
    call borderleft
    pop bx
    pop bx

    pop bp
    ret
endp callleftfuncs1

proc callrightfuncs1
    push bp
    mov bp,sp

    push bx
    push [bx+len_times_two-3]
    call borderright
    pop bx
    pop bx

    pop bp
    ret
endp callrightfuncs1

proc borderup
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    sub di,160
    cmp di,0
    jle borderlabel
    pop di
    pop bp
    ret
    borderlabel:
        call borderset
        pop di
        pop bp
        ret
endp borderup

proc borderdown
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    add di,160
    sub di,4000
    cmp di,0
    jge borderlabel2
    pop di
    pop bp
    ret
    borderlabel2:
        call borderset
        pop di
        pop bp
        ret
endp borderdown

proc borderleft
    push bp
    mov bp,sp
    push ax
    push cx
    xor cx,cx
    xor ax,ax
    mov cl,160
    mov ax,[bp+4]
    div cl
    cmp ah, 0
    je borderlabel3
    pop cx
    pop ax
    pop bp
    ret
    borderlabel3:
        call borderset
        pop cx
        pop ax
        pop bp
        ret
endp borderleft

proc borderright
    push bp
    mov bp,sp
    push ax
    push bx
    xor bx,bx
    xor ax,ax
    mov cl,160
    mov ax,[bp+4]
    div cl
    cmp ah, 158
    je borderlabel4
    pop cx
    pop ax
    pop bp
    ret
    borderlabel4:
        call borderset
        pop cx
        pop ax
        pop bp
        ret
endp borderright

proc borderset
    push bp
    mov bp,sp
    mov [BorderCheck],1
    pop bp
    ret
endp borderset

proc shortnerw
    push bp
    mov bp,sp
    push ax
    xor ax,ax
    push bx
    mov bx,[bp+4]
    push [bx+len_times_two-3]
    call w
    push di
    mov di,ax
    ; delete last func
    push bx
    mov bx,[bp+4]
    push bx
    call delete_last
    pop bx
    ; params for switch func
    push bx
    mov bx,[bp+4]
    push bx
    call switch
    pop bx
    ;end of switch func
    mov [bx+len_times_two-3],ax
    mov ah, 200
	mov al, '*'
    mov [es:di], ax
    pop di
    pop bx
    pop bx
    pop ax
    pop bp
    ret
endp shortnerw

proc shortners
    push bp
    mov bp,sp
    push ax
    xor ax,ax
    push bx
    mov bx,[bp+4]
    push [bx+len_times_two-3]
    call s
    push di
    mov di,ax
    ; delete last func
    push bx
    mov bx,[bp+4]
    push bx
    call delete_last
    pop bx
    ; params for switch func
    push bx
    mov bx,[bp+4]
    push bx
    call switch
    pop bx
    ;end of switch func
    mov [bx+len_times_two-3],ax
    mov ah, 200
	mov al, '*'
    mov [es:di], ax
    pop di
    pop bx
    pop bx
    pop ax
    pop bp
    ret
endp shortners

proc shortnera
    push bp
    mov bp,sp
    push ax
    xor ax,ax
    push bx
    mov bx,[bp+4]
    push [bx+len_times_two-3]
    call a
    push di
    mov di,ax
    ; delete last func
    push bx
    mov bx,[bp+4]
    push bx
    call delete_last
    pop bx
    ; params for switch func
    push bx
    mov bx,[bp+4]
    push bx
    call switch
    pop bx
    ;end of switch func
    mov [bx+len_times_two-3],ax
    mov ah, 200
	mov al, '*'
    mov [es:di], ax
    pop di
    pop bx
    pop bx
    pop ax
    pop bp
    ret
endp shortnera

proc shortnerd
    push bp
    mov bp,sp
    push ax
    xor ax,ax
    push bx
    mov bx,[bp+4]
    push [bx+len_times_two-3]
    call d
    push di
    mov di,ax
    ; delete last func
    push bx
    mov bx,[bp+4]
    push bx
    call delete_last
    pop bx
    ; params for switch func
    push bx
    mov bx,[bp+4]
    push bx
    call switch
    pop bx
    ;end of switch func
    mov [bx+len_times_two-3],ax
    mov ah, 200
	mov al, '*'
    mov [es:di], ax
    pop di
    pop bx
    pop bx
    pop ax
    pop bp
    ret
endp shortnerd

proc delete_last
    push bp
    mov bp,sp
    push bx
    push di
    push ax
    xor ax,ax
    mov di,[bp+4]
    mov bx,[di]
    mov [es:bx],ax
    pop ax
    pop di
    pop bx
    pop bp
    ret 2
endp delete_last

proc switch
    push bp
    mov bp,sp
    push di
    push bx
    push ax
    xor ax,ax
    mov ax,[len_times_two]
    mov bx,[bp+4]
    push dx
    xor dx,dx
    mov dx,bx
    add dx,ax
    switchloop:
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
    ret 2
endp switch

proc w
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    sub di,160
    mov ax,di
    pop di
    pop bp
    ret
endp w

proc s
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    add di,160
    mov ax,di
    pop di
    pop bp
    ret
endp s

proc a
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    sub di,2
    mov ax,di
    pop di
    pop bp
    ret
endp a

proc d
    push bp
    mov bp,sp
    push di
    mov di,[bp+4]
    add di,2
    mov ax,di
    pop di
    pop bp
    ret
endp d

proc createstars
    push bp
    mov bp,sp
    push dx
    push ax
    mov ah, 200
	mov al, '*'
    push bx
    xor dx,dx
    xor bx,bx
    mov dx,[len_times_two]
    mov bx,4
    add dl,2
    place:
        push bx
        push bp
        add bp,bx
        mov di,[bp]
        pop bp
        mov [es:di],ax
        pop bx
        cmp bx,dx
        jne inclabel
    pop bx
    pop ax
    pop dx
    pop bp
    ret
    inclabel:
        add bx,2
        jmp place
endp createstars

proc clear
    push bp
    mov bp,sp
    push di
    xor di,di
    push ax
    xor ax,ax
    clearscreen:
        mov [es:di],ax
        add di,2
        cmp di,4000
        jne clearscreen
    pop ax
    pop di
    pop bp
    ret
endp clear

start:
	mov ax, @data
	mov ds, ax

    mov ax, 0b800h
	mov es, ax

call clear
jmp createbeg
createbeg:
    ; push params
    push bx
    mov bx, offset stars
    push ax
    mov ax,[len_times_two]
    push cx
    xor cx,cx
    mov cx,-4
    append:
        push [bx]
        add cx,2
        add bl,2
        cmp cl,al
        jne append
    pop cx
    pop ax
    call createstars
    pop bx
    pop bx
    pop bx
    xor bx,bx
    call apple
    jmp mainloop
left:
    push bx
    mov bx,offset stars
    push bx
    call callleftfuncs1
    pop bx
    mov bl, [BorderCheck]
    cmp bl,1
    je mainloop

    cmp [dirright],1
    je mainloop
    call resetdir
    mov [dirleft],1

    push bx
    mov bx,offset stars
    push bx
    call shortnera
    pop bx
    jmp mainloop

right:
    push bx
    mov bx,offset stars
    push bx
    call callrightfuncs1
    pop bx
    mov bl, [BorderCheck]
    cmp bl,1
    je mainloop

    cmp [dirleft],1
    je mainloop
    call resetdir
    mov [dirright],1

    push bx
    mov bx,offset stars
    push bx
    call shortnerd
    pop bx
    jmp mainloop

mainloop:
    call collision
    mov [BorderCheck],0
    mov ah, 1
	int 16h
	mov ah,0
	int 16h
    cmp al,'w'
    je up
    cmp al,'s'
    je down
    cmp al,'a'
    je left
    cmp al,'d'
    je right
    jmp mainloop
up:
    call callupfuncs1
    mov bl, [BorderCheck]
    cmp bl,1
    je mainloop

    cmp [dirdown],1
    je mainloop
    call resetdir
    mov [dirup],1
    
    mov bx,offset stars
    push bx
    call shortnerw
    pop bx
    jmp mainloop

down:
    call calldownfuncs1
    mov bl, [BorderCheck]
    cmp bl,1
    je mainloop

    cmp [dirup],1
    je mainloop
    call resetdir
    mov [dirdown],1

    push bx
    mov bx,offset stars
    push bx
    call shortners
    pop bx
    jmp mainloop


exit:
		mov ax, 4c00h
		int 21h
END start