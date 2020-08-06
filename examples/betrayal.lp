professor(alice;bob;george).
student(carol).
intends(start, passed(carol), carol).

strong_notholds(start, decision_made(Prof, Student)) :- student(Student), professor(Prof).
% strong_notholds(start, final_decision(Student)) :- student(Student).
strong_notholds(start, passed(Student)) :- student(Student).
strong_notholds(start, failed(Student)) :- student(Student).

possible(I, action(ask_to_sign(Student, Prof)), al(Student)) :-
    id(I),
    student(Student),
    professor(Prof).

initiates(I, Action, asked(Student, Prof)) :-
    happens(I, Action, al(Student)),
    Action=action(ask_to_sign(Student, Prof)).

intends(I, passed(Student), Prof) :-
    happens(I, Action, al(Student)),
    Action=action(ask_to_sign(Student, Prof)).

possible(I, action(promise_to_sign(Prof, Student)), al(Prof)) :-
    strong_holds(I, asked(Student, Prof)).

initiates(I, Action, has_promise(Student, Prof)) :-
    happens(I, Action, al(Prof)),
    Action=action(promise_to_sign(Prof, Student)).

possible(I, action(lie(Prof, Student)), al(Prof)) :-
    id(I),
    professor(Prof),
    student(Student).

initiates(I, Action, has_promise(Student, Prof)) :-
    happens(I, Action, al(Prof)),
    Action=action(lie(Prof, Student)).

intends(I, failed(Student), Prof) :-
    happens(I, Action, al(Prof)),
    Action=action(lie(Prof, Student)).

% :- satisfies(I2, intention(I1, failed(Student), Prof)), not concludes(end, I2).

possible(I, action(thesis_defense(Student)), al(Student)) :-
    id(I),
    student(Student),
    3 { strong_holds(I, has_promise(Student, Prof)): professor(Prof) }.

initiates(I, Action, thesis_available_to_sign(Student)) :-
    happens(I, Action, al(Student)),
    Action=action(thesis_defense(Student)).

possible(I, action(sign_thesis(Prof, Student)), al(Prof)) :-
    strong_holds(I, thesis_available_to_sign(Student)),
    strong_notholds(I, decision_made(Prof, Student)),
    professor(Prof),
    student(Student).

initiates(I, Action, thesis_signed(Prof, Student)) :-
    happens(I, Action, al(Prof)),
    Action=action(sign_thesis(Prof, Student)).

initiates(I, Action, decision_made(Prof, Student)) :-
    happens(I, Action, al(Prof)),
    Action=action(sign_thesis(Prof, Student)).

possible(I, action(refuse_to_sign(Prof, Student)), al(Prof)) :-
    strong_holds(I, thesis_available_to_sign(Student)),
    professor(Prof),
    student(Student).

initiates(I, Action, decision_made(Prof, Student)) :-
    happens(I, Action, al(Prof)),
    Action=action(refuse_to_sign(Prof, Student)).

possible(I, action(pass(Student)), al(env)) :-
    id(I),
    student(Student),
    % strong_notholds(I, final_decision(Student)),
    % strong_notholds(I, passed(Student)),
    strong_notholds(I, failed(Student)),
    3 { strong_holds(I, thesis_signed(Prof, Student)): professor(Prof) },
    3 { strong_holds(I, decision_made(Prof, Student)): professor(Prof) }.

initiates(I, Action, passed(Student)) :-
    happens(I, Action, al(env)),
    Action=action(pass(Student)).

% initiates(I, Action, final_decision(Student)) :-
%     happens(I, Action, al(env)),
%     Action=action(pass(Student)).

possible(I, action(fail(Student)), al(env)) :-
    id(I),
    student(Student),
    % strong_notholds(I, final_decision(Student)),
    strong_notholds(I, passed(Student)),
    % strong_notholds(I, failed(Student)),
    { strong_holds(I, thesis_signed(Prof, Student)): professor(Prof) } 2,
    3 { strong_holds(I, decision_made(Prof, Student)): professor(Prof) }.

initiates(I, Action, failed(Student)) :-
    happens(I, Action, al(env)),
    Action=action(fail(Student)).

% initiates(I, Action, final_decision(Student)) :-
%     happens(I, Action, al(env)),
%     Action=action(fail(Student)).

% totalorder.
#const tmax=15.

:- not happens(_, action(lie(_, _)), _).
#show happens/3.
#show edge/2.