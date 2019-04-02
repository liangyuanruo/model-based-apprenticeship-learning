%%EXPERT CALCULATIONS

load('expert.mat'); %Get expert's trajectory

expert.x = expert.x(:,feati);

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
