#ifndef DECL_LIST_H
#define DECL_LIST_H

/*
 * Declaration List
 * A linked list of declared variable names
 */
typedef struct decl_elem_s {
  char *name;

  struct decl_elem_s *next;
} decl_elem;

void decl_destroy(decl_elem *head);
decl_elem *decl_append(decl_elem *head, char *name);

#endif
