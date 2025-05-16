%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;
int camel=0;
int snake=0;

%}

camelCase [a-zA-Z][a-zA-Z]*[A-Z][a-z]*

snake_case [a-z][a-zA-Z]*_[a-z][a-zA-Z]*

%%

{camelCase} {
    camel++;
    cout << "Camel Case: " << yytext << endl;
}

{snake_case} {
    snake++;
    cout << "Snake Case: " << yytext << endl;
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