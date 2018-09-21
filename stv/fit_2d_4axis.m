function fit_2d_4axis(filename)
    S=load(filename);
    clust_num=length(S.clust_polar);
    x=[0;pi/2;pi/4;0.75*pi];
    figure('Unit','Normal','position',[0 0.3 0.3+0.1*clust_num 0.6]);
    for i=1:clust_num
        gain=sqrt(S.clust_polar(i).x.^2+S.clust_polar(i).y.^2);
        phase=S.clust_polar(i).phase;
        cos_sign=sign(cos(phase));
        [gain_fitobj,gain_gof,~]=fitting_ellipse(x,gain);
        stv=STV;
        if gain_fitobj.a>gain_fitobj.b
            stv.Smax=gain_fitobj.a;
            stv.Smin=gain_fitobj.b;
            stv.alpha=gain_fitobj.c;
        else
            stv.Smax=gain_fitobj.b;
            stv.Smin=gain_fitobj.a;
            stv.alpha=gain_fitobj.c+pi/2;
        end
        [phase_fit,phase_gof,Rs_e,Rs_w]=fitting_phase(stv,x,phase);
        [phase_fit_al,phase_gof_al,Rs_e_al,Rs_w_al]=fitting_phase(stv,-x,phase);
        if phase_gof_al<phase_gof
            stv.phi=phase_fit_al;
            stv.Smin_leading=-1;
            Rs=Rs_e_al;
            RsW=Rs_w_al;
        else
            stv.phi=phase_fit;
            stv.Smin_leading=1;
            Rs=Rs_e;
            RsW=Rs_w;
        end
        save(filename,'stv','-append')
        subplot(2,clust_num,i)
        plot_ellipse_phase_2d(stv)
        hold on;
        for j=1:length(S.clust_polar(i).x)
            plot([S.clust_polar(i).x(j),-S.clust_polar(i).x(j)],[S.clust_polar(i).y(j),-S.clust_polar(i).y(j)],'g')
            
            quiver(sin(phase(j)).*S.clust_polar(i).x(j),sin(phase(j)).*S.clust_polar(i).y(j),...
                cos_sign(j).*S.clust_polar(i).x(j)*0.25,cos_sign(j).*S.clust_polar(i).y(j)*0.25,...
                 'color','blue','LineWidth',4,'MaxHeadSize',2,'Marker','*');
        end
        title({['Cluster ' num2str(i) ' Ratio: ' num2str(stv.Smin/stv.Smax)],['Gain Rsquare: ' num2str(gain_gof.rsquare)],...
            ['Phase Rs: ' num2str(Rs)]},'FontSize',20,'FontWeight','bold')
        hold off;
        Axis_lim=stv.Smax+stv.Smin;
        xlim([-Axis_lim Axis_lim])
        ylim([-Axis_lim Axis_lim])
        axis square
        subplot(2,clust_num,i+clust_num)
        plot_revolve(stv)
        Axis_lim=stv.Smax+stv.Smin;
        xlim([-Axis_lim Axis_lim])
        ylim([-Axis_lim Axis_lim])
        axis square
    end
end