# Model-based Apprenticeship Learning for Robotics in High Dimensional Spaces

_This repository contains my thesis for the MSc Computing Science programme in Imperial College London, 2013-2014. The abstract of the dissertation is reproduced below._

## Abstract
_This project shows that model-based, probabilistic inverse reinforcement learning (IRL) is achievable in high-dimension state-action spaces with only a single expert demonstration. By implementing the IRL max-margin algorithm with a probabilistic model-based reinforcement learning algorithm named PILCO, we can combine the algorithms to create the IRL/PILCO algorithm, which is capable of reproducing expert trajectories by choosing suitable features.
Using IRL/PILCO, we carry out a simulation with a cart-pole system where the goal is to invert a stiff pendulum, and demonstrate that a policy replicating the task can be reproduced without explicitly defining a cost function from features.
We also carry out an experiment with the Baxter robot, using both of its arms (28 DOF) to reproduce a sweeping action by holding a brush and dustpan using velocity control. This task involved applying PILCO to a state-action space with 42 dimensions. The task was replicated nearly exactly with very high data efficiency and a minimal amount of interaction (7 trials, 56s)._

## Demonstration
A video recording of the final demonstration may be found [here](https://www.youtube.com/watch?v=1UGQlu9tEvI).

## Additional Resources
[GPML toolbox](http://www.gaussianprocess.org/gpml/code/matlab/doc/)
