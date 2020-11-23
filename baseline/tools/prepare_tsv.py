import os
import numpy as np
import argparse


def tsv_saver(path, data):
    if len(data.shape) == 1:
        data = data.flatten()
        with open(path, 'w') as f:
            for i in range(len(data)):
                f.write(str(data[i]) + '\n')
            print("Saved in {}".format(path))
    else:
        num, dim = data.shape
        with open(path, 'w') as f:
            for i in range(num):
                for d in range(dim):
                    f.write(str(data[i][d]) + '\t')
                f.write('\n')
            print("Saved in {}".format(path))


def tsv_writer(prefix, data, meta):
    data_path = prefix + '_data.tsv'
    tsv_saver(data_path, data)
    meta_path = prefix + '_meta.tsv'
    tsv_saver(meta_path, meta)


def tsv_sampler(npz_path, prefix, seed, num_class, num_sample):
    print("sample class: {}, sample num: {}".format(num_class, num_sample))
    np.random.seed(seed)
    feats = np.load(npz_path)['feats']
    spkers = np.load(npz_path)['spker_label']
    print("feats shape: ", np.shape(feats))
    print("spker label shape: ", np.shape(spkers))
    print("num of spker: ", np.shape(np.unique(spkers)))

    # shuffle feats and spkers
    np.random.seed(seed)
    np.random.shuffle(feats)
    np.random.seed(seed)
    np.random.shuffle(spkers)

    class_idx = []
    while (len(class_idx) < num_class):
        idx = np.random.randint(0, len(np.unique(spkers)))
        if idx not in class_idx:
            class_idx.append(idx)

    sample_data = []
    sample_meta = []
    meta = 0
    for idx in class_idx:
        cnt = 0
        for i in range(len(spkers)):
            if (idx == spkers[i]):
                if (cnt < num_sample):
                    cnt += 1
                    sample_data.append(feats[i])
                    sample_meta.append(meta)
                else:
                    break
        meta += 1

    sample_data = np.array(sample_data)
    sample_meta = np.array(sample_meta)
    tsv_writer(prefix=prefix, data=sample_data, meta=sample_meta)
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--npz-path", type=str, default="feats.npz",
                        help="Path of npz data.")
    parser.add_argument("--prefix", type=str, default="",
                        help="Adds a prefix to the output tsv files.")
    parser.add_argument("--seed", type=int, default=123,
                        help="Seed for random number generator")
    parser.add_argument("--num-class", type=int, default=10,
                        help="The number of classes sampled.")
    parser.add_argument("--num-sample", type=int, default=1000, 
                        help="The number of samples per class.")
    args = parser.parse_args()

    tsv_sampler(args.npz_path, args.prefix, args.seed, args.num_class, args.num_sample)
