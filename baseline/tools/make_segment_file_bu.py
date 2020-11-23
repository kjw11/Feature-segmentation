
# This script split utterances into fixed segment by making segment file.
import os
import argparse


def make_seg(segment_len, src_dir, des_dir, keep_tail=False):

    segment_list = []
    with open(os.path.join(src_dir,'utt2num_frames'), 'r') as f:
        utt2num_frames = f.readlines()
    for line in utt2num_frames:
        utt = line.strip().split(' ')[0]
        length = int(line.strip().split(' ')[1])

        assert length > segment_len, 'Length only: {}'.format(length)

        num_seg = int(length/segment_len)
        for idx in range(num_seg):
            segment_line = "{}-{} {} {} {}\n".format(utt,idx,utt,float(idx*segment_len)/100, float((idx+1)*segment_len+2)/100)
            segment_list.append(segment_line)
       
        if keep_tail:
            segment_line = "{}-{} {} {} {}\n".format(utt,idx+1,utt,float((idx+1)*segment_len)/100, float(length+2)/100)
            segment_list.append(segment_line)
        else:
            segment_list[-1] = segment_line = "{}-{} {} {} {}\n".format(utt,idx,utt,float(idx*segment_len)/100, float(length+2)/100)

    # write
    with open(os.path.join(des_dir,'segments'), 'w') as f:
        for line in segment_list:
            f.write(line)


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

    assert os.path.exists(args.src_dir), 'source dir does not exist: {}'.format(args.src_dir)
    if not os.path.exists(args.des_dir):
        os.mkdir(args.des_dir)

    make_seg(args.segment_len, args.src_dir, args.des_dir, args.keep_tail)
    

if __name__ == "__main__":
    main()
