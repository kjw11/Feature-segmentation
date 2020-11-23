import os
import numpy as np
from matplotlib import pyplot as plt

if __name__ == "__main__":
    px_loss = np.loadtxt('px.loss', dtype=np.float).T
    pz_loss = np.loadtxt('pz.loss', dtype=np.float).T
    det_loss = np.loadtxt('det.loss', dtype=np.float).T
    
    assert(len(px_loss)==len(pz_loss))
    assert(len(px_loss)==len(det_loss))

    x = np.arange(1, len(px_loss) + 1)
    plt.figure()
    plt.title("ML DNF Loss")
    plt.xlabel("Loss")
    plt.ylabel("Epoch")

    plt.plot(x, px_loss, label='px')
    plt.plot(x, pz_loss, label='pz')
    plt.plot(x, det_loss, label='jacob')

    plt.legend()

    plt.savefig('ml_dnf.png')

