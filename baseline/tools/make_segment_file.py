
# This script split utterances into fixed segment by making segment file.
import os
import argparse


def make_seg(segment_len, src_dir, des_dir, keep_tail=False):

    assert os.path.exists(os.path.join(des_dir,'utt2spk'))
    utt2spk_dict = {}
    with open(os.path.join(des_dir,'utt2spk')) as f:
        for line in f.readlines():
            utt = line.strip().split(' ')[0]
            spk = line.strip().split(' ')[1]
            utt2spk_dict[utt] = spk
    
    segment_list = []
    new_utt2spk = []
    with open(os.path.join(src_dir,'utt2num_frames'), 'r') as f:
        utt2num_frames = f.readlines()
    for line in utt2num_frames:
        utt = line.strip().split(' ')[0]
        spk = utt2spk_dict[utt]
        length = int(line.strip().split(' ')[1])

        assert length > segment_len, 'Length only: {}'.format(length)

        num_seg = int(length/segment_len)
        for idx in range(num_seg):
            segment_line = "{}-{} {} {} {}\n".format(utt,idx,utt,float(idx*segment_len)/100, float((idx+1)*segment_len+2)/100)
            segment_list.append(segment_line)
            new_utt2spk.append("{}-{} {}\n".format(utt, idx, spk))
       
        if keep_tail:
            segment_line = "{}-{} {} {} {}\n".format(utt,idx+1,utt,float((idx+1)*segment_len)/100, float(length+2)/100)
            segment_list.append(segment_line)
            new_utt2spk.append("{}-{} {}\n".format(utt, idx+1, spk))
        else:
            segment_list[-1] = segment_line = "{}-{} {} {} {}\n".format(utt,idx,utt,float(idx*segment_len)/100, float(length+2)/100)

    # write
    with open(os.path.join(des_dir,'segments'), 'w') as f:
        for line in segment_list:
            f.write(line)

    with open(os.path.join(des_dir,'utt2spk'), 'w') as f:
        for line in new_utt2spk:
            f.write(line)

    utt2spk_2_spk2utt(des_dir)


def utt2spk_2_spk2utt(des_dir):
    assert os.path.exists(os.path.join(des_dir,'utt2spk'))

    utt2spk_dict = {}
    with open(os.path.join(des_dir,'utt2spk')) as f:
        for line in f.readlines():
            utt = line.strip().split(' ')[0]
            spk = line.strip().split(' ')[1]
            utt2spk_dict[utt] = spk

    new_spk2utt = {}
    for k,v in utt2spk_dict.items():
        if v not in new_spk2utt:
            new_spk2utt[v] = []
        new_spk2utt[v].append(k)

    # write
    with open(os.path.join(des_dir,'spk2utt'), 'w') as f:
        for k,v in new_spk2utt.items():
            f.write(k)
            for utt in v:
                f.write(' '+utt)
            f.write('\n')
            
    
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--segment-len", type=int, default=25,
                        help="segment length")
    parser.add_argument("--src-dir", type=str, default="../data/voxceleb-1000-50_no_sil",
                        help="source dir")
    parser.add_argument("--des-dir", type=str, default="../data/voxceleb-1000-50_no_sil-25f",
                        help="tar dir")
    parser.add_argument("--keep-tail", type=bool, default=False, 
                        help ="if true, 1000=3*300+100, else 1000=2*300+400")
    args = parser.parse_args()

    #src_dir = '/work103/kangjiawen/100820-uncertainty/data/voxceleb-1000-50'
    #des_dir = '/work103/kangjiawen/100820-uncertainty/data/voxceleb-1000-50-25f'

    assert os.path.exists(os.path.join(args.src_dir,'spk2utt')), 'spk2utt file does not exist under {}'.format(args.src_dir)
    assert os.path.exists(os.path.join(args.src_dir,'utt2spk')), 'utt2spk file does not exist under {}'.format(args.src_dir)
    if not os.path.exists(args.des_dir):
        print("create tar dir")
        os.mkdir(args.des_dir)
        os.system('cp  {}/spk2utt {}'.format(args.src_dir, args.des_dir))
        os.system('cp  {}/utt2spk {}'.format(args.src_dir, args.des_dir))

    make_seg(args.segment_len, args.src_dir, args.des_dir, args.keep_tail)


if __name__ == "__main__":
    main()
