%%Initialise
clear; clc; close all;

%Settings
ERROR_BARS = 1;
SAVE = 1;
IT = 15; %Iteration number  PLAY WITH THIS

%Get data
load 260814_MAIN_TRAJ/baxter_15_H16.mat

%% Results
%Obtain variances from covariance matrix
Cov = Sigma{IT};
t=1:H; %Trajectory time steps

%Compare between actual and predicted
expi = 0; %Expert trajectory's iterator

for feat = feati %For every feature
        
    expi = expi + 1;
    %Plotting
    figure(feat) %Open new figure
    hold on; grid on;

    %Plotting results
    starti = IT*(H-1) + 1;
    endi = starti + H-2;

    plot((1:H-1)*dt,x(starti:endi,feat),'r-','LineWidth',2) %Actual trajectory by Baxter
    plot((1:H-1)*dt,M{IT}(feat,1:end-2),'b-.','LineWidth',2) %Predicted trajectory by GP
    plot((1:H-1)*dt,expert.x(1:end-1,expi),'m--','LineWidth',2) %Demonstrated trajectory

    if ERROR_BARS
        %errorbar((1:H+1)*dt,M{IT}(feat,:),2*sqrt(Cov(feat,feat,:)))
        shadedErrorBar((1:H-1)*dt,M{IT}(feat,1:end-2),2*sqrt(Cov(feat,feat,1:end-2)),...
            '-b',1)

        %try 
        %    for k = t(1):t(end)
        %        errorbar(k*dt,M{IT}(feat,k),2*sqrt(Cov(feat,feat,k)));
        %        shadedErrorBar(k*dt,M{IT}(feat,k),...
        %            2*sqrt(Cov(feat,feat,k)))
        %    end
        %catch
        %end
    end
    
    %Labelling
    legend('Actual','Predicted','Expert');
    xlabel('Time [s]');
    titles = {'left\_s0','left\_s1','left\_w0','left\_w1', ...
                'left\_w2','left\_e0','left\_e1', ...
               'right\_s0','right\_s1','right\_w0','right\_w1', ...
                'right\_w2','right\_e0','right\_e1'};

            
    if feat <= 7
        title(titles{feat});
        ylabel(titles{feat});
        filetitle = titles{feat};
    else 
        title(titles{feat-7});
        ylabel(titles{feat-7});
        filetitle = titles{feat-7};
    end
    
    if SAVE
        filename = strcat(num2str(IT),'_',regexprep(filetitle,'\',''),'_',cost.type);
        set(gcf, 'PaperPosition', [0 0 6 4]); %Position plot at left hand corner with width 5 and height 5.
        set(gcf, 'PaperSize', [6 4]); %Set the paper to have width 5 and height 5.
        saveas(gcf, filename, 'pdf'); %Save figure
    end
end %End feature iteration


%% Weights
% weights = [];
% 
% for i = 1:length(Weights)
%     weights = [weights Weights{i}];
% end
% 
% it = 1:length(weights);
% 
% figure(feat+1)
% plot(it,weights(1:7,:))
% title('Weights of each position (left arm)')
% xlabel('Iteration #')
% ylabel('Weight')
% legend('left\_s0','left\_s1','left\_w0','left\_w1', ...
%                 'left\_w2','left\_e0','left\_e1')
% 
% figure(feat+2)
% plot(it,weights(8:14,:))
% title('Weights of each feature (right arm)')
% xlabel('Iteration #')
% ylabel('Weight')         
% legend('right\_s0','right\_s1','right\_w0','right\_w1', ...
%                 'right\_w2','right\_e0','right\_e1');
% 
% figure(feat+3)
% plot(1:length(costVal),costVal)
% title('Cost t(i) on each iteration')
% xlabel('Iteration #')
% ylabel('Cost')

