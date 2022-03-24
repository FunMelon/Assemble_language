;@auther:Fun_Melon
;@2022/3/24
data segment
    INPUT   db  "Please input a piece of string(< 80): ",'$'
    ITEMCH  db  "char",'$'
    ITEMNUM db  "num",'$';��ʾ�ַ�
    BUFFER  db  80
            db  ?;�洢���ӻ�����
            db  80  dup(0)
    STOCK   db  128 dup(0);ͳ������
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
readInput:;��ȡ����
        lea dx,INPUT      
        mov ah,09h          
        int 21h
        lea dx,BUFFER
        mov ah,0ah
        int 21h
        ret

stockChar:;�洢�ַ�����ӦASCII���ŵ�����ȥ
        mov bx,offset BUFFER+2
        mov si,offset STOCK+2
        mov cl,[bx-1]
        mov ch,0;��ȡѭ������

charNoEnd:      
        mov al,[bx] ;��ȡbx��ASCII��Ĵ�С
        mov ah,0    
        add si,ax   ;�ݴ��ҵ���Ӧ�Ĵ洢��ַ
        mov al,[si]
        add al,1    ;�洢����Ŀ��һ
        mov [si],al
        mov si,offset STOCK+2;�ص�Ĭ��
        inc bx
        loop charNoEnd
        ret

PRINTCRLF:;��ӡ����
        lea dx,CRLF
        mov ah,09h
        int 21h
        ret

PRINTSPACE:;��ӡ�ո�
        push cx
        mov cx,12
        mov dl,32
        mov ah,02h
s:      int 21h
        loop s
        pop cx
        ret

printResult:;��ӡ���
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
        mov al,[bx+si];��ȡ�洢����Ŀ
        cmp al,0
        je  isZero

        cmp si,35
        je  isZero
        call PRINTSPACE
        mov dx,si
        mov ah,02h
        int 21h;��ʾ�ַ�
        call PRINTSPACE
        mov dl,[bx+si];��ʾ����
        call printNuminDl
        call PRINTCRLF
isZero:        
        inc si
        loop stockNoEnd
        ret

printNuminDl:;��ʮ���Ƶ���ʽ
        push bx
        push ax
        push cx
        
        mov al,dl
        sub ah,ah
        mov bx,10
        mov cx,0
        mov dx,0
noZero: div bx
        push dx;dx����
        inc cx
        cwd
        cmp ax,0;ax����
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