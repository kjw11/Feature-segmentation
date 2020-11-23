import math
import numpy as np
import kaldi_io
import argparse
from scipy import stats

def get_skew_and_kurt(data):
    '''calculate skew and kurt'''
    data = data.transpose()
    skew = []
    kurt = []
    for i in data:
        _s = stats.skew(i)
        _k = stats.kurtosis(i)
        skew.append(_s)
        kurt.append(_k)
    skew_mean = sum(skew)/len(skew)
    kurt_mean = sum(kurt)/len(kurt)
    return skew_mean, kurt_mean


def mat_flt_ark2npz(kaldi_mat_ark):
    data = []
    for _, v in kaldi_io.read_mat_ark(kaldi_mat_ark):
        data.append(v)
    data = np.array(data)
    print(data.shape)
    data = np.vstack(data)
    print(data.shape)
    return data


if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--src-file', help='src file of feats.(ark)')
    args = parser.parse_args()

    data = mat_flt_ark2npz(args.src_file)
    skew, kurt = get_skew_and_kurt(data)
    print('skew = {}  kurt = {}'.format(skew, kurt))

