#!/bin/bash

. ./cmd.sh
. ./path.sh

set -e

mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc
data=data
nnet_dir=exp/xvector_nnet_vox-1000-50
exp=exp

stage=5


if [ $stage -le 0 ]; then
  for sub in voxceleb-1000-50; do
    utils/fix_data_dir.sh data/$sub
    steps/make_mfcc.sh --mfcc-config conf/mfcc.conf \
      --nj 15 --cmd "$cmd" \
      data/$sub exp/make_mfcc $mfccdir
    sid/compute_vad_decision.sh --vad-config conf/vad.conf \
      --nj 15 --cmd "$cmd" \
      data/$sub exp/make_vad $vaddir
    utils/fix_data_dir.sh data/$sub

  done
fi


if [ $stage -le 1 ]; then
  local/nnet3/xvector/prepare_feats_for_egs.sh --nj 15 --cmd "$cmd" \
    $data/voxceleb-1000-50 $data/voxceleb-1000-50_no_sil $exp/voxceleb-1000-50_no_sil
  utils/fix_data_dir.sh $data/voxceleb-1000-50_no_sil
fi


if [ $stage -le 2 ]; then
  # remove short features
  min_len=400
  mv $data/voxceleb-1000-50_no_sil/utt2num_frames $data/voxceleb-1000-50_no_sil/utt2num_frames.bak
  awk -v min_len=${min_len} '$2 > min_len {print $1, $2}' $data/voxceleb-1000-50_no_sil/utt2num_frames.bak > $data/voxceleb-1000-50_no_sil/utt2num_frames
  utils/filter_scp.pl $data/voxceleb-1000-50_no_sil/utt2num_frames $data/voxceleb-1000-50_no_sil/utt2spk > $data/voxceleb-1000-50_no_sil/utt2spk.new
  mv $data/voxceleb-1000-50_no_sil/utt2spk.new $data/voxceleb-1000-50_no_sil/utt2spk
  utils/fix_data_dir.sh $data/voxceleb-1000-50_no_sil
fi


if [ $stage -le 3 ]; then
  # Stages 6 through 8 are handled in run_xvector.sh
  local/nnet3/xvector/run_xvector.sh --stage 8 --train-stage -1 \
    --data data/voxceleb-1000-50_no_sil --nnet-dir $nnet_dir \
    --egs-dir $nnet_dir/egs
fi


if [ $stage -le 4 ]; then
  # extract vectors used in back-end
  sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd" --nj 30 \
    $nnet_dir data/voxceleb-1000-50 \
    $nnet_dir/xvectors_voxceleb-1000-50

  # Extract x-vectors used in the evaluation.
  for name in sitw_eval_enroll sitw_eval_test; do
    sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd" --nj 30 \
      $nnet_dir data/$name \
      $nnet_dir/xvectors_$name
  done
fi

if [ $stage -le -1 ]; then
    cp $data/voxceleb-1000-50/{spk2utt,utt2spk} $nnet_dir/xvectors_voxceleb-1000-50
    cp $data/sitw_dev_enroll/spk2utt $nnet_dir/xvectors_sitw_dev_enroll
    awk '{print $1,NF-1}' $data/sitw_dev_enroll/spk2utt > $nnet_dir/xvectors_sitw_dev_enroll/num_utts.ark
    echo "SITW DEV:"
    tools/compute_eer.sh --lda-dim 150 \
                         xvector.scp \
                         $nnet_dir/xvectors_voxceleb-1000-50 \
                         $nnet_dir/xvectors_sitw_dev_enroll \
                         $nnet_dir/xvectors_sitw_dev_test \
                         data/sitw_dev_test/trials/core-core.lst \
                         scores/sitw_dev
    #Cosine EER: 19.06%
    #LDA_PLDA EER: 11.71%
fi


if [ $stage -le 6 ]; then
    cp $data/sitw_eval_enroll/spk2utt $nnet_dir/xvectors_sitw_eval_enroll
    awk '{print $1,NF-1}' $data/sitw_eval_enroll/spk2utt > $nnet_dir/xvectors_sitw_eval_enroll/num_utts.ark
    echo "SITW EVAL:"
    tools/compute_eer.sh --lda-dim 150 \
                         xvector.scp \
                         $nnet_dir/xvectors_voxceleb-1000-50 \
                         $nnet_dir/xvectors_sitw_eval_enroll \
                         $nnet_dir/xvectors_sitw_eval_test \
                         data/sitw_eval_test/trials/core-core.lst \
                         scores/sitw_eval
    # Cosine EER: 18.94%
    # LDA_PLDA EER: 10.06%

fi



