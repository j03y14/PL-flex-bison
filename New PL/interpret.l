%{
  //definition section
#include <stdio.h>
#include "tree.h"
#include "type.h" //symtab_type type
#include "interpret.tab.h"  //interpret.y에서 정의된 토큰 가져옴.
%}

letter			[a-zA-Z]
digit			[0-9]
id			{letter}({letter}|{digit})*

digits			{digit}{digit}*
fraction		("."{digits})
rnum			{digits}{fraction}
inum			{digits}
whitespace		[ \t]

relop			(">"|"="|">="|"<"|"<="|"=="|"<>")
addop			("+"|"-")
mulop			("*"|"/")

%%
 /* reserved-word : nop, print ? */
"mainprog"		{ return MAINPROG; }
"var"			{ return VAR; }
"of" 			{ return OF; }
"function"		{ return FUNCTION; }
"procedure"		{ return PROCEDURE; }
"begin"			{ return BBEGIN; }
"end"			{ return END; }
"if"			{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"while"			{ return WHILE; }
"array"			{ return ARRAY; }
"float"			{ return FLOAT; }
"int"			{ return INT; }
"return"		{ return RETURN; }
"="			{ return ASSIGNOP; }
"print"			{ return PRINT;	}
";"			{ return SEMI; }
","			{ return COMA; }
":"			{ return COLON; }
"("			{ return LPARENT;}
")"			{ return RPARENT;}
"["			{ return LSBRACK;}
"]"			{ return RSBRACK;}
"!"			{ return NOT; }
"."			{ return DOT; }
 /* sign operation
"+"			{ return POSITIVE;}                        
"-"			{ return NEGATIVE;}
 */
{addop}			{ yylval.opval = strdup(yytext); return ADDOP; }	//yylval.opval에 yytext(현재토큰) 복사 후 addop 리턴
{mulop}			{ yylval.opval = strdup(yytext); return MULOP; }
{relop}			{ yylval.opval = strdup(yytext); return RELOP; }
{id}			{ yylval.sval = strdup(yytext); return ID; }
{rnum}			{ yylval.rval = atof(yytext); return RNUM; }	//real type
{inum}			{ yylval.ival = atoi(yytext); return INUM; }	//int type
	
{whitespace}	        { }                    				/* whitespace */

"//".*			{ }						/* skip singleline comments */
"/*"               	{ int c;
			   printf("comment\n");
                   	   while (c = input()) {
                  	      if (c == '*')
                        	  if ((c = input()) == '/')
                        	    break;
                       		  else
	                            unput(c);
        	           } }
\n			{ } 						// pass line
.			{ /*printf("unknown token (%c)\n",yytext[0]);*/ /*return yytext[0];*/ }

%%

void yyerror(char *msg) {
  fprintf(stderr, "error [line: %d]: %s at %s\n", yylineno, msg, yytext);
  exit(1);
}

