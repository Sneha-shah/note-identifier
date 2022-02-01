load FreqArr.mat
load FreqMap.mat
load notes.mat

Fs = 44100;
len = 10; %in seconds
t = 1/Fs:1/Fs:len;

for i = 30:-1:1
% for i = 15:2:69
% for i = 73:4:110
% for i = 117:7:170
% for i = 170:10:525
% for i = 525:30:900
% for i = 900:50:1600
% for i = 1600:100:3000
    
    f = FreqArr{i}; %in Hz
    w = 2 * pi * f;

    y = sin(w*t);

    file_name = "../Project_Pa/TSin/Sin_" + notes(i) + int2str(f) + ".wav";
    audiowrite(file_name,y,Fs);

    sound(y, Fs);
    pause(1);

end



%%% Sounds to create:
% sin waves of all freq at Fs = 44100 % DONE
% tones with exact harmonics
% single file with multiple sin waves or tones
% record voice or take from stored files

%%% Note frequencies
% 
% load notes.mat
% 
% key_n = cell(108,1);
% key_n(10:97) = cellstr(notes);
% key_n(1) = {'C0'};
% key_n(2) = {'Dd0'};
% key_n(3) = {'D0'};
% key_n(4) = {'Eb0'};
% key_n(5) = {'E0'};
% key_n(6) = {'F0'};
% key_n(7) = {'Gg0'};
% key_n(8) = {'G0'};
% key_n(9) = {'Ab0'};
% key_n(98) = {'Db8'};
% key_n(99) = {'D8'};
% key_n(100) = {'Eb8'};
% key_n(101) = {'E8'};
% key_n(102) = {'F8'};
% key_n(103) = {'Gb8'};
% key_n(104) = {'G8'};
% key_n(105) = {'Ab8'};
% key_n(106) = {'A8'};
% key_n(107) = {'Bb8'};
% key_n(108) = {'B8'};
% 
% val_f = {16.35
% 17.32
% 18.35
% 19.45
% 20.60
% 21.83
% 23.12
% 24.50
% 25.96
% 27.50
% 29.14
% 30.87
% 32.70
% 34.65
% 36.71
% 38.89
% 41.20
% 43.65
% 46.25
% 49.00
% 51.91
% 55.00
% 58.27
% 61.74
% 65.41
% 69.30
% 73.42
% 77.78
% 82.41
% 87.31
% 92.50
% 98.00
% 103.83
% 110.00
% 116.54
% 123.47
% 130.81
% 138.59
% 146.83
% 155.56
% 164.81
% 174.61
% 185.00
% 196.00
% 207.65
% 220.00
% 233.08
% 246.94
% 261.63
% 277.18
% 293.66
% 311.13
% 329.63
% 349.23
% 369.99
% 392.00
% 415.30
% 440.00
% 466.16
% 493.88
% 523.25
% 554.37
% 587.33
% 622.25
% 659.25
% 698.46
% 739.99
% 783.99
% 830.61
% 880.00
% 932.33
% 987.77
% 1046.50
% 1108.73
% 1174.66
% 1244.51
% 1318.51
% 1396.91
% 1479.98
% 1567.98
% 1661.22
% 1760.00
% 1864.66
% 1975.53
% 2093.00
% 2217.46
% 2349.32
% 2489.02
% 2637.02
% 2793.83
% 2959.96
% 3135.96
% 3322.44
% 3520.00
% 3729.31
% 3951.07
% 4186.01
% 4434.92
% 4698.63
% 4978.03
% 5274.04
% 5587.65
% 5919.91
% 6271.93
% 6644.88
% 7040.00
% 7458.62
% 7902.13};
% 
% Note_freq = containers.Map(key_n,val_f);
% 
% save('Freq', 'Note_freq');
% 
% FreqArr = val_f;
% save('FArr', 'FreqArr')
% notes = key_n;
% save('notes', 'notes')