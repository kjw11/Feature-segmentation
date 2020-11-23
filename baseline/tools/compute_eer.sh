#!/bin/bash
# Copyright   2017   Johns Hopkins University (Author: Daniel Garcia-Romero)
#             2017   Johns Hopkins University (Author: Daniel Povey)
#        2017-2018   David Snyder
#             2018   Ewald Enzinger
#             2019   Lantian Li
# Apache 2.0.
#
# This is an x-vector-based recipe for speaker recognition evaluation.

# number of components
lda_dim=150

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

vec_type=$1
dev_dir=$2
enroll_dir=$3
test_dir=$4
trials=$5
scores_dir=$6

# Cosine metric.
tools/cosine_scoring.sh $vec_type $dev_dir $enroll_dir $test_dir \
                        $trials $scores_dir

# Create a PLDA model and do scoring.
#tools/plda_scoring.sh --simple-length-norm true \
#                      $vec_type $dev_dir $enroll_dir $test_dir \
#                      $trials $scores_dir

# Create a LDA-PLDA model and do scoring.
tools/lda_plda_scoring.sh --lda-dim $lda_dim --covar-factor 0.0 \
                          --simple-length-norm true \
                          $vec_type $dev_dir $enroll_dir $test_dir \
                          $trials $scores_dir
