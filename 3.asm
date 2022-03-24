;@auther:Fun_Melon
;@2022/3/24
data    segment
    INNAME  db  "Please input name(< 21): ",'$'
    INNUM   db  "Please input telephone number(< 21): ",'$'
    ISCONT  db  "Do you want to search a telephone number?(Y/N)",'$'
    SEARCH  db  "name?: ",'$'
    NOTFIND db  "Not found",0ah,'$'
    STORPEO db  "How many people it is: ",'$'
    CRLF    db  0ah,'$';���е������Ϣ��ʾ

    bufferName      label  byte
    maxLenName      db     21
    actLenName      db     ?
    bufferNameData  db     21 dup(0);name�Ļ�����

    bufferNum       label  word
    maxLenNum       db     9
    actLenNum       db     ?
    bufferNumData   db     9 dup(0);num�Ļ�����

    numtable  db     50 dup(28 dup(0));num�Ĵ洢��
    nameCount dw     0                ;��ǰ�����˼�����
    endaddr   dw     ?                ;β��ַ
    tempend   dw     ?                ;�ݴ�β��ַ
    ;swapped   dw     ?                ;�ж��Ƿ���н����Ĳ�������
    peopleNum dw     ?                ;������
    savenp    db     28 dup(0),0dh,0ah,'$';�ݴ���
    searchaddr dw    ?                ;��Ѱ��ַ
    ;flag      db     ?
    ;flagb     db     ?
    show      db     'name                phone',0dh,0ah,'$'
    data  ends
code    segment
assume  cs:code,ds:data,es:data
start:
        mov ax,data
        mov ds,ax
        mov es,ax           ;װ��ds,es
        lea di,numtable     ;�洢���ݵ�λ��
        lea dx,STORPEO
        mov ah,09h
        int 21h             ;ѯ�ʼ�����
        mov bx,0
conTreadPeo:;newchar
        mov ah,1
        int 21h
        sub al,30h
        jl  stockPeoNum
        cmp al,9
        ja  stockPeoNum
        cbw
        xchg ax,bx
        mov cx,10
        mul cx
        xchg ax,bx
        add bx,ax
        jmp conTreadPeo
stockPeoNum:;next 
        mov peopleNum,bx     ;�Ӽ��̽���peopleNum
        call PRINTCRLF
conInput:;a10
        call PRINTINNAME
        call inputName
        inc nameCount
        call stockName
        call PRINTINNUM
        call inputPhoneNum
        call stockPhoneNum
        cmp nameCount,0
        je exit
        mov bx,peopleNum
        cmp nameCount,bx
        jne conInput        ;����peopleNum���ζ�ȡ��Ϣ
        call nameSort
controlModel:;a20    
        call PRINTISCON
        mov ah,08
        int 21h
        cmp al,'y'
        jz  searchName
        cmp al,'Y'
        jz  searchName
        cmp al,'n'
        jz  exit
        cmp al,'N'
        jz  exit
        jmp controlModel    ;�ڿ��ƽ���ת��
searchName:;a30
        call PRINTCRLF
        call PRINTSEARCH
        call inputName      ;��ȡ������������
searchModel:;a40
        call nameSearch
        jmp controlModel    ;���в���
exit:   
        call PRINTALL
        mov ax,4c00h        ;��ֹ����
        int 21h

PRINT:
        mov ah,09h
        int 21h
        ret

PRINTINNAME:
        lea dx,INNAME
        call PRINT
        ret

PRINTINNUM:
        lea dx,INNUM
        call PRINT
        ret

PRINTCRLF:
        lea dx,CRLF
        call PRINT
        ret
PRINTISCON:
        lea dx,ISCONT
        call PRINT
        ret
PRINTSEARCH:
        lea dx,SEARCH
        call PRINT
        ret
PRINTNOTFIND:
        lea dx,NOTFIND
        call PRINT
        ret
inputName:                  ;��ȡ���������ݴ��ڻ�����
        mov ah,0ah
        lea dx,bufferName
        int 21h
        call PRINTCRLF
        sub bh,bh
        mov bl,actLenName
        mov cx,21
        sub cx,bx
noEndofName:;b10           ;"�޲�"����
        mov bufferNameData[bx],' '
        inc bx
        loop noEndofName
        ret

