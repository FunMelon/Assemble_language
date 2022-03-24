;@auther:Fun_Melon
;@2022/3/24
data    segment
    INKEY           db  "Enter keyword(< 40): ",'$'
    INSENSTENCE     db  "Enter sentence(< 40): ",'$'
    FAIL            db  "No match.",'$'
    SUCCESS         db  "Match at the location: ",'$'
    SUCCESS2        db  " H of the sentence.",'$'
    CRLF            db  0ah,'$';存储提示信息

    KEYBUF          db  40
                    db  ?
                    db  40  dup(0);key缓冲区
    SENTENCEBUF     db  40
                    db  ?
                    db  40  dup(0);sentence缓冲区
data    ends

code    segment
assume  cs:code,ds:data;,ss:stack
start:  
        mov ax,data         
        mov ds,ax           
        call    readKey
        call    PRINTCRLF
sb:     call    readSentence
        call    PRINTCRLF
        call    CMPKS
        call    PRINTCRLF
        jmp     sb
        mov ax,4c00h
        int 21h

readKey:;读取key
        lea dx,INKEY        
        mov ah,09h          
        int 21h
        lea dx,KEYBUF
        mov ah,0ah
        int 21h
        ret

readSentence:;读取sentence
        lea dx,INSENSTENCE      
        mov ah,09h          
        int 21h
        lea dx,SENTENCEBUF
        mov ah,0ah
        int 21h
        ret

CMPKS:;将key和sentence进行比较
        mov bx,offset KEYBUF+2
        mov si,offset SENTENCEBUF+2
        mov ax,offset SENTENCEBUF+1;[si-1]
        sub al,offset KEYBUF+1;[bx-1];获取长度之差
        jb  cmpFail
        mov cx,ax

s:      mov al,[bx]
        cmp al,[si]                 ;比较字符串是否相等
        jne noEqual
Equal:  
        inc bx                      ;相等,判断是否比较完成
        inc si
        mov ax,bx
        sub ax,offset KEYBUF+2

        cmp al,KEYBUF+1
        jne noEnd
        call PRINTSUCCESS
        ret
noEnd:  loop s
        jmp cmpFail

noEqual:
        mov ax,bx
        mov bx,offset KEYBUF+2      ;不相等
        sub ax,bx
        sub si,ax
        inc si

        loop s
        jmp cmpFail

cmpFail:;比较失败
        call PRINTFAIL
        ret

PRINTCRLF:;打印换行
        lea dx,CRLF
        mov ah,09h
        int 21h
        ret

PRINTFAIL:;比较出错，打印失败提示
        lea dx,FAIL
        mov ah,09h
        int 21h
        ret

PRINTSUCCESS:;比较成功，打印成功信息
        lea dx,SUCCESS
        mov ah,09h
        int 21h

        mov ax,si
        sub ax,offset SENTENCEBUF+2
        sub al,KEYBUF+1
        add ax,1;al里面存储着匹配位置

        mov bx,16
        mov cx,0
        mov dx,0
noZero: div bx
        push dx;dx存余
        inc cx
        cwd
        cmp ax,0;ax存商
        jne noZero
noEmpty:pop dx
        cmp dl,9
        jna isNum
        add dl,7
isNum:  add dl,30h
        mov ah,02h
        int 21h
        loop noEmpty

        lea dx,SUCCESS2
        mov ah,09h
        int 21h
        ret
code    ends
end     start