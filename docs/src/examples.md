# CssMakieLayout.jl
This library helps in the development of reactive frontends and can be
used alongside **WGLMakie** and **JSServe**.

## Focus on the styling and let us handle the reactive part!

Let's go through two examples on how to use this library, the first one will be a simple one, and the second, more complex.

Example 1                  |  Example 2
:-------------------------:|:-------------------------:
!["examples/assets/example1.gif"](https://github.com/adrianariton/CssMMakieLayout/blob/master/examples/assets/example1.gif?raw=true)  |  !["examples/assets/example2.gif"](https://github.com/adrianariton/CssMMakieLayout/blob/master/examples/assets/example2.gif?raw=true)

## Example 1
For example let's say we want to create a view in which we can visualize
one of three figures (**a**, **b** and **c**) in a slider manner. 
We also want to control the slider with two buttons: `LEFT` and `RIGHT`. The
`RIGHT` button slided to the next figure and the `LEFT` one slides to the
figure before.

The layout would look something like this:

!["< (left) | 1 | (right) >"](https://github.com/adrianariton/CssMMakieLayout/blob/master/examples/assets/example1.gif?raw=true)

By acting on the buttons, one moves from one figure to the other.

### This can be easily implemented using **CssMakieLayout.jl**

1. First of all include the library in your project

```julia
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown

# 1. LOAD LIBRARY   
using CssMakieLayout
```
2. Then define your layout using CSSMakieLayout.jl,

```julia

config = Dict(
    :resolution => (1400, 700), #used for the main figures
)

landing = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Active index: 1 2 or 3
    #   1: the first a.k.a 'a' figure is active
    #   2: the second a.k.a 'b' figure is active    
    #   3: the third a.k.a 'c' figure is active
    activeidx = Observable(1)

    # Create the buttons and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    
    buttons = [modifier(wrap(DOM.h1("〈")); action=:decreasecap, parameter=activeidx, cap=3),
                modifier(wrap(DOM.h1("〉")); action=:increasecap, parameter=activeidx, cap=3)]
    
    
    axii = [Axis(mainfigures[i][1, 1]) for i in 1:3]
    # Plot each of the 3 figures using your own plots!
    scatter!(axii[1], 0:0.1:10, x -> sin(x))
    scatter!(axii[2], 0:0.1:10, x -> tan(x))
    scatter!(axii[3], 0:0.1:10, x -> log(x))

    # Obtain the reactive layout using a zstack controlled by the activeidx observable
    activefig = zstack(
                active(mainfigures[1]),
                wrap(mainfigures[2]),
                wrap(mainfigures[3]);
                activeidx=activeidx,
                style="width: $(config[:resolution][1])px")
    

    layout = hstack(buttons[1], activefig, buttons[2])
    
    
    return hstack(CssMakieLayout.formatstyle, layout)

end
```

3. And finally Serve the app

```julia
isdefined(Main, :server) && close(server);
port = 8888
interface = "127.0.0.1"
server = JSServe.Server(interface, port);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => landing);


# the app will run on localhost at port 8888
wait(server)
```
  
This code can be visualized at [./examples/example_readme](./examples/example_readme), or at [https://github.com/adrianariton/QuantumFristGenRepeater](https://github.com/adrianariton/QuantumFristGenRepeater)  (this will be updated shortly with the plots of the first gen repeater)

# Example 2

This time we are going to create a selectable layout with a menu, that will look like this:


!["< (left) | 1 | (right) >"](https://github.com/adrianariton/CssMMakieLayout/blob/master/examples/assets/example2.gif?raw=true)

To do this we will follow the same stept, with a modified layout function:

1. First of all include the library in your project

```julia
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown

# 1. LOAD LIBRARY   
using CssMakieLayout
```

2. Create the layout

```julia

config = Dict(
    :resolution => (1400, 700), #used for the main figures
    :smallresolution => (280, 160), #used for the menufigures
)

# define some additional style for the menufigures' container
menufigs_style = """
    display:flex;
    flex-direction: row;
    justify-content: space-around;
    background-color: rgb(242, 242, 247);
    padding-top: 20px;
    width: $(config[:resolution][1])px;
"""

landing = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Create the menufigures and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    menufigures = [Figure(backgroundcolor=:white,  resolution=config[:smallresolution]) for _ in 1:3]
    # Figure titles
    titles= ["Figure a: sin(x)",
            "Figure b: tan(x)",
            "Figure c: cos(x)"]
    
    # Active index/ hovered index: 1 2 or 3
    #   1: the first a.k.a 'a' figure is active / hovered respectively
    #   2: the second a.k.a 'b' figure is active / hovered respectively
    #   3: the third a.k.a 'c' figure is active / hovered respectively
    activeidx = Observable(1)
    hoveredidx = Observable(0)

    # Add custom click event listeners
    for i in 1:3
        on(events(menufigures[i]).mousebutton) do event
            activeidx[]=i  
            notify(activeidx)
        end
        on(events(menufigures[i]).mouseposition) do event
            hoveredidx[]=i  
            notify(hoveredidx)
        end
    end

    # Axii of each of the 6 figures
    main_axii = [Axis(mainfigures[i][1, 1]) for i in 1:3]
    menu_axii = [Axis(menufigures[i][1, 1]) for i in 1:3]

    # Plot each of the 3 figures using your own plots!
    scatter!(main_axii[1], 0:0.1:10, x -> sin(x))
    scatter!(main_axii[2], 0:0.1:10, x -> tan(x))
    scatter!(main_axii[3], 0:0.1:10, x -> log(x))

    scatter!(menu_axii[1], 0:0.1:10, x -> sin(x))
    scatter!(menu_axii[2], 0:0.1:10, x -> tan(x))
    scatter!(menu_axii[3], 0:0.1:10, x -> log(x))

    
    # Create ZStacks displaying titles below the menu graphs
    titles_zstack = [DOM.h4(t, class="upper") for t in titles]
    
    for i in 1:3
        titles_zstack[i] = zstack(titles_zstack[i], wrap(""); 
                                activeidx=@lift(($hoveredidx == i || $activeidx == i)),
                                anim=[:opacity])
    end

    # Wrap each of the menu figures and its corresponing title zstack in a div
    menufigs_andtitles = wrap([
            vstack(
                hoverable(menufigures[i], anim=[:border];
                        stayactiveif=@lift($activeidx == i)),
                titles_zstack[i];
                class="justify-center align-center "    
            ) for i in 1:3]; 
            class="menufigs",
            style=menufigs_style
        )
    
    # Create the active figure zstack and add the :whoop (zoom in) animation to it
    activefig = zstack(
                active(mainfigures[1]),
                wrap(mainfigures[2]),
                wrap(mainfigures[3]);
                activeidx=activeidx,
                anim=[:whoop])

    # Obtain reactive layout of the figures 
    return wrap(menufigs_andtitles, activefig, CssMakieLayout.formatstyle)

end
```

3. And finally Serve the app

```julia
isdefined(Main, :server) && close(server);
port = 8888
interface = "127.0.0.1"
proxy_url = ""
server = JSServe.Server(interface, port; proxy_url);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => landing);


# the app will run on localhost at port 8888
wait(server)
```