#
# Plots packet traffic as a stacked bar chart.
#

COL_TOTAL = '4'

set yrange [0:100]
set ylabel "% of total"
set style data histograms
set style histogram rowstacked
set key invert box outside
set style fill solid border -1
set boxwidth 0.75
set offsets 0, 0.85, 0, 0
set title "Percent of Packets as Path 2 Delay Increases"

set macros
PLOT = sprintf("using (100.*$2/$%s):xtic(1) t column(2), for [i=3:3] '' using (100.*column(i)/column(%s)) title column(i)", COL_TOTAL,COL_TOTAL)


set multiplot layout 3,1
set label 1 "128KB" at graph 0.90,0.9 font ",10"
plot "rtt-ratio-traffic-128KB.dat" @PLOT

unset title
set xlabel "Delay P2 [ms], P1 constant at 10ms"
unset label
set label 2 "1MB" at graph 0.90,0.9 font ",10"
plot "rtt-ratio-traffic-1MB.dat" @PLOT

set xlabel "Delay P2 [ms], P1 constant at 10ms"
unset label
set label 2 "10MB" at graph 0.90,0.9 font ",10"
plot "rtt-ratio-traffic-10MB.dat" @PLOT
unset multiplot
