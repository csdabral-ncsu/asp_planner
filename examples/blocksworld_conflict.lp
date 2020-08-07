% See blocks_world.lp for details about the scenario
% Meant to be run with blocks_world_base.lp

% This tmax is the minimum required for this scenario, arrived at by experimentation.
% Larger tmax will increase running time.
#const tmax=8.

% Force a timeline split (conflict)
:- not split(X, Y) : id(X), id(Y), X!=Y.