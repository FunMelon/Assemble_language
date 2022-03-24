;@auther:Fun_Melon
;@2022/3/24
data    segment
    INNAME  db  "Please input name(< 21): ",'$'
    INNUM   db  "Please input telephone number(< 21): ",'$'
    ISCONT  db  "Do you want to search a telephone number?(Y/N)",'$'
    SEARCH  db  "name?: ",'$'
    NOTFIND db  "Not found",0ah,'$'
    STORPEO db  "How many people it is: ",'$'
    CRLF    db  0ah,'$';所有的输出信息显示

    bufferName      label  byte
    maxLenName      db     21
    actLenName      db     ?
    bufferNameData  db     21 dup(0);name的缓存区

    bufferNum       label  word
    maxLenNum       db     9
    actLenNum       db     ?
    bufferNumData   db     9 dup(0);num的缓存区

    numtable  db     50 dup(28 dup(0));num的存储域
    nameCount dw     0                ;当前输入了几个人
    endaddr   dw     ?                ;尾地址
    tempend   dw     ?                ;暂存尾地址
    ;swapped   dw     ?                ;判断是否进行交换的布尔变量
    peopleNum dw     ?                ;总人数
    savenp    db     28 dup(0),0dh,0ah,'$';暂存器
    searchaddr dw    ?                ;搜寻地址
    ;flag      db     ?
    ;flagb     db     ?
    show      db     'name                phone',0dh,0ah,'$'
    data  ends
code    segment
assume  cs:code,ds:data,es:data
start:
        mov ax,data
        mov ds,ax
        mov es,ax           ;装载ds,es
        lea di,numtable     ;存储数据的位置
        lea dx,STORPEO
        mov ah,09h
        int 21h             ;询问几个人
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
        mov peopleNum,bx     ;从键盘接受peopleNum
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
        jne conInput        ;根据peopleNum依次读取信息
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
        jmp controlModel    ;在控制界面转悠
searchName:;a30
        call PRINTCRLF
        call PRINTSEARCH
        call inputName      ;读取待搜索的姓名
searchModel:;a40
        call nameSearch
        jmp controlModel    ;进行查找
exit:   
        call PRINTALL
        mov ax,4c00h        ;终止程序
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
inputName:                  ;读取姓名，并暂存在缓冲区
        mov ah,0ah
        lea dx,bufferName
        int 21h
        call PRINTCRLF
        sub bh,bh
        mov bl,actLenName
        mov cx,21
        sub cx,bx
noEndofName:;b10           ;"修补"名字
        mov bufferNameData[bx],' '
        inc bx
        loop noEndofName
        ret

inputPhoneNum:             ;读取号码，并暂存在缓冲区
        mov ah,0ah
        lea dx,bufferNum
        int 21h
        call PRINTCRLF
        sub bh,bh
        mov bl,actLenNum
        mov cx,9
        sub cx,bx
noEndofNum:;c10            ;"修补"号码
        mov bufferNumData[bx],' '
        inc bx
        loop noEndofNum
        ret

stockName:                  ;存放名字
        lea si,bufferNameData
        mov cx,20
        rep movsb
        ret

stockPhoneNum:              ;存放号码，二者一共占28byte
        lea si,bufferNumData
        mov cx,8
        rep movsb
        ret
nameSort:                   ;起泡排序
        sub di,28
        mov endaddr,di;设置终止地址,用来恢复si
        mov tempend,di
c1:
        ;mov swapped,0
        lea si,numtable;回到最初的起点
c2:     
        mov cx,20
        mov di,si
        add di,28;用si和di（si+28）分别指向邻接的两个名字
        mov ax,di
        mov bx,si;暂存di和si
        repz cmpsb;比较跳出的条件ZF=0或者CX=0
        jbe c3;ZF=1，小于等于则转移(此时不需要交换)
        ;ja c3

        mov si,bx;恢复si
        lea di,savenp;用di来指向暂存器
        mov cx,28
        rep movsb;（si）转移到暂存器
        mov cx,28
        mov di,bx;
        rep movsb;用(si+28)修改(si)
        mov cx,28
        lea si,savenp
        rep movsb;转移寄存器到（si+28）
        ;mov swapped,1
c3:                     ;字符串不同
        mov si,ax;恢复si

        ;add si,28;;;;
        cmp si,tempend;判断是否第一轮结束
        jb  c2;没有结束si继续右移
        mov bx,tempend
        sub bx,28
        mov tempend,bx;已经比到末尾就末尾减一
        lea ax,numtable
        cmp bx,ax;在第一轮已经结束的情况下判断是否全部结束
        je  finish;全部结束了
        jmp c1

        ;cmp si,endaddr
        ;jb  c2
        ;cmp swapped,0
        ;jne c1          ;已经发生了交换
finish: ret

nameSearch:
        lea bx,numtable
        ;mov flag,0
searchProcess:      
        mov cx,20
        lea si,bufferNameData
        mov di,bx
        repz cmpsb;比较缓冲区和内存里的名字
        je  found;找到了！
        add bx,28;没找到,那就继续
        cmp bx,endaddr;判断是否查完了
        jbe searchProcess;没查完，那就继续
        ;cmp flag,0
        ;jz nof;查完了而且没找到
        ;jmp dexit
nof:    
        call PRINTNOTFIND
        jmp dexit
found:     
        mov searchaddr,bx;找到当前查找位置
        ;inc flag
        call printLine
        ;add bx,28
        ;cmp bx,endaddr;判断是否查完了
        ;jbe d
        ;jmp dexit

        ;jnz d
dexit:  
        ret
printLine:
        ;cmp flag,0;没找到
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
        mov ah,09h;在缓存区显示结果
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