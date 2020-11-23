#!/bin/bash

. ./cmd.sh
. ./path.sh

stage=$1
model=$2


# T-SNE
if [ $stage -eq 1 ]; then
  echo $model
  for ((infer_epoch=0; infer_epoch<1001; infer_epoch=infer_epoch+100)); do
    echo $infer_epoch
    data_npz=$model/$infer_epoch/P100/feats.npz

    mdl=`basename $model`
    mkdir -p tsne/$mdl/P100
    save_png=tsne/$mdl/P100/${infer_epoch}.png

    python tools/tsne.py --data-npz $data_npz \
                         --seed 1 \
                         --num-class 10 \
                         --num-sample 200 \
                         --save-png $save_png \
                         --title $infer_epoch

  done
fi


# Prepare_TSV
if [ $stage -eq 2 ]; then
  echo $model
  for ((infer_epoch=0; infer_epoch<1001; infer_epoch=infer_epoch+100)); do
    echo $infer_epoch
    data_npz=$model/$infer_epoch/P100/feats.npz
    python tools/prepare_tsv.py --npz-path $data_npz \
                                --prefix P100 \
                                --seed 1 \
                                --num-class 10 \
                                --num-sample 200

  done
fi


# T-SNE
if [ $stage -eq 3 ]; then
  echo $model
  mdl=`basename $model`
  for sub in P80 P20; do
    mkdir -p tsne/$mdl/$sub
    for ((infer_epoch=0; infer_epoch<1001; infer_epoch=infer_epoch+100)); do
      echo $infer_epoch
      data_npz=$model/$infer_epoch/$sub/feats.npz
      save_png=tsne/$mdl/$sub/${infer_epoch}.png
  
      python tools/tsne.py --data-npz $data_npz \
                           --seed 1 \
                           --num-class 10 \
                           --num-sample 200 \
                           --save-png $save_png \
                           --title $infer_epoch
  
    done
  done
fi


# Prepare_TSV
if [ $stage -eq 4 ]; then
  echo $model
  for sub in digits_enroll; do
    for ((infer_epoch=0; infer_epoch<1001; infer_epoch=infer_epoch+100)); do
      echo $infer_epoch
      data_npz=$model/$infer_epoch/$sub/feats.npz
      python tools/prepare_tsv.py --npz-path $data_npz \
                                  --prefix digits \
                                  --seed 1 \
                                  --num-class 10 \
                                  --num-sample 200

    done
  done
fi

