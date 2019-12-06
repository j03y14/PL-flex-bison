#include <stdio.h>
#include <stdlib.h>
#include "decl_list.h"

/*
 * A linked list for variable name declaration 
 */

void decl_destroy(decl_elem *head) {
  if (head == NULL)
    return;

  decl_elem *curr, *tmp;

  curr = head->next;
  head->next = NULL;

  while (curr != NULL) {
    tmp = curr->next;
    free(curr);
    curr = tmp;
  }
}


decl_elem *decl_append(decl_elem *head, char *name) { //add variable name in linked list
  decl_elem *tmp;

  if (head == NULL) {	//error handling
    if ((head = (decl_elem *) malloc(sizeof(decl_elem))) == NULL) {
      printf("could not malloc\n");
      exit(1);
    }
    head->name = name;
    head->next = head;
  }
  else {
    tmp = head;

    while (tmp->next != head)
      tmp = tmp->next;

    if ((tmp->next = (decl_elem *)malloc(sizeof(decl_elem))) == NULL) {
      printf("coul not malloc\n");
      exit(1);
    }

    tmp = tmp->next;
    tmp->name = name;
    tmp->next = head;
  }

  return head;
}
