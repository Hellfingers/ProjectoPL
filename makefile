lpis: lex.yy.c y.tab.c
	gcc -g hashTable.c y.tab.c -o lpis

lex.yy.c: y.tab.c lpis.l
	flex lpis.l

y.tab.c: lpis.y
	yacc -d lpis.y

clean: 
	rm -f lex.yy.c y.tab.c y.tab.h lpis