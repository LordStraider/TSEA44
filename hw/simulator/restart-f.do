write format wave wave_restart_tmp.do
delete wave *
virtual delete *
restart -f
do mymaps.do
do wave_restart_tmp.do