
using Base.Threads
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown
import JSServe.TailwindDashboard as D

# 1. LOAD LAYOUT HELPER FUNCTION AND UTILSm    
using CssMakieLayout

## config sizes TODO: make linear w.r.t screen size
# Change between color schemes by uncommentinh lines 17-18
config = Dict(
    :resolution => (1400, 700), #used for the main figures
    :smallresolution => (280, 160), #used for the menufigures
    :colorscheme => ["rgb(242, 242, 247)", "black", "#000529", "white"]
    #:colorscheme => ["rgb(242, 242, 247)", "black", "rgb(242, 242, 247)", "black"]

)


###################### 2. LAYOUT ######################
#   Returns the reactive (click events handled by zstack)
#   layout of the activefigure (mainfigure)
#   and menufigures (the small figures at the top which get
#   clicked)

function layout_content(DOM, mainfigures #TODO: remove DOM param
    , menufigures, title_zstack, session, active_index)
    
    menufigs_style = """
        display:flex;
        flex-direction: row;
        justify-content: space-around;
        background-color: $(config[:colorscheme][1]);
        padding-top: 20px;
        width: $(config[:resolution][1])px;
    """
    menufigs_andtitles = wrap([
        vstack(
            hoverable(menufigures[i], anim=[:border], class="$(config[:colorscheme][2])";
                    observable=@lift($active_index == i)),
            title_zstack[i];
            class="justify-center align-center "    
            ) 
        for i in 1:3]; class="menufigs", style=menufigs_style)
   
    activefig = zstack(
                active(mainfigures[1]),
                wrap(mainfigures[2]),
                wrap(mainfigures[3]);
                observable=active_index,
                anim=[:whoop],
                style="width: $(config[:resolution][1])px")
    
    content = Dict(
        :activefig => activefig,
        :menufigs => menufigs_andtitles
    )
    return DOM.div(menufigs_andtitles, CssMakieLayout.formatstyle, activefig), content

end

###################### 3. PLOT FUNCTIONS ######################
#   These are used to configure each figure from the layout,
#   meaning both the menufigures and the mainfigures.
#   One can use either on whatever figure, but for the purpose
#   of this project, they will be used as such
#       |   plot_alphafig - for the first figure (Entanglement Generation)
#       |   plot_betafig - for the second figure (Entanglement Swapping)
#       |   plot_gammafig - for the third figure (Entanglement Purification)
#   , as one can see in the plot(figure_array, metas) function.


function plot_alphafig(f, meta=""; hidedecor=false)
    # This is where we will do the receipe for the first figure (Entanglement Gen)
    # for now this plot is taken from the tutorial
    ax = Axis(f[1, 1], limits = (0, 1, 0, 1))

    rs_h = IntervalSlider(f[2, 1], range = LinRange(0, 1, 1000),
        startvalues = (0.2, 0.8))
    rs_v = IntervalSlider(f[1, 2], range = LinRange(0, 1, 1000),
        startvalues = (0.4, 0.9), horizontal = false)
   
    labeltext1 = lift(rs_h.interval) do int
        string(round.(int, digits = 2))
    end
    Label(f[3, 1], labeltext1, tellwidth = false)
    labeltext2 = lift(rs_v.interval) do int
        string(round.(int, digits = 2))
    end
    Label(f[1, 3], labeltext2,
        tellheight = false, rotation = pi/2)

    points = rand(Point2f, 300)

    # color points differently if they are within the two intervals
    colors = lift(rs_h.interval, rs_v.interval) do h_int, v_int
        map(points) do p
            (h_int[1] < p[1] < h_int[2]) && (v_int[1] < p[2] < v_int[2])
        end
    end

    scatter!(ax, points, color = colors, colormap = [:black, :orange], strokewidth = 0)
    if hidedecor
        hidedecorations!(ax)
    end
end

function plot_betafig(figure, meta=""; hidedecor=false)
    # This is where we will do the receipe for the second figure (Entanglement Swap)

    ax = Axis(figure[1, 1])
    scatter!(ax, [1,2], [2,3], color=(:black, 0.2))
    axx = Axis(figure[1, 2])
    scatter!(axx, [1,2], [2,3], color=(:black, 0.2))
    axxx = Axis(figure[2, 1:2])
    scatter!(axxx, [1,2], [2,3], color=(:black, 0.2))

    if hidedecor
        hidedecorations!(ax)
        hidedecorations!(axx)
        hidedecorations!(axxx)
    end
end

function plot_gammafig(figure, meta=""; hidedecor=false)
    # This is where we will do the receipe for the third figure (Entanglement Purif)

    ax = Axis(figure[1, 1])
    scatter!(ax, [1,2], [2,3], color=(:black, 0.2))

    if hidedecor
        hidedecorations!(ax)
    end
end

#   The plot function is used to prepare the receipe (plots) for
#   the mainfigures which get toggled by the identical figures in
#   the menu (the menufigures), as well as for the menufigures themselves

