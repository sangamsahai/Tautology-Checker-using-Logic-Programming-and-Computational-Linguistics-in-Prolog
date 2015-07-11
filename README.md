Tautology Checker using Logic Programming and Computational Linguistics in Prolog.

This is an application based on Logic Programming which computes whether the given expression is a tautology or not.

Prolog is a general purpose logic programming language associated with artificial intelligence and computational linguistics.
Prolog has its roots in first-order logic, a formal logic, and unlike many other programming languages, Prolog is declarative.
The program logic is expressed in terms of relations, represented as facts and rules.
A computation is initiated by running a query over these relations.


In logic, a Tautology  is a formula that is true in every possible interpretation.
A very simple Tautology would be 'p Or (Not(p))' which would always evaluate to true.

This application accepts an expression from the user and computes weather  the expression is a tautology or not.
In this application ,  we have to generate the 'Truth Table' as a data structure.

Following is the list of steps (summarized) , which this application performs - 

1) Make a list of all Variables in the input expression

2) Convert the given expression into an S-Expression (which is explained later).

3) Determine all combination of truth assignments.

4) Substitute all those combination into the expression and record the final result.

5) If all the evaluations result to 'True' , the the given input expression is a tautology.



Concept of S-Expression :
The expression which is entered by the user  can not be computed directly.
It has to be parsed and converted to a  form which further can be computed.
That form is S-Expression.
In this application , the S expression is based on Prefix notation.

For example,  Sample input expression and output S expression is -
Input expression - ['~','(',a,'&',b,'or',c,')']
S Expression -     [~, [or, [&, a, b], c]]

The Grammar used for parsing is as follows - 

S0 -> Var | 'True' | 'False' | '(' S6 ')'

 S2 -> S0 | '~' S2

 S3 -> S2 | S3 '&' S2

 S4 -> S3 | S4 'or' S3

 S5 -> S4 | S4 '=>' S5

 S6 -> S5 | S5 '<=>' S6



Some sample test cases are as follows - 

The following queries should yield true: 
 
  taut( [p, or, ~, p] )

  taut( ['(',p, =>, ~,p,')', &, '(',~,p,=>,p,')', =>, 'False'] )

And the following should yield false: 

  taut( [p,=>,q] )
  taut( [a, <=>, ~, b] )

The code is self explanatory and I have used comments wherever required.  