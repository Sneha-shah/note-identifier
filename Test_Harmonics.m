m = 44100
x_fft = zeros(m,1);

x_fft(200) = 100;
x_fft(400) = 40;
x_fft(600) = 10;
x_fft(800) = 40;
x_fft(100) = 5;
x_fft(1200) = 2;
x_fft(1400) = 1;
x_fft(1600) = 20;
x_fft(1800) = 1;

x_fft(m-200) = 100;
x_fft(m-400) = 50;
x_fft(m-600) = 20;
x_fft(m-800) = 10;
x_fft(m-100) = 5;
x_fft(m-1200) = 2;
x_fft(m-1400) = 1;
x_fft(m-1600) = 1;
x_fft(m-1800) = 1;

% x_fft(200) = 10;
% x_fft(400) = 10;
% x_fft(600) = 10;
% x_fft(800) = 10;
% x_fft(100) = 10;
% x_fft(1200) = 10;
% x_fft(1400) = 0;
% x_fft(1600) = 10;
% x_fft(1800) = 10;

% x = [-300:1:300];
% x_fft = normpdf(x,0,1);

x_1 = abs(ifft(x_fft));
x_1 = x_1/max(x_1);
sound(x_1,44100)
% pause(2);
% 
% x_fft(200) = 0;
% x_2 = abs(ifft(x_fft));
% x_2 = x_2/max(x_2);
% sound(x_2,44100)
% pause(2);
% 
% x_fft(400) = 0;
% x_2 = abs(ifft(x_fft));
% x_2 = x_2/max(x_2);
% sound(x_2,44100)
% pause(2);
% 
% x_fft(600) = 0;
% x_3 = abs(ifft(x_fft));
% x_3 = x_3/max(x_3);
% sound(x_3,44100)
% pause(2);
% 
% x_fft(800) = 0;
% x_4 = abs(ifft(x_fft));
% x_4 = x_4/max(x_4);
% sound(x_4,44100)
% pause(2);
% 
% x_fft(1000) = 0;
% x_5 = abs(ifft(x_fft));
% x_5 = x_5/max(x_5);
% sound(x_5,44100)
% pause(2);
% 
% x_fft(1200) = 0;
% x_6 = abs(ifft(x_fft));
% x_6 = x_6/max(x_6);
% sound(x_6,44100)
% pause(2);
% 
% x_fft(1400) = 0;
% x_7 = abs(ifft(x_fft));
% x_7 = x_7/max(x_7);
% sound(x_7,44100)
% pause(2);
% 
% x_fft(1600) = 0;
% x_8 = abs(ifft(x_fft));
% x_8 = x_8/max(x_8);
% sound(x_8,44100)
% pause(2);

