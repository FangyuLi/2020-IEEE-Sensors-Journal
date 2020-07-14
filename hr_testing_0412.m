%% experiment to show why hr is not working

 clear
 clc
 close all
 
 lagg = 800;

sigjose = csvread('joseHB.csv');

sigtest = sigjose(4800+lagg:5800+lagg);




%%

fs = 100;
df = fs/length(sigtest);
tt = 0:df:(length(sigtest)-1)*df;


%%

figure
subplot(311)
plot(50:0.01:60,sigtest)
xlabel 'Time (s)'
title 'Time Series'

subplot(312)
plot(tt,abs(fft(sigtest-mean(sigtest))))
xlim([0 20])
xlabel 'Frequency (Hz)'
title 'Spectrum'

subplot(313)
fsst(sigtest,fs,hann(512),'xaxis')
xlim([0 20])
title 'Time-frequecny Analysis'

%%
hp = 3;
Nr = 100;

s1 = sigtest(1:Nr);
s2 = sigtest(end-Nr+1:end);
sig=[s1;sigtest;s2];


sigff = bandpass(sig-mean(sig),[0.7 hp],fs,'Steepness',0.8);

sigf=sigff(Nr+1:end-Nr);

figure
subplot(311)
plot(0:0.01:10,sigf)
xlabel 'Time (s)'
title 'Time Series'

subplot(312)
plot(tt,abs(fft(sigf-mean(sigf))))
xlim([0 hp])
xlabel 'Frequency (Hz)'
title 'Spectrum'

subplot(313)
fsst(sigf,fs,hann(512),'xaxis')
xlim([0 hp])
title 'Time-frequecny Analysis'

%%


[imf,residual] =eemd(sigf,0.1,200,1000);

%% calculate the dominant frequencies of different imfs
imf = imf';
[m n]=size(imf);

ff = zeros([1 20]);

for i = 1:n
   
    ff(i) = mean(instfreq(imf(:,i),fs));
    
end

%% 
Hrlow = 0.7;
Hrhigh = 1.6;


HRindex = find(ff>Hrlow & ff<Hrhigh);

% RR PCA

ftlength = 10000;
df = fs/ftlength;


%[coeffR,scoreR,latentR] = pca(imf(:,7:12));
[coeffR,scoreR,latentR] = pca(imf(:,min(HRindex):max(HRindex)));

hrspectrum = abs(fft(scoreR(:,1)-mean(scoreR(:,1)),ftlength));



%hrspectrumf = sgolayfilt(hrspectrum,3,5);

% [Pxx, F] = pyulear(scoreR(:,1),2,1000,fs);
% figure
% plot(F,Pxx)
% xlabel('Frequency (Hz)')
% title('Autoregressive (AR) Spectral Analysis')
% xlim([0 2])

hrlow = Hrlow/df+5;
hrhigh = Hrhigh/df+5;


HR = (find(hrspectrum(hrlow:hrhigh) == max(hrspectrum(hrlow:hrhigh))) +hrlow-2)* df * 60;

% plot result
ddf = 0:df:(length(hrspectrum)-1)*df;




figure
hold on
plot(ddf,hrspectrum,'linewidth',2);
%plot(ddf,hrspectrumf,'linewidth',2);
hold off
xlim([0 2])
box on
xlabel('Frequency (Hz)')
title([' HR= ',num2str(HR)])



