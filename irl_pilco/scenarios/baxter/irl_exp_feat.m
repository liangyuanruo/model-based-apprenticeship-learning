%function [ L, dLdm, dLds] = irl_exp_feat(cost, m, s)
function [ L, S, dLdm, dLds, dSdm, dSds] = irl_exp_feat(cost, m, s)
%L, S, dLdm, dLds, dSdm, dSds
%Baxter feature expectation function for IRL
%   cost: the cost struct
%   m: mean vector of features [LPos, LVel, RPos, RVel]
%   s: covariance matrix of state m
%
%   L: expected feature vector defined by cost.feati
%   dLdm: derivative of L wrt state m
%   dLds: derivative of L wrt state s
%   dSdm: derivative of S wrt state m
%   dSds: derivative of S wrt state s
%
%% Code
s = (s+s')/2;
% 1. Some precomputations
D0 = size(s,2);    % state dimension 
D1 = D0 + 2*length(cost.angle);       % state dimension (with sin/cos)

%Allocate memory
i = 1:D0; k = D0+1:D1;

L = zeros(D1,1); L(i) = m; 
S = zeros(D1); S(i,i) = s;

%dLdm = zeros(D1,D0);
%dLds = zeros(D1,D0*D0); %Tensor reshaped into a matrix D1 x D0 x D0

%Full mean and covariance matrices obtained
[ L(k),S(k,k),C,augdLdm,augdSdm,dCdm,augdLds,augdSds,dCds] = ...
                                        gTrig(m,s,cost.angle);
                                    
%Crossterm
sC = s*C;
S(i,k) = sC;
S(k,i) = sC';

%Obtain dLdm (D1 x D0)
dLdm = [eye(D0);
        augdLdm];
    
%Obtain dLds  
dLds = [zeros(D0,D0*D0); 
        augdLds]; %(D1 x D0*D0)     

%%%%%%%%%%%%%%%%%%%%    
% dSdm 
% size of D1*D1 x D0 
%dSdm = [ dsdm = zeros(D0,D0), dsCdm 
%         d(sC)'dm,            augdSdm]

ss = kron(eye(D1-D0),s);
dsCdm = ss*dCdm;
dsCdm = reshape(dsCdm,[D0 D1-D0 D0]);
dsCtdm = permute(dsCdm,[2 1 3]);
augdSdm = reshape(augdSdm,[D1-D0 D1-D0 D0]);

dSdm = zeros([D1 D1 D0]); %Preallocate

dSdm = [zeros(D0,D0,D0), dsCdm;
        dsCtdm, augdSdm];
    

%%%%%%%%%%%%%%%%%%%%    

%dSds D1*D1 x D0*D0

%dSds = [ dsds, dsCds
%          dsC'ds, augdSds]

% dsds = matrix of ones and halves 4x4x4x4
% dsCds 2x4x4x4 = dsds * C + dCds * s (note: reshape C and s)


%Create dsds (There must be a better way..?)
dsds = zeros(D0,D0,D0,D0);

for i=1:D0
for j=1:D0
for k=1:D0
for l=1:D0
    if(i==j && k==l && i==k)
        dsds(i,j,k,l) = 1;
    elseif((i==k && j==l) || (i==l && j==k))
        dsds(i,j,k,l)=0.5;
    end
end
end
end
end

%dsds is matrix of ones and halves
dsCds = ss*dCds + (reshape(dsds,D0*D0,D0*D0)*kron(eye(D0),C))';
dsCds = reshape(dsCds,[D0 D1-D0 D0 D0]);
dsCtds = permute(dsCds,[2 1 3 4]); 
augdSds = reshape(augdSds,[D1-D0 D1-D0 D0 D0]);

dSds = [dsds, dsCds;
        dsCtds, augdSds];

%%%%%%%%%%%%%%%%%%%%    
%Get rid of Theta after Sin/Cos obtained
L = L(cost.feati);
S = S(cost.feati,cost.feati);
dLdm = dLdm(cost.feati,:); 
dLds = dLds(cost.feati,:);

D = length(cost.feati); %Dimension without theta
dSdm = dSdm(cost.feati,cost.feati,:); %Remove Theta
dSdm = reshape(dSdm,[D*D D0]); %Reshape into 2D

dSds = dSds(cost.feati,cost.feati,:,:); %Remove theta
dSds = reshape(dSds,[D*D D0*D0]); %Reshape into 2D


end

