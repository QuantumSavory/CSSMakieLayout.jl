module CssMakieLayout
using Base.Threads
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown
import JSServe.TailwindDashboard as D

export  hstack, vstack, wrap, zstack, active, classstack,
        button, hoverable

animtoclass(anim) = join(pushfirst!([String(s) for s in anim], ""), " anim-")
###################### 1. Helper functions for UX ######################
#   Functions that add css classes to DOM.div elements in order to 
#   createa a nice UX experience and also cleaner code

# Scene content to md
markdowned(figure) = md"""$(figure.scene)"""

# Equivalent of DOM.div.
# Wraps the content in a div with position set to relative
wrap(content...; class="", style="", md=false) = DOM.div(JSServe.MarkdownCSS,
                                            JSServe.Styling,
                                            md ? [markdowned(i) for i in content] : content,
                                            style=style*"; position: relative;", class=class)

# Wraps content in a div and ads the hoverable class to it
# anim can be set to [:default] or [:border]
_hoverable(item...; class="", style="", anim=[:default], md=false) = wrap(item; class="hoverable "*class*" "*animtoclass(anim), style=style, md=md)

# Hoverable element that stays active when observable is set to 1
function hoverable(item...; observable::Observable=nothing, session::Session=nothing, anim=[:default], class="", style="", md=false)
    if observable === nothing
        return _hoverable(item; class=class, style=style, md=md)
    end
    return classstack(_hoverable(item; anim=anim, class=class, style=style, md=md);
                    observable=observable, session=session,
                    toggleclasses=["stay", "_"])
end
# DOM.div + add zstack class
# ZStack: holds more items, one active (on top) and the others hidden
# When a click event is trigered the active element can be changed by
# toggling the class 'active' from it's class list
# 1. Static Z-stack. Just the html, no click events (need to be added by hand)
_zstack(item...; class="", style="", md=false) = wrap(item; class="zstack "*class, style=style)
active(item...; class="", style="", md=false) = wrap(item; class="active "*class, style=style)

# DOM.div + add zstack class
# ZStack: holds more items, one active (on top) and the others hidden
# When a click event is trigered the active element can be changed by
# toggling the class 'active' from it's class list
# 2. Dinamic Z-stack, with active element selected by an observable with
#    range 1:height, where height defaults to 3 but can be modified

zstack(item::Array; observable::Observable=nothing, session::Session=nothing, class="", anim=[:default], style="", md=false) = 
    zstack(tuple(item); height=size(item)[1], observable=observable, session=session, class=class, anim=anim, style=style, md=md)
function zstack(item...; height=nothing, observable::Observable=nothing, session::Session=nothing, class="", anim=[:default], style="", md=false) 
    if observable === nothing
        return _zstack(item; class=class*" "*animtoclass(anim), style=style, md=md)
    else
        if height===nothing
            height=length(item)
        end
        # static zstack
        item_div =  wrap(item; class="zstack "*class*" "*animtoclass(anim), style=style)

        # add on(observable) event
        onjs(session, observable, js"""function on_update(new_value) {
            const activefig_stack = $(item_div)
            for(i = 1; i <= $(height); ++i) {
                const element = activefig_stack.querySelector(":nth-child(" + i +")")
                element.classList.remove("active");
                if(i == new_value) {
                    element.classList.add("active");
                }
            }
        }
        """)
    end

    return item_div
end
# DOM.div + add hstack class => row of items
hstack(item...; class="", style="", md=false) = wrap(item; class="hstack "*class, style=style)
# DOM.div + add vstack class => col of items
vstack(item...; class="", style="", md=false) = wrap(item; class="vstack "*class, style=style)

# Toggle classes from toggleclasses array based on the value of the observable
# used as selector
function classstack(item; toggleclasses=[], observable::Observable=nothing, session::Session=nothing, class="", style="", md=false) 
    if observable === nothing
        return item
    else
        height = size(toggleclasses)
        # add on(observable) event
        onjs(session, observable, js"""function on_update(new_value) {
            const element = $(item)
            const cllist = $(toggleclasses)
            cllist.forEach((el) => {
                element.classList.remove(el);
            })
            element.classList.add(cllist[new_value-1]);
        }
        """)
    end

    return item
