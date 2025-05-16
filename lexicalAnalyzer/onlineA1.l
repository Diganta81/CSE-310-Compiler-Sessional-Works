%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;
string token="";
string templ="";
int nesting=0;
bool valid;

bool hasDuplicate(string input) {
    const int MAX_TOKENS = 100;
    string tokens[MAX_TOKENS];
    int tokenCount = 0;

    string temp = "";

    for (size_t i = 0; i <= input.length(); i++) {
        if (input[i] == ',' || i == input.length()) {
            // Check for duplicates
            for (int j = 0; j < tokenCount; j++) {
                if (tokens[j] == temp) {
                    return true;  // Duplicate found
                }
            }
            tokens[tokenCount++] = temp;
            temp = "";
        } else {
            temp += input[i];
        }
    }

    return false;  // All unique
}


%}


%%

[ \t]+  { /* Ignore whitespace */ }

[A-Za-z_][A-Za-z0-9_]*  { 
    templ+=yytext;
    if(nesting==0){
        token+=yytext;
    }
    else{
        token+=",";
        token+=yytext;
    }
}

"<" {
    nesting++;
    templ+="<";
}

">" {
    nesting--;
    templ+=">";
}

\n|\r\n {
    if(nesting==0){
        valid=hasDuplicate(token);
        if(valid){
            cout<<"Error: Duplicate tokens found in the input string."<<endl;
        }
        else{
            cout<<"Valid input string: "<<templ<<endl;
        }
    }
    else{
        cout<<"Error: Unmatched angle brackets."<<endl;
    }
    token="";
    templ="";
}

%%

int main(int argc, char* argv[]) {
    if(argc!=2){
        cout<<"Usage: "<<argv[0]<<" <input_string>"<<endl;
        return 1;
    }
    FILE *fin = fopen(argv[1], "r");
    yyin = fin;
    yylex();
    fclose(fin);
    return 0;
}


