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

"mainprog"|"procedure"|"begin"|"end"|"print"|"function"|"if"|"elif"|"else"|"while"|"nop"|"return"|"in"  {printf("keyword!\n");yylval.str=yytext; return T_KEYWORD;}
"int"|"float" {printf("data type!\n"); yylval.str=yytext; return T_DATATYPE;}
[0-9]*  {printf("int!\n"); yylval.int_num=atoi(yytext); return T_INTEGER;}
[0-9]+"."[0-9]*  {printf("float!\n"); yylval.float_num=atof(yytext); return T_FLOAT;}
[()\[\]:=;.,]  {printf("delimiter!\n"); yylval.str=yytext; return T_DELIMITER;}
[+\-*/!<>] {printf("operator!\n"); yylval.str=yytext; return T_OPERATOR;}
"<="|">="|"=="|"!=" {printf("operator!\n"); yylval.str=yytext; return T_OPERATOR;}
\t {printf("tab! no return\n"); }
\n  {printf("newline! no return\n"); lineCount++;}
" " {printf("spacebar no return\n");}
[a-zA-Z_][a-zA-Z0-9_]*  {printf("text!\n"); yylval.str= yytext; return T_ID;}
. {printf("error in lexical analysis\n");}
%%

/*** Code Section prints the number of
capital letter present in the given input***/

int yywrap(){}
