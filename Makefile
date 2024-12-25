all: lex yacc
	g++ lex.yy.c y.tab.c -ll -o cse351

yacc: cse351.y
	yacc -d cse351.y

lex: cse351.l
	lex cse351.l

clean:
	rm -f lex.yy.c y.tab.c y.tab.h cse351