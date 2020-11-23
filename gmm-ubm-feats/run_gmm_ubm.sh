#!/bin/bash

. ./cmd.sh
. ./path.sh
set -e

#number of components
cnum=512

ubm_name=voxceleb-1000-50_no_sil-25f
gmm_name=sitw_eval_enroll
test_name=sitw_eval_test

ubm_data=vectors/${ubm_name}
gmm_data=vectors/${gmm_name}
test_data=vectors/${test_name}
trials=data/sitw_eval_test/trials/core-core.lst

exp=exp/${ubm_name}

stage=1

if [ $stage -le 1 ];then
  # train UBM model with unlabeled data
  sid/train_diag_ubm_vec.sh --nj 20 --cmd "$train_cmd" $ubm_data $cnum $exp/diag_ubm_${cnum}
fi

if [ $stage -le 2 ];then
  # train gmm with labeled data
  sid/map_diag_gmm_vec.sh --nj 20 --cmd "$train_cmd" $gmm_data $exp/diag_ubm_${cnum} $exp/diag_train_gmm_${cnum}-${gmm_name}
fi

if [ $stage -le 3 ];then
  # get log likelihoods.
  sid/score_gmm.sh --nj 20 --cmd "$train_cmd" \
    $test_data $exp/diag_train_gmm_${cnum}-${gmm_name} $exp/gmm_score_${cnum}-${gmm_name}

  sid/score_ubm.sh --nj 20 --cmd "$train_cmd" \
    $test_data $exp/diag_ubm_${cnum} $exp/ubm_score_${cnum}-${test_name}
fi

if [ $stage -le 4 ];then
  # calculate likelihood ratios as scores.
  python local/lr_score.py --gmm-scores $exp/gmm_score_${cnum}-${gmm_name} \
                           --ubm-scores $exp/ubm_score_${cnum}-${test_name} \
                           --trials $trials \
                           --lr-scores $exp/lr_scores

  eer=$(paste $trials ${exp}/lr_scores | awk '{print $6, $3}' | compute-eer - 2>/dev/null)
  echo "EER: $eer%"

#25f:
# lr EER: 30%
fi
