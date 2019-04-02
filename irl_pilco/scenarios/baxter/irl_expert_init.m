%%EXPERT CALCULATIONS

%Ready to read in expert trajectory 
pathname = fileparts(expert_path); %defined in settings file
expert_file = fullfile(pathname,expert_filename);

try
expert.data = csvread(expert_file,...
                    0,0,[0 0 H-1 N_STATES-1]); %Read expert trajectory
catch
    fprintf(['Error reading expert trajectory:\n'...
            'Please have expert demonstration ready in %s\n'],...
            strcat(expert_path,expert_filename));
    exit
end

%Reduce expert features to only those we are matching in cost function
expert.x = expert.data(:,feati);

%Expert's mean and std dev
expert.mean = mean(expert.x);
expert.std = std(expert.x);

expert.featExp = irl_feature_exp(expert.x,cost); %Expert feature expectations

%Normalise all states
expert.x_norm = zeros(size(expert.x));
for i=1:size(expert.x,1)
   expert.x_norm(i,:) = (expert.x(i,:) - expert.mean)./expert.std;
end

%Sum of states in features
expert.normFeatExp = irl_feature_exp(expert.x_norm,cost);
