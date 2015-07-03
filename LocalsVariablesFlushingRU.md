# Обнуление локальных переменных #

## Использование flush locals ##

cJass предлагает автоматизированные средства обнуления локальных переменных для избежания утечек. Базовое - инструкция `flush locals`

```
nothing fx () {
    unit foo = GetSomeUnit ()
    unit bar = GetSomeUnit ()
    unit free

    // действия с foo и bar
    bar = null
    flush locals
}

// данный код будет переведен на jass как

function fx takes nothing returns nothing
    local unit foo=GetSomeUnit()
    local unit bar=GetSomeUnit()
    local unit free
    set bar=null // это - написано пользователем
    set foo=null // cJass обнуляет только foo, т.к. знает, что bar уже обнулено
endfunction
```

**Важно**: Локальные массивы не обнуляются из-за сложности алгоритма, который определит ячейки, которые указывают на объекты.

cJass использует продвинутый анализатор кода, который обнуляет только переменные, которые потенциально могут вызвать утечку.

## Автоматическое обнуление ##

Рекомендуемым является использование `/alf` флага (в расширенном NewGenWE установить галочку Locals auto flush) - данная опция добавит `flush locals` к каждой `return`, `endfunction` и `endmethod` инструкции. Также будет переработана обработка возвращаемого выражения, если в нем используется локальная переменная - будет создана временная глобальная переменная, в которую будем помещен результат, после чего переменные будут обнулены и возвращен результат.

В коде, написанном ранее, где переменные обнулялись вручную данная опция не приведет к повторному обнулению и не скажется на быстродействии кода.

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

## Псевдообнуление ##

В редких случаях, при низкоуровневой оптимизации или в коде часто используемых библиотек необходимо указать, что переменная уже пуста (например cJass не может анализировать обработку exitwhen в цикле, и поэтому, если в цикле есть присвоение переменной значения он будет считать ее не пустой) - для этого используется псевдообнуление.

```
    set var = null_cjnullex // данная строка указывает, что в данный момент переменная пуста
                            // данная строка будет удалена из конечного кода
```

## Список обнуляемых типов ##

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
weathereffect // надо ли?
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