%{
    #include "item_type.h" // Item struct for later usage in symbol table.
    #include "y.tab.h"
    #include <string>
    using namespace std;
    int linenum = 1; // Line number tracker for error messages.
    
%}

%%
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
[0-9]+                  { yylval.intval = atoi(yytext); return CONST; }
"="                     { return ASSIGN; }
";"                     { return SEMICOLON; }
"\*"                    { return MULTI; }
"/"                     { return DIV; }
"\+"                    { return PLUS; }
"^"                     { return EXPO; }    
"-"                     { return MINUS; }
\n                      { linenum++; }
[ \t\r]+                { /* Ignore whitespace */ }
.                       { /* Handle unexpected characters */ }
%%

int yywrap() {
    return 1;
}
