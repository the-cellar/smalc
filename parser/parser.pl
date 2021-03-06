:- module(parser, [parse/2]).
:- use_module(lexer).

parse(Code, AST) :-
    tokenize(Code, Out),
    expr(AST, Out, []).

expr(E)       --> e1(E); assign(E).

e1(pow(A, B)) --> e2(A), [pow_t(_)], e2(_), e2(B).
e1(E)         --> e2(E).

e2(div(A, B)) --> e3(A), [div_t(_)], e3(B).
e2(E)         --> e3(E).

e3(mul(A, B)) --> e4(A), e4(B), [mul_t(_)].
e3(E)         --> e4(E).

e4(add(A, B)) --> [add_t(_)], e5(A), e5(B).
e4(E)         --> e5(E).

e5(sub(A, B)) --> e6(A), [sub_t(_)], e6(B).
e5(E)         --> e6(E).

e6(mod(A, B)) --> [mod_t(_)], e7(_), e7(A), e7(B).
e6(E)         --> e7(E).

e7(sqrt(A))   --> e8(A), [sqrt_t(_)].
e7(E)         --> e8(E).

e8(ident(N))  --> [ident_t(N, _)].
e8(E)         --> [l_brack_t(_)], e1(E), [r_brack_t(_)].

assign(assign(V, N, E)) --> [colon_t(_)], e1(V), [ident_t(N, _)], [colon_t(_)], e1(E).
