clear all; clc

%%% Creating app ui window

% fig = createFig();

%%% Function to close ui window - defined at eof

% function [fig] = createFig()
% function my_closereq(fig)


%%% Initialising variables

% Recording variables
Fs_record = 44100;
Bit_rate = 16;
Record_audio = audiorecorder(Fs_record,Bit_rate,1);

F_res = 1.5; % check? 1.25 is 5cents @ 100Hz
Window_length = 0.05; %in seconds
Overlap_time = 0.01; %in seconds
% Overlap = 1;  % boolean for overlapping windows
Window_type = "Rect";
Window_function = 1;
Freq_range = [20,2000]; % frequency range of the human voice (in Hz?)

Scale_f = 4; % default scale is A
Fund_arr = [220,233.08,246.94,261.63,277.18,293.66,...
    311.13,164.81,174.61,185,196,207.65]; % array of Sa frequencies for each scale
Ratio_num = [1,16,9,6,5,4,45,3,8,5,9,15]; % ratios of every note wrt Sa
Ratio_den = [1,15,8,5,4,3,32,2,5,3,5,8];  % denominator
Note_name = ['Sa  ';'Re~ ';'Re  ';'Ga~ ';'Ga  ';'Ma  ';'Ma~ ';'Pa  ';'Dha~';'Dha ';'Ni~ ';'Ni  '];

c11 = [(75 /256);0;        (130/256)];    % RGB for indigo
c12 = [(150/256);(80 /256);(150/256)];    % RGB for dark magenta
c21 = [0;        (128/256);(128/256)];    % RGB for teal
c22 = [0;        (206/256);(209/256)];    % RGB for dark turquoise
c31 = [(255/256);(99 /256);(71 /256)];    % RGB for tomato
c32 = [(233/256);(150/256);(122/256)];    % RGB for dark salmon
Colour_codes = zeros(3,12,3);
Colour_codes(:,:,1) = [c11 c12 c11 c12 c11 c11 c12 c11 c12 c11 c12 c11];
Colour_codes(:,:,2) = [c21 c22 c21 c22 c21 c21 c22 c21 c22 c21 c22 c21];
Colour_codes(:,:,3) = [c31 c32 c31 c32 c31 c31 c32 c31 c32 c31 c32 c31];
Notes_freq = zeros(1,12); % to define frequency of each note in scale
lstfn = {'A','A#','B','C','C#','D','D#','E','F','F#','G','G#'}; % options for scale
thresh = 0.05; % default noise threshold ----- NEED TO CALIBERATE AND USE IN CODE


%%% Coding Block to take in audio recording or upload file
while 1
    
     % Setting scale ------- NEED TO HAVE OPTION TO SING THE SA

    [Scale_f,~] = listdlg('PromptString','Choose the scale: ', ... 
    'SelectionMode','single','ListString',lstfn);
    if Scale_f
    else
        break
    end
    
    % Take in file ------- ADD LIVE OPTION
    answer = questdlg('What audio file would you like to use?', ... 
        'Choose file', ...
        '  Open file  ','Record voice ','Live Tracking','Live Tracking');

    switch answer
        case '  Open file  '
            [file_name, path] = uigetfile('','Enter a valid file name:');
            [Audio_time, Fs] = audioread([path file_name]); % timeseries of audio data
            while(length(Audio_time(1,:))>1)
                Audio_time(:,2)=[];
            end
        case 'Record voice '
            ans2 = questdlg(['Click to begin recording (minimum length is 3 seconds)'],...
            'Waiting to record','Record','Cancel','Record');
            if ans2 == 'Cancel'
                continue
            end
