CC = gcc
CFLAGS = -g
#CFLAGS = -g -DPRINT_SYMBOL_TABLE -DPRINT_SYNTAX_TREE
LEX = flex
LFLAGS = -l
YACC = bison
YFLAGS = -dv
LIBS = -ll -ly
HEADERS = scope.h tree.h symtab.h decl_list.h arg_list.h semantics.h gencode.h type.h
SOURCES = scope.c tree.c symtab.c decl_list.c arg_list.c semantics.c #gencode.c
OBJECTS = interpret.tab.o lex.yy.o scope.o tree.o symtab.o decl_list.o arg_list.o semantics.o #gencode.o
BINARY = interpret

all: interpret.tab.c lex.yy.c $(SOURCES) $(BINARY)	

$(BINARY): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(BINARY) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c $<

interpret.tab.c: interpret.y
	$(YACC) $(YFLAGS) interpret.y 	# $bison -dv interpret.y

lex.yy.c: interpret.l
	$(LEX) $(LFLAGS) interpret.l	#flex -l interpret.l

tar:
	tar -cvf interpret.tar Makefile interpret.l interpret.y test_files $(HEADERS) $(SOURCES)

clean:
	rm -f interpret.tab.* lex.yy.* *.o interpret.output $(BINARY)
