%{
    #include <iostream>
    #include <string>
    #include <unordered_map> // For the symbol table
    #include <cstdio>         // For fopen, fclose
    #include <cstdlib>        // For exit()
	#include <cmath>
    
    using namespace std;

    extern FILE *yyin;
    extern int linenum;
    extern char *yytext;

    void yyerror(const string &s);

    // Define the item struct, ensure it's declared before use
    struct item {
        bool is_constant;
        int value;
    };

    // Declare the symbol table as an unordered_map
    unordered_map<string, item> symbol_table; // Store identifiers and their values
%}

%union {
    int intval;      // For integer values
    char *strval;    // For string (identifier) values
    item Item;       // For item struct
}

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

assignment:
    IDENTIFIER ASSIGN oper SEMICOLON
{
        string id($1); // Convert IDENTIFIER to string

        // Check if oper (i.e., $3) is an expression or a single identifier
        if (is_integer($3)) {
            // If oper is a number, assign it as a constant
            symbol_table[id] = item{true, stoi($3)}; // Store as constant
        } else if (strlen($3) == 1) {
            // If $3 is a single character (e.g., identifier), assign its ASCII value
            string operand($3);
            symbol_table[id] = item{false, static_cast<int>(operand[0])}; // Use ASCII value of operand
        } 

        cout << id << "=" << $3 << endl;
        free($1); // Free memory allocated for IDENTIFIER
    }
    ;

oper:
    X PLUS X
{
    if ($1.is_constant && $3.is_constant) {
        // If both operands are constants, add them and store as a string
        string result = to_string($1.value + $3.value);  // Add constants and store result as string
        $$ = strdup(result.c_str());  // Convert to char* and store in $$ (use strdup to copy)
    }
    else {
        // Handle the non-constant operands by converting them to strings
        string result;

        // Process first operand
        if ($1.is_constant) {
            if ($1.value != 0) {
                result = to_string($1.value);  // Convert constant value to string (skip if zero)
            }
        } else {
            result = string(1, static_cast<char>($1.value));  // Convert ASCII value to character
        }

         if ($3.value != 0 && !result.empty()) {
            result += "+";  
        }

        // Process second operand
        if ($3.is_constant) {
            if ($3.value != 0) {
                result += to_string($3.value);  // Convert constant value to string (skip if zero)
            }
        } else {
			
            result += string(1, static_cast<char>($3.value));  
        }
        $$ = strdup(result.c_str());
    }
}


    | X MULTI X
{
    if ($1.is_constant && $3.is_constant) {
        // If both operands are constants, add them and store as a string
        string result = to_string($1.value * $3.value);  // Add constants and store result as string
        $$ = strdup(result.c_str());  // Convert to char* and store in $$ (use strdup to copy)
    }
    else {
        // Handle the non-constant operands by converting them to strings
        string result;

        // Process first operand
        if ($1.is_constant) {
            if ($1.value != 1) {
                result = to_string($1.value);  // Convert constant value to string (skip if zero)
            }
        } else {
            result = string(1, static_cast<char>($1.value));  // Convert ASCII value to character
        }

         if ($3.value != 1 && !result.empty()) {
            result += "*";  
        }

        // Process second operand
        if ($3.is_constant) {

            if ($3.value != 1) {
                result += to_string($3.value);  // Convert constant value to string (skip if zero)
            }
        } else {
			
            result += string(1, static_cast<char>($3.value));  
        }
	if ($3.value == 0 || $1.value == 0) {
        result = to_string(0);  // Convert constant value to string (skip if one)
        }
        $$ = strdup(result.c_str());
    }
}
    | X DIV X
    {
        if ($1.is_constant && $3.is_constant) {
            // If both operands are constants, divide them and store as a string
            if ($3.value != 0) {  // Check for division by zero
                string result = to_string($1.value / $3.value);  // Divide constants and store result as string
                $$ = strdup(result.c_str());
            } else {
                yyerror("Division by zero");  // Handle division by zero
            }
        }
        else {
            // Handle the non-constant operands by converting them to strings
            string result;

            // Process first operand
            if ($1.is_constant) {
                result = to_string($1.value);  // Convert constant value to string
            } else {
                result = string(1, static_cast<char>($1.value));  // Convert ASCII value to character
            }

            result += "/";  // Add the division sign

            // Process second operand
            if ($3.is_constant) {
                result += to_string($3.value);  // Convert constant value to string
            } else {
                result += string(1, static_cast<char>($3.value));  // Convert ASCII value to character
            }

            $$ = strdup(result.c_str());  // Convert to char* and store in $$ (use strdup to copy)
        }
    }

    | X MINUS X
    {
        if ($1.is_constant && $3.is_constant) {
            // If both operands are constants, subtract them and store as a string
            string result = to_string($1.value - $3.value);  // Subtract constants and store result as string
            $$ = strdup(result.c_str()); 
        }
        else {
            // Handle the non-constant operands by converting them to strings
            string result;

            // Process first operand
            if ($1.is_constant) {
                result = to_string($1.value);  // Convert constant value to string
            } else {
                result = string(1, static_cast<char>($1.value));  // Convert ASCII value to character
            }

            result += "-";  // Add the subtraction sign

            // Process second operand
            if ($3.is_constant) {
                result += to_string($3.value);  // Convert constant value to string
            } else {
                result += string(1, static_cast<char>($3.value));  // Convert ASCII value to character
            }

            $$ = strdup(result.c_str());  // Convert to char* and store in $$ (use strdup to copy)
        }
    }
	| X EXPO X
    {
		if ($1.is_constant && $3.is_constant) {
        // If both operands are constants, perform exponentiation
		string result = to_string(static_cast<int>(pow($1.value, $3.value)));
        $$ = strdup(result.c_str());
    }
    else {
        // Handle the non-constant operands by converting them to strings
        string result;

        // Process first operand
        if ($1.is_constant) {
            result = to_string($1.value);  // Convert constant value to string
        } else {
            result = string(1, static_cast<char>($1.value));  // Convert ASCII value to character
        }

        result += "^";  // Add the exponentiation sign

        // Process second operand
        if ($3.is_constant) {
			if ($3.value==2){
				result = string(1, static_cast<char>($1.value))+"*"+string(1, static_cast<char>($1.value));
			}
            else if($3.value==1)
				result = string(1, static_cast<char>($1.value));
			else
			    result += to_string($3.value);
        } else {
            result += string(1, static_cast<char>($3.value));  // Convert ASCII value to character
        }

        $$ = strdup(result.c_str());  // Convert to char* and store in $$ (use strdup to copy)
    }
	}

    | X
    {
        // This is for the base case, where X is just a constant or identifier
        if ($1.is_constant) {
            $$ = strdup(to_string($1.value).c_str());  // Convert constant to string
        } else {
            $$ = strdup(string(1, static_cast<char>($1.value)).c_str());  // Convert ASCII to character and store
        }
    }
    ;

X:
    CONST
    {
        $$ = item{true, $1}; // Initialize Item with integer value
    }
    | IDENTIFIER
	{
		string id($1); // Convert IDENTIFIER to string
		if (symbol_table.find(id) == symbol_table.end()) {
			symbol_table[id] = item{false, static_cast<int>(id[0])}; // Store ASCII value as default
		}
		$$ = symbol_table[id]; 
	}

%%

void yyerror(const string &s) {
    cerr << "Error at line " << linenum << ": " << s << endl;
    exit(1);
}

int yywrap() {
    return 1; // End of file or input stream handling
}
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
