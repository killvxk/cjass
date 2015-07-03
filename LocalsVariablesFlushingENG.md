<a href='Hidden comment: 
Автоматизация рутинной операции обнуления локальных переменных для избежания утечек памяти.
'></a>

# Nullifying local variables #

## Using _flush locals_ ##

cJass offers automated means of flushing (nullifying) local variables to avoid memory leaks. The basic way is `flush locals` instruction:

<a href='Hidden comment: 
cJass предлагает автоматизированные средства обнуления локальных переменных для избежания утечек. Базовое - инструкция flush locals
'></a>
```
nothing fx () {
    unit foo = GetSomeUnit ()
    unit bar = GetSomeUnit ()
    unit free

    // actions with foo and bar
    bar = null
    flush locals
}

// the code above is compiled to:

function fx takes nothing returns nothing
    local unit foo=GetSomeUnit()
    local unit bar=GetSomeUnit()
    local unit free
    set bar=null // written by user
    set foo=null // cJass nullifies only foo, because bar is already null
endfunction
```

**Important**: Local arrays are not nullified due to complexity of algorithm that identifies cells pointing to objects.

cJass uses advanced code parser, which only nullifies variables that may potentially cause memory leaks.

<a href='Hidden comment: 
// parser or analyzer?

Важно: Локальные массивы не обнуляются из-за сложности алгоритма, который определит ячейки, которые указывают на объекты.

cJass использует продвинутый анализатор кода, который обнуляет только переменные, которые потенциально могут вызвать утечку.
'></a>

## Automatic flushing ##

It is recommended to use `/alf` flag (in NewGenWE check `Locals auto flush` box). This will add `flush locals` instruction to every `return`, `endfunction`, and `endmethod` instruction. In addition, if the return expression of a function contains local variables, it will also be reworked to avoid leaks. For this purpose, cJass creates a temporary global variable and assigns the result to it, after which the locals are flushed and `return` statement is placed.

<a href='Hidden comment: 
Рекомендуемым является использование /alf флага (в расширенном NewGenWE установить галочку Locals auto flush) - данная опция добавит flush locals к каждой return, endfunction и endmethod инструкции. Также будет переработана обработка возвращаемого выражения, если в нем используется локальная переменная - будет создана временная глобальная переменная, в которую будем помещен результат, после чего переменные будут обнулены и возвращен результат.
'></a>

If your code already contains statements that nullify locals, this mechanism won't generate unnecessary nullifications and won't affect code performance.

```
#if ! AUTOFLUSH_LOCALS
    #error ("Please, enable locals variables autoflush!")
#endif

unit fx () {
    unit foo = SomeUnit ()
    int i
    if (b) {
        unit bar = AnotherUnit ()
        return null
    }
    return foo
}

// --->

function fx takes nothing returns unit
    local unit foo=SomeUnit()
    local int i
    local unit cjlocgn_00000000
    if (b) then
        set cjlocgn_00000000=AnotherUnit()
        set cjlocgn_00000000=null
        set foo=null
        return null
    endif
    set cj_v666_unit=foo
    set foo=null
    return cj_v666_unit
endfunction

globals
    unit cj_v666_unit
endglobals
```

<a href='Hidden comment: 
В коде, написанном ранее, где переменные обнулялись вручную данная опция не приведет к повторному обнулению и не скажется на быстродействии кода.
'></a>

## Pseudo-flushing ##

In some rare cases, such as low-level optimization or in widely used libraries, it's recommended to point out that a variable is already empty (for example, cJass is unable to analyze the processing of `exitwhen` in a loop, and therefore, if the loop contains assignment to a variable, it will consider it non-empty) - for such cases there is pseudo-flushing.

<a href='Hidden comment: 

В редких случаях, при низкоуровневой оптимизации или в коде часто используемых библиотек необходимо указать, что переменная уже пуста (например cJass не может анализировать обработку exithwen в цикле, и поэтому, если в цикле есть присвоение переменной значения он будет считать ее не пустой) - для этого используется псевдообнуление.

Оно используется в форе по группе, там идет цикл с условием exitwhen u == null. Поскольку использование данного кода предполагается частое я посчитал рациональным сделать такую фичу. Ну а раз есть - надо написать.

// необходимо указать - it"s recommended to point out?
'></a>

```
    set var = null_cjnullex // this line hints that the variable is empty
                            // this line will be deleted in the resulting code
```

## List of nullified types ##

<a href='Hidden comment: 

== Processed types ==

cJass will nullifies variables if it belongs to a type listed below.
'></a>

```
agent
event
widget
unit
destructable
item
force
group
trigger
triggercondition
triggeraction
timer
location
region
rect 
sound
unitpool
itempool
effect
weathereffect
dialog
button
quest
questitem
timerdialog
leaderboard
multiboard
multiboarditem
gamecache
hashtable
```