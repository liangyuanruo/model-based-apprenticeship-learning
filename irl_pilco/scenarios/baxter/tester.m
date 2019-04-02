clear;clc;close all

load baxter_1_H16
H=2;
err = 1e-4;

%% Checkgrad for irl_value

%%[J, dJdp] = irl_value(p, m0, S0, dynmodel, policy, plant, cost, H, expert)
[d dy dh] = checkgrad(@irl_value,policy.p,err,mu0Sim,S0Sim,...
               dynmodel,policy,plant,cost,H,expert);


return
%% Settings for other two functions
Q = 3;
m = randn(Q,1);
s = randn(Q,Q);
s = s*s';

opt.verbosity = 3;
cost.feati = 1:Q;
cost.scale = 1;
cost.fcn = @test_irl_exp_feat;
cost.gamma = 1;
cost.width = 0.25;
cost.expl = 0;
cost.angle = [];
cost.type = 'TRAJ';
cost.W = randn(14,1);

%% Checkgrad for irl_exp_feat
%[ L, S, dLdm, dLds, dSdm, dSds] = test_irl_exp_feat(cost, m, s)
[d dy dh] = checkgrad(@test_irl_exp_feat,s,err,m,cost);

disp('Results for irl_exp_feat')
d
dy
dh

%% Checkgrad for irl_trajectory_cost
%function [f, df] = irl_trajectory_cost(featExp, expertFeatExp, cost)

featExp = randn(1,28);
expertFeatExp = randn(1,28);

[d dy dh] = checkgrad(@irl_trajectory_cost,featExp,err,expertFeatExp,cost);

disp('Results for irl_trajectory_cost')
d
dy
dh
