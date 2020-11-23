# "queue.pl" uses qsub.  The options to it are
# options to qsub.  If you have GridEngine installed,
# change this to a queue you have access to.
# Otherwise, use "run.pl", which will run jobs locally
# (make sure your --num-jobs options are no more than
# the number of cpus on your machine.

#a) JHU cluster options
export cmd="run.pl"
#export train_cmd="queue.pl -l arch=*64* -q tiger.cpu.q"
#export train_cmd="queue.pl -l arch=*64*  -q tiger.cpu.q@tiger01 -q tiger.cpu.q@tiger04"
export train_cmd="run.pl"

#export gpu_cmd="queue.pl -q tiger.gpu.q"
export gpu_cmd="queue.pl -q tiger.gpu.q@tiger01  -q tiger.gpu.q@tiger04"
#export gpu_cmd="run.pl"
#export iv_cmd="queue.pl -q tiger.iv.q@tiger01 -q tiger.iv.q@tiger02  -q tiger.iv.q@tiger03"