%             n = 10;
%             record(Record_audio); 
%             pause(3);
%             stop(Record_audio);
%             Noise_time = getaudiodata(Record_audio); % to set noise threshold
            record(Record_audio);
            ans2 = questdlg('Click to end recording','Recording...','Stop ','Pause','Stop ');
            while ans2 == 'Pause'
                pause(Record_audio);
                Paused = msgbox('Recording paused. Click Ok to continue recording');
                uiwait(Paused)
                resume(Record_audio);
                ans2 = questdlg('Click to end recording','Recording...','Stop ','Pause','Stop ');
            end
            stop(Record_audio);
            Audio_time = getaudiodata(Record_audio); % time series of audio data
            Fs = Fs_record;
        case 'Live Tracking'
            Fs = Fs_record;
            deviceReader = audioDeviceReader(Fs,floor(Fs * Window_length));
        otherwise
            disp('Invalid Option')
            break
    end
    
    % Setting frequency for each note based on scale
    Notes_freq = Set_freq(Scale_f, Fund_arr, Ratio_num, Ratio_den);
    
    
    if answer=='Live Tracking'
        
        %%% Initialising variables to process audio

        Num_samples = floor(Fs * Window_length);    % samples per window
        Freq = Fs/Num_samples:Fs/Num_samples:Fs;        % freq array
        Window = ones(Num_samples,1);                   % sampled window function
        Window = Window * Window_function;     % or use MATLAB in-built function
        x_axis_5 = 1:1:5;
        
        F_low = floor((Freq_range(1)) / (Fs/Num_samples));
        F_high = floor((Freq_range(2)) / (Fs/Num_samples));

        % Initialising figure
        Freq_fig = figure('Name','Fundamental frequency');
        semilogy(x_axis_5,[0 0 0 0 0]);
        
        % Plot lines for each note of scale
        plotLines(x_axis_5,Notes_freq,Colour_codes,Note_name)

        % Label axes
        xlabel('Your Note')
        ylabel('Frequency (Hz)')
        ytickformat('%.0f Hz')
        xlim = [x_axis_5(1) x_axis_5(5)];
        ylim = [((Notes_freq(12)/2)*0.9) ((2*Notes_freq(2))*1.1)];
        hold('on')
        
        Curr_freq = [0 430 440 430 0];
        p = plot(x_axis_5,Curr_freq,'Color','b');
%         p.XDataSource = 'x_axis_5';
%         p.YDataSource = 'Curr_freq';
        linkdata on
        
        %%% Processing audio and displaying
%         Paused = msgbox('Transcribing Started. Click OK to stop.');
        while(1)    % looping over live audio till plot is closed
            [Curr_frame,numOverrun] = deviceReader(); % numOverrun is number of samples by
                                                   % which the audio reader's queue was 
                                                   % overrun since the last call to deviceReader
            Wind_frame = Curr_frame .* Window;                  % i-th current frame
            Frame_fft = fft(Wind_frame);                        % storing fft of current frame
            Frame_fft_abs = abs(Frame_fft);                     % storing real fft
            Frame_fund = Find_fundamental(Frame_fft_abs,F_low,F_high); % storing fund freq of frame
            Frame_amp = max(Curr_frame);  % highest amplitude in frame

            % Converting fundamental frequencies to a single octave
            Temp_freq = (Fs/Num_samples) * Frame_fund; %from samples to frequency
            while(Temp_freq>(2*Notes_freq(2)))
                Temp_freq = Temp_freq/2;
            end
            while(Temp_freq<(Notes_freq(12)/2))
                Temp_freq = Temp_freq*2;
            end
            Curr_freq = [0 Temp_freq-10 Temp_freq Temp_freq-10 0];

            % Plot Fundamental frequency
%             plot(x_axis_5,[0 Curr_freq-10 Curr_freq Curr_freq-10 0]);
            
            refreshdata
            drawnow
            
