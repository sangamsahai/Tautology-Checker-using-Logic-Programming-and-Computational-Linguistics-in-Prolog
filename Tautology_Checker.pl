reserveWord('True').
reserveWord('False').
reserveWord('~').
reserveWord('or').
reserveWord('&').
reserveWord('=>').
reserveWord('<=>').
reserveWord('(').
reserveWord(')').


/*
This function returns a list of variables in the input expression.
Variables are the identifiers which are not reserve words.
This function uses the helper function 'getVar' for computation.
For example-
getVarMain(['p','q','or','r','=>'],X)  --> X = [p, q, r]

*/
getVarMain(X,Y) :-  sort(X,Z) , getVar(Z,TEMP1),sort(TEMP1,Y).

%This is helper function for the function getVarMain.
getVar(X,Y) :- X=[] , Y=[];
X=[H|T],H=[A|B],getVarMain(H,TEMP1),getVarMain(T,TEMP2),append(TEMP1,TEMP2,TEMP3),sort(TEMP3,Y);
X=[H|T] , reserveWord(H) , getVar(T,TEMP), Y=TEMP;
X=[H|T], not(reserveWord(H)), getVar(T,TEMP) , append([H],TEMP,Y).


/*
This function returns the count of number of variables in the input
expression. Variables are the identifiers which are not reserve words.
For example-
countVarMain(['p','q','or','r','=>'],X) --> X = 3.

*/
%countVarMain(X,Y) :-  sort(X,Z) , countVar(Z,Y).
countVarMain(X,Y) :- getVarMain(X,TEMP) , length(TEMP,Y).



/*
Following function returns all the possible combinations of truth table
in form of 't' and 'f'. The functions returns all the possible
combinations in a list.
Here C is the number of variables and X is the output list.
For example-
truthArray(1,X)   --> X = [[t], [f]]
truthArray(2,X)   --> X = [[t, t], [t, f], [f, t], [f, f]]

*/
truthArray(C,X) :- C=0,X=[];
                    C=1,X=[[t],[f]];
       not(C=1),not(C=0),CC is C-1,truthArray(CC,TEMP),appendInFront(t,TEMP,TEMP1),appendInFront(f,TEMP,TEMP2),append(TEMP1,TEMP2,X).



/*This function appends the element X in front of all the elements of the list L.
For example-
appendInFront(t,[[t],[f]],U)           --> U = [[t, t], [t, f]]
appendInFront(f,[[t, t], [t, f]],U)    --> U = [[f, t, t], [f, t, f]]
*/
appendInFront(X,L,S) :- L=[],S=[];
                       L=[H|T],appendInFront(X,T,TEMP),append([X],H,TEMP2),append([TEMP2],TEMP,S).

/*
This method takes in List of truth values (T) , List of variables (V)
and the required variable(E) and returns the corresponding t/f value
corresponding to the required variable.
For example-
find(p,[t,f,t],[q,p,r],U)  --> U=f
*/
find(E,T,V,A) :- V=[E|X] , T=[A|Y];
                V=[H1|T1] , T=[H2|T2] , not(H1=E) , find(E,T2,T1,A).

/*This method replaces the variables in the input expression with the t/f values based of the Truth Array and the Variable Array.
 This method takes as input - Truth Array(T) , Variable List(V) , Input Expression (E) and returns the output list R.*/
subst(T,V,E,R) :- E=[],R=[];
                  E=[X|Y],X=[H|J],  subst(T,V,X,TEMPL), subst(T,V,Y,TEMP),append([TEMPL],TEMP,R);
                  E=[X|Y],reserveWord(X),subst(T,V,Y,TEMP),append([X],TEMP,R);
 E=[X|Y],not(X=[H|J]),not(reserveWord(X)),subst(T,V,Y,TEMP),find(X,T,V,A),append([A],TEMP,R).

/*
This returns the final evaluated value of the input expression E based
on the Truth Array T.
For example-
getTautValue(['p','&','q'],[t,f],A)  -->  A=false.
*/
%here T = [t] or [t,f] or [t,t,f] etc...
getTautValue(E,T,A) :- s6(E,S),getVarMain(E,VL),  subst(T,VL,S,SV),eval(SV,A).

/*
This method returns the list of all possible evaluations of the
expression on the basis of Truth Array supplied.
Note - here the turth array should have all possible combinations in the
list.
For example -
getBooleanAnswerArray(['p','&','q'], [[t, t], [t, f], [f, t], [f,f]],AA)
-->  AA = [true, false, false, false]
*/
getBooleanAnswerArray(E,T,AA) :- T=[],AA=[];
T=[X|Y] , getTautValue(E,X,A) , getBooleanAnswerArray(E,Y,TEMP),append([A],TEMP,AA).


