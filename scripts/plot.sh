#!/usr/bin/gnuplot -c

# GNUPLOT script file. Edit to change plot formatting.

set title ARG3

set term png
set output ARG2 

set xlabel "seconds"
set ylabel "Mbits/sec"

set xrange [0:]
set yrange [0:]

set key right bottom

plot ARG1 with linespoints title "bandwidth"
