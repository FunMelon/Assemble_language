;@auther:Fun_Melon
;@2022/3/24
data segment
    INPUT   db  "Please input n(n must > 0 and < 100): ",'$'
    OUTPUT  db  "F(n) = ",'$';提示信息
    num     dw  ?;待检查书
    DATAA   db  21 dup(0),1
    DATAB   db  21 dup(0),1;伪操作域
    endaddr dw  ?;末尾的地址
    TEMP    db  22 dup(0);另一个伪操作域
    CRLF    db  0ah,'$'
data ends

code segment
assume cs:code,ds:data
start:  
        mov ax,data
        mov ds,ax
        mov es,ax
        call PRINTINPUT

        mov bx,0
constReadNum:
        mov ah,1
        int 21h
        sub al,30h
        jl  stockNum
        cmp al,9
        ja  stockNum
        cbw
        xchg ax,bx
        mov cx,10
        mul cx
        xchg ax,bx
        add bx,ax
        jmp constReadNum
stockNum:
        mov cx,bx;读取数字存到cx里面
        dec cx 
        cmp cx,0
        jbe show
        cmp cx,99
        ja exit;不处理小于0大于99的情况
time:   call movOnce
        loop time       
show:   call PRINTSULT
        call PRINTDATAA
exit:   mov ax,4c00h
        int 21h
movOnce: ;进行一次移位操作
        push cx
        lea si,DATAA
        lea di,TEMP
        mov cx,22
        rep movsb   ;A->TEMP
        lea si,DATAB
        lea di,DATAA
        mov cx,22
        rep movsb   ;B->A
        lea si,DATAB
        add si,21
        lea di,TEMP
        add di,21   ;从末尾开始
        mov cx,21
        mov ah,0
noFinish:
        mov al,[si]
        add al,[di]
        add al,ah
        mov ah,0
        cmp al,10
        jb  noCarry
        sub al,10
        mov ah,1
noCarry:
        mov [si],al
        dec si
        dec di
        loop noFinish;B=B+TEMP
        pop cx
        ret
PRINTDATAA:
        lea si,DATAA
        mov endaddr,si
        add endaddr,22;;;;;;;;
        sub si,1
isZero: 
        inc si
        mov al,[si]
        cmp al,0
        je isZero;从第一个非0位显示
        sub endaddr,si;;;
        push cx
        mov cx,endaddr
noEnd:  
        mov dl,[si]
        add dl,30h
        mov ah,02h
        int 21h
        inc si
        loop noEnd
        pop cx
        ret
PRINTCRLF:
        lea dx,CRLF
        mov ah,09h
        int 21h
        ret

PRINTINPUT:
        lea dx,INPUT
        mov ah,09h
        int 21h
        ret

PRINTSULT:
        lea dx,OUTPUT
        mov ah,09h
        int 21h
        ret
code ends
end start