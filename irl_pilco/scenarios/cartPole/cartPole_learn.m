%% cartPole_learn.m
% *Summary:* Script to learn a controller for the cart-pole swingup
%
% Copyright (C) 2008-2013 by
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Last modified: 2013-03-27
%
%% High-Level Steps
% # Load parameters
% # Create J initial trajectories by applying random controls
% # Controlled learning (train dynamics model, policy learning, policy
% application)

%% Code

% 1. Initialization
clear all; close all;
settings_cp;                      % load scenario-specific settings
basename = 'cartPole_';           % filename used for saving data

% 2. Initial J random rollouts (generating trajectories?)
for jj = 1:J
  [xx, yy, realCost{jj}, latent{jj}] = ...
    rollout(gaussian(mu0, S0), struct('maxU',policy.maxU), H, plant, cost);
  x = [x; xx]; y = [y; yy];       % augment training sets for dynamics model
   
%   if plotting.verbosity > 0;      % visualization of trajectory
%     if ~ishandle(1); figure(1); 
%     else set(0,'CurrentFigure',1); 
%     end; 
%     clf(1);
%     draw_rollout_cp;
%   end
  
end

mu0Sim(odei,:) = mu0; 
S0Sim(odei,odei) = S0;
mu0Sim = mu0Sim(dyno); 
S0Sim = S0Sim(dyno,dyno);

% 3. Controlled learning (N iterations)
for j = 1:N
%  trainDynModel;   % train (GP) dynamics model which maps (s,a) -> s'
%  learnPolicy;     % learn policy
%  applyController; % apply controller to system

%%%%%%%%%%%%%%%%%%%%%%trainDynModel%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 1. Train GP dynamics model
Du = length(policy.maxU); Da = length(plant.angi); % no. of ctrl and angles
xaug = [x(:,dyno) x(:,end-Du-2*Da+1:end-Du)];     % x augmented with angles
dynmodel.inputs = [xaug(:,dyni) x(:,end-Du+1:end)];     % use dyni and ctrl
dynmodel.targets = y(:,dyno);
dynmodel.targets(:,difi) = dynmodel.targets(:,difi) - x(:,dyno(difi));
dynmodel = dynmodel.train(dynmodel, plant, trainOpt);  %  train dynamics GP

% display some hyperparameters
Xh = dynmodel.hyp;     
% noise standard deviations
disp(['Learned noise std: ' num2str(exp(Xh(end,:)))]);
% signal-to-noise ratios (values > 500 can cause numerical problems)
disp(['SNRs             : ' num2str(exp(Xh(end-1,:)-Xh(end,:)))]);


%%%%%%%%%%%%%%%%%%%%learnPolicy%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Update the policy
opt.fh = 1;
[policy.p fX3] = minimize(policy.p, 'value', opt, mu0Sim, S0Sim, ...
  dynmodel, policy, plant, cost, H);
%Policy.p = theta are the hyperparameters to u = pi(x,theta)

% (optional) Plot overall optimization progress
% if exist('plotting', 'var') && isfield(plotting, 'verbosity') ...
%     && plotting.verbosity > 1
%   if ~ishandle(2); figure(2); else set(0,'CurrentFigure',2); end
%   hold on; plot(fX3); drawnow; 
%   xlabel('line search iteration'); ylabel('function value')
% end

% 2. Predict state trajectory from p(x0) ...
[M{j} Sigma{j}] = pred(policy, plant, dynmodel, mu0Sim(:,1), S0Sim, H);

% and compute cost trajectory
[fantasy.mean{j} fantasy.std{j}] = ...
  calcCost(cost, M{j}, Sigma{j}); % predict cost trajectory

% (optional) Plot predicted immediate costs (as a function of the time steps)
% if exist('plotting', 'var') && isfield(plotting, 'verbosity') ...
%     && plotting.verbosity > 0
%   if ~ishandle(3); figure(3); else set(0,'CurrentFigure',3); end
%   clf(3); errorbar(0:H,fantasy.mean{j},2*fantasy.std{j}); drawnow;
%   xlabel('time step'); ylabel('immediate cost');
% end


%%%%%%%%%%%%%%%%%%%%%%applyController%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Generate trajectory rollout given the current policy
if isfield(plant,'constraint'), 
    HH = maxH; 
else HH = H; 
end

[xx, yy, realCost{j+J}, latent{j}] = ...
  rollout(gaussian(mu0, S0), policy, HH, plant, cost);

disp(xx);                           % display states of observed trajectory
x = [x; xx]; y = [y; yy];                            % augment training set

% if plotting.verbosity > 0
%   if ~ishandle(3); figure(3); else set(0,'CurrentFigure',3); end
%   hold on; plot(1:length(realCost{J+j}),realCost{J+j},'r'); drawnow;
% end

% % 2. Make many rollouts to test the controller quality
% if plotting.verbosity > 1
%   lat = cell(1,10);
%   for i=1:10
%     [~,~,~,lat{i}] = rollout(gaussian(mu0, S0), policy, HH, plant, cost);
%   end
%   
%   if ~ishandle(4); figure(4); else set(0,'CurrentFigure',4); end; clf(4);
%   
%   ldyno = length(dyno);
%   for i=1:ldyno       % plot the rollouts on top of predicted error bars
%     subplot(ceil(ldyno/sqrt(ldyno)),ceil(sqrt(ldyno)),i); hold on;
%     errorbar( 0:length(M{j}(i,:))-1, M{j}(i,:), ...
%       2*sqrt(squeeze(Sigma{j}(i,i,:))) );
%     for ii=1:10
%       plot( 0:size(lat{ii}(:,dyno(i)),1)-1, lat{ii}(:,dyno(i)), 'r' );
%     end
%     plot( 0:size(latent{j}(:,dyno(i)),1)-1, latent{j}(:,dyno(i)),'g');
%     axis tight
%   end
%   drawnow;
% end

% 3. Save data
filename = [basename num2str(j) '_H' num2str(H)]; save(filename);


%   disp(['controlled trial # ' num2str(j)]);
%   if plotting.verbosity > 0;      % visualization of trajectory
%     if ~ishandle(1); figure(1); else set(0,'CurrentFigure',1); end; clf(1);
%     draw_rollout_cp;
%   end

end