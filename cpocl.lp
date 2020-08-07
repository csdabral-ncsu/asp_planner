% Basic constraints
id(1..tmax).
id(start).
id(end).

% All ids should be after start, but we don't want to generate after preds here, so using negation
:-  not after(I, start),
    id(I),
    I!=start.

% Generate partial ordering
% Should produce all orderings across runs, from minimal to total
{ edge(X, Y) } :-
    id(X),
    id(Y),
    X!=Y.

:-  edge(X, Y),
    after_indirect(Y, X). % A->B->C This is to avoid frivolous edges of the form A->C here

%% Partial ordering rules
after(X, Z) :-
    edge(Z, X).

after(X, Z) :-
    after(X, Y),
    after(Y, Z), X!=Z.

not after(Y, X) :-
    after(X, Y).

before(Y, X) :-
    after(X, Y).

after_indirect(X, Z) :-
    after(Y, Z),
    edge(Y, X).

% Unordered nodes are nodes that are not ordered and are in the same timeline
unordered(X, Y) :-
    id(X),
    id(Y),
    not after(X, Y),
    not before(X, Y),
    X!=Y,
    concludes(C, X):
        terminus(C),
        concludes(C, Y).

% We want minimal ordering so causal links correspond to edges
#minimize {1@1,after(X,Y):after(X,Y)}.

% A conclusion of a given timestep is a timestep that is farthest away from it (the terminus of a timeline)
% A given timestep can have multiple conclusions (if there is branching downstream)
terminus(C) :-
    id(C),
    not after(X, C): id(X).

concludes(C, X) :-
    id(X),
    after(C, X),
    terminus(C).

concludes(C, C) :-
    terminus(C).

%% A split indicates unexecuted actions, or more generally, a split in the timeline
% A split occurs when a child node doesn't have all the conclusions of its parent
split(X, Y) :-
    edge(X, Y),
    concludes(C, X),
    not concludes(C, Y),
    C!=Y,
    not terminus(Y),
    not edge(X, C).

% A node where timeline splits should have a single parent.
% This is to avoid scenarios where a timeline feeds back into another timeline.
:-  split(X, Y),
    not { edge(P, Y): id(P) } = 1.

% Every id should have a happens, unless it's a terminus or start
:-  id(I),
    not terminus(I),
    I!=start,
    not { happens(I, _, _) } = 1.

{ happens(I, X, A) } :-
    possible(I, X, A),
    id(I).

% A terminus should not have a happens
:-  happens(T, _, _),
    terminus(T).

% Neither should start
:-  happens(start, _, _).

% end should always be a terminus
:-  not terminus(end).

% A split should only occur if there's a conflict
not possible(I1', X, A) :-
    split(S, I1),
    split(S, I2),
    I1!=I2,
    edge(I1, I1'),
    happens(I2, X, A).

% Extract actors
% The list of actors is in a nested predicate of the form al(Actor1, al(Actor2, al(...)))
% Couldn't think of a more elegant way to pass a variable-length list
__happens(I, A) :-
    happens(I, E, A).

__happens(I, A) :-
    __happens(I, al(_, A)).

actor(I, A) :-
    __happens(I, al(A, _)).

actor(I, A) :-
    __happens(I, al(A)).

%% Intention rules
satisfies(I2, intention(I1, X, A)) :-
    intends(I1, X, A),
    initiates(I2, _, X),
    after(I2, I1),
    not satisfies(I3, intention(I1, X, A)):
        after(I3, I1),
        before(I3, I2).

% All intended fluents must hold at some point after they're intended
:-  intends(I1, X, A),
    not satisfies(_, intention(I1, X, A)).

% Intention frame
% first arg of frame is event_ID in the frame, excluding motivating and satisfying steps
frame(I3, intention(I1, X, A)) :-
    satisfies(I2, intention(I1, X, A)),
    after(I3, I1),
    before(I3, I2),
    actor(I3, A).

% All events must be part of frames of all their actors, except for unintentional agents, including the environment (env)
:-  actor(I, A),
    not frame(I, intention(_, _, A)),
    not satisfies(I, intention(_, _, A)),
    not unintentional(A).

unintentional(env).

%% "strong" inertial rules

% holds
strong_holds(I, X) :-
    initiates(I1, E, X),
    before(I1, I),
    not killed(I1, X, I).

strong_holds(I, X) :-
    strong_holds(I1, X),
    before(I1, I),
    not killed(I1, X, I).

% A fluent is killed if it was terminated at least once in the interval [I1, I2).
% We need to be conservative, so we include all I such that unordered(I1, I) or unordered(I2, I).
% Unordered is only defined for the same timeline branch above, so there won't be interference from other branches
% Strictly in between (inc I1):
killed(I1, X, I2) :-
    id(I2),
    before(I1, I),
    before(I, I2),
    terminates(I, _, X).

killed(I1, X, I2) :-
    id(I2),
    terminates(I1, _, X).

% unordered wrt I1 or I2:
killed(I1, X, I2) :-
    id(I2),
    unordered(I, I1),
    terminates(I, _, X).

killed(I1, X, I2) :-
    id(I1),
    unordered(I, I2),
    terminates(I, _, X).

% We need a separate predicate for notholds. We can't infer notholds from the absence of strong_holds because of partial ordering.
strong_notholds(I, X) :-
    terminates(I1, E, X),
    before(I1, I),
    not resurrected(I1, X, I).

strong_notholds(I, X) :-
    strong_notholds(I1, X),
    before(I1, I),
    not resurrected(I1, X, I).

% "resurrected" is opposite of "killed" (a fluent has been made true again)
% Strictly in between (inc I1):
resurrected(I1, X, I2) :-
    id(I2),
    before(I1, I),
    before(I, I2),
    initiates(I, _, X).

resurrected(I1, X, I2) :-
    id(I2),
    initiates(I1, _, X).

% unordered wrt I1 or I2:
resurrected(I1, X, I2) :-
    id(I2),
    unordered(I, I1),
    initiates(I, _, X).

resurrected(I1, X, I2) :-
    id(I1),
    unordered(I, I2),
    initiates(I, _, X).

% sanity check
:-  strong_holds(I, X),
    strong_notholds(I, X).

% Automatically add intentions
% Option mastermind must be turned on
% Fluent space must be defined using the fluent(F) predicate
orchestrator(mastermind).

possible(I, A, al(O)) :-
    id(I),
    orchestrator(O),
    A=action(motivate, F, E),
    fluent(F),
    actor(E),
    mastermind.

intends(I, F, P) :-
    happens(I, action(motivate, F, P), al(O)).

% Minimize number of automatically added intentions
#minimize {1@2,I:happens(I,action(motivate,_,_),_)}.

unintentional(O) :-
    orchestrator(O).

%% options

% totalorder
% means no nodes are unordered
:- unordered(X, Y), totalorder.

% noconflict
% means single timeline; all intentions must be satisfied
:- split(X, Y), noconflict.