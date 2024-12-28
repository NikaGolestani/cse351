%{
    #include <iostream>
    #include <string>
    #include <unordered_map>
    #include <cstdio>
    #include <cstdlib>
    #include <cmath>

    using namespace std;

    extern FILE *yyin;
    extern int linenum;
    extern char *yytext;

    void yyerror(const string &s);

    // Define the item struct to manage constants and identifiers
    struct item {
        bool is_constant; // True if the value is a constant; false for identifiers
        int value;        // The value of the constant or ASCII value of the identifier
    };

    // Symbol table to store identifiers and their associated values
    unordered_map<string, item> symbol_table;
%}

%union {
    int intval;      // To store integer values
    char *strval;    // To store string values
    item Item;       // To store item structs
}

// Define the types of variables for grammar rules
%type <strval> IDENTIFIER
%type <strval> oper
%type <intval> CONST
%type <Item> X

%token ASSIGN MULTI DIV PLUS MINUS SEMICOLON EXPO

%%

program:
    assignments
    ;

assignments:
    assignment assignments
    | assignment
    ;

// Handles assignment statements. 
// Left-hand side is $1, right-hand side is $3. Based on whether $3 is a constant or identifier, 
// an `item` is created. If $3 is a single operand, it is stored directly. Otherwise, its name is stored.
assignment:
    IDENTIFIER ASSIGN oper SEMICOLON
    {
        string id($1); // Convert IDENTIFIER to string

        // Check if oper (right-hand side) is an expression or a single value
        if (is_integer($3)) {
            // If oper is a number, store it as a constant
            symbol_table[id] = item{true, stoi($3)};
        } else if (strlen($3) == 1) {
            // If oper is a single character, store its ASCII value
            string operand($3);
            symbol_table[id] = item{false, static_cast<int>(operand[0])};
        }

        // Print the assignment result
        cout << id << "=" << $3 << endl;

        free($1); // Free allocated memory for IDENTIFIER
    }
    ;

// Handles arithmetic and logical operations.
// Depending on whether the operands are constants, performs folding or builds the expression as a string.
oper:
    X PLUS X
    {
        if ($1.is_constant && $3.is_constant) {
            // Fold the constants and return the result as a string
            string result = to_string($1.value + $3.value);
            $$ = strdup(result.c_str());
        } else {
            // Construct the expression with simplifications
            string result;

            if ($1.is_constant && $1.value != 0) result = to_string($1.value);
            else result = string(1, static_cast<char>($1.value));

            if ($3.value != 0 && !result.empty()) result += "+";

            if ($3.is_constant && $3.value != 0) result += to_string($3.value);
            else result += string(1, static_cast<char>($3.value));

            $$ = strdup(result.c_str());
        }
    }
    | X MULTI X
    {
        if ($1.is_constant && $3.is_constant) {
            // Multiply constants and return the result
            string result = to_string($1.value * $3.value);
            $$ = strdup(result.c_str());
        } else {
            // Construct the multiplication expression
            string result;

            if ($1.is_constant && $1.value != 1) result = to_string($1.value);
            else result = string(1, static_cast<char>($1.value));

            if ($3.value != 1 && !result.empty()) result += "*";

            if ($3.is_constant && $3.value != 1) result += to_string($3.value);
            else result += string(1, static_cast<char>($3.value));

            if ($3.value == 0 || $1.value == 0) result = to_string(0); // Handle zero multiplication

            $$ = strdup(result.c_str());
        }
    }
    | X DIV X
    {
        if ($1.is_constant && $3.is_constant) {
            // Handle constant division with zero check
            if ($3.value != 0) {
                string result = to_string($1.value / $3.value);
                $$ = strdup(result.c_str());
            } else {
                yyerror("Division by zero");
            }
        } else {
            // Build the division expression
            string result;

            if ($1.is_constant) result = to_string($1.value);
            else result = string(1, static_cast<char>($1.value));

            result += "/";

            if ($3.is_constant) result += to_string($3.value);
            else result += string(1, static_cast<char>($3.value));

            $$ = strdup(result.c_str());
        }
    }
    | X MINUS X
    {
        if ($1.is_constant && $3.is_constant) {
            // Perform constant subtraction
            string result = to_string($1.value - $3.value);
            $$ = strdup(result.c_str());
        } else {
            // Construct the subtraction expression
            string result;

            if ($1.is_constant) result = to_string($1.value);
            else result = string(1, static_cast<char>($1.value));

            result += "-";

            if ($3.is_constant) result += to_string($3.value);
            else result += string(1, static_cast<char>($3.value));

            $$ = strdup(result.c_str());
        }
    }
    | X EXPO X
    {
        if ($1.is_constant && $3.is_constant) {
            // Perform constant exponentiation
            string result = to_string(static_cast<int>(pow($1.value, $3.value)));
            $$ = strdup(result.c_str());
        } else {
            // Build the exponentiation expression with simplifications
            string result;

            if ($1.is_constant) result = to_string($1.value);
            else result = string(1, static_cast<char>($1.value));

            result += "^";

            if ($3.is_constant) {
                if ($3.value == 2) result = string(1, static_cast<char>($1.value)) + "*" + string(1, static_cast<char>($1.value));
                else if ($3.value == 1) result = string(1, static_cast<char>($1.value));
                else result += to_string($3.value);
            } else {
                result += string(1, static_cast<char>($3.value));
            }

            $$ = strdup(result.c_str());
        }
    }
    | X
    {
        // Base case: Return a constant or identifier as-is
        if ($1.is_constant) $$ = strdup(to_string($1.value).c_str());
        else $$ = strdup(string(1, static_cast<char>($1.value)).c_str());
    }
    ;

// Handles constants and identifiers.
// If an identifier is undefined, initialize it with its ASCII value.
X:
    CONST
    {
        $$ = item{true, $1}; // Store constant
    }
    | IDENTIFIER
    {
        string id($1);

        if (symbol_table.find(id) == symbol_table.end()) {
            // Initialize undefined identifier with its ASCII value
            symbol_table[id] = item{false, static_cast<int>(id[0])};
        }

        $$ = symbol_table[id];
    }
    ;

%%

// Error handling function
void yyerror(const string &s) {
    cerr << "Error at line " << linenum << ": " << s << endl;
    exit(1);
}

int yywrap() {
    return 1; // Indicates end of input
}

// Helper function to check if a string is numeric
bool is_integer(const string &s) {
    if (s.empty()) return false;
    for (char c : s) {
        if (!isdigit(c)) return false;
    }
    return true;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        cerr << "Error: Unable to open file " << argv[1] << endl;
        return 1;
    }

    yyparse();
    fclose(yyin);

    // Print the symbol table after parsing
    cout << "\nSymbol Table:" << endl;
    for (const auto &entry : symbol_table) {
        cout << entry.first << " = " << entry.second.value << endl;
    }

    return 0;
}
