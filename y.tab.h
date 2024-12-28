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
    int intval;      /* To store integer values*/
    char *strval;    /* To store string values*/
    item Item;       /* To store item structs*/
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

#endif /* _yy_defines_h_ */
