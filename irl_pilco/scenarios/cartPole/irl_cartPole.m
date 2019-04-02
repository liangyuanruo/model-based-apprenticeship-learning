clear; close all; clc;

%INITIALISATION
%Load the trajectory from "expert"
irl_settings_cp; clc;
basename = 'cartPole_'; % filename used for saving data

%Load expert data
irl_expert_init;

% Initial J rollouts using a random initial policy
for jj = 1:J
  [xx, yy, latent{jj}] = ...
    irl_rollout(gaussian(mu0, S0), struct('maxU',policy.maxU), H, plant, cost);
  x = [x; xx]; y = [y; yy];       % augment training sets for dynamics model
  
  if plotting.verbosity > 0;      % visualization of trajectory
    if ~ishandle(1); figure(1); 
    else set(0,'CurrentFigure',1); 
    end; 
    clf(1);
    draw_rollout_cp;
  end
  
end

mu0Sim(odei,:) = mu0; 
S0Sim(odei,odei) = S0;
mu0Sim = mu0Sim(dyno); 
S0Sim = S0Sim(dyno,dyno);

for j=1:N
    trainDynModel;
    learnPolicyIRL;
    learnWeightsIRL
    applyControllerIRL;
end









