#ifndef SYMTAB_H
#define SYMTAB_H
#include "decl_list.h"
#include "arg_list.h"
#include "type.h"

#define EOS '\0'
#define PRIME 211

typedef enum location_enum {
  ST_LOCAL,
  ST_PARAMETER
} location_e;

typedef struct st_node_s {
  char *name;
  symtab_type class;
  type_struct *type;
  location_e location;
  arg_elem *arg_type_list;
  int num_of_args;
  int index;

struct st_node_s *next;
} st_node_t;

typedef struct symtab_s {
  char *name;
  int has_return;
  int entries;
  st_node_t *Table[PRIME];
} symtable;

st_node_t *symtab_lookup(symtable *st, char *name);
st_node_t *symtab_insert(symtable *st, char *name, symtab_type class,
                         type_struct *type, location_e location, int symtab_index);
int hashpjw(char *s);

symtable *setup_input_output(symtable *st, decl_elem *head);

int calculate_stack_offset(symtable *st);

void print_symtab(symtable *st);
void print_entry(st_node_t *n, int hash_index);

#endif
