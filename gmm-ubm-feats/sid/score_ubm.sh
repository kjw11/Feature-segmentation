#!/bin/bash
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey).  Apache 2.0.
#           2013  Daniel Povey

# This trains a full-covariance UBM from an existing (diagonal or full) UBM,
# for a specified number of iterations.  This is for speaker-id systems
# (we use features specialized for that, and vad).

# Begin configuration section.
nj=16
cmd=run.pl

# End configuration section.

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 3 ]; then
  echo "Usage: steps/score_diag_gmm.sh <data> <diag-gmm-dir> <score-dir>"
  echo "Evaluates on speaker gmms."
  echo " e.g.: steps/score_diag_gmm.sh data/test exp/spk_gmm exp/gmm_score"
  echo "main options (for others, see top of script file)"
  echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
  echo "  --nj <n|16>                                      # Number of parallel training jobs"
  exit 1;
fi

data=$1
gmmdir=$2
scoredir=$3

for f in $data/feats.scp; do
  [ ! -f $f ] && echo "No such file $f" && exit 1;
done

mkdir -p $scoredir/log

sdata=$data/split$nj;
utils/split_data.sh $data $nj || exit 1;

delta_opts=`cat $gmmdir/delta_opts 2>/dev/null`

# Pre-processing
#feats="ark,s,cs:add-deltas $delta_opts scp:$sdata/JOB/feats.scp ark:- | apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 ark:- ark:- | select-voiced-frames ark:- scp,s,cs:$sdata/JOB/vad.scp ark:- |"

# Or no pre-processing
feats="scp:$data/feats.scp"

gmm-global-get-frame-likes --average=true $gmmdir/final.dubm "$feats" ark,t:$scoredir/ubm.score
echo UBM-scoring is done!

#rm -r $scoredir/log
exit 0;

