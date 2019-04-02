%%Initialise
clear; clc; close all;

%Settings
%ERROR_BARS = 1;
IT = 15; %Trajectory from old feature expectations

%Get data
load baxter_linear_16_H16.mat

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
    hold on;

    %Plotting results
    starti = IT*(H-1) + 1;
    endi = starti + H-2;
    
    %Actual trajectory with cost on every time step
    plot((1:H-1)*dt,x(starti:endi,feat),'r') 
    %Actual trajectory with cost on every trajectory
    plot((1:H-1)*dt,xx(:,feat),'k')    
    %Predicted trajectory by GP
    %plot((1:H+1)*dt,M{IT}(feat,:),'b') 
    %Demonstrated trajectory
    plot((1:H)*dt,expert.x(:,expi),'m') 

    %if ERROR_BARS
        %try 
            %for k = t(1):t(end)
            %    errorbar(k*dt,M{IT}(feat,k),2*sqrt(Cov(feat,feat,k)));
            %end
        %catch
        %end
    %end
    
    %Labelling
    %legend('Cost on every time step','Cost over trajectory','Predicted','Expert');
    legend('Cost on every time step','Cost over trajectory','Expert');
    xlabel('Time [s]')
    titles = {'left\_s0','left\_s1','left\_w0','left\_w1', ...
                'left\_w2','left\_e0','left\_e1', ...
               'right\_s0','right\_s1','right\_w0','right\_w1', ...
                'right\_w2','right\_e0','right\_e1'};
    
    if feat <= 7
        title(titles{feat});
        ylabel(titles{feat});
    else 
        title(titles{feat-7});
        ylabel(titles{feat-7});

    end
    
        
end %End feature iteration


%% Weights
weights = [];

for i = 1:length(Weights)
    weights = [weights Weights{i}];
end

it = 1:length(weights);

figure(feat+1)
plot(it,weights(1:7,:))
title('Weights of each feature over iterations for left arm')
xlabel('Iteration #')
ylabel('Weight')
legend('left\_s0','left\_s1','left\_w0','left\_w1', ...
                'left\_w2','left\_e0','left\_e1')

figure(feat+2)
plot(it,weights(8:14,:))
title('Weights of each feature over iterations for right arm')
xlabel('Iteration #')
ylabel('Weight')         
legend('right\_s0','right\_s1','right\_w0','right\_w1', ...
                'right\_w2','right\_e0','right\_e1');

figure(feat+3)
plot(1:length(costVal),costVal)
title('Cost at each iteration')
xlabel('Iteration #')
ylabel('Cost')

