#
# Gnuplot script to plot goodput
#


FILE = "rtt-ratio-goodput.dat"
set terminal wxt size 800,800

set title "Goodput as Path 2 Delay Increases - 0.1% packet loss, OLIA, minRTT scheduler"
set ylabel "Goodput [Mbit/sec]"
set style data linespoints
set key right top 

set multiplot layout 3,1
set label 1 "128KB" at graph 0.5,0.9 center font ",10"
plot FILE index 0 using 2:xtic(1) title "MPTCP", '' index 0 using 3:xtic(1) title "Single Path"

unset title
unset label

set label 2 "1MB" at graph 0.5,0.9 center font ",10"
plot FILE index 1 using 2:xtic(1) title "MPTCP", '' index 1 using 3:xtic(1) title "Single Path"

unset label

set xlabel "Delay P2 [ms], P1 consant at 10ms"
set label 3 "10MB" at graph 0.5,0.9 center font ",10"
plot FILE index 2 using 2:xtic(1) title "MPTCP", '' index 2 using 3:xtic(1) title "Single Path"
unset multiplot
