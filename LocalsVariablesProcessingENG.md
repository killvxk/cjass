# Local variables in cJass #

## Declaration freedom ##

In JASS2 local variables must be declared at the start of function. While using cJass, you can declare local variables anywhere inside the function.

```
nothing foo () {
    DoNothing ()
    int bar = 0
}
```

The parser will move all declarations of locals to the top of the function.
Because in JASS2 locals may be initialized when declared, cJass analyzes the assignment expression before moving it. If the variable is initialized with exact value, cJass will move the initialization entirely. Any other initialization lines will remain in place, for example:

<a href='Hidden comment: 
Парсер перенесет в начало функции объявления всех локальных переменных. Так, как в JASS2 вместе с объявлением, переменная может быть инициализирована, cJass анализирует присваемое ей значение перед переносом в начало. Инициализация переменных явными значениями однозначно переносится вместе с соответствуюшими переменными. Остальные строки инициализации переменных остаются на местах объявления, например:
'></a>

```
nothing foo () {
      DoNothing()
      integer i = 0              // declaration will be moved entirely
      location l = Location(0,0) // this variable will be initialized here
}
// --->
function foo takes nothing returns nothing
    local integer i = 0
    local location l
    call DoNothing ()
    set l = Location (0,0)
endfunction
```

cJass syntax also lets you declare variables of the same type on the same line, separating them by commas. These variables can also be initialized:

```
int i = 7, j, k
// --->
local integer i = 7
local integer j
local integer k
```

## Limited scope of a local variable declared in a block ##

In cJass the scope of a local variable is limited to the block (such as `if`, `for` or `loop`), where it is declared. From user's perspective, a variable is created in a block just like an ordinary local variable is created in a function; uninitialized variables contain junk; the variable is deleted after exiting the block.

<a href='Hidden comment: 
С точки зрения пользователя переменная создается при входе в блок точно также, как создается обычная локальная переменная при входе в функцию; не инициализированная переменная содержит мусор; переменная удаляется после выхода из блока.
'></a>

```
nothing fx () {
    int foo // can be referenced from anywhere inside the function
    if (b) {
        int bar
    }
    bar ++ // error, we cannot use this variable outside of previous block
    for (int bar = 0; bar < 16; bar++) { // we can declare a variable with the same name
                                         // in a different block and use it
        DoSomething ()
    }
    for (int i = 0; i < 16; i++) {
        for (int i = 0; i < 16; i++) { // error, shadowing of variables is not supported
            Spam (i)                   // otherwise it would provoke the coder
                                       // to make errors such as this one
        }
    }
}
```

Declaring a variable in loop body with assigning a value to it, is interpreted as creating that variable once and then assigning a value to it in every iteration of the loop (ignorance of this principle may lead to errors):

<a href='Hidden comment: 
Объявление переменной в теле цикла с присвоением ей значения будет интерпретировано как однократное создание переменной и присвоение ей указанного значения в каждой итерации цикла (непонимание этого принципа может приводить к ошибкам):
'></a>

```
nothing fx () {
    loop {
        int i = 0 //
    }
}
// --->
function fx takes nothing returns nothing
    local int i
    loop
        set i = 0
    endloop
endfunction
```

`for` loop contains declaration and initialization of the variable in  its header. Therefore declaration (if present) and initialization will take place right before the loop body.

<a href='Hidden comment: 
поэтому при его использование объявление (если оно есть) и инициализация переменной происходит непосредственно перед телом цикла.
'></a>

### Operating principle ###

cJass renames all local variables declared in a block (their names look like `cjlocgn_********`).  In each function, a minimum set of required variables is created.

<a href='Hidden comment: 
cJass переименовывает все локальные переменные, объявленные в блоке (их имена имеют вид cjlocgn_********). В каждой функции создается минимальный набор необходимых переменных:
'></a>

