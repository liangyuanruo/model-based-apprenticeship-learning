function [ featExp ] = irl_feature_exp( f, cost )
%IRL_FEATURE_EXP Computes expected features for one or more trajectories
%   featExp: Features expectation
%   f: feature matrix
%   cost.gamma: discount factor

%This implementation returns featExp simply as a discounted state matrix
if strcmp(cost.type,'TRAJ')
    if ndims(f) == 2
        [T,D] = size(f);
        featExp = f;
    
        for t = 1:T
            featExp(t,:) = cost.gamma^t.*featExp(t,:);
        end
    
    elseif ndims(f) == 3
        [T,D,J] = size(f);
        featExp = f;

        for j = 1:J
        for t = 1:T
            featExp(t,:,j) = cost.gamma^t.*featExp(t,:,j);
        end
        end

    end
        
%This implementation below sums over the trajectory for all features
%This is used as the "expected discounted accumulated feature value vector"
%Must also edit irl_trajectory_cost to reflect the different implementation
elseif strcmp(cost.type,'FEATEXP')

    if ndims(f) == 2 %i.e. only one trajectory
        [T, D] = size(f);
        featExp = zeros(1,D);

        for t=1:T
            featExp = featExp + f(t,:).*cost.gamma.^t;
        end

    elseif ndims(f) == 3 %
         [T, D, J] = size(f);
         featExp = zeros(1,D);

         for j=1:J
         for t=1:T
            featExp = featExp + f(t,:,j).*cost.gamma.^t;
         end
         end

         featExp = featExp./J; %normalise over no. of trajectories
    end
end

end %end function
