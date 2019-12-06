#ifndef SEMANTICS_H
#define SEMANTICS_H

#include <stdlib.h>
#include "arg_list.h"
#include "tree.h"

/* Use Flex's line counter for error messages */
extern int yylineno;

/*
 * Semantic Checker
 *
 * 여기에 정의된 함수들은 syntax tree를 만들고 올바르지 않은 tree 가 있으면 컴파일러를 종료하는 sem_error 를 발생시킴
 */

typedef enum sem_error_id_e {
  VAR_UNDECLARED,
  VAR_REDECLARED,
  WRONG_NUMBER_OF_ARGS,
  WRONG_ARG_TYPE,
  NO_RETURN_STMT,
  NON_LOCAL_MODIFICATION,
  BAD_RETURN_TYPE,
  ARRAY_INDEX_OUT_OF_BOUNDS,
  ARRAY_NON_INTEGER_BOUNDS,
  TYPE_MISMATCH_EXPR,
  TYPE_MISMATCH_ASSN,
  TYPE_NON_BOOLEAN
} sem_error_id;

void if_then_semantics(tree_t *t);
void while_semantics(tree_t *t);
void function_semantics(st_node_t *st_node, tree_t *t);
void procedure_semantics(st_node_t *st_node, tree_t *t);
arg_elem *expr_list_eval(arg_elem *head, tree_t *t);
void array_semantics(st_node_t *st_node, tree_t *t);

void sem_error(sem_error_id id);

#endif
