function [ c, ceq ] = irl_weight_constraint( w, expertFeatExp, featExp, costVal, cost )

%IRL_WEIGHT_CONSTRAINT Constraint function to evaluate weights
%   This is used by fmincon to find a suitable weights for the separate
%   features-expectation cost function for the problem

%The constraints are
%c(w) <= 0 
%ceq(w) == 0

if strcmp(cost.type,'TRAJ')
    c = w' * sum(featExp)' - w' * sum(expertFeatExp)' + costVal;
elseif strcmp(cost.type,'FEATEXP')
    c = w' * featExp' - w' * expertFeatExp' + costVal;
end

ceq = norm(w,2) - 1; %using 2-norm. norm of weights should be one

end

