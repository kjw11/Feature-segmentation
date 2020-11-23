
#!/bin/bash

. ./cmd.sh
. ./path.sh

set -e

seg_len=100
nnet_dir=$(realpath exp/xvector_nnet_vox-1000-50)
data_name=voxceleb-1000-50_no_sil

stage=7

if [ $stage -le 7 ]; then
  # We split utterance into segments with fixed length.
  tools/split_feats.sh ${seg_len} data/$data_name data/$data_name-${seg_len}f
fi

if [ $stage -le 8 ]; then
  # extract deep feature vectors
  sid/nnet3/xvector/extract_xvectors_no_vad.sh --cmd "$train_cmd" --nj 8 \
    $nnet_dir data/$data_name-${seg_len}f \
    $nnet_dir/xvectors_$data_name-${seg_len}f

fi

exit 0;

if [ $stage -le 9 ]; then
  # For DNF training, convert kaldi format to numpy format.
  for name in voxceleb-1000-50_no_sil-25f;do
    python -u local/kaldi2npz.py \
         --src-file $nnet_dir/xvectors_$name/xvector.scp \
         --dest-file  npz/${name}.npz \
         --utt2spk-file data/$name/utt2spk
  done
fi
