% Blocks world toy example with two arms having potentially conflicting intentions
% Starting state is A on B, B on C, C on table
% Arm1 wants B on A, Arm2 wants C on B
% Two solutions are possible:
% - "collaborative", where both intentions are satisfied (C on B on A)
% - conflicting where the timeline splits to satisfy one intention at a time

block(a;b;c).
arm(arm1;arm2).
loc(table).
loc(Block) :-
    block(Block).

% Describing the initial state is quite tedious for now, since you also have to describe the negations
strong_holds(start, at(a, b)).
strong_holds(start, at(b, c)).
strong_holds(start, at(c, table)).

strong_notholds(start, at(Block, a)) :-
    block(Block).
strong_notholds(start, at(c,b;b,b)).
strong_notholds(start, at(a,c;c,c)).
strong_notholds(start, at((a;b), table)).
strong_notholds(start, holding(Arm, Block)) :-
    arm(Arm),
    block(Block).

% Arms can lift a block if no other block is sitting on top
possible(I, Action, al(Arm)) :-
    id(I),
    Action=action(lift, Arm, Block, From),
    block(Block),
    arm(Arm),
    strong_holds(I, at(Block, From)),
    strong_notholds(I, holding(Arm, Block')) :
        block(Block');
    strong_notholds(I, holding(Arm', Block)) :
        arm(Arm');
    strong_notholds(I, at(Block'', Block)) :
        block(Block'').

initiates(I, Action, holding(Arm, Block)) :-
    happens(I, Action, al(Arm)),
    Action=action(lift, Arm, Block, From).

terminates(I, Action, at(Block, From)) :-
    happens(I, Action, al(Arm)),
    Action=action(lift, Arm, Block, From).

% Arms can always place a held block on the table
possible(I, Action, al(Arm)) :-
    id(I),
    Action=action(place, Arm, Block, table),
    block(Block),
    arm(Arm),
    strong_holds(I, holding(Arm, Block)).

% Arms can place a held block on another block, if its top is free and it's not held by an arm
possible(I, Action, al(Arm)) :-
    id(I),
    Action=action(place, Arm, Block, Block'),
    block(Block),
    block(Block'),
    arm(Arm),
    strong_holds(I, holding(Arm, Block)),
    strong_notholds(I, at(Block'', Block')) :
        block(Block'');
    strong_notholds(I, holding(Arm', Block')) :
        arm(Arm').

initiates(I, Action, at(Block, On)) :-
    id(I),
    Action=action(place, Arm, Block, On),
    happens(I, Action, al(Arm)).

terminates(I, Action, holding(Arm, Block)) :-
    id(I),
    Action=action(place, Arm, Block, On),
    happens(I, Action, al(Arm)).

intends(start, at(b, a), arm1).
intends(start, at(c, b), arm2).

% #const tmax=8.
#show happens/3.
#show edge/2.
#show satisfies/2.
#show intends/3.
#show split/2.
% totalorder.