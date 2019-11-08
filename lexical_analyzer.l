/*** Definition Section has one variable
which can be accessed inside yylex()
and main() ***/
%{
#include <windows.h>
#include <string.h>
#include "parser.tab.h"
extern union token yylval;
int lineCount = 1;

%}

%%

"mainprog"|"procedure"|"begin"|"end"|"print"|"function"|"if"|"elif"|"else"|"while"|"nop"|"return"|"in"  {yylval.str=yytext; return T_KEYWORD;}
[0-9]*  {yylval.int_num=atoi(yytext); return T_INTEGER;}
[0-9]+"."[0-9]*  {yylval.float_num=atof(yytext); return T_FLOAT;}
[()[]:=;.,]  {yylval.str=yytext; return T_DELIMITER;}
[+\-*/!<>] {yylval.str=yytext; return T_OPERATOR;}
"<="|">="|"=="|"!=" {yylval.str=yytext; return T_OPERATOR;}
" "|\t {return T_WHITESPACE;}
\n  {lineCount++; return T_WHITESPACE;}
[a-zA-Z_][a-zA-Z0-9_]*  {yylval.str= yytext; return T_ID;}
. {printf("error in lexical analysis");}
%%

/*** Code Section prints the number of
capital letter present in the given input***/

int yywrap(){}
