#!/bin/bash
# Copyright 2015   David Snyder
# Apache 2.0.
#
# This script trains PLDA models and does scoring.

use_existing_models=false
simple_length_norm=true  # If true, replace the default length normalization
                         # performed in PLDA  by an alternative that
                         # normalizes the length of the iVectors to be equal
                         # to the square root of the iVector dimension.
length_norm=false

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 6 ]; then
  echo "Usage: $0 <vec-type> <dev-dir> <enroll-dir> <test-dir> <trials-file> <scores-dir>"
fi

vec_type=$1
dev_dir=$2
enroll_dir=$3
test_dir=$4
trials=$5
scores_dir=$6

if [ "$use_existing_models" == "true" ]; then
  for f in $dev_dir/mean.vec $dev_dir/plda ; do
    [ ! -f $f ] && echo "No such file $f" && exit 1;
  done
else
  run.pl $dev_dir/log/compute_mean.log \
    ivector-mean scp:$dev_dir/$vec_type \
    $dev_dir/mean.vec || exit 1;

  if [ "$length_norm" == "true" ]; then
    run.pl $dev_dir/log/plda.log \
      ivector-compute-plda ark:$dev_dir/spk2utt \
      "ark:ivector-subtract-global-mean $dev_dir/mean.vec scp:$dev_dir/$vec_type ark:- | ivector-normalize-length ark:- ark:- |" $dev_dir/plda || exit 1;
  else
    run.pl $dev_dir/log/plda.log \
      ivector-compute-plda ark:$dev_dir/spk2utt \
      "ark:ivector-subtract-global-mean $dev_dir/mean.vec scp:$dev_dir/$vec_type ark:- |" $dev_dir/plda || exit 1;
  fi
fi

mkdir -p $scores_dir/log

if [ "$length_norm" == "true" ]; then
  run.pl $scores_dir/log/plda_scoring.log \
    ivector-plda-scoring --normalize-length=true \
      --simple-length-normalization=$simple_length_norm \
      --num-utts=ark:$enroll_dir/num_utts.ark \
      "ivector-copy-plda --smoothing=0.0 $dev_dir/plda - |" \
      "ark:ivector-mean ark:$enroll_dir/spk2utt scp:$enroll_dir/$vec_type ark:- | ivector-subtract-global-mean $dev_dir/mean.vec ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
      "ark:ivector-subtract-global-mean $dev_dir/mean.vec scp:$test_dir/$vec_type ark:- | ivector-normalize-length ark:- ark:- |" \
      "cat '$trials' | cut -d\  --fields=1,2 |" $scores_dir/plda_scores || exit 1;
else
  run.pl $scores_dir/log/plda_scoring.log \
    ivector-plda-scoring --normalize-length=true \
      --simple-length-normalization=$simple_length_norm \
      --num-utts=ark:$enroll_dir/num_utts.ark \
      "ivector-copy-plda --smoothing=0.0 $dev_dir/plda - |" \
      "ark:ivector-mean ark:$enroll_dir/spk2utt scp:$enroll_dir/$vec_type ark:- | ivector-subtract-global-mean $dev_dir/mean.vec ark:- ark:- |" \
      "ark:ivector-subtract-global-mean $dev_dir/mean.vec scp:$test_dir/$vec_type ark:- |" \
      "cat '$trials' | cut -d\  --fields=1,2 |" $scores_dir/plda_scores || exit 1;
fi

eer=$(paste $trials $scores_dir/plda_scores | awk '{print $6, $3}' | compute-eer - 2>/dev/null)
echo "PLDA EER: $eer%"
