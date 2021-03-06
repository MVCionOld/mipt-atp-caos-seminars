# Семинар №6
## Введение в программирование на ассемблере x86_64

---

### Немного истории и про регистры

Немного истории

| Год  | Регистры           | Битность | Первый процессор | Комментарий |
|------|--------------------|----------|------------------|-------------|
| 1974 | a, b, c, d         | 8 bit    | Intel 8080       | |
| 1978 | ax, bx, cx, dx     | 16 bit   | Intel 8086       | X - eXtended ([совсем ненадежный источник](https://stackoverflow.com/a/892948))|
| 1985 | eax, ebx, exc, edx | 32 bit   | Intel 80386      | E - extended |
| 2003 | rax, rbx, rcx, rdx | 64 bit   | AMD Opteron      | R - (внезапно) register |


Как оно выглядит сейчас в 64-битных процессорах

<table width="800px" border="1" style="text-align:center; font-family: Courier New; font-size: 10pt">

<tbody><tr>
<td colspan="8" width="25%" style="background:lightgrey">RAX

<td colspan="8" width="25%" style="background:lightgrey">RCX

<td colspan="8" width="25%" style="background:lightgrey">RDX

<td colspan="8" width="25%" style="background:lightgrey">RBX

<tr>
<td colspan="4" width="12.5%">
<td colspan="4" width="12.5%" style="background:lightgrey">EAX

<td colspan="4" width="12.5%">
<td colspan="4" width="12.5%" style="background:lightgrey">ECX

<td colspan="4" width="12.5%">
<td colspan="4" width="12.5%" style="background:lightgrey">EDX

<td colspan="4" width="12.5%">
<td colspan="4" width="12.5%" style="background:lightgrey">EBX

<tr>
<td colspan="6" width="18.75%">
<td colspan="2" width="6.25%" style="background:lightgrey">AX

<td colspan="6" width="18.75%">
<td colspan="2" width="6.25%" style="background:lightgrey">CX

<td colspan="6" width="18.75%">
<td colspan="2" width="6.25%" style="background:lightgrey">DX

<td colspan="6" width="18.75%">
<td colspan="2" width="6.25%" style="background:lightgrey">BX

<tr>
<td colspan="6" width="18.75%">
<td width="3.125%" style="background:lightgrey">AH
<td width="3.125%" style="background:lightgrey">AL

<td colspan="6" width="18.75%">
<td width="3.125%" style="background:lightgrey">CH
<td width="3.125%" style="background:lightgrey">CL

<td colspan="6" width="18.75%">
<td width="3.125%" style="background:lightgrey">DH
<td width="3.125%" style="background:lightgrey">DL

<td colspan="6" width="18.75%">
<td width="3.125%" style="background:lightgrey">BH
<td width="3.125%" style="background:lightgrey">BL
</tbody></table>

(На самом деле все далеко не так просто устроено. [stackoverflow](https://stackoverflow.com/a/25456097))

Регистры x86 и их странные названия
* RAX - Accumulator Register
* RBX - Base Register
* RCX - Counter Register
* RDX - Data Register
* RSI - Source Index
* RDI - Destination Index
* RBP - Base Pointer
* RSP - Stack Pointer
* R8...R15 - дополнительные регистры общего назначения

Регистры в x86-64:

<br> `rax`, `rbx`, `rcx`, `rdx` - регистры общего назначения.
<br> `rsp` - указатель на вершину стека
<br> `rbp` - указатель на начало фрейма (но можно использовать аккуратно использовать как регистр общего назначения)
<br> `rsi`, `rdi` - странные регистры для копирования массива, по сути регистры общего назначения, но ограниченные в возможностях.
<br> `r8`...`r15`

Целочисленные аргументы передаются последовательно в регистрах: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`. Если передается более 6 аргументов, то оставшиеся - через стек.
Вещественные аргументы передаются через регистры `xmm0`...`xmm7`.

Возвращаемое значение записывается в регистр `rax`.

Вызываемая функция **обязана сохранять на стеке значения регистров** общего назначения `rbx`, `rbp`, `r12`...`r15`. ([Почему `rbx` в этом ряду?](https://stackoverflow.com/questions/22214208/x86-assembly-why-is-ebx-preserved-in-calling-conventions))

Кроме того, при вызове функции для 64-разрядной архитектуры есть дополнительное требование - перед вызовом функции стек должен быть выровнен по границе 16 байт, то есть необходимо уменьшить значение rsp таким образом, оно было кратно 16. Если кроме регистров задействуется стек для передачи параметров, то они должны быть прижаты к нижней выровненной границе стека.

Для функций гарантируется 128-байтная "красная зона" в стеке ниже регистра rsp - область, которая не будет затронута 
внешним событием, например, обработчиком сигнала. Таким образом, можно задействовать для адресации локальных 
переменных память до rsp-128.  

Если Вы не поняли про красную зону или про rbp, то рекомендую почитать этот [блог](https://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/).
  
Стоит добавить, что "красная зона" гарантируется в каждый момент времени, т.e. не забывайте сдвигать rsp перед 
аллокацией.

### Синтаксисы

Исторически сложилось два синтаксиса языка ассемблера x86: синтаксис AT&T,
используемый в UNIX-системах, и синтаксис Intel, используемый в DOS/Windows.

Различие, в первую очередь, относится к порядку аргументов команд.

Компилятор gcc по умолчанию использует синтаксис AT&T, но с указанием опции
`-masm=intel` может переключаться в синтаксис Intel.

Кроме того, можно указать используемый синтаксис первой строкой в тексте
самой программы:
```nasm
.intel_syntax noprefix
```

Здесь параметр `noprefix` после `.intel_syntax` указывает на то, что помимо порядка аргументов, соответствующих синтаксису Intel, ещё и имена регистров не должны начинаться с символа `%`, а константы - с символа `$`, как это принято в синтаксисе AT&T.

Мы будем использовать именно этот синтаксис, поскольку с его использованием
написано большинство доступной документации и примеров, включая документацию
от производителей процессоров.

При чтении по адресу используется QWORD PTR — это переменная типа четверного слова, DWORD PTR — это переменная типа 
двойного слова. Слово — это 16 бит. Термин получил распространение в эпоху 16-ти битных процессоров, тогда в регистр 
помещалось ровно 16 бит. Такой объем информации стали называть словом (word). Т. е. в нашем случае dword (double 
word) 2*16 = 32 бита = 4 байта (обычный int).  
[Чтиво на Хабре](https://habr.com/ru/post/344896/)

### Инструкции

```nasm
add     DST, SRC        /* DST += SRC */
sub     DST, SRC        /* DST -= SRC */
inc     DST             /* ++DST */
dec     DST             /* --DST */
neg     DST             /* DST = -DST */
mov     DST, SRC        /* DST = SRC */
imul    SRC             /* (eax,edx) = eax * SRC - знаковое */
mul     SRC             /* (eax,edx) = eax * SRC - беззнаковое */
and     DST, SRC        /* DST &= SRC */
or      DST, SRC        /* DST |= SRC */
xor     DST, SRC        /* DST ^= SRC */
not     DST             /* DST = ~DST */
cmp     DST, SRC        /* DST - SRC, результат не сохраняется, */
test    DST, SRC        /* DST & SRC, результат не сохраняется  */
adc     DST, SRC        /* DST += SRC + CF */
sbb     DST, SRC        /* DST -= SRC - CF */
```

В отличии от процессоров ARM, где обновление регистра флагов производится
только при наличии специального флага в команде, обозначаемого суффиксом
`s`, в процессорах Intel флаги обновляются всегда большинстом инструкций.

Флаг `ZF` устанавливается, если в результате операции был получен нуль.

Флаг `SF` устанавливается, если в результате операции было получено
отрицательное число.

Флаг `CF` устанавливается, если в результате выполнения операции произошел
перенос из старшего бита результата. Например, для сложения `CF` устанавливается
если результат сложения двух беззнаковых чисел не может быть представлен
32-битным беззнаковым числом.

Флаг `OF` устанавливается, если в результате выполняния операции произошло
переполнение знакового результата. Например, при сложении `OF` устанавливается,
если результат сложения двух знаковых чисел не может быть представлен
32-битным знаковым числом.

Обратите внимание, что и сложение `add`, и вычитание `sub` устанавливают
одновременно и флаг `CF`, и флаг `OF`. Сложение и вычитание знаковых и
беззнаковых чисел выполняется совершенно одинаково, и поэтому используется одна
инструкция и для знаковой, и для беззнаковой операции.

Инструкции `test` и `cmp` не сохраняют результат, а только меняют флаги.

Безусловный переход выполняется с помощью инструкции `jmp`
```nasm
jmp label
```

Условные переходы проверяют комбинации арифметических флагов:
```nasm
jz      label   /* переход, если равно (нуль), ZF == 1 */
jnz     label   /* переход, если не равно (не нуль), ZF == 0 */
jc      label   /* переход, если CF == 1 */
jnc     label   /* переход, если CF == 0 */
jo      label   /* переход, если OF == 1 */
jno     label   /* переход, если OF == 0 */
jg      label   /* переход, если больше для знаковых чисел */
jge     label   /* переход, если >= для знаковых чисел */
jl      label   /* переход, если < для знаковых чисел */
jle     label   /* переход, если <= для знаковых чисел */
ja      label   /* переход, если > для беззнаковых чисел */
jae     label   /* переход, если >= (беззнаковый) */
jb      label   /* переход, если < (беззнаковый) */
jbe     label   /* переход, если <= (беззнаковый) */
```

Вызов функции и возврат из неё осуществляются командами `call` и `ret`
```nasm
call    label   /* складывает в стек адрес возврата, и переход на label */
ret             /* вытаскивает из стека адрес возврата и переходит к нему */
```

Кроме того, есть составная команда для организации циклов, которая
подразумевает, что в регистре `ecx` находится счётчик цикла:
```nasm
loop    label   /* уменьшает значение ecx на 1; если ecx==0, то
                   переход на следующую инструкцию, в противном случае
                   переход на label */
```

В отличии от RISC-процессоров, x86 позволяет использовать в качестве
**один из аргументов** команды как адрес в памяти.

**В синтаксисе AT&T** такая адресация записывается в виде:
`OFFSET(BASE, INDEX, SCALE)`, где `OFFSET` - это константа, `BASE` и `INDEX` -
регистры, а `SCALE` - одно из значений: `1`, `2`, `4` или `8`.

Адрес в памяти вычисляется как `OFFSET+BASE+INDEX*SCALE`. Параметры `OFFSET`,
`INDEX` и `SCALE` являются опциональными. При их отсутсвтвии подразумевается,
что `OFFSET=0`, `INDEX=0`, `SCALE` равен размеру машинного слова.

**В синтаксисе Intel** используется более очевидная нотация:
`[BASE + INDEX * SCALE + OFFSET]`.
