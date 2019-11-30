%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

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
%token <str> T_DATATYPE

%token T_WHITESPACE

%start program

%%
program : T_KEYWORD T_ID T_DELIMITER declarations subprogram_declarations compound_statement 
{
  if(strcmp($1,"mainprog")!=0) 
    { printf("1\n");
      yyerror($1);} 
};

declarations :  ;


subprogram_declarations :  ;


compound_statement : T_KEYWORD statement_list T_KEYWORD
{
  if(strcmp($1,"begin")!=0) 
    { printf("2 %s \n",$1);
      yyerror($1);} 

  if(strcmp($3,"end")!=0) 
    { printf("3\n");
      yyerror($3);} 

};

statement_list : ;

%%

int main() {
  FILE *fp;
  char filename[50];
  printf("Enter the filename: \n");
  //scanf("%s",filename);
  fp = fopen("pl.txt","r");
  yyin = fp;

  if(yyparse()) {
        fprintf(stderr, "Error!\n");
        exit(1);
  }else{
    printf("done\n");
  }


	return 0;
}

void yyerror(const char* s) {
	printf("Parse error: %s\n", s);
	exit(1);
}