%             pause(Window_length);
        end
        hold('off')
        disp(numOverrun)
        break
    % for recorded audio
    else
    %%% Processing audio

    Num_samples = floor(Fs * Window_length);    % samples per window
    Start_sample = floor(Fs * Overlap_time);    % samples between 2 windows
    Num_frames = floor((length(Audio_time)-Num_samples)/...
        Start_sample); % assume overlapping windows, good approxiamtion either way
    Freq = Fs/Num_samples:Fs/Num_samples:Fs;                  % freq array
    Time = Overlap_time:Overlap_time:Num_frames*Overlap_time; % time array
    Window = ones(Num_samples,1);                   % sampled window function
    Window = Window * Window_function; % or use MATLAB in-built function
    Frames = zeros(Num_samples,Num_frames);         % 2d array of all frames
    Frames_fft_abs = zeros(Num_samples,Num_frames); % 2d array of freq spectrum of frames
    Frames_fft = zeros(Num_samples,Num_frames);     % ^^ as real numbers
    Frames_fund = zeros(Num_frames, 1);             % array of fund freq of each frame
    Frames_amp = zeros(Num_frames, 1);              % highest amplitude in each frame
    Time_freq = zeros(length(Audio_time),1);        % freq of each sample
    
    F_low = floor((Freq_range(1)) / (Fs/Num_samples));
    F_high = floor((Freq_range(2)) / (Fs/Num_samples));
    
    for i = 1:1:Num_frames                                  % iterating over each frame
        j = 1 + Start_sample*(i-1);                         % j gives start index of frame
        Curr_frame = Audio_time(j:j+Num_samples-1) .* Window; % i-th current frame
        Frames(:,i) = Curr_frame;                           % storing frame into 2d array
        Frames_fft(:,i) = fft(Curr_frame);                  % storing fft of current frame
        Frames_fft_abs(:,i) = abs(Frames_fft(:,i));         % storing real fft
        Frames_fund(i) = Find_fundamental(...
            Frames_fft_abs(:,i),F_low,F_high);              % storing fund freq of frame
        Zero_array = zeros(Num_samples,1);                  % creating artificial fund-
        Zero_array(Frames_fund(i)) = 100;                   % freq only sound
        Freq_single = Frames_fft(:,i) .* Zero_array;        % fft of sin wave
        Time_freq(j:j+Num_samples-1) = Time_freq(j:j+Num_samples-1) + ...
            abs(ifft(Freq_single));                         % 
        Frames_amp(i) = max(Audio_time(j:j+Num_samples-1)); % highest amplitude in frame
        
%         plot(Freq(F_low:F_high),Frames_fft_abs(F_low:F_high,i),'-o',...
%             'MarkerIndices',Frames_fund(i),'MarkerEdgeColor','r');
%         pause();
    end
    
    
    
    %%% Plotting Frequency Spectogram
    