inputPhoneNum:             ;��ȡ���룬���ݴ��ڻ�����
        mov ah,0ah
        lea dx,bufferNum
        int 21h
        call PRINTCRLF
        sub bh,bh
        mov bl,actLenNum
        mov cx,9
        sub cx,bx
noEndofNum:;c10            ;"�޲�"����
        mov bufferNumData[bx],' '
        inc bx
        loop noEndofNum
        ret

stockName:                  ;�������
        lea si,bufferNameData
        mov cx,20
        rep movsb
        ret

stockPhoneNum:              ;��ź��룬����һ��ռ28byte
        lea si,bufferNumData
        mov cx,8
        rep movsb
        ret
nameSort:                   ;��������
        sub di,28
        mov endaddr,di;������ֹ��ַ,�����ָ�si
        mov tempend,di
c1:
        ;mov swapped,0
        lea si,numtable;�ص���������
c2:     
        mov cx,20
        mov di,si
        add di,28;��si��di��si+28���ֱ�ָ���ڽӵ���������
        mov ax,di
        mov bx,si;�ݴ�di��si
        repz cmpsb;�Ƚ�����������ZF=0����CX=0
        jbe c3;ZF=1��С�ڵ�����ת��(��ʱ����Ҫ����)
        ;ja c3

        mov si,bx;�ָ�si
        lea di,savenp;��di��ָ���ݴ���
        mov cx,28
        rep movsb;��si��ת�Ƶ��ݴ���
        mov cx,28
        mov di,bx;
        rep movsb;��(si+28)�޸�(si)
        mov cx,28
        lea si,savenp
        rep movsb;ת�ƼĴ�������si+28��
        ;mov swapped,1
c3:                     ;�ַ�����ͬ
        mov si,ax;�ָ�si

        ;add si,28;;;;
        cmp si,tempend;�ж��Ƿ��һ�ֽ���
        jb  c2;û�н���si��������
        mov bx,tempend
        sub bx,28
        mov tempend,bx;�Ѿ��ȵ�ĩβ��ĩβ��һ
        lea ax,numtable
        cmp bx,ax;�ڵ�һ���Ѿ�������������ж��Ƿ�ȫ������
        je  finish;ȫ��������
        jmp c1

        ;cmp si,endaddr
        ;jb  c2
        ;cmp swapped,0
        ;jne c1          ;�Ѿ������˽���
finish: ret

nameSearch:
        lea bx,numtable
        ;mov flag,0
searchProcess:      
        mov cx,20
        lea si,bufferNameData
        mov di,bx
        repz cmpsb;�Ƚϻ��������ڴ��������
        je  found;�ҵ��ˣ�
        add bx,28;û�ҵ�,�Ǿͼ���
        cmp bx,endaddr;�ж��Ƿ������
        jbe searchProcess;û���꣬�Ǿͼ���
        ;cmp flag,0
        ;jz nof;�����˶���û�ҵ�
        ;jmp dexit
nof:    
        call PRINTNOTFIND
        jmp dexit
found:     
        mov searchaddr,bx;�ҵ���ǰ����λ��
        ;inc flag
        call printLine
        ;add bx,28
        ;cmp bx,endaddr;�ж��Ƿ������
        ;jbe d
        ;jmp dexit

        ;jnz d
dexit:  
        ret
printLine:
        ;cmp flag,0;û�ҵ�
        ;jz no
;p10:    
        mov ah,09h
        lea dx,show
        int 21h
        mov cx,28
        mov si,searchaddr
        lea di,savenp
        rep movsb
        lea dx,savenp
        mov ah,09h;�ڻ�������ʾ���
        int 21h
        jmp fexit
;no:     
        call PRINTNOTFIND
fexit:  
        ret
PRINTALL:
        call PRINTCRLF
        lea di,savenp
        lea si,numtable
        mov bx,peopleNum
line:   
        mov cx,28
        rep movsb
        inc di
        ;mov es:[di],'$'
        lea dx,savenp
        mov ah,09h
        int 21h
        sub bx,1
        lea di,savenp
        jnz line
        ;lea dx,numtable
        ;mov ah,09h
        ;int 21h
        ret

code ends
end start