/*This method returns the list of all possible combinations of the input expression.
This uses the function 'getBooleanAnswerArray' as a helper function.
For example-
 getBooleanAnswerArrayMain(['a','&','b'],R)  --> R = [true, false, false, false]

*/
getBooleanAnswerArrayMain(E,AA) :-
	countVarMain(E,0),s6(E,TEMP),eval(TEMP,V),AA=[V];%in case there are no variables we directly calculate result
	countVarMain(E,N),truthArray(N,X),getBooleanAnswerArray(E,X,AA).

allElementsTrue(L) :- L=[];
     L=[X|Y] , X=true,allElementsTrue(Y).


taut(E) :-  not(E=[]), getBooleanAnswerArrayMain(E,AA),!,allElementsTrue(AA).


/*
Grammar

S0 -> Var | 'True' | 'False' | '(' S6 ')'

 S2 -> S0 | '~' S2

 S3 -> S2 | S3 '&' S2

 S4 -> S3 | S4 'or' S3

 S5 -> S4 | S4 '=>' S5

 S6 -> S5 | S5 '<=>' S6
 */

% Following the parser code which converts user input into S Expression
% Here L represents input list and T represents S-expression.

% Sample input and output -
% Input -  s6(['~','(',a,'&',b,'or',c,')'],T).
% Output - [~, [or, [&, a, b], c]]

s0(L,T):-
  L=[T],not(reserveWord(T)) ;L=['True'],T = 'True';L=['False'],T = 'False';
append(['('|A],[')'],L),s6(A,T).

s2(L,T):-
  s0(L,T) ;
  L=['~'| A], s2(A,T1), T=['~',T1].

s3(L,T):-
  s2(L,T);
  append(A,['&'|B],L), s3(A,T1), s2(B,T2),T=['&',T1,T2].

s4(L,T):-
  s3(L,T);
  append(A,['or'|B],L), s4(A,T1), s3(B,T2),T=['or',T1,T2].

s5(L,T):-
  s4(L,T);
  append(A,['=>'|B],L), s4(A,T1), s5(B,T2),T=['=>',T1,T2].

s6(L,T):-
  s5(L,T);
  append(A,['<=>'|B],L), s5(A,T1), s6(B,T2),T=['<=>',T1,T2].


/*
Following is the evaluator code.
It takes S-expression as input and evaluates the complete expression and
returns true or false.
In the arguments , E represents S-expression and V represents output
value.
For this function , the input S Expression should have either
'True'/'False' values or t/f and boolean operators

Following is the sample input and output

eval(['&','True','True'],U)      --> U=true
eval(['&',t,t],U)                --> U=true
eval(['or',['&',t,t],f],U)       --> U=true
eval(['~',['&',t,f]],U)          --> U=true
eval(['~',['~',['&',t,f]]],U)    --> U=false

*/


eval(E,V) :-
E='True',V=true;
E='False',V=false;
E='t',V=true;
E='f',V=false;

E=['&',X,Y],eval(X,Xval),eval(Y,Yval),
 (Xval=true, Yval=true, V=true  ;
        Xval=true, Yval=false,V=false ;
        Xval=false,Yval=true, V=false ;
        Xval=false,Yval=false,V=false;
        Xval=true,Yval=true,V=true
       );

 E=['or',X,Y],eval(X,Xval),eval(Y,Yval),
 (Xval=true, Yval=true, V=true  ;
        Xval=true, Yval=false,V=true ;
        Xval=false,Yval=true, V=true ;
        Xval=false,Yval=false,V=false;
        Xval=true,Yval=true,V=true
       );

  E=['=>',X,Y],eval(X,Xval),eval(Y,Yval),
 (Xval=true, Yval=true, V=true  ;
        Xval=true, Yval=false,V=false ;
        Xval=false,Yval=true, V=true ;
        Xval=false,Yval=false,V=true;
        Xval=true,Yval=true,V=true
       );


  E=['=>',X,Y],eval(X,Xval),eval(Y,Yval),
 (Xval=true, Yval=true, V=true  ;
        Xval=true, Yval=false,V=false ;
        Xval=false,Yval=true, V=true ;
        Xval=false,Yval=false,V=true;
        Xval=true,Yval=true,V=true
       );


  E=['<=>',X,Y],eval(X,Xval),eval(Y,Yval),
 (Xval=true, Yval=true, V=true  ;
        Xval=true, Yval=false,V=false ;
        Xval=false,Yval=true, V=false ;
        Xval=false,Yval=false,V=true;
        Xval=true,Yval=true,V=true
       );

 E=['~',X], eval(X,Xval),
     (Xval=true,V=false ; Xval=false,V=true).
















