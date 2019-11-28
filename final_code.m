clear, clc, close all
    % sampled data and sample rate
    [y,fs] = audioread('arctic_a0001.wav');
    y=resample(y,8000,fs);
    s=y(:,1);
    fs=8000;
    N=length(s);
    
    %Difference the speech signal(to remove any time-varying low frequency bias in the signal)
    x=diff(s);
    x(end+1)=x(end);
    
    %getting lp residual and taking hilbert transform of that
    lpc_1=lpc(s,10);
    residual=filter(lpc_1,1,s);
    s_a=hilbert(residual);
    s_he=abs(s_a);

    %applying zero frequency filtering to the differenced speech sample
    % equivalent to succesive integration 4 times
    b=1;
    a=[1,-2,1];
    y1=filter(b,a,x);
    y2=filter(b,a,y1);
    
    %applying zff to Hilbert Envelope
    y1_he=filter(b,a,s_he);
    y2_he=filter(b,a,y1_he);

    %taking mean window
    M=5*fs/1000;
    
    %subtracting out the mean to extract the characteristics of
    %discontinuities i.e removing trend
    y3=y2;
    for k=1:3 %N=2
        tt=filter(ones(M,1),1,y3)/M;
        y3=y3-tt;
        y3=y3/5; %2N+1=5
    end
    
    %subtracting out the mean to extract the characteristics of
    %discontinuities i.e removing trend second time
    y4=y3;
    for k=1:3
        tt=filter(ones(M,1),1,y4)/M;
        y4=y4-tt;
        y4=y4/5;
    end
    
    %subtracting out the mean to extract the characteristics of
    %discontinuities i.e removing trend from HE
    y3_he=y2_he;
    for k=1:4
        tt=filter(ones(M,1),1,y3_he)/M;
        y3_he=y3_he-tt;
    end
    
    t1=(0:N-1)/fs;
    subplot(5,1,1)
    plot(t1,s)
    title('sound signal')

    subplot(5,1,4)
    plot(t1,y4)
    title('zero frequency filtered signal(after trend removal twice)')
    
    subplot(5,1,3)
    plot(t1,y2)
    title('Output of cascade of two 0-Hz filter')

    subplot(5,1,2)
    plot(t1,s_he)
    title('hilbert envelope')
    
    subplot(5,1,5)
    plot(t1,y3_he)
    title('zff of HE')