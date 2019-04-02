%%Initialise
clear; clc; close all;

%Settings
ERROR_BARS = 1;
IT = 8; %Iteration number to print from the data -  PLAY WITH THIS

%Get data
load baxter_8.mat


%% Results
t = linspace(1,40,40); %Time steps

%Obtain sine and cosine from M
%M{end-2}(5,:) = sin(M{end-2}(4,:));
%M{end-2}(6,:) = cos(M{end-2}(4,:));
M{IT}(5,:) = sin(M{IT}(4,:));
M{IT}(6,:) = cos(M{IT}(4,:));

%Obtain variances from covariance matrix
Cov = Sigma{IT};

%Compare between actual and predicted
for feat = 1:size(xx,2) %For every feature
    if (~any(feat==[1 2 3 5 6])) %Exclude Theta
        continue
    end
        
    %Plotting
    figure(feat) %Open new figure
    hold on;

        plot(t,xx(:,feat),'r') %Actual trajectory
    
        plot(t,M{IT}(feat,1:end-1),'b') %Predicted trajectory
    
        plot(t,expert.x(:,feat),'m') %Expert trajectory
    
    if ERROR_BARS
        try 
            for k = t(1):t(end)
                errorbar(k,M{IT}(feat,k),2*sqrt(Cov(feat,feat,k)));
            end
        catch
        end
    end
    
    %Labelling
    legend('Actual','Predicted','Expert');
    xlabel('Time step')
    titles = {'x(t)','dx/dt','dTheta/dt','Theta',...
        'sin(Theta)','cos(Theta)'};
    
    title(titles{feat});
    ylabel(titles{feat});
    
        
end %End feature iteration


%% Weights
weights = [];

for i = 1:length(Weights)
    weights = [weights Weights{i}];
end

disp(weights)
it = 1:length(weights);

figure
weights
plot(it,weights)
title('weights of each feature')
xlabel('Iteration #')
ylabel('Weight')
legend('x','dxdt','dthetadt','sin(theta)','cos(theta)');

figure
title('cost at each iteration')
xlabel('Iteration #')
ylabel('Cost')
plot(it,costVal)

