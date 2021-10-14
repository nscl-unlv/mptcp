#
# Plots packet traffic as a stacked bar chart.
#

FILE = "rtt-ratio-traffic.dat"
COL_TOTAL = '4'

set yrange [0:100]
set ylabel "% of total"
set style data histograms
set style histogram rowstacked
set key invert box outside
set style fill solid border -1
set boxwidth 0.75
set offsets 0, 0.85, 0, 0
set title "Percent of Packets as Path 2 Delay Increases - 0.1% packet loss, OLIA, minRTT scheduler"


set multiplot layout 3,1
set label 1 "128KB" at graph 0.90,0.9 font ",10"
plot FILE index 0 using (100.*$2/$4):xtic(1) title 'P1', '' index 0 using (100.*$3/$4) title 'P2'

unset title
unset label

set label 2 "1MB" at graph 0.90,0.9 font ",10"
plot FILE index 1 using (100.*$2/$4):xtic(1) title 'P1', '' index 1 using (100.*$3/$4) title 'P2'

unset label

set xlabel "Delay P2 [ms], P1 constant at 10ms"
set label 2 "10MB" at graph 0.90,0.9 font ",10"
plot FILE index 2 using (100.*$2/$4):xtic(1) title 'P1', '' index 2 using (100.*$3/$4) title 'P2'
unset multiplot
