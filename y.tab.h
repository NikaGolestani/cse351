#ifndef _yy_defines_h_
#define _yy_defines_h_

#define IDENTIFIER 257
#define CONST 258
#define ASSIGN 259
#define MULTI 260
#define DIV 261
#define PLUS 262
#define MINUS 263
#define SEMICOLON 264
#define EXPO 265
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union YYSTYPE {
    int intval;      /* For integer values*/
    char *strval;    /* For string (identifier) values*/
    item Item;       /* For item struct*/
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

#endif /* _yy_defines_h_ */
