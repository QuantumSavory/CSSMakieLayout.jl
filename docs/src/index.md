# Reactive and static elements

##        CssMakieLayout.CurrentSession

Session used as default for all session::Session params of the following functions. Set it at the begining of your code as such:

```julia
landing2 = App() do session::Session
CssMakieLayout.CurrentSession = session
...
end
```


##        markdowned

```julia
markdowned(figure)
```
Markdown wrapper that displays `figure`'s scene content. 

Use:
It is optional, 
meaning you can also wrap the figure itself in a `wrap` function. Tipically used
with Markdown pages.

# wrap

```julia 
wrap(content...; class, style, md=false)
```
Wraps the content in a div element and sets the position of the div to `relative`.

**Arguments**
- `class`: classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them




##        _hoverable


```julia
_hoverable(item...; class="", style="", anim=[:default], md=false)
```
Wraps content in a div and adds the hoverable class to it

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.
- `anim`: Choose which animation to perform on hover: can be set to [:default] or [:border]



##        hoverable

```julia
hoverable(item...; stayactiveif::Observable=nothing, session::Session=CurrentSession, anim=[:default], class="", style="", md=false)
```
Hoverable element which also stays active if the `stayactiveif` observable is set to 1. By active, we mean 
"to remain in the same state as when hovered".

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.
- `anim::Array`: Choose which animations to perform on hover: can be set to [:default] or [:border] or a combination of the 2
- `stayactiveif::Observable`: If the observable set as parameter is one, the element will be active weather hovered or not,
                                otherwise it will not be active unless hovered
- `session::Session=CurrentSession`: App session (defaults to CssMakieLayout.CurrentSession which can be set at the begining. See [`CurrentSession`](@ref))



##        _zstack
```julia
_zstack(item...; class="", style="", md=false)
```
A zstack receives an array/a tuple of elements, and displays just one of them based on the
`activeidx` given as parameter. _zstack is a static version of the zstack, which is used in the main [`zstack`](@ref)
implementation.
It can also be used as scaffolding for user defined behaviours.
    

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.



##       active
```julia 
active(item...; class="", style="", md=false)
```
When constructing a layout, this function marks an element as 'active', i.e. topmost in a zstack.

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.



##        zstack

```julia
zstack(item::Array; activeidx::Observable=nothing, session::Session=CurrentSession, class="", anim=[:default], style="", md=false)
```
A zstack receives an array/a tuple of elements, and displays just one of them based on the
`activeidx` given as parameter. The displayed (active in the context of the zstack) element can be thought of as the top of the zstack

# Arguments
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.
- `activeidx::Observable`: This selects the element which is displayed. For example if observable is 4,
                                the zstack will display the 4th element of the `item` array/tuple.
- `anim::Array`: Choose which animations to perform on transition (when `observable` is changed). Can be set to [:default], [:whoop], [:static], [:opacity] or a non-conflicting combination of them
- `session::Session=CurrentSession`: App session (defaults to CssMakieLayout.CurrentSession which can be set at the begining. See [`CurrentSession`](@ref))

# Example

```julia
mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
activefig = zstack(
        active(mainfigures[1]),
        wrap(mainfigures[2]),
        wrap(mainfigures[3]);
        activeidx=activeidx)
```

##    zstack

```julia
zstack(item...; activeidx::Observable=nothing, session::Session=CurrentSession, class="", anim=[:default], style="", md=false)
```

