
# This scipt sample num_spk speakers, and each speaker have utt_per_spk utterances.

num_spk = 1000
utt_per_spk = 50

src_spk2utt = "../data/voxceleb-ori/spk2utt"
src_utt2spk = "../data/voxceleb-ori/utt2spk"
src_scp = "../data/voxceleb-ori/wav.scp"

des_spk2utt = "../data/voxceleb-{}-{}/spk2utt".format(num_spk, utt_per_spk) 
des_utt2spk = "../data/voxceleb-{}-{}/utt2spk".format(num_spk, utt_per_spk) 
des_scp = "../data/voxceleb-{}-{}/wav.scp".format(num_spk, utt_per_spk) 
 
def main():

    # read in
    with open(src_spk2utt, 'r') as f:
        spk2utt = f.readlines()
    with open(src_utt2spk, 'r') as f:
        utt2spk = f.readlines()
    with open(src_scp, 'r') as f:
        scp_dict = {}
        for line in f.readlines():
            utt_name = line.strip().split(' ')[0]
            name_len = len(utt_name)
            utt_dir = line.strip()[name_len:]
            scp_dict[utt_name] = utt_dir
    
    # collect utts
    utt_dict = {}
    counter = 0
    for line in spk2utt:
        #spk = line.strip().split(' ')[0]
        utts = line.strip().split(' ')[1:]
        num_utts = len(utts)
        if num_utts < utt_per_spk:
            continue
        spk = line.strip().split(' ')[0]
        utts = line.strip().split(' ')[1:51]
        utt_dict[spk] = utts
        counter = counter + 1
        if counter == num_spk:
            break

    # write
    f_utt2spk = open(des_spk2utt, 'w')
    f_spk2utt = open(des_utt2spk, 'w')
    f_scp = open(des_scp, 'w')

    for spk, utts in utt_dict.items():
        f_spk2utt.write(spk)
        for utt in utts:
            f_spk2utt.write(' '+utt)
            f_utt2spk.write(utt+' '+spk+'\n')
            f_scp.write(utt+' '+scp_dict[utt]+'\n')
        f_spk2utt.write('\n')
    

if __name__ == "__main__":
    main()
