export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/freeneb/home/zhaomy/cuda/cuda-8.0/lib64
export PATH=$PATH:/freeneb/home/zhaomy/cuda/cuda-8.0/bin
export CUDA_HOME=$CUDA_HOME:/freeneb/home/zhaomy/cuda/cuda-8.0

#export KALDI_ROOT=/work103/liuruiqi/kaldi_1207
export KALDI_ROOT=/work103/kangjiawen/100819-kaldi/kaldi
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/sph2pipe_v2.5:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
