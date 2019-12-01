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
    { yyerror($1);} 
};

declarations : type identifier_list T_DELIMITER declarations
{
  if(strcmp($3, ";")!=0)
    { yyerror($3);}
};

declarations : ;

identifier_list : T_ID T_DELIMITER identifier_list
{
  if(strcmp($2,";")!=0)
    {yyerror($2);}
};

identifier_list : T_ID ;

type : standard_type;

type : standard_type T_DELIMITER T_INTEGER T_DELIMITER
{
  if(strcmp($2,"[")!=0)
    {yyerror($2);}
  if(strcmp($4,"]")!=0)
    {yyerror($4);}
};

type : standard_type T_DELIMITER T_FLOAT T_DELIMITER
{
  if(strcmp($2,"[")!=0)
    {yyerror($2);}
  if(strcmp($4,"]")!=0)
    {yyerror($4);}
};

standard_type : T_DATATYPE;

subprogram_declarations :  subprogram_declarations subprogram_declarations | ;

subprogram_declarations : subprogram_head declarations compound_statement;

subprogram_head : T_KEYWORD T_ID arguments T_DELIMITER standard_type T_DELIMITER
{
  if(strcmp($1,"function")!=0)
    {yyerror($1);}
  if(strcmp($4,":")!=0)
    {yyerror($4);}
  if(strcmp($6,"[")!=0)
    {yyerror($6);}
};

subprogram_head : T_KEYWORD T_ID arguments T_DELIMITER
{
  if(strcmp($1,"procedure")!=0)
    {yyerror($1);}
  if(strcmp($4,";")!=0)
    {yyerror($4);}
};

arguments : T_DELIMITER parameter_list T_DELIMITER
{
  if(strcmp($1,"(")!=0)
    {yyerror($1);}
  if(strcmp($3,")")!=0)
    {yyerror($3);}
};

arguments : ;

parameter_list : identifier_list T_DELIMITER type
{
  if(strcmp($2,":")!=0)
    {yyerror($2);}
};

parameter_list : identifier_list T_DELIMITER type T_DELIMITER parameter_list
{
  if(strcmp($2,":")!=0)
    {yyerror($2);}
  if(strcmp($4,";")!=0)
    {yyerror($4);}
};

compound_statement : T_KEYWORD statement_list T_KEYWORD
{
  if(strcmp($1,"begin")!=0) 
    { yyerror($1);} 

  if(strcmp($3,"end")!=0) 
    { yyerror($3);} 

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
