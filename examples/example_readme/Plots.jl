
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