end

# static button with no click events added (equivalent to hoverable)
_button(item; class="", style="") = hoverable(item; class=class, style=style)

# Button which modifies the observable taken as parameter
# type can be: :toggle, :increase, :decrease, :increasemod, :decreasemod
#              :increasecap, :decreasecap
function button(item; observable::Observable=nothing, session::Session=nothing, class="", style="", type=:toggle, cap=3, step=1, md=false)
    if observable === nothing
        return _button(item; class=class, style=style)
    end
    t = D.Button(item; class=class, style=style)
    on(t) do event
        if type == :toggle
            observable[] = !observable[]
        elseif type == :increase
            observable[] = observable[] + step
        elseif type == :decrease
            observable[] = observable[] - step
        elseif type == :increasemod
            observable[] = observable[] + step
            if observable[] >= cap + 1
                observable[] = 1
            end
        elseif type == :decreasemod
            observable[] = observable[] - step
            if observable[] <= 0
                observable[] = cap
            end
        elseif type == :increasecap
            observable[] = observable[] + step
            if observable[] >= cap + 1
                observable[] = observable[] - step
            end
        elseif type == :decreasecap
            observable[] = observable[] - step
            if observable[] <= 0
                observable[] =  observable[] + step
            end
        end
    end
    return wrap(t; class="btn")
end

## CSS code used by the library for styling
formatstyle=DOM.style("""
    .hoverable.anim-default{
        transition: all 0.1s ease;
    }
    .hoverable.anim-default:hover, .stay.anim-default{
        transform: scale(1.1);
    }

    .hoverable.anim-border{
        transition: all 0.1s ease;
        border: 2px solid transparent;

    }
    .hoverable.anim-border:hover, .stay.anim-border{
        border: 2px solid black;
    }

    .hoverable.anim-border.white{
        transition: all 0.1s ease;
        border: 2px solid transparent;
        padding: 4px;
        padding-bottom: 0px;

    }
    .hoverable.anim-border.white:hover, .stay.anim-white.border{
        border: 2px solid white;
    }


    .hstack{
        display:flex;
        flex-direction: row;
    }

    .vstack{
        display: flex;
        flex-direction: column;
    }

    .align-center{
        align-items: center;
    }

    .justify-center{
        justify-content: center;
    }

    .zstack{
        display:flex;
        flex-direction: row;
    }

    .zstack, .zstack > *{
        transition: all 0.3s ease;
    }

    .zstack.anim-default .active{
        transition: all 0.3s ease;
        width: 100%;
        overflow: hidden;

    }

    .zstack.anim-default > :not(.active){
        transition: all 0.3s ease;
        width: 0%;
        overflow: hidden;
    }

    .zstack.anim-whoop{
        display: grid;
    }

    .zstack.anim-whoop > *{
        grid-area: 1/1/1/1;

    }

    .zstack.anim-whoop .active{
        z-index: 4;
        position: absolute;
        transition: all 0.3s ease;
        transform: scale(1);
        overflow: hidden;

    }

    .zstack.anim-whoop > :not(.active){
        position: absolute;
        z-index: 1;

        transition: all 0.3s ease;
        transform: scale(0);
        overflow: hidden;
    }

    .zstack.anim-static .active{
        overflow: hidden;

    }

    .zstack.anim-static > :not(.active){
        width: 0px;
        overflow: hidden;
    }

    .zstack.anim-opacity .active{
        transition: all 0.1s ease;
        opacity: 1;

    }

    .zstack.anim-opacity > :not(.active){
        transition: all 0.1s ease;
        opacity: 0;
    }

    .upper{
        text-transform: uppercase;
    }
    .btn button{
        height: 100%;
        width: 100%;
    }
    .btn button:hover{
        box-shadow: rgba(50, 50, 93, 0.25) 0px 30px 60px -12px inset, rgba(0, 0, 0, 0.3) 0px 18px 36px -18px inset !important;
    }


    """)

end # module CssMakieLayout
