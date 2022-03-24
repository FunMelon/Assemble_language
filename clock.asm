;@auther:Fun_Melon
;@2022/3/24
;数字计时器
data        segment
    CLEARSCREEN db 23 dup(0ah), '$'
    TIME    db  '00:00', 0ah, '$'
    INFOR   db  'Pless any key to start(except the blank)',0ah, '$'
data        ends

stacks       segment
            db  128 dup(0)
stacks       ends

code        segment
assume      cs:code, ds:data, ss:stacks
start:      ;加载数据区
            mov     ax, data
            mov     ds, ax
            lea     dx, INFOR
            call    PRINT
            call    WAITINPUT

            ;第一次读取时间，这个作为基准值
            call    READTIME
            ;将开始时间读入到dx中，用以以后的减法
            mov     dx, bx
s:;开始循环，不断的读取打印，直到输入空格停止
            call    READTIME

            call    STOCKINASCII
            push    dx
            lea     dx, CLEARSCREEN
            call    PRINT
            lea     dx, TIME
            call    PRINT
            pop     dx

            push    dx
            mov     ah, 06h
            mov     dl, 0ffh
            int     21h
            cmp     al, ' '
            je      exit
            pop     dx

            call    DELAY
            jmp     s
exit:       ;终止程序
            mov     ax, 4c00h
            int     21h

PRINT:;打印信息,参数已经被提前导入到了dx中
            mov     ah, 09h
            int     21h
            ret

WAITINPUT:;等待正确的输入，空格就一直循环
            mov     ah, 0
            int     16h
            cmp     al, ' '
            je      WAITINPUT
            ret

READTIME:;读取当前的时间信息,BCD秒放到bl，BCD分放到bh
            ;读取秒
            mov     al, 0
            out     70h, al
            in      al, 71h
            mov     bl, al
            ;读取分钟
            mov     al, 2
            out     70h, al
            in      al, 71h
            mov     bh, al
            ret

STOCKINASCII:;将获取的时间以ascii码的形式存储到TIME中
            lea     si, TIME
            ;先打秒
            add     si, 3
            push    cx
            push    bx
            push    dx

            ;处理dl
            mov     al, dl
            call    PROCESS
            mov     dx, ax
            ;处理bl
            mov     al, bl
            call    PROCESS
            mov     bx, ax
            ;标志寄存器（管他呢）置零
            mov     cx, 0
            call    SUBSTOCK
            ;再处理分钟
            lea     si, TIME
            pop     dx
            pop     bx
            push    bx
            push    dx
            ;处理dh
            mov     al, dh
            call    PROCESS
            mov     dx, ax
            ;处理bh
            mov     al, bh
            call    PROCESS
            mov     bx, ax

            call    SUBSTOCK

            pop     dx
            pop     bx
            pop     cx

            ret

PROCESS:;对BCD码进行预处理，ah为数字低位，al为高位
            mov     ah,al
            mov     cl,4
            shr     al,cl
            and     ah,00001111b
            ret

SUBSTOCK:;进行减法，bx和dx的低位和高位依次相减,完成后变为ascii码然后存储
            ;先对比低位,如果bh比dh要小的话表明需要借位
            add     dh, ch
            cmp     bh, dh
            jae     noCarry1
            add     bh, 10
            add     dl, 1
noCarry1:
            sub     bh, dh
            ;比较高位
            cmp     bl, dl
            jae     noCarry2
            add     bl, 6
            ;改变标志寄存器
            mov     cx, 0001h
noCarry2:   
            sub     bl, dl
            ;变为ascii码并存储
            add     bx, 3030h
            mov     [si], bx
            ret

DELAY:;;延时函数
            push    cx
            push    bx
            mov     bx, 00025h
cirOut:
            mov     cx, 0ffffh
cirIn:
            loop    cirIn
            dec     bx
            cmp     bx, 0
            jne     cirOut

            pop     bx
            pop     cx
            ret

code        ends
end         start