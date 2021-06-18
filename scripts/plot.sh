#!/usr/bin/gnuplot -c

# TODO set title from args
set title "MPTCP Bandwith from Iperf"

set term png
# TODO set file name from args
set output "test.png"

set xlabel "seconds"
set ylabel "Mbit/sec"

set xrange [0:]
set yrange [0:]

set key right bottom

plot ARG1 with linespoints title "bandwidth"
