%applyControllerToBaxter

%High level steps:
%
%   1 Save policy parameters to file
%   2 Pause the program, wait for robot to execute policy and save results
%   3 Read results from file into xx, yy
%   4 Save data
%

% 1. Save policy parameters
%(policy.p.w and policy.p.b for conlin)

pathname = fileparts(control_path); %defined in settings file
w_file = fullfile(pathname,conlin_w_filename);
b_file = fullfile(pathname,conlin_b_filename);
w = policy.p.w;
b = policy.p.b;
save(w_file,'w','-ascii'); %Save to controller (conlin) folder
save(b_file,'b','-ascii');

% 2. Wait for robot to execute policy/save results
fprintf('Policy parameters saved in %s. Passing control to Baxter.\n',pathname);
fprintf(['Executing controller on Baxter with trajectories\n'...
        ' saved in %s state.dat and %s action.dat \n'],...
        state_path,action_path)

%Wait for robot to execute controller
irl_mutex;


% 3. Read results from dir/trajectory
pathname = fileparts(state_path);
state_file = fullfile(pathname,state_filename); %Get paths
action_file = fullfile(pathname,action_filename);

states = csvread(state_file,0,0,[0 0 H-1 N_STATES-1]); %Start from 0th row, 0th col
actions = csvread(action_file,0,0,[0 0 H-1 N_ACTIONS-1]);

[xx, yy] = irl_get_ctrl_trajectory(states,actions); %Get xx,yy
x = [x; xx]; y = [y; yy];        % augment training set

% 4. Save data from this run
filename = [basename num2str(j) '_H' num2str(H) '.mat']; 
pathname = fileparts(save_path);
save_file = fullfile(pathname,filename);
save(save_file);