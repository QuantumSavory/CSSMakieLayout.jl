
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown

# 1. LOAD LIBRARY   
using CssMakieLayout



config = Dict(
    :resolution => (1400, 700), #used for the main figures
    :colorscheme => ["rgb(242, 242, 247)", "black", "#000529", "white"],
    :smallresolution => (280, 160), #used for the menufigures

)

# define some style for the menufigures' container
menufigs_style = """
    display:flex;
    flex-direction: row;
    justify-content: space-around;
    background-color: $(config[:colorscheme][1]);
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

isdefined(Main, :server) && close(server);
port = 8888
interface = "127.0.0.1"
proxy_url = ""
server = JSServe.Server(interface, port; proxy_url);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => landing);


# the app will run on localhost at port 8888
wait(server)