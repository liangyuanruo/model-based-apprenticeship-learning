clear;clc;close all;

load data_linear_280814; %Load data
%% Init
%The file where the controllers are saved
basename = 'baxter_linear_'; % filename used for saving data
pathname = fileparts(control_path); %defined in settings file

w_filename='w.dat';
b_filename='b.dat';
w_file = fullfile(pathname,w_filename);
b_file = fullfile(pathname,b_filename);

%% Execute demo
%Begin demo
fprintf('Beginning controller demo.');
fprintf('Saving files into %s',pathname);

%Save file into shared workspace
save(w_file,'w','-ascii');
save(b_file,'b','-ascii');

fprintf('Policy parameters saved in %s. Passing control to Baxter.\n',pathname);
irl_mutex; %Pass control to Baxter, wait for reply..


%% Read results from dir/trajectory

pathname = fileparts(state_path);
state_file = fullfile(pathname,state_filename); %Get paths
action_file = fullfile(pathname,action_filename);

states = csvread(state_file,0,0,[0 0 H-1 N_STATES-1]); %Start from 0th row, 0th col
actions = csvread(action_file,0,0,[0 0 H-1 N_ACTIONS-1]);

[xx, yy] = irl_get_ctrl_trajectory(states,actions); %Get xx,yy
x = [x; xx]; y = [y; yy];        % augment training set

% 4. Save data from this run
j=j+1;
filename = [basename num2str(j) '_H' num2str(H) '.mat']; 
pathname = fileparts(save_path);
save_file = fullfile(pathname,filename);
save(save_file);

disp('Done');