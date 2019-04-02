%% irl_settings_cp.m
% *Summary:* Script set up the cart-pole scenario
%
% Copyright (C) 2008-2013 by 
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Last modified: 2013-05-24
%
%% High-Level Steps
% # Define state and important indices
% # Set up scenario
% # Set up the plant structure
% # Set up the policy structure
% # Set up the cost structure
% # Set up the GP dynamics model structure
% # Parameters for policy optimization
% # Plotting verbosity
% # Some array initializations

%% Code

rand('seed',3); randn('seed',5); format short; format compact; 
% include some paths
try
  rd = '../../';
  addpath([rd 'base'],[rd 'util'],[rd 'gp'],[rd 'control'],[rd 'loss']);
catch
end

clc

% 1. Define state and important indices

% 1a. Full state representation
%
%   Left Arm Positions (in radians)
%   1   left_s0 
%   2   left_s1
%   3   left_e0
%   4   left_e1
%   5   left_w0
%   6   left_w1  
%   7   left_w2

%   Left Arm Velocities (in rad/s)
%   8  left_s0 
%   9  left_s1
%   10  left_e0
%   11  left_e1
%   12  left_w0
%   13  left_w1  
%   14  left_w2

%   Right Arm Positions (in radians)
%   15  right_s0 
%   16  right_s1
%   17  right_e0
%   18  right_e1
%   19  right_w0
%   20  right_w1  
%   21  right_w2

%   Right Arm Velocities (in radians)
%   22  right_s0 
%   23  right_s1
%   24  right_e0
%   25  right_e1
%   26  right_w0
%   27  right_w1  
%   28  right_w2


% 1b. Important indices
% odei  indices for the ode solver
% augi  indices for variables augmented to the ode variables
% dyno  indices for the output from the dynamics model and indicies to loss
% angi  indices for variables treated as angles (using sin/cos representation)
% dyni  indices for inputs to the dynamics model
% poli  indices for the inputs to the policy
% difi  indices for training targets that are differences (rather than values)

ARMS = 'BOTH';  %LEFT, RIGHT or BOTH. Same in Linux VM

if(strcmp(ARMS,'BOTH')) %IF we are using both arms
    N_STATES = 28;
    N_ACTIONS = 14;
else %Either left or right arms
    N_STATES = 14;
    N_ACTIONS = 7;
end

odei = 1:N_STATES;          % variables for the ode solver
augi = [];                  % variables to be augmented
dyno = 1:N_STATES;          % variables to be predicted (and known to loss)
angi = [];                  % angle variables
dyni = 1:N_STATES;          % variables that serve as inputs to the dynamics GP
poli = 1:N_STATES;          % variables that serve as inputs to the policy
difi = 1:N_STATES;          % variables that are learned via differences

%Features
%feati = 1:N_STATES;    %Indices to use as our features
feati = [1:7, 15:21];   %No velocities in our cost function


% 2. File I/O
control_path = 'scenarios/baxter/conlin/';
conlin_w_filename = 'w.dat';
conlin_b_filename = 'b.dat';

state_path = 'scenarios/baxter/trajectory/';
state_filename = 'state.dat';

action_path = 'scenarios/baxter/trajectory/';
action_filename = 'action.dat';

save_path = 'scenarios/baxter/results/';

mutex_path = 'scenarios/baxter/mutex/';
mutex_filename = 'mutex.dat';

expert_path = 'scenarios/baxter/expert/';
expert_filename = 'expert.dat';

basename = 'baxter_'; % filename used for saving data


%For demo only
conlin_lw_filename = 'lw.dat';
conlin_lb_filename = 'lb.dat';
conlin_rw_filename = 'rw.dat';
conlin_rb_filename = 'rb.dat';

% 3. Set up the scenario (Must be same as linuxVM)
f = 2;                             % [Hz] Frequency of sampling
                                   % (must be same as Baxter)
dt = 1/f;                          % [s] sampling time
T = 8.0;                          % [s] initial prediction horizon time
H = ceil(T/dt);                    % prediction steps (optimization horizon)
%neutral_pos = [0 -0.55 0 1.26 0 0 0.75]; %Definition of neutral 
                                         %position in 
                                            
%mu0 = [leftArmPos rightArmPos leftArmVel rightArmVel]' column vector
% initial state mean 
%if strcmp(ARMS,'BOTH')
%    mu0 = [repmat(neutral_pos,1,2) zeros(1,N_ACTIONS)]';
%else
%    mu0 = [neutral_pos zeros(1,N_ACTIONS)]';
%end

if (~strcmp(ARMS,'BOTH'))
%Initial state is the first state in expert's trajectory
mu0 = [csvread(strcat(expert_path,expert_filename),...
                    0,0,[0 0 0 N_STATES/2-1]),...
                    zeros(1,N_ACTIONS)]';
