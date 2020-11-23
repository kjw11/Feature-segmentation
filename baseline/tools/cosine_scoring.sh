#!/bin/bash
# This script does cosine scoring.

use_global_mean=false

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

mkdir -p $scores_dir/log

if [ "$use_global_mean" == "true" ]; then
  run.pl $dev_dir/log/compute_mean.log \
   ivector-normalize-length scp:$dev_dir/$vec_type \
    ark:- \| ivector-mean ark:- $dev_dir/mean.vec || exit 1;

  run.pl $scores_dir/log/cosine_scoring.log \
   cat $trials \| awk '{print $1" "$2}' \| \
   ivector-compute-dot-products - \
    "ark:ivector-mean ark:$enroll_dir/spk2utt scp:$enroll_dir/$vec_type ark:- | ivector-normalize-length ark:- ark:- | ivector-subtract-global-mean $dev_dir/mean.vec ark:- ark:-  | ivector-normalize-length ark:- ark:- |" \
    "ark:ivector-normalize-length scp:$test_dir/$vec_type ark:- | ivector-subtract-global-mean $dev_dir/mean.vec ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
     $scores_dir/cosine_scores || exit 1;
else
  run.pl $scores_dir/log/cosine_scoring.log \
   cat $trials \| awk '{print $1" "$2}' \| \
   ivector-compute-dot-products - \
    "ark:ivector-mean ark:$enroll_dir/spk2utt scp:$enroll_dir/$vec_type ark:- | ivector-normalize-length ark:- ark:- |" \
    "ark:ivector-normalize-length scp:$test_dir/$vec_type ark:- |" \
     $scores_dir/cosine_scores || exit 1;
fi

eer=$(paste $trials $scores_dir/cosine_scores | awk '{print $6, $3}' | compute-eer - 2>/dev/null)
echo "Cosine EER: $eer%"
