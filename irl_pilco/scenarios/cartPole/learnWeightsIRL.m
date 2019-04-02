
%Get expected features from the latest trajectory in xx
f_xx = xx(:,feati); %Trajectory of features are columns specified by feati
featExp_xx = irl_feature_exp(f_xx,cost); %Feature expectations of 
                                          %latest trajectory

                                          
%This is important as featExp_xx is updated
fcn.cost = @(w)irl_weight_cost(w,expert.featExp,featExp_xx,cost); %Cost function
fcn.nonlcon = @(w)irl_weight_constraint(w,...
                    expert.featExp,featExp_xx,costVal(max(1,j-1)),cost); %Constraint function

                
%Fill in problem struct

%fmincon
disp('--------------------------------')
disp('Running fmincon to learn cost.w')
problem = createOptimProblem('fmincon'); %Create problem struct
problem.objective = fcn.cost; %Function to minimise
problem.x0 = cost.W; %Initial guess is cost array
problem.lb = zeros(size(cost.W)); %Weights can't go below zero
problem.ub = ones(size(cost.W)); %and can't go above one
problem.nonlcon = fcn.nonlcon; %Function to calculate constraints
[cost.W, costVal(j)] = fmincon(problem);%Minimize resulting cost
fprintf('costVal(%d)=%f\n',j,costVal(j));
disp('--------------------------------')

%quadprog
% min(x) 0.5*x'*H*x + f'*x   subject to:  A*x <= b 
% problem = createOptimProblem('quadprog'); %Paper says it's a quadprog prob
% problem.H = zeros(length(cost.W));
% problem.f = (Ef_expert - featExp_xx)';
% problem.Aineq = Ef_expert - featExp_xx;
% problem.bineq = costVal[max(0,j-1)]; %max() to avoid negative index
% problem.Aeq = [];
% problem.beq = [];
% problem.lb = zeros(size(cost.W)); %Weights can't go below zero
% problem.ub = ones(size(cost.W)); %and can't go above one
% problem.x0 = cost.W;


Weights{j}=cost.W; %Save the result