%     figure('Name','Frequency Sqectrum');
%     mesh(Freq(F_low:F_high),Time,Frames_fft_abs(F_low:F_high,:).')
%     xlabel('Frequency')
%     ylabel('Time')
    
    %%% Plotting audio frequency data with notes
    
    % Converting fundamental frequencies to a single octave
    Freq_array = (Fs/Num_samples) * Frames_fund; %from samples to frequency
    for i = 1:1:Num_frames
        while(Freq_array(i)>(2*Notes_freq(2)))
            Freq_array(i) = Freq_array(i)/2;
        end
        while(Freq_array(i)<(Notes_freq(12)/2))
            Freq_array(i) = Freq_array(i)*2;
        end
    end
    
    % Smoothen freq curve
    Freq_array_smooth = smooth(Freq_array);
    
    % Plot Fundamental frequency curve
    figure('Name','Fundamental frequency');
    semilogy(Time,Freq_array);
    hold('on')
    plot(Time,Freq_array_smooth);
    hold('off')
    
    % Plot lines for each note of scale
    plotLines(Time,Notes_freq,Colour_codes,Note_name)
    
    % Label axes
    xlabel('Time (sec)')
    ylabel('Frequency (Hz)')
    ytickformat('%.0f Hz')
    xlim = [0 length(Audio_time)];
    ylim = [((Notes_freq(12)/2)*0.9) ((2*Notes_freq(2))*1.1)];
       
    % Listening to audio formed by fundamental frequency only
%     Time_freq = (255/max(Time_freq)) * Time_freq;
%     sound(Time_freq,Fs) %Shows poor response, erraneous code or bad results overall?
    
    break
    
    end
    
end

% Function to find fundamental frequence from given spectrum
function [Fund] = Find_fundamental(F_Spect,f1,f2)
    % fundamental is maxima in range f1 to f2
    
    % option 1
    [~, Fund] = max(F_Spect(f1:f2));
    Fund = Fund + f1 - 1;
    % option 2
    [~, peak1] = max(F_Spect(f1:f2));
    peak1 = peak1 + f1 - 1;
    [a, peak2] = max(F_Spect((peak1*1.1):f2));
    peak2 = peak2 + peak1 - 1;
    [b, peak3] = max(F_Spect(f1:(peak1*0.9)));
    peak3 = peak3 + f1 - 1;
    if(b>a)
        peak2 = peak3;
    end
    F_diff = abs(peak1-peak2);
    
    % choose option 2 if max is either 1,2,3 harmonic
    if(abs(F_diff-Fund)<(Fund*0.1))
        Fund = F_diff;
    end
    if(abs((2*F_diff)-Fund)<(Fund*0.1))
        Fund = F_diff;
    end
    if(abs((3*F_diff)-Fund)<(Fund*0.1))
        Fund = F_diff;
    end
    
    Fund = int32(Fund);
end

% Function to 
function [Notes] = Set_freq(Scale_f, Fund_arr, Ratio_num, Ratio_den)
    Notes = zeros(1,12);
    Notes(1) = Fund_arr(Scale_f);
    for i = 2:1:12
        Notes(i) = (Notes(1) * Ratio_num(i)) / Ratio_den(i);
    end
    % Upper and lower bound???
end

function [] = plotLines(Time, Notes_freq,Colour_codes,Note_name)
    Line_arr = ones(1,length(Time));
    hold('on');
    
    if(length(Time)<30)
        Sa_x = 2:5:length(Time); % Sa Re Ga.. will be printed every 5 seconds
        Sa_y = ones(length(Sa_x),1);
    else
        Sa_x = 2;
        Sa_y = 1;
    end
    Line_arr1 = Line_arr * Notes_freq(12) / 2;
    plot(Time, Line_arr1,'Color',Colour_codes(:,12,1));
%     text(Sa_x,Sa_y*(Notes_freq(12)/2)*1.02,Note_name(12,:),'FontSize',...
%         15,'FontWeight','bold','Color',Colour_codes(:,12,1))
    for i = 1:1:12
        Line_arr1 = Line_arr * Notes_freq(i);
        plot(Time, Line_arr1,'Color',Colour_codes(:,i,1));
        text(Sa_x,Sa_y*Notes_freq(i)*1.02,Note_name(i,:),'FontSize',...
        15,'FontWeight','bold','Color',Colour_codes(:,i,1));
    end
    Line_arr1 = Line_arr * Notes_freq(1) * 2;
    plot(Time, Line_arr1,'Color',Colour_codes(:,1,1));
    text(Sa_x,Sa_y*(Notes_freq(1)*2)*1.02,Note_name(1,:),'FontSize',...
        15,'FontWeight','bold','Color',Colour_codes(:,12,1));
    
%     for i = 1:1:12
%         Line_arr1 = Line_arr * Notes_freq(i) * 2;
%         plot(Time, Line_arr1,'Color',Colour_codes(:,i,2));
%     end
%     for i = 1:1:12
%         Line_arr1 = Line_arr * Notes_freq(i) * 4;
%         plot(Time, Line_arr1,'Color',Colour_codes(:,i,3));
%     end
    hold('off');
end

function [fig] = createFig()
    fig = uifigure('CloseRequestFcn',@(fig, event) my_closereq(fig));
end

function my_closereq(fig)
selection = questdlg('Close the figure window?',...
    'Confirmation',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        delete(fig)
    case 'No'
        return
end
end


% % TO DO

            % 2. ending while loop for live recording
        % 3. figure out best window length and overlap
        % 4. figure out best window type
                % 5. noise reduction/ figuring out when voice singing
    % 6. confirm values of frequency uf Shruti box
% 7. test with voice samples
% 8. test without bringing all notes to one octave
    % 9. fft of sine and how to artificially create it
        % 10. more ui/ outer while loop? option to change scale midway

% DONE 1. add 'Sa' etc note names to axis label


% Questions:
% 1. Detect when voice present and when not.
% 7. minimum cutoff volume for voice
        % 2. Discrete vs overlapping windows
        % 3. Should size of window depend on Fs? Should it be fixed time or fixed
        % samples
% 4. Blackmann Window?
        % 5. Minimum length of note? For window size
% 6. Overlap depends on size and type, window
% 8. Shruti? komal and ati?
% 9. Get frequency values for Shruti box, save. Get voice samples from
%    teacher, Pooja.
% 10. play(Record_audio);
%     sound(Audio_time,Fs)
%     sound(abs(ifft(fft(Audio_time))),Fs)
% 11. Respresent frequency with notes
% 12. Need to first window to 30-3000 Hz (freq response) before analysing
% 13. How to find fundamental frequency
% 14. Noise removal filter before processing?
% 15. Size of window 0.1s is too less