else %Arms set to "both"
   
    mu0 = [csvread(strcat(expert_path,expert_filename),...
                    0,0,[0 0 0 6]),...
           zeros(1,N_ACTIONS/2),...
           csvread(strcat(expert_path,expert_filename),...
                    0,14,[0 14 0 20]),...
           zeros(1,N_ACTIONS/2)]';
    
end

% initial state covariance                           
S0 = diag((1e-4*ones(1,N_STATES))); %Set to really small value to reflect
                                    %near-complete certainty in pos
N = 15;                            % no. of controller optimizations
J = 1;                             % initial J trajectories of length H each
K = 1;                             % no. of initial states for which we optimize
%nc = 50;                           % number of controller basis functions

% 4. Plant structure
%plant.dynamics = @dynamics_cp;                    % dynamics ode function
%plant.noise = diag(ones(1,4)*0.01.^2);            % measurement noise
%plant.dt = dt;
%plant.ctrl = @zoh;                                % controller is zero order hold
plant.odei = odei;
plant.augi = augi;
plant.angi = angi;
plant.poli = poli;
plant.dyno = dyno;
plant.dyni = dyni;
plant.difi = difi;
plant.prop = @propagated;

% 6. Set up the cost structure
 cost.fcn = @irl_exp_feat;                  % cost function
 cost.gamma = 1;                            % discount factor
 cost.width = 0.25;                         % cost function width
 cost.expl =  0.0;                          % exploration parameter (UCB)
 cost.angle = plant.angi;                   % index of angle (for cost function)
 cost.scale = 1e3;                          %Cost function scaling (numerical reasons)
 cost.type = 'FEATEXP'%'TRAJ';        %TRAJ-ectory matching, or
                            %FEATEXP( feature expectation)
%12. Initiate expert data
irl_expert_init;

% 5. Policy structure
%policy.fcn = @(policy,m,s)conCat(@congp,@gSat,policy,m,s);% controller 
policy.fcn = @(policy,m,s)conCat(@conlin,@gSat,policy,m,s);% controller 
                                                          % representation
%policy.maxU = 0.6*ones(N_ACTIONS,1);      % max. amplitude of ctrl sig

policy.maxU = max(abs(expert.data(:,[8:14 22:28])))';

% control signal
%For conlin.m controller
policy.p.w = ones(N_ACTIONS,N_STATES); %Weights ExD
policy.p.b = zeros(N_ACTIONS,1); %Bias Ex1
                                                          
                                                          
%For congp.m controller
%[mm ss cc] = gTrig(mu0, S0, plant.angi);                  % represent angles 
%mm = [mu0; mm]; cc = S0*cc; ss = [S0 cc; cc' ss];         % in complex plane 

%policy.p.inputs = gaussian(mm(poli), ss(poli,poli), nc)'; % init. location of 
                                                          % basis functions
                                                          
%policy.p.targets = 0.1*randn(nc, length(policy.maxU));    % init. policy targets 
                                                          % (close to zero)
                                                          
%policy.p.hyp = log([1 1 1 0.7 0.7 1 0.01])';              % initialize policy
                                                          % hyper-parameters


 
 %cost.W = (ones(size(feati))./length(feati))'; %norm(w) <= 1, weight equally 
 if strcmp(ARMS,'BOTH')
    cost.W = [ones(1,7)./14,zeros(1,7),ones(1,7)./14,zeros(1,7)]';
 else
    cost.W = [ones(1,7)./7,zeros(1,7)]';
 end
 cost.W = cost.W(feati); %Use only features in cost computation
 cost.feati = feati; %Features indices for the cost struct
 
 %To save previous weights
 Weights = cell(N,1); %Previous weights
 costVal = zeros(N,1); %Previous costs from those weights

% 7. Dynamics model structure
dynmodel.fcn = @gp1d;                % function for GP predictions
dynmodel.train = @train;             % function to train dynamics model
dynmodel.induce = zeros(1000,0,1);    % shared inducing inputs (sparse GP)
trainOpt = [300 500];                % defines the max. number of line searches
                                     % when training the GP dynamics models
                                     % trainOpt(1): full GP,
                                     % trainOpt(2): sparse GP (FITC)

% 8. Parameters for policy optimization
opt.length = -200;                        % max. number of line searches
opt.MFEPLS = 10;                         % max. number of function evaluations
                                         % per line search
opt.verbosity = 3;                       % verbosity: specifies how much 
                                         % information is displayed during
                                         % policy learning. Options: 0-3

% 9. Plotting verbosity
plotting.verbosity = 0;            % 0: no plots
                                   % 1: some plots
                                   % 2: all plots

% 10. Some initializations
x = []; y = [];
fantasy.mean = cell(1,N); fantasy.std = cell(1,N);
realCost = cell(1,N); M = cell(N,1); Sigma = cell(N,1);
Policies = cell(N,1);

%11. Mutex (Passing control between linuxVM and MATLAB)

SELF_ID = 'MATLAB';
BAXTER_ID = 'BAXTER';

