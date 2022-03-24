;@auther:Fun_Melon
;@2022/3/24
data segment
    INPUT   db  "Please input a piece of string(< 80): ",'$'
    ITEMCH  db  "char",'$'
    ITEMNUM db  "num",'$';提示字符
    BUFFER  db  80
            db  ?;存储句子缓冲区
            db  80  dup(0)
    STOCK   db  128 dup(0);统计数组
    CRLF    db  0ah,'$'
data ends

code    segment
assume  cs:code,ds:data
start:
        mov ax,data
        mov ds,ax
        call readInput
        call PRINTCRLF
        call stockChar
        call printResult
        mov ax,4c00h
        int 21h
readInput:;读取输入
        lea dx,INPUT      
        mov ah,09h          
        int 21h
        lea dx,BUFFER
        mov ah,0ah
        int 21h
        ret

stockChar:;存储字符到对应ASCII码标号的数组去
        mov bx,offset BUFFER+2
        mov si,offset STOCK+2
        mov cl,[bx-1]
        mov ch,0;获取循环次数

charNoEnd:      
        mov al,[bx] ;获取bx的ASCII码的大小
        mov ah,0    
        add si,ax   ;据此找到对应的存储地址
        mov al,[si]
        add al,1    ;存储的数目加一
        mov [si],al
        mov si,offset STOCK+2;回到默认
        inc bx
        loop charNoEnd
        ret

PRINTCRLF:;打印换行
        lea dx,CRLF
        mov ah,09h
        int 21h
        ret

PRINTSPACE:;打印空格
        push cx
        mov cx,12
        mov dl,32
        mov ah,02h
s:      int 21h
        loop s
        pop cx
        ret

printResult:;打印结果
        call PRINTSPACE
        lea dx,ITEMCH
        mov ah,09h
        int 21h
        call PRINTSPACE
        lea dx,ITEMNUM
        mov ah,09h
        int 21h
        call PRINTCRLF
        mov bx,offset STOCK+2
        mov si,0
        mov cx,124
stockNoEnd:
        mov al,[bx+si];获取存储的数目
        cmp al,0
        je  isZero

        cmp si,35
        je  isZero
        call PRINTSPACE
        mov dx,si
        mov ah,02h
        int 21h;显示字符
        call PRINTSPACE
        mov dl,[bx+si];显示数字
        call printNuminDl
        call PRINTCRLF
isZero:        
        inc si
        loop stockNoEnd
        ret

printNuminDl:;以十进制的形式
        push bx
        push ax
        push cx
        
        mov al,dl
        sub ah,ah
        mov bx,10
        mov cx,0
        mov dx,0
noZero: div bx
        push dx;dx存余
        inc cx
        cwd
        cmp ax,0;ax存商
        jne noZero
noEmpty:pop dx
        add dl,30h
        mov ah,02h
        int 21h
        loop noEmpty

        pop cx
        pop ax
        pop bx
        ret

code    ends
end     start