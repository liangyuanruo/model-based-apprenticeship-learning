%%Initialise
clear; clc; close all;

%Settings
ERROR_BARS = 1;
IT = 4; %Iteration number  PLAY WITH THIS

%Get data
load 300814_MAIN_TRAJ/cartPole_15_H40.mat

%% Results
%Obtain variances from covariance matrix
Cov = Sigma{IT};
t=(1:H)*dt; %Trajectory time steps

%Compare between actual and predicted
expi = 0; %Expert trajectory's iterator

%Get sin/cos representations
%expert.x(:,5) = sin(expert.x(:,4))
%expert.x(:,6) = cos(expert.x(:,4))

for it=1:N
M{it}(5,:) = sin(M{it}(4,:));
M{it}(6,:) = cos(M{it}(4,:));
end

expert.y(:,5) = sin(expert.y(:,4));
expert.y(:,6) = cos(expert.y(:,4));

feati = [1 4];
for feat = feati %For every feature
        
    %expi = expi + 1;
    %Plotting
    figure(feat) %Open new figure
    hold on; grid on;

    %Plotting results
    starti = IT*H + 1;
    endi = starti + H - 1;
    plot(t(1:end-1),x(starti+1:endi,feat),'r-','LineWidth',2) %Actual trajectory by cartpole
    plot(t(1:end-1),M{IT}(feat,2:end-1),'b-.','LineWidth',2) %Predicted trajectory by GP
    plot(t(1:end-1),expert.y(1:end-1,feat),'m--','LineWidth',2) %Demonstrated trajectory

    if ERROR_BARS
        %errorbar((1:H+1)*dt,M{IT}(feat,:),2*sqrt(Cov(feat,feat,:)))
        if feat < 5
        shadedErrorBar(t(1:end-1),M{IT}(feat,2:end-1),2*sqrt(Cov(feat,feat,2:end-1)),...
            '-b',1)
        
        end
    end
    
    %Labelling
    if feat == 4
        legend('Actual','Predicted','Expert','Location','SouthEast')
    else
    legend('Actual','Predicted','Expert','Location','NorthEast');
    end
    xlabel('Time [s]')
    titles = {'x [m]','dx [m/s]','dtheta [rad/s]','theta [rad]',...
        'sin(theta)','cos(theta)'};
    
    title(titles{feat});
    ylabel(titles{feat});
    
    %Save figures
    filetitles = {'x','dx','dtheta','theta',...
        'sin(theta)','cos(theta)'};
    filename = strcat(num2str(IT),'_',filetitles{feat},'_',cost.type)
    set(gcf, 'PaperPosition', [0 0 6 4]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [6 4]); %Set the paper to have width 5 and height 5.
    saveas(gcf, filename, 'pdf') %Save figure
    
end %End feature iteration


% %% Weights
% weights = [];
% 
% for i = 1:length(Weights)
%     weights = [weights Weights{i}];
% end
% 
% it = 1:length(weights);
% 
% figure(feat+1)
% plot(it,weights)
% title('Weights of each state')
% xlabel('Iteration #')
% ylabel('Weight')
% legend('x','sin(theta)','cos(theta)')
% 
% figure(feat+2)
% plot(1:length(costVal),costVal)
% title('Cost t(i) on each iteration')
% xlabel('Iteration #')
% ylabel('Cost')

