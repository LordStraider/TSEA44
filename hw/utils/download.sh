#!/bin/sh
echo 'setmode -bs' > impactbatch.cmd
echo 'setcable -port auto' >> impactbatch.cmd
echo 'loadcdf -file avnetchain.cdf' >> impactbatch.cmd
echo "setAttribute -position 3 -attr configFileName -value $1" >> impactbatch.cmd
echo "program -p 3" >> impactbatch.cmd
echo "quit" >> impactbatch.cmd
impact -batch impactbatch.cmd