```
nothing fx () {
    if (b) {
        int a = 0
    }
    if (b) {
        int b = 1
        for (int c = 2; c < 256; c++) {
            b += 2
        }
    }
}
// --->
function fx takes nothing returns nothing
    local int cjlocgn_00000000
    local int cjlocgn_00000001
    if (b) then
        set cjlocgn_00000000 = 0
    endif
    if (b) then
        set cjlocgn_00000000 = 1 // re-using variable
        if (cjlocgn_00000000) then
            set cjlocgn_00000001 = 2
        endif
    endif
endfunction
```

### Flushing local variables ###

The programmer does not know (and does not need to know) whether a local variable is to be used after some block of code.

<a href='Hidden comment: 
Фактически, программист не знает (и ему не зачем знать) будет ли, и если да - то как переменная использована после какой либо области кода:
'></a>

```
// ...
if (expr) {
    unit u = GetSomeUnit ()
    DoSomething (u)
    // ...
}
// ...
```

If you need to nullify a local variable, you can do it manually: `u = null`. However, if the local is to be used later, there's no point in doing that. Of course, one more nullification won't do any harm. But it is "unnecessary" piece of work. To avoid it, it's recommended to use [Automated flushing of local variables](http://code.google.com/p/cjass/wiki/LocalsVariablesFlushingENG#Automatic_flushing) - cJass knows where and how each variable will be used, therefore it is able to generate cleaner code.

<a href='Hidden comment: 
При этом конечно можно обнулить переменную вручную: u = null, однако если переменная будет использована дальше, то данное действие становится бессмысленный. Конечно, в лишнем обнулении нет ничего страшного. Тем не менее это "лишняя" работа. Для ее избежания рекомендуется использовать  [http://code.google.com/p/cjass/wiki/LocalsVariablesFlushingRU#Автоматическое_обнуление автоматическое обнуление локальных переменных] - cJass, зная, как и где какая переменная используется будет генерировать более чистый код.
'></a>

### Anonymous block _vblock_ ###

Anonymous block is used to limit the scope of local variables.

<a href='Hidden comment: 
Анонимный блок используется для разграничения области видимости локальных переменных.
'></a>

```
#define RegOnRegEntry (code, xMin, yMin, xMax, yMax) = {
    vblock {
        rect r = Rect (xMin, yMin, xMax, yMax)
        region rg = CreateRegion ()
        RegionAddRect (rg, r)
        trigger t = CreateTrigger ()
        TriggerAddAction (t, code)
        TriggerRegisterEnterRegion (t, rg, null)
    }
}
```

<a href='Hidden comment: 
Без анонимного блока создание подобного макроса было бы заметно усложнено.
'></a>

## Static variables ##

In cJass, you can declare static variables in functions.

```
nothing foo () {
    static int bar = 0
}
```

Static variables are created when the code is first run. Therefore, in case you make a declaration with assignment, you cannot use nonexistent objects such as local variables. Static variables are not removed upon leaving the function body, and are not recreated in consequent function calls. Because of that, static variables do not need to be nullified.

The scope of a static variable is the whole function body.

<a href='Hidden comment: 
Статические переменные создаются в момент инициализации кода, поэтому в случаи объявления с присвоением нельзя использовать еще не существующие объекты, например локальные переменные. Статические переменные не удаляются при выходе из функции, а при повторном входе не создаются снова. Ввиду этого статические переменные не нуждаются в обнулении.

Область видимости статической переменной - все тело функции.
'></a>

```
nothing fx (int foo) {
    static int callCounter = 0 // counter of function calls
    callCounter ++             // incrementing the counter
    static int bar
    if (foo > bar) {
        bar = foo
    }
}
```

At present one cannot access static variables in anonymous functions, but this feature will be added in further versions.

<a href='Hidden comment: 
В настоящий момент нельзя получить доступ к статической переменной из анонимной функции, однако в следующих версиях такая возможность будет добавлена.
'></a>