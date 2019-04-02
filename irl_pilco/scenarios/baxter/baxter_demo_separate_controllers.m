clear;clc;close all;

%No. of trajectories
J = 15;



%The two files where the controllers are saved
l_prefix = 'scenarios/baxter/results/150814_larm_sweep/baxter_';
l_num = 15;
l_suffix = '_H32.mat';
l_file = strcat(l_prefix,num2str(l_num),l_suffix);

r_prefix = 'scenarios/baxter/results/150814_rarm_sweep/baxter_';
r_num = 15;
r_suffix = '_H32.mat';
r_file = strcat(r_prefix,num2str(r_num),r_suffix);
control_path = 'scenarios/baxter/conlin/';
pathname = fileparts(control_path); %defined in settings file
lw_filename='lw.dat';
lb_filename='lb.dat';
rw_filename='rw.dat';
rb_filename='rb.dat';
lw_file = fullfile(pathname,lw_filename);
lb_file = fullfile(pathname,lb_filename);
rw_file = fullfile(pathname,rw_filename);
rb_file = fullfile(pathname,rb_filename);

%Mutex Settings
BAXTER_ID = 'BAXTER';
SELF_ID = 'MATLAB';
mutex_path = 'scenarios/baxter/mutex/';
mutex_filename = 'mutex.dat';

%Get data
l_data = matfile(l_file);
r_data = matfile(r_file);

l_pol = l_data.Policies;
r_pol = r_data.Policies;

for j=1:J
    fprintf('Beginning controller demo %d of %d.\n',j,J);
    %Save file into shared workspace
    lw = l_pol{j}.p.w;
    lb = l_pol{j}.p.b;
    rw = r_pol{j}.p.w;
    rb = r_pol{j}.p.b;
    save(lw_file,'lw','-ascii'); %Save to controller (conlin) folder
    save(lb_file,'lb','-ascii');
    save(rw_file,'rw','-ascii');
    save(rb_file,'rb','-ascii');
    
    fprintf('Policy parameters saved in %s. Passing control to Baxter.\n',pathname);
    irl_mutex; %Pass control to Baxter, wait for reply..
    disp('Done');

end