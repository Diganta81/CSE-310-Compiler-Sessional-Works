%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;
%}

%%

^[ \t]*"\#"define[ \t]+[a-zA-Z_][a-zA-Z0-9_]*[ \t]+[a-zA-Z_][a-zA-Z0-9_]* {
    string s=yytext;
    cout<<"Macro "<<s<<" detected"<<endl;
}

^[ \t]*"\#"define[ \t]+[a-zA-Z_][a-zA-Z0-9_]*[ \t]* {
    cout<<"MACRO " << yytext << " DETECTED2" << endl;
}

\n {

}

%%

int main(int argc, char* argv[]) {
    if(argc!=2){
        cout<<"Usage: "<<argv[0]<<" <input_string>"<<endl;
        return 0;
    }
    FILE *fin = fopen(argv[1], "r");
    yyin = fin;
    yylex();
    fclose(fin);
    return 0;
}