function plot(figure_array, metas=["", "", ""]; hidedecor=false)
    plot_alphafig(figure_array[1], metas[1]; hidedecor=hidedecor)
    plot_betafig( figure_array[2], metas[2]; hidedecor=hidedecor)
    plot_gammafig(figure_array[3], metas[3]; hidedecor=hidedecor)
end

###################### 4. LANDING PAGE OF THE APP ######################

landing = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Create the menufigures and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    menufigures = [Figure(backgroundcolor=:white,  resolution=config[:smallresolution]) for _ in 1:3]
    titles= ["Entanglement Generation",
    "Entanglement Swapping",
    "Entanglement Purification"]
    # Active index: 1 2 or 3
    #   1: the first a.k.a alpha (Entanglement Generation) figure is active
    #   2: the second a.k.a beta (Entanglement Swapping) figure is active    
    #   3: the third a.k.a gamma (Entanglement Purification) figure is active
    activeidx = Observable(1)
    hoveredidx = Observable(0)

    # CLICK EVENT LISTENERS
    for i in 1:3
        on(events(menufigures[i]).mousebutton) do event
            activeidx[]=i  
            notify(activeidx)
        end
        on(events(menufigures[i]).mouseposition) do event
            hoveredidx[]=i  
            notify(hoveredidx)
        end
        
        # TODO: figure out when mouse leaves and set hoverableidx[] to 0
    end

    # Using the aforementioned plot function to plot for each figure array
    plot(mainfigures)
    plot(menufigures; hidedecor=true)

    
    # Create ZStacks displayong titles below the menu graphs
    titles_zstack = [DOM.h4(t, class="upper") for t in titles]
    for i in 1:3
        titles_zstack[i] = zstack(titles_zstack[i], wrap(""); 
                                        observable=@lift(($hoveredidx == i || $activeidx == i)),
                                        anim=[:opacity], style="""color: $(config[:colorscheme][2]);""")
    end

    # Obtain reactive layout of the figures
    
    layout, content = layout_content(DOM, mainfigures, menufigures, titles_zstack, session, activeidx)

    # Add title to the right in the form of a ZStack
    titles_div = [DOM.h1(t) for t in titles]
    titles_div[1] = active(titles_div[1])
    titles_div = zstack(titles_div; observable=activeidx, anim=[:static]
    , style="""color: $(config[:colorscheme][4]);""") # static = no animation
    
    
    return hstack(layout, hstack(titles_div; style="padding: 20px; margin-left: 10px;
                                background-color: $(config[:colorscheme][3]);"); style="width: 100%;")

end

landing2 = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Active index: 1 2 or 3
    #   1: the first a.k.a alpha (Entanglement Generation) figure is active
    #   2: the second a.k.a beta (Entanglement Swapping) figure is active    
    #   3: the third a.k.a gamma (Entanglement Purification) figure is active
    activeidx = Observable(1)
    hoveredidx = Observable(0)

    # Create the buttons and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    buttonstyle = """
        background-color: $(config[:colorscheme][1]);
        color: $(config[:colorscheme][2]);
        border: none !important;
    """
    buttons = [button(wrap(DOM.h1("〈")); observable=activeidx, cap=3, type=:decreasecap, style=buttonstyle),
               button(wrap(DOM.h1("〉")); observable=activeidx, cap=3, type=:increasecap, style=buttonstyle)]
    
    # Titles of the plots
    titles= ["Entanglement Generation",
    "Entanglement Swapping",
    "Entanglement Purification"]
    

    # Using the aforementioned plot function to plot for each figure array
    plot(mainfigures)

    # Obtain the reactive layout
    activefig = zstack(
                active(mainfigures[1]),
                wrap(mainfigures[2]),
                wrap(mainfigures[3]);
                observable=activeidx,
                style="width: $(config[:resolution][1])px")
    

    layout = hstack(buttons[1], activefig, buttons[2])
    # Add title to the right in the form of a ZStack
    titles_div = [DOM.h1(t) for t in titles]
    titles_div[1] = active(titles_div[1])
    titles_div = zstack(titles_div; observable=activeidx, anim=[:static],
                    style="""color: $(config[:colorscheme][4]);""") # static = no animation
    
    
    return hstack(CssMakieLayout.formatstyle, layout, hstack(titles_div; style="padding: 20px;  margin-left: 10px;
                                background-color:  $(config[:colorscheme][3]);"); style="width: 100%;")

end

nav = App() do session::Session
    return vstack(DOM.a("LANDING", href="/1"), DOM.a("LANDING2", href="/2"))
end

##
# Serve the Makie app
isdefined(Main, :server) && close(server);
port = parse(Int, get(ENV, "QS_COLORCENTERMODCLUSTER_PORT", "8888"))
interface = get(ENV, "QS_COLORCENTERMODCLUSTER_IP", "127.0.0.1")
proxy_url = get(ENV, "QS_COLORCENTERMODCLUSTER_PROXY", "")
server = JSServe.Server(interface, port; proxy_url);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => nav);
JSServe.route!(server, "/1" => landing);
JSServe.route!(server, "/2" => landing2);

##

wait(server)