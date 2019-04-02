clear;clc;close all

%These plots measure how close the trajectories are for each run.
%The data from cart-pole and baxter are normalised, by trajectory duration
%and by the total number of features used.

%Data files
matFiles = {'baxter_13_H16_FEATEXP',...
            'baxter_15_H16_TRAJ',...
            'cartPole_15_H40_FEATEXP',...
            'cartPole_15_H40_TRAJ'};
iterations = [13,15,15,15]; %Iterations each file runs to        
types = {'baxter','baxter','cartpole','cartpole'}; %Type of each file      
legends = {'Baxter Feat. Exp.','Baxter Feat. Matching',...
            'CartPole Feat. Exp.','CartPole Feat. Matching'};
plotSettings = {'r-o','b:+','m-.x','ks--'};        

%Open a new figure
figure;hold on;grid on;

for f = 1:length(matFiles) %For each mat file
    data = load(matFiles{f}); %Get data
    N = iterations(f);  %Number of data
    type = types(f);    %baxter or cartpole
    cost = zeros(1,N); %Cost vector for each iteration of algorithm
    
    for i=1:N; %For each run
        cost(i) = get_cost(data,i,type);
    end
    figure(1);
    plot(1:length(cost),cost,plotSettings{f},'LineWidth',2);
    
end %file iterator

%Labelling
title('Cost comparison')
xlabel('# Iterations')
ylabel('Cost')
legend(legends);

%Save file
filename = 'results_comparison';
set(gcf, 'PaperPosition', [0 0 6 4]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [6 4]); %Set the paper to have width 5 and height 5.
saveas(gcf, filename, 'pdf') %Save figure