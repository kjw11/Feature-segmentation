#!/bin/bash

# This file firstly make a segment file, then use extract-feature-segments
# to extract features according to segment file.

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

segment_len=$1
src_dir=$2
des_dir=$3

stage=0

if [ $stage -le 0 ];then
  # make segment file
  python tools/make_segment_file.py  --segment-len $segment_len \
                               --src-dir $src_dir \
                               --des-dir $des_dir  
fi

if [ $stage -le 1 ];then
  # extract features according to segment file
  extract-feature-segments scp:$src_dir/feats.scp $des_dir/segments ark,scp:$(realpath $des_dir)/feats.ark,$(realpath $des_dir)/feats.scp
fi

