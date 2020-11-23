import os
import numpy as np
import argparse

def mk_gmm_scores_dict(scores_dir):
    '''
    make a dict:{enroll spk1: [(test_utt1,score),(test_utt2,score), ...],
                 enroll spk2: [(test_utt1,score),(test_utt2,score), ...],
                 ...}
    '''    
    scores_dict = {}
    all_enroll = os.listdir(scores_dir)
    all_enroll.remove('log')

    for enroll in all_enroll:
        enroll_spk = enroll.strip().split('.')[0]
        with open(os.path.join(scores_dir, enroll), 'r') as f:
            all_test = []
            for line in f.readlines():
                test_utt = line.strip().split(' ')[0]
                score = line.strip().split(' ')[1]
                all_test.append((test_utt,score))

        scores_dict[enroll_spk] = all_test
       
    return scores_dict

def mk_ubm_scores_dict(scores_dir):

    scores_dict = {}
    with open(os.path.join(scores_dir, 'ubm.score'), 'r') as f:
        for line in f.readlines():
            test_utt = line.strip().split(' ')[0]
            score = line.strip().split(' ')[1]
            scores_dict[test_utt] = score

    return scores_dict


def lr_scoring(trials_dir, gmm_scores, ubm_scores, lr_scores_dir):
    lr_scores = []
    with open (lr_scores_dir, 'a+') as f:
        with open(trials_dir, 'r') as ff:
            trials = ff.readlines()
        for line in trials:
            enroll_spk = line.strip().split(' ')[0]
            test_utt = line.strip().split(' ')[1]
            
            gmm_score = []
            # search gmm score
            for con in gmm_scores[enroll_spk]:
                if con[0] == test_utt:
                    gmm_score = con[1]
                    break

            if gmm_score == []:
                raise IndexError("Trial enroll:'{}' test:'{}' not found in scores file".format(enroll_spk,test_utt))

            # get ubm score
            ubm_score = ubm_scores[test_utt]

            # lr = log(gmm) - log(ubm)
            lr = float(gmm_score) - float(ubm_score)

            f.write(enroll_spk+' '+test_utt+' '+str(lr)+'\n')


def main():
      

    parser = argparse.ArgumentParser()
    parser.add_argument("--gmm-scores", type=str, default="/work103/kangjiawen/100820-uncertainty/gmm-ubm/exp/voxceleb-1000-50_no_sil-25f/gmm_score_512",
                        help="Path of gmm scores.")
    parser.add_argument("--ubm-scores", type=str, default="/work103/kangjiawen/100820-uncertainty/gmm-ubm/exp/voxceleb-1000-50_no_sil-25f/ubm_score_512",
                        help="Path of ubm scores.")
    parser.add_argument("--trials", type=str, default="/work103/kangjiawen/100820-uncertainty/gmm-ubm/data/sitw_eval_test/trials/core-core.lst",
                        help="Path of trials list.")
    parser.add_argument("--lr-scores", type=str, default="./scores",
                        help="Path of trials list.")
    args = parser.parse_args()

    # make a dict:{enroll spk: [(test_utt1,score),(test_utt2,score)...]}
    gmm_scores = mk_gmm_scores_dict(args.gmm_scores)
    ubm_scores = mk_ubm_scores_dict(args.ubm_scores)
    lr_scoring(args.trials, gmm_scores, ubm_scores, args.lr_scores)


if __name__ == '__main__':
  main()