A zstack receives an array/a tuple of elements, and displays just one of them based on the
`activeidx` given as parameter (it will desplay the `activeindex`'th element). Think of it as a carousel. 

The displayed (active in the context of the zstack) will represent top of the zstack


# Arguments
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.
- `activeidx::Observable`: This selects the element which is displayed. For example if observable is 4,
                        the zstack will display the 4th element of the `item` array/tuple.
- `anim::Array`: Choose which animations to perform on transition (when `activeidx` is changed). Can be set to [:default], [:whoop], [:static], [:opacity] or a non-conflicting combination of them
- `session::Session=CurrentSession`: App session (defaults to CssMakieLayout.CurrentSession which can be set at the begining. See [`CurrentSession`](@ref))

# Example

```julia
activeidx = Observable(1)
mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
activefig = zstack(
        active(mainfigures[1]),
        wrap(mainfigures[2]),
        wrap(mainfigures[3]);
        activeidx=activeidx)
```


##        hstack

```julia
hstack(item...; class="", style="", md=false)
```
Displays the given elements in a flex row.

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them


## vstack

```julia 
vstack(item...; class="", style="", md=false)
```
Displays the given elements in a flex column.

**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them


##    selectclass


```julia 
selectclass(item; toggleclasses=[], selector::Observable=nothing, session::Session=CurrentSession, class="", style="", md=false) 
```

Ads a class from the `toggleclasses` Array to the `item` element based on the value of the `selector` Observable.
Returns the modified item.
**Arguments**
- `class`: additional classes of the element in a string separated with space
- `style`: string containing the additional css style of the wrapper div
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
    function to each element of the content parameter before wrapping them.
- `toggleclasses::Array` : Array of classes to select from 
- `selector::Observable`: Selects which class is added to the element.
- `session::Session=CurrentSession`: App session (defaults to CssMakieLayout.CurrentSession which can be set at the begining. See [`CurrentSession`](@ref))


## _button

```julia
_button(item; class="", style="")
```
Static button with no click events added (equivalent to hoverable).



## modifier


```julia
modifier(item; action=:toggle, parameter::Observable=nothing, class="", style="", cap=3, step=1, md=false)
```
Wrap an item in a clickable div (modifier element/button) and bind it to an observable. When clicked, it modifies the `parameter` Observable taken as parameter based on the button's `action`, `cap` and `step`.
`action` can be: :toggle, :increase, :decrease, :increasemod, :decreasemod
        :increasecap, :decreasecap

**Arguments**
- `class`: additional classes of the modifier element in a string separated with space
- `style`: string containing the additional css style of the modifier
- `md`: Set to false unless specified otherwise. Specifies weather to aply the [`markdowned`](@ref)
        function to each element of the content parameter before wrapping them.
- `parameter::Observable`: Observable that is modified when a click event is triggered on the modifier.
- `action`: The way that the modifier button modifies it's `parameter` when clicked:    
- `:toggle`: toggles the observable from 0 to 1, or from 1 to 0 (for example 1 - play, 0 - pause)
-  `:increase`, `decrease`: increase or decrease the observable by `step`
- `:increasemod`, `decreasemod`: increase or decrease the observable by `step` nd then take the modulo w.r.t `cap` and add 1, to keep the number in the [1, cap] interval
- `:increasecap`, `:decreasecap`: increase or decrease the observable by `step`, keep it in the [1, cap] interval, but do not increase/decrease when increasing and decreasing would make the observable exit the interval (as oposed to the mod option which loops back, the cap option stays there).
- `step`, `cap`: the step of the increase/decrease steps and the maximum cappacity

### Example 

The modifier element can be used hand in hand with a zstack element to create reactive layouts as such:
```julia
mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
buttons = [modifier(wrap(DOM.h1("〈")); action=:decreasecap, parameter=activeidx, cap=3, style=buttonstyle),
        modifier(wrap(DOM.h1("〉")); action=:increasecap, parameter=activeidx, cap=3, style=buttonstyle)]
activefig = zstack(
            active(mainfigures[1]),
            wrap(mainfigures[2]),
            wrap(mainfigures[3]);
            observable=activeidx)
layout = hstack(buttons[1], activefig, buttons[2])
```



##        CssMakieLayout.formatstyle

CSS code used by the library for styling

Include it in your layout when returning the final element as such:
```julia
return hstack(CssMakieLayout.formatstyle, layout)
```


##        CssMakieLayout.Themes

Some basic themes for abstract styling that are still in development
