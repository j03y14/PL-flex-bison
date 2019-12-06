#ifndef SCOPE_H
#define SCOPE_H

#include "symtab.h"

/*
scope : symbol table stack
symbol table에 대해 push와 pop 하고 적절히 contents를 수정한다.

search function : 주어진 name이 있는지 알기위해 모든 scope를 탐색한다.(top-down 방식)
stack을 사용하기에 같은 식별자가 사용될 수 있다. 그리고 가장 위에 잇는게 처음으로 return된다.
*/
typedef struct scope_elem_s {
  symtable **content;
  int max_size;
  int top;
} scope_elem;

scope_elem *scope_init(int max_size);
void scope_push(scope_elem *stack, symtable *st);
symtable *scope_pop(scope_elem *stack);
st_node_t *search_scope_stack(scope_elem *stack, char * name);

#endif
