# CSSMakieLayout.jl
This library helps in the development of reactive frontends and can be
used alongside **WGLMakie** and **JSServe**.

## Example 1
For example let's say we want to create a view in which we can visualize
one of three figures (**a**, **b** and **c**) in a slider manner. 
We also want to control the slider with two buttons: `LEFT` and `RIGHT`. The
`RIGHT` button slided to the next figure and the `LEFT` one slides to the
figure before.

The layout would look something like this:

!["< (left) | 1 | (right) >"](https://github.com/adrianariton/CssMMakieLayout/blob/master/examples/assets/example1.gif?raw=true)

By acting on the buttons, one moves from one figure to the other.

### This can be easily implemented using **CSSMakieLayout.jl**

1. First of all include the library in your project

```julia
using Base.Threads
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown
import JSServe.TailwindDashboard as D

# 1. LOAD LIBRARY   
using CssMakieLayout
```
2. Then define your layout using CSSMakieLayout.jl,

```julia

landing = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Active index: 1 2 or 3
    #   1: the first a.k.a 'a' figure is active
    #   2: the second a.k.a 'b' figure is active    
    #   3: the third a.k.a 'c' figure is active
    activeidx = Observable(1)

    # Create the buttons and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    
    buttons = [button(wrap(DOM.h1("〈")); observable=activeidx, cap=3, type=:decreasecap),
               button(wrap(DOM.h1("〉")); observable=activeidx, cap=3, type=:increasecap)]
    
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
                observable=activeidx,
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
proxy_url = ""
server = JSServe.Server(interface, port; proxy_url);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => landing);


# the app will run on localhost at port 8888
wait(server)
```
  
This code can be visualized at [./examples/example_readme](./examples/example_readme), or at [https://github.com/adrianariton/QuantumFristGenRepeater](https://github.com/adrianariton/QuantumFristGenRepeater)  (this will be updated shortly with the plots of the first gen repeater)