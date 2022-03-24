;@auther:Fun_Melon
;@2022/3/24
data    segment
    INKEY           db  "Enter keyword(< 40): ",'$'
    INSENSTENCE     db  "Enter sentence(< 40): ",'$'
    FAIL            db  "No match.",'$'
    SUCCESS         db  "Match at the location: ",'$'
    SUCCESS2        db  " H of the sentence.",'$'
    CRLF            db  0ah,'$';�洢��ʾ��Ϣ

    KEYBUF          db  40
                    db  ?
                    db  40  dup(0);key������
    SENTENCEBUF     db  40
                    db  ?
                    db  40  dup(0);sentence������
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

readKey:;��ȡkey
        lea dx,INKEY        
        mov ah,09h          
        int 21h
        lea dx,KEYBUF
        mov ah,0ah
        int 21h
        ret

readSentence:;��ȡsentence
        lea dx,INSENSTENCE      
        mov ah,09h          
        int 21h
        lea dx,SENTENCEBUF
        mov ah,0ah
        int 21h
        ret

CMPKS:;��key��sentence���бȽ�
        mov bx,offset KEYBUF+2
        mov si,offset SENTENCEBUF+2
        mov ax,offset SENTENCEBUF+1;[si-1]
        sub al,offset KEYBUF+1;[bx-1];��ȡ����֮��
        jb  cmpFail
        mov cx,ax

s:      mov al,[bx]
        cmp al,[si]                 ;�Ƚ��ַ����Ƿ����
        jne noEqual
Equal:  
        inc bx                      ;���,�ж��Ƿ�Ƚ����
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
        mov bx,offset KEYBUF+2      ;�����
        sub ax,bx
        sub si,ax
        inc si

        loop s
        jmp cmpFail

cmpFail:;�Ƚ�ʧ��
        call PRINTFAIL
        ret

PRINTCRLF:;��ӡ����
        lea dx,CRLF
        mov ah,09h
        int 21h
        ret

PRINTFAIL:;�Ƚϳ�����ӡʧ����ʾ
        lea dx,FAIL
        mov ah,09h
        int 21h
        ret

PRINTSUCCESS:;�Ƚϳɹ�����ӡ�ɹ���Ϣ
        lea dx,SUCCESS
        mov ah,09h
        int 21h

        mov ax,si
        sub ax,offset SENTENCEBUF+2
        sub al,KEYBUF+1
        add ax,1;al����洢��ƥ��λ��

        mov bx,16
        mov cx,0
        mov dx,0
noZero: div bx
        push dx;dx����
        inc cx
        cwd
        cmp ax,0;ax����
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