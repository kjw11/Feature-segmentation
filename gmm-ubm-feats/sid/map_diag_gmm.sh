#!/bin/bash
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey).  Apache 2.0.
#           2013  Daniel Povey

# This trains a full-covariance UBM from an existing (diagonal or full) UBM,
# for a specified number of iterations.  This is for speaker-id systems
# (we use features specialized for that, and vad).

# Begin configuration section.
nj=16
cmd=run.pl

binary=true
update_flags="mvw" # Which GMM parameters will be updated: subset of "mvw".
mean_tau= # Tau value for updating means "m". (float, default = 10)
variance_tau= #  Tau value for updating variances "v". (float, default = 10)
weight_tau= # Tau value for updating weight "w". (float, default = 10)
cleanup=true
# End configuration section.

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 3 ]; then
  echo "Usage: steps/map_diag_gmm.sh <data> <diag-ubm-dir> <diag-gmm-dir>"
  echo "Trains speaker gmms from an existing diagonal UBM."
  echo " e.g.: steps/map_diag_gmm.sh data/train exp/diag_ubm exp/spk_gmm"
  echo "main options (for others, see top of script file)"
  echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
  echo "  --nj <n|16>                                      # Number of parallel training jobs"
  echo "  --update-flags                                   # A subset of "mvw""
  echo "  --mean-tau <default = 10>                        # Tau value for updating means "m""
  echo "  --variance-tau <default = 10>                    # Tau value for updating means "v""
  echo "  --weight-tau <default = 10>                        # Tau value for updating means "w""
  exit 1;
fi

data=$1
srcdir=$2
dir=$3

for f in $data/feats.scp $data/vad.scp; do
  [ ! -f $f ] && echo "No such file $f" && exit 1;
done

mkdir -p $dir/acc $dir/gmm $dir/log
echo $nj > $dir/num_jobs
sdata=$data/split$nj;
utils/split_data.sh $data $nj || exit 1;

delta_opts=`cat $srcdir/delta_opts 2>/dev/null`
if [ -f $srcdir/delta_opts ]; then
  cp $srcdir/delta_opts $dir/ 2>/dev/null
fi

if [ -f $srcdir/final.dubm ]; then # diagonal-covariance in $srcdir
  
  feats="scp:xvector.scp"
  ## Set up features.
  $cmd JOB=1:$nj $dir/log/get_spk_feats.JOB.log \
  concat-segments $feats $sdata/JOB/spk2utt ark,scp:$sdata/JOB/spk_feats.ark,$sdata/JOB/spk_feats.scp \
   || exit 1;

  ## GMM training.
  echo Model adaption: --update-flags=$update_flags --mean-tau=$mean_tau
  $cmd JOB=1:$nj $dir/log/convert_diag_to_gmm.JOB.log \
    sid/map.sh --binary $binary --update-flags "$update_flags" --mean-tau $mean_tau \
      $sdata/JOB/spk_feats.scp JOB $srcdir/final.dubm $dir/acc $dir/gmm
  wait

else
  echo "$0: in $srcdir, expecting final.dubm to exist"
  exit 1;
fi

$cleanup && rm -r $dir/acc

exit 0;

