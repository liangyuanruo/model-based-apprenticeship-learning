clear; close all; clc;

%% INITIALISATION
%Load settings
irl_settings_baxter; clc;

%Load expert data
%irl_expert_init;

%% Apply initial random policy
j=0;
applyControllerToBaxter; %In Linux VM

mu0Sim(odei,:) = mu0; 
S0Sim(odei,odei) = S0;
mu0Sim = mu0Sim(dyno); 
S0Sim = S0Sim(dyno,dyno);

%% Begin learning
for j=1:N
    trainDynModel;
    learnPolicyIRL;
    learnWeightsIRL;
    applyControllerToBaxter; %In Linux VM
end