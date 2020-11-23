#!/bin/bash

. cmd.sh
. path.sh

set -e

binary=true
update_flags="mvw" # Which GMM parameters will be updated: subset of "mvw".
mean_tau= # Tau value for updating means "m". (float, default = 10)
variance_tau= #  Tau value for updating variances "v". (float, default = 10)
weight_tau= # Tau value for updating weight "w". (float, default = 10)

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# != 5 ]; then
   echo "e.g.: $0 feats.scp nJOB"
   exit 1;
fi

featdir=$1
nJOB=$2
ubmDir=$3
train_acc=$4
train_gmm=$5

cat $featdir | while read line; do

  model=`echo $line | awk '{print $1}'`
  echo $line > $train_acc/single.$nJOB.scp
  feats="ark,s,cs:copy-feats scp:$train_acc/single.$nJOB.scp ark:- |"
  gmm-global-acc-stats --binary=$binary --update-flags=$update_flags \
    $ubmDir "$feats" $train_acc/$model.sp.acc

  gmm-global-est-map --binary=$binary --update-flags=$update_flags --mean-tau=$mean_tau \
    $ubmDir $train_acc/$model.sp.acc $train_gmm/$model.mod
done

rm $train_acc/single.$nJOB.scp

