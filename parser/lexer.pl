:- module(lexer, [tokenize/2]).

tokenize(In, Out) :- tokenize(In, Out, 1).

tokenize([], [], _LineNo).

% increment the lineno on
tokenize([In|T], Out, LineNo) :-
    code_type(In, newline),
    NextLineNo is LineNo + 1, !,
    tokenize(T, Out, NextLineNo).

% ignore that whitespace
tokenize([In|T], Out, LineNo) :-
    code_type(In, space),
    tokenize(T, Out, LineNo).

% symbols and ops
tokenize([0'{|T_i], [l_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0'}|T_i], [r_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0'(|T_i], [l_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0')|T_i], [r_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0'[|T_i], [l_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0']|T_i], [r_brack_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).

tokenize([0'm, 0'i, 0'n|T_i], [add_t(LineNo)|T_o], LineNo) :- !, tokenize(T_i, T_o, LineNo).
tokenize([0'm, 0'a, 0'x|T_i], [sub_t(LineNo)|T_o], LineNo) :- !, tokenize(T_i, T_o, LineNo).
tokenize([0'+|T_i], [mul_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0'-|T_i], [div_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0'e, 0'x, 0't, 0'r, 0'e, 0'm, 0'a|T_i], [pow_t(LineNo)|T_o], LineNo) :- !, tokenize(T_i, T_o, LineNo).
tokenize([0'@|T_i], [mod_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).
tokenize([0's, 0'i, 0'n|T_i], [sqrt_t(LineNo)|T_o], LineNo) :- !, tokenize(T_i, T_o, LineNo).

tokenize([0':|T_i], [colon_t(LineNo)|T_o], LineNo) :- tokenize(T_i, T_o, LineNo).

% IDENT
tokenize([In|T_i], [Out|T_o], LineNo) :-
    code_type(In, csym),
    consume_type([In|T_i], csym, Remain, CharList),
    string_codes(Name, CharList),
    Out = ident_t(Name, LineNo),
    tokenize(Remain, T_o, LineNo).


% utils
consume_type([], _, [], []).
consume_type([Char|In], Type, Remain, [Char|Out]) :-
    code_type(Char, Type),
    consume_type(In, Type, Remain, Out).
consume_type([Char|In], Type, [Char|In], []) :-
    \+ code_type(Char, Type).

consume_until([], _, [], []).
consume_until([TargetChar|In], TargetChar, In, []).
consume_until([Char|In], TargetChar, Remain, [Char|Out]) :-
    consume_until(In, TargetChar, Remain, Out).

pretty_print(Code) :-
    tokenize(Code, Out),
    print_term(Out, []).
% string_codes/2 to convert to codes
