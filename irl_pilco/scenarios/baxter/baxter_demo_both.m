clear;clc;close all;

%No. of trajectories
J = 15;
J_START =15;
J_END = 15;

%The file where the controllers are saved
prefix = 'scenarios/baxter/results/260814_MAIN_TRAJ/baxter_';
num = 15;
suffix = '_H16.mat';
file = strcat(prefix,num2str(num),suffix);
control_path = 'scenarios/baxter/conlin/';
pathname = fileparts(control_path); %defined in settings file

w_filename='w.dat';
b_filename='b.dat';
w_file = fullfile(pathname,w_filename);
b_file = fullfile(pathname,b_filename);

%Mutex Settings
BAXTER_ID = 'BAXTER';
SELF_ID = 'MATLAB';
mutex_path = 'scenarios/baxter/mutex/';
mutex_filename = 'mutex.dat';

%Get data
data = matfile(file);

pol = data.Policies;

for j=J_START:J_END
    fprintf('Beginning controller demo %d of %d.\n',j,J);
    
    %Save file into shared workspace
    w = pol{j}.p.w;
    b = pol{j}.p.b;
    save(w_file,'w','-ascii');
    save(b_file,'b','-ascii');
    
    fprintf('Policy parameters saved in %s. Passing control to Baxter.\n',pathname);
    irl_mutex; %Pass control to Baxter, wait for reply..
    disp('Done');

end