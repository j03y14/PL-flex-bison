%{
//#define YYDEBUG 1
//#define YYERROR_VERBOSE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "tree.h"	
#include "decl_list.h"
#include "arg_list.h"			//argument list
#include "scope.h"			//scope
#include "type.h"  			//symbol table 이용
#include "symtab.h"			//symbol table
#include "semantics.h"			//semantic

int num_add_to_sytb = 1;
void add_decl_to_symtab(symtab_type class, type_struct *type, location_e location);

/* Declaration list head node (linked list) */
decl_elem *head = NULL, *data;

/* A single symbol table */
symtable *st;

/* Symbol table entry */
st_node_t *st_node;

/* Function/Procedure argument list head node (linked list) */
arg_elem *arg_head = NULL;

char *calling_func_name;

/* Symbol table stack */
scope_elem *symtable_stack;

int num_of_args;
int stack_offset;
FILE* yyin;				//read file
int yylex();				//error handling
void yyerror(const char *msg);		//error handling
%}


%union {
  char *sval;
  int ival;
  float rval;
  char *opval;
  tree_t *tval;
  type_struct *type_s;
}

%token <sval> ID
%token <rval> RNUM
%token <ival> INUM

%token ARRAY BBEGIN ELSE END FOR FUNCTION IF INT SEMI COMA COLON LPARENT RPARENT LSBRACK RSBRACK NOT DOT POSITIVE NEGATIVE
%token OF PROCEDURE MAINPROG FLOAT THEN VAR WHILE PRINT RETURN SIGN
%token <opval> ADDOP MULOP RELOP ASSIGNOP

%type <type_s> type
%type <ival> standard_type

%type <tval> compound_statement statement_list statement print_statement
%type <tval> variable procedure_statement
%type <tval> expression_list expression simple_expression
%type <tval> term factor

%start program

%%

program :
            MAINPROG ID SEMI
		{
		printf("MAINPROG ID SEMI!!\n");
		}
            declarations
		{
		printf("declarations!!\n");
                scope_push(symtable_stack, st); // 전역변수 선언
		print_symtab(st);	//declaration 결과 symbol table 출력
		}
            subprogram_declarations
		{
		printf("subprogram_declarations!!\n");
		}
            compound_statement
		{
		printf("compound_statement!!\n");
                stack_offset = calculate_stack_offset(st); // 선언문의 내용 전역변수로 저장?
		}

          ;

declarations:
            VAR identifier_list COLON type SEMI declarations
			{
//				printf("declarations!!\n");
				add_decl_to_symtab(VAR_CLASS, $4, ST_LOCAL); // variable class , type, location저장
			}
          | //epsilon
          ;


identifier_list:
            ID 
			{
//				printf("ID\n");
				head = decl_append(head, $1); // 첫번째 토큰 ID를 decl_elem list에 확장
			}
          | ID COMA identifier_list
			{
//				printf("ID_LIST\n");
				head = decl_append(head, $1); // . 토큰 ID를 decl_elem list에 확장
			}
	  ;

type:
            standard_type
			{
				$$ = (type_struct *) calloc(1, sizeof(type_struct)); //type을 추가하고
				$$->name = $1;					//이름을 추가
			}

          | ARRAY LSBRACK INUM RSBRACK OF standard_type
		{
               $$ = (type_struct *) calloc(1, sizeof(type_struct));
               if ($6 == INTEGER_TYPE)
               	$$->name = ARRAY_TYPE_INT;
               else if ($6 == FLOAT_TYPE)
               	$$->name = ARRAY_TYPE_REAL;
               $$->lb = 1;	//low bound = 1
               $$->ub = $3;	//upper bound = inum
		}
          ;

standard_type:
            INT
		{
			$$ = INTEGER_TYPE;	//int = integer_type 으로 치환
		}
          | FLOAT
		{
			$$ = FLOAT_TYPE;
		}
          ;

subprogram_declarations:
            subprogram_declaration subprogram_declarations
          | //epsilon
          ;

subprogram_declaration:
            subprogram_head declarations compound_statement
		{
               /* Calculate a function's stack offset */
               stack_offset = calculate_stack_offset(st);
//               prologue(st->name, stack_offset);

               /* Make sure the function var was assigned if class is function_type
                  The procedure case might not fire because there should be a
                  type mismatch when trying to assign a value to the proc's id */
               if (calling_func_name != NULL) {
                 st_node = search_scope_stack(symtable_stack, calling_func_name);
                 if (st_node->class == FUNCTION_CLASS && st->has_return != 1 && st->name != NULL)
                   sem_error(NO_RETURN_STMT);
                 else if (st_node->class == PROCEDURE_CLASS && st->has_return == 1)
                   sem_error(NON_LOCAL_MODIFICATION);
		/* Pop current scope */
               st = scope_pop(symtable_stack);
		/* Pop parent scope so it's available again */
               st = scope_pop(symtable_stack);

//               epilogue(); //무슨함수인지? 어셈블리 관련 STACK CLEAR 같은데..
               }
		}
          ;

