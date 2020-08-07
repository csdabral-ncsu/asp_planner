% See blocks_world.lp for details about the scenario
% Meant to be run with blocks_world_base.lp

% This tmax is the minimum required for this scenario, arrived at by experimentation.
% Larger tmax will increase running time.
#const tmax=6.

% Force a "collaborative" timeline, by forcing noconflict
noconflict.