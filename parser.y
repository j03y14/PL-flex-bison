%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int lineCount;
extern char* lexeme;
void yyerror(const char* s);




%}

%union token{
  char* str;
  int int_num;
  float float_num;
}

%token <str> T_ID
%token <int_num> T_INTEGER
%token <float_num> T_FLOAT
%token <str> T_KEYWORD
%token <str> T_OPERATOR
%token <str> T_DELIMITER
%token T_WHITESPACE

%start expression

%%
expression
    : T_INTEGER T_OPERATOR T_INTEGER;
%%

int main() {
  FILE *fp;
  char filename[50];
  printf("Enter the filename: \n");
  scanf("%s",filename);
  fp = fopen(filename,"r");
  yyin = fp;

  if(yyparse()) {
        fprintf(stderr, "Error!\n");
        exit(1);
    }


	return 0;
}

void yyerror(const char* s) {
	printf("Parse error: %s\n", s);
	exit(1);
}
