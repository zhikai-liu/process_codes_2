function results=der_deconv_iterative(data,template)
%%
% For each iteration except the first, the template is generated by the average
% signal of detected events from the last iteration, and the penalty
% between reconstructed and real signal is calculated. The process
% is continued until the penalty doesn't decrease anymore.

%%
% For 'results', it contains('count' specifies which iteration):
%         results(count).model_T: Template used for deconv.

%         results(count).D: Deconvoluted traces.

%         results(count).LM: Thresholded event index, or the timepoint of detected event.

%         results(count+1).all_template: Events chosen for generating template for the next iteration.

%         results(count+1).model_T: Template for next iteration.

%         results(count).coeff_delta: coeff for each event that minimize the least square error.

%         results(count).D_re: Reconstructed deconvolved trace, where event timepoint has value of its coefficient and 
%                               non-event timepoint being zero.

%         results(count).LM_Y: Value of each event timepoint for the orignal signal.

%         results(count).signal_fft_re: Reconstructed signal in Fourier space.

%         results(count).signal_re: Reconstructed signal.

%         results(count).penalty: Penalty between real and reconstructed signals.

%% Initialization
s_data=diff(data);
results=struct();
count=1;
results(count).model_T=diff(template);% Use given template for first iteration of deconvolution

%% Calculate the deconvolved signal
% Iterative process until we find the template for which the penalty doesn't decrease
while 1
    [results(count).D,results(count).D_fs]=signal_deconv(s_data,results(count).model_T,5e4,0,2000);
    results(count).LM=get_local_maxima_above_threshold(results(count).D_fs,3.5*std(results(count).D_fs),1);   
    results(count).LM=results(count).LM(results(count).LM+8<=length(s_data)&results(count).LM-8>=0); %delete events that is at the edge of trace, edge is defined as 8 points away from the start or the end of trace
  
%% Find single event that is temporally isolated from other events and use their average as the next template
    inter_LM=diff(results(count).LM);
    long_single_events=results(count).LM(inter_LM>1000&[0;inter_LM(1:end-1)]>200);
    all_template=zeros(320,length(long_single_events));
    figure;
    hold on;
    for i=1:length(long_single_events)
        all_template(:,i)=s_data(long_single_events(i)-20:long_single_events(i)+299)-mean(s_data(long_single_events(i)-30:long_single_events(i)-20));
        plot(all_template(:,i),'color',[0.3,0.3,0.3])
    end

    results(count+1).model_T=mean(all_template,2);
    results(count+1).all_template=all_template;
    plot(results(count+1).model_T,'k','LineWidth',5)
    hold off;
    
 %% Reconstruct the signal from the deconvolution trace and calculate the penalty
    results(count).D_re=zeros(length(results(count).D_fs),1);
    results(count).coeff_delta=coeff_delta_signal(s_data,results(count).model_T,results(count).LM);% get coeff of the delta function, that minimize the least square root error
    results(count).LM=results(count).LM(results(count).coeff_delta>0);% elminate some events that are in the oppose direction of template but still picked up
    results(count).D_re(results(count).LM)=results(count).coeff_delta(results(count).coeff_delta>0);
    results(count).LM_Y=s_data(results(count).LM);
    results(count).signal_fft_re=fft(results(count).D_re).*fft(results(count).model_T,size(s_data,1));
    results(count).signal_re=real(ifft(results(count).der_fft_re));
    %results(count).signal_re=cumsum([data(1);results(count).der_re]);
    results(count).penalty=(results(count).signal_re-s_data)'*(results(count).signal_re-s_data); % penalty function used for later if iteration is needed to improve peformance
    if count>2
        if results(count-1).penalty-results(count).penalty<1000
            break
        end
    end
    count=count+1;
end
