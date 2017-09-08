EPSC_trials=load('Trials_EPSC_accel_ZL170901_fish04a.mat');
EPSP_trials=load('Trials_EPSP_accel_ZL170901_fish04a.mat');
for i=1:length(EPSC_trials.Trials)
    for j=1:length(EPSP_trials.Trials)
        if round(EPSC_trials.Trials(i).S_freq,1)==round(EPSP_trials.Trials(j).S_freq,1)...
                && round(EPSC_trials.Trials(i).S_amp,1)==round(EPSP_trials.Trials(j).S_amp,1)
            EPSC_file=load(EPSC_trials.Trials(i).mat_file);
            EPSP_file=load(EPSP_trials.Trials(j).mat_file);
            figure;
            for k=1:2
                subplot(2,1,k)
                plot_only_fit(EPSC_file.Data,...
                    EPSC_file.fit_model{EPSC_trials.Trials(i).poi_num},...
                    EPSC_file.S_period{EPSC_trials.Trials(i).poi_num},...
                    EPSC_file.accel_axis,...
                    EPSC_file.si,...
                    EPSC_file.type,...
                    k);
                hold on;
                plot_only_fit(EPSP_file.Data,...
                    EPSP_file.fit_model{EPSP_trials.Trials(j).poi_num},...
                    EPSP_file.S_period{EPSP_trials.Trials(j).poi_num},...
                    EPSP_file.accel_axis,...
                    EPSP_file.si,...
                    EPSP_file.type,...
                    k);
            hold off;
            end
            samexaxis('YAxisLocation','none','Box','off','ytac','join');
        end
    end
end

function plot_only_fit(Data,fit_model,S_period,accel_axis,si,type,subplot_order)
    if strcmp(type,'EPSC+accel')||strcmp(type,'IPSC+accel')
    YLabel = {'pA','g','g','g'};
    Color='r';
    yAx='yyaxis left';
    elseif strcmp(type,'EPSP+accel')||strcmp(type,'IPSP+accel')
    YLabel = {'mV','g','g','g'};
    Color='k';
    yAx='yyaxis right';
    end
    %fit_accel_y = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
    xrange=S_period-S_period(1);
    if subplot_order==1
        eval(yAx);
        plot(xrange*si*1e-6,Data(S_period,1),Color);
        ylabel(YLabel{1},'Rotation',0);
    elseif subplot_order==2
        eval(yAx);
        plot(xrange*si*1e-6,Data(S_period,accel_axis),Color)
        ylabel(YLabel{2},'Rotation',0);
    end
    xlabel('Second');
end