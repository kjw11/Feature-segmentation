import os
import numpy as np
import argparse
import matplotlib.pyplot as plt
from sklearn.manifold import TSNE


def data_sampler(npz_path, seed=123, num_class=10, num_sample=100):
    print("sampling class: {}, sample num: {}".format(num_class, num_sample))
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

    #print(np.shape(sample_data))
    #print(np.shape(sample_meta))
    print("sampled class: {}, sample num: {}".format(num_class, num_sample))

    return sample_data, sample_meta
  

def tsne_plotter(data, label, save_png, title):
    n_labels = len(set(label))
    tsne = TSNE(n_components=2, init='pca', learning_rate=10, perplexity=12, n_iter=1000)
    transformed_data = tsne.fit_transform(data)

    plt.figure()
    plt.scatter(transformed_data[:, 0], transformed_data[:, 1], 10, c=label, cmap=plt.cm.Spectral, alpha=0.5)
    plt.title(title)
    plt.savefig(save_png)
 

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-npz", type=str, default="feats.npz",
                        help="file of npz data.")
    parser.add_argument("--seed", type=int, default=123,
                        help="Seed for random number generator")
    parser.add_argument("--num-class", type=int, default=10,
                        help="The number of classes sampled.")
    parser.add_argument("--num-sample", type=int, default=1000, 
                        help="The number of samples per class.")
    parser.add_argument("--save-png", type=str, default="tsne.png", 
                        help="file of saved png.")
    parser.add_argument("--title", type=str, default="xxx", 
                        help="title of png.")
    args = parser.parse_args()

    data, label = data_sampler(args.data_npz, args.seed, args.num_class, args.num_sample)
    tsne_plotter(data, label, args.save_png, args.title)

