#!/bin/sh
if test -f /usr/local/bin/xc3sprog
then
# Assume that Impact does not work if xc3sprog is installed
    /usr/local/bin/xc3sprog -v $1 2
else
# We are probably in a Windows environment, try to run Impact in batch mode
    echo 'setmode -bs' > impactbatch.cmd
    echo 'setcable -port auto' >> impactbatch.cmd
    echo 'loadcdf -file avnetchain.cdf' >> impactbatch.cmd
    echo "setAttribute -position 3 -attr configFileName -value $1" >> impactbatch.cmd
    echo "program -p 3" >> impactbatch.cmd
    echo "quit" >> impactbatch.cmd
    impact -batch impactbatch.cmd
fi



