%% irl_value.m
% *Summary:* Compute expected (discounted) cumulative cost for a given (set of) initial
% state distributions
%
%     function [J, dJdp] = value(p, m0, S0, dynmodel, policy, plant, cost, H)
%
% *Input arguments:*
%
%   p            policy parameters chosen by minimize
%   policy       policy structure
%     .fcn       function which implements the policy
%     .p         parameters passed to the policy
%   m0           matrix (D by k) of initial state means
%   S0           covariance matrix (D by D) for initial state
%   dynmodel     dynamics model structure
%   plant        plant structure
%   cost         cost function structure
%     .fcn       function handle to the cost
%     .gamma     discount factor
%  H             length of prediction horizon
%
% *Output arguments:*
%
%  J             expected cumulative (discounted) cost
%  dJdp          (optional) derivative of J wrt the policy parameters
%
% Copyright (C) 2008-2013 by 
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Last modification: 2013-03-21
%
%% High-Level Steps
% # Compute distribution of next state
% # Compute corresponding expected immediate cost (discounted)
% # At end of prediction horizon: sum all immediate costs up

function [J, dJdp] = irl_value(p, m0, S0, dynmodel, policy, plant, cost, H, expert)
%% Code

policy.p = p;            % overwrite policy.p with new parameters from minimize
p = unwrap(policy.p); 
m = m0; S = S0; 

D0 = size(S,2);                           % state dimension
D1 = D0 + 2*length(cost.angle);           % state dimension (with sin/cos)
L = zeros(length(cost.feati),H);          % Cost of features
J = zeros(1,H);

dp = zeros(size(J,1), length(p));
if nargout <= 1                                       % no derivatives required
  
  for t = 1:H                                  % for all time steps in horizon
    [m, S] = plant.prop(m, S, plant, dynmodel, policy);      % get next state
    L(:,t) = cost.gamma^t.*irl_exp_feat(cost, m, S);% expected features at every time step
    
    if strcmp(cost.type,'TRAJ') %Take cost on every time step
        J(t) = irl_trajectory_cost(L(:,t)',expert.featExp(t,:),cost); 
    end
  end
  
  if strcmp(cost.type,'FEATEXP')
    L = sum(L);
    J = irl_trajectory_cost(L,expert.featExp,cost);
  end
  
  J = sum(J);

else                                               % otherwise, get derivatives
  
  dmOdp = zeros([size(m0,1), length(p)]);
  dSOdp = zeros([size(m0,1)*size(m0,1), length(p)]);
  
  dJdp = 0;
  sumdLdp = 0;
  for t = 1:H                                  % for all time steps in horizon
    [m, S, dmdmO, dSdmO, dmdSO, dSdSO, dmdp, dSdp] = ...
      plant.prop(m, S, plant, dynmodel, policy); % get next state
    
    dmdp = dmdmO*dmOdp + dmdSO*dSOdp + dmdp;
    dSdp = dSdmO*dmOdp + dSdSO*dSOdp + dSdp;
    
    %Get trajectory matching cost and derivatives
    [L(:,t),S_L(:,:,t), dLdm, dLds, dSdm, dSds] = ...
        irl_exp_feat(cost, m, S);          % predictive cost
    
    %L(:,t) = cost.gamma^t.*L(:,t);         % discount
    
    %discounting gradients
    dLdp = dLdm*dmdp + dLds*dSdp; %On every time step
    sumdLdp = sumdLdp + dLdp; %For entire trajectory
    
     if strcmp(cost.type,'TRAJ')
        [J(t), dJdL] = irl_trajectory_cost(L(:,t)',expert.x(t,:),cost);
        dp = dp + cost.gamma^t*dJdL*dLdp;
     end

     dmOdp = dmdp; dSOdp = dSdp;       % bookkeeping

  end
  
  if strcmp(cost.type,'FEATEXP')
    L = irl_feature_exp(L',cost); %Get features expectations
    [J,dJdL] = irl_trajectory_cost(L,expert.featExp,cost);
    dJdp = dJdL*sumdLdp;
  elseif strcmp(cost.type,'TRAJ')
    J = sum(J);
    dJdp = rewrap(policy.p, dp);
  end

end

end