subprogram_head: //이 그래머 부분 해석 필요
            FUNCTION ID
		{
               type_struct *t = calloc(1, sizeof(type_struct));

               /* st->entries increases to keep track of the variable's
                  index in the symbol table (st).  Used for gencode identifier lookups */
               (st->entries)++;
               symtab_insert(st, $2, FUNCTION_CLASS, t, ST_LOCAL, st->entries);

               // push parent with function name added to it
               scope_push(symtable_stack, st);
               st = calloc(1, sizeof(symtable));
               /* reset to 0 because a new symbol table has its own set of offsets
                  for local declarations */
               st->entries = 0;

               // set encountered func as calling func name
               calling_func_name = $2;

               // reset arg counter and argument list
               num_of_args = 0;
               arg_head = NULL;
		}
 	     arguments COLON standard_type SEMI
		{
 		// set symtab name as the function name
               st->name = calling_func_name;

               // create arg_type_list for the parent symbol table
               st_node = search_scope_stack(symtable_stack, $2);
               st_node->arg_type_list = arg_head;
               st_node->type->name = $6;
               st_node->num_of_args = num_of_args;

               // push symtab so it can be searched in the function
               scope_push(symtable_stack, st);
		}
          | PROCEDURE ID
		{
               type_struct *t = calloc(1, sizeof(type_struct));

               (st->entries)++;
               symtab_insert(st, $2, PROCEDURE_CLASS, t, ST_LOCAL, st->entries);

               // push parent with procedure name added to it
               scope_push(symtable_stack, st);
               st = calloc(1, sizeof(symtable));
               st->entries = 0;

               // set func as calling func name
               calling_func_name = $2;

               // reset arg counter and argument list
               num_of_args = 0;
               //arg_destroy(arg_head);
               arg_head = NULL;
		}
	    arguments SEMI
		{
  		// set symtab name as the procedure name
               st->name = calling_func_name;

               // create arg_type_list for the parent symbol table
               st_node = search_scope_stack(symtable_stack, $2);
               st_node->arg_type_list = arg_head;
               st_node->num_of_args = num_of_args;

               // push symtab so it can be searched in the function
               scope_push(symtable_stack, st);
		}
          ;

arguments:
            LPARENT parameter_list RPARENT
          | //epsilon
          ;

parameter_list:
            identifier_list COLON type
		{
               add_decl_to_symtab(VAR_CLASS, $3, ST_PARAMETER);
		}
          | identifier_list COLON type SEMI parameter_list
		{
            //   add_decl_to_symtab(VAR_CLASS, $5, ST_PARAMETER);
		}
          ;

compound_statement:
            BBEGIN statement_list END
		{
		
		$$ = mktree(BEGIN_END, 1, $2);

		}

          ;

statement_list:
			statement
		{
			$$=$1;
		}
		  | statement SEMI statement_list
		{
			$$ = mktree(STMT_LIST, 2, $3, $1);
		}
		  ;

statement:
		variable ASSIGNOP expression
		{
			//type checking
	               	if (type_check($1) != type_check($3)) { sem_error(TYPE_MISMATCH_ASSN); }
               		label_tree($3, 1);
			$$ = mktree(ASSIGN_STMT, 2, $1, $3);
		}
		  | print_statement
			{}
		  | procedure_statement
			{}
		  | compound_statement
			{}
		  | IF expression THEN statement ELSE statement
			{}
		  | WHILE LPARENT expression RPARENT statement
			{}
		  | RETURN expression
			{}
		  //| {} //nop 
		  ;


print_statement:
			PRINT
			{}
		  | PRINT LPARENT expression RPARENT
			{}
		  ;

variable:
			ID
{
               st_node = search_scope_stack(symtable_stack, $1);	//ID 토큰의 이름으로 SCOPE STACK 탐색.. 없으면
               if (st_node == NULL) { sem_error(VAR_UNDECLARED); }	//에러 코드 출력 

               if (st_node->class == FUNCTION_CLASS)
                 if (!strcmp($1, st->name))
                   st->has_return = 1;

               $$ = mktree(IDENT, 0);
               $$->attr.sval = st_node;
}
		  | ID LSBRACK expression RSBRACK
			{
				st_node = search_scope_stack(symtable_stack, $1);
				if (st_node == NULL) { sem_error(VAR_UNDECLARED); }
				array_semantics(st_node, $3);

				$$ = mktree(ID_ARRAY, 1, $3);
				$$->attr.sval = st_node;
			}
		  ;

procedure_statement:
			ID LPARENT actual_parameter_expression RPARENT
				{}
		  ;

actual_parameter_expression:
			//epsilon
		  | expression_list

		  ;

expression_list:
			expression
		  | expression COMA expression_list
		  ;

expression:
			simple_expression
		  | simple_expression RELOP simple_expression
		  ;

simple_expression:
            term
		{
			$$=$1;
		}
          | term ADDOP simple_expression
	  ;
term:
            factor
		{
			$$=$1;
		}
          | factor MULOP term
		{
			$$ = mktree(MULOP_EXPR, 2, $3, $1);
			$$->attr.opval = $2;
		}

          ;

factor:
            INT
		{}
          | FLOAT
		{}
          | variable
		{}
          | procedure_statement
          | NOT factor
                { $$ = mktree(NOT_FACTOR, 1, $2); }
          | SIGN factor
		{ $$ = mktree(SIGN_TERM, 1, $2); }
          ;
/*
sign:
            POSITIVE 
		{}
          | NEGATIVE
		{}
	  ;
*/
%%

void add_decl_to_symtab(symtab_type class, type_struct *type, location_e location) {
  data = head;
//	printf("num_add_to_sytb : %d\n",num_add_to_sytb++);
  if (data != NULL) {
    do {
      if (location == ST_PARAMETER) {
        num_of_args++;
        arg_head = arg_append(arg_head, type->name);
      }

      (st->entries)++;
      symtab_insert(st, data->name, class, type, location, st->entries);

      data = data->next;
    }
    while (data != head);

    decl_destroy(head);
    decl_destroy(data);
    head = NULL;
  }
  else
    fprintf(stderr, "data is null\n");

}

int main() {
  FILE *fp;
  char filename[50];
  printf("Enter the filename: \n");
  symtable_stack = scope_init(10);
  st = calloc(1, sizeof(symtable));
  st->entries = 0;
  //scanf("%s",filename);
  fp = fopen("example.txt","r");
  yyin = fp;
  yyparse();
  printf("\n");
}

