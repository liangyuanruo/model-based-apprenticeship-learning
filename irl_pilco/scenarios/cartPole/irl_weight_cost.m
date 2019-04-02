function [ J ] = irl_weight_cost( w, expertFeatExp, featExp, cost )
%IRL_WEIGHT_COST Cost function to evaluate weights
%   This is used by fmincon to find a suitable weights for the separate
%   features-expectation cost function for the problem


if strcmp(cost.type,'TRAJ')

    J = - w' * (sum(expertFeatExp) - sum(featExp))';

elseif strcmp(cost.type,'FEATEXP')
    J = - w' * (expertFeatExp - featExp)';
end


end %end function

