%option noyywrap

%x singleComment
%x multiComment
%x stringState

%{
#include<bits/stdc++.h>
#include"2105081_symbol_table.hpp"

int total_bucket=7;
int line_count=1;
int error_count=0;
int warning_count=0;
int line_starts=1;
int temp_line_count=0;
string temp_line;
string token;
SymbolTable* symbol_table;
ofstream logout;
ofstream tokenout;

string make_upper(string s){
    string s1="";
    for(int i=0;i<s.length();i++){
        s1+=toupper(s[i]);
    }
    return s1;
}

char special_char_parse(string s){
    if(s=="\\n"){
        return '\n';
    }
    else if(s=="\\t"){
        return '\t';
    }
    else if(s=="\\a"){
        return '\a';
    }
    else if(s=="\\f"){
        return '\f';
    }
    else if(s=="\\r"){
        return '\r';
    }
    else if(s=="\\b"){
        return '\b';
    }
    else if(s=="\\v"){
        return '\v';
    }
    else if(s=="\\0"){
        return '\0';
    }
    else if(s=="\\\'"){
        return '\'';
    }
    else if(s=="\\\\"){
        return '\\';
    }
    else if(s=="\\\""){
        return '\"';
    }
    else{
        return 'o';
    }
}

void process_char(){;
    char c=yytext[1];
    string s="";
    s+=c;
    if(c=='\\'){
        s+=yytext[2];
        c=special_char_parse(s);
    }
    if(c!='o'){
        tokenout<<"<CONST_CHAR, "<<c<<"> ";
        logout<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme \'"<<s<<"\' found --> <CONST_CHAR, "<<c<<">\n\n";
    }
    else{
        tokenout<<"<CONST_CHAR, "<<s<<"> ";
        logout<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<s<<" found\n\n";
    }
    s="\'"+s+"'";
    bool inserted=symbol_table->insert(s,"CONST_CHAR");
    if(inserted){
        symbol_table->printAllScopeTable();
    }
    // else{
    //     logout<<"Line no "<<line_count<<" Error: <CONST_CHAR> Lexeme "<<s<<" already exists in symbol table\n\n";
    // }
}

void print(string s){
    tokenout<<"<"<<s<<", "<<yytext<<"> ";
    logout<<"Line no "<<line_count<<": Token <"<<s<<"> Lexeme "<<yytext<<" found\n\n";
}    

%}



WHITESPACE [ \t\f\r\v]+ 
KEYWORD "if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"|"goto"|"long"|"short"|"static"|"unsigned"
DIGIT [0-9]
CONST_INT {DIGIT}+
CONST_FLOAT {DIGIT}+("."{DIGIT}+)?([Ee][+-]?{DIGIT}+)?
SPECIAL_CHAR "\\n"|"\\t"|"\\\\"|"\\\'"|"\\a"|"\\f"|"\\b"|"\\v"|"\\0"|"\\r"|"\\\""
LETTER [a-zA-Z_]
ID {LETTER}({LETTER}|{DIGIT})* 
ADDOP [+-]
MULOP [*/%]
INCOP "++"|"--"
RELOP "<"|"<="|">"|">="|"=="|"!="
ASSIGNOP [=]
LOGICOP "&&"|"\|"
NOT "!"
LPAREN "("
RPAREN ")"
LCURL "{"
RCURL "}"
LTHIRD "["
RTHIRD "]"
COMMA ","
SEMICOLON ";"
NEWLINE [\n]|[\r\n]
CHARACTER [^\n\r\\\'\"]|SPECIAL_CHAR
/* CHAR "\'{CHARACTER}\'" */



%%

{WHITESPACE} {}

{NEWLINE} {
    line_count++;
    line_starts=1;
}

{KEYWORD} {
    string s=make_upper(yytext);
    tokenout<<"<"<<s<<"> ";
    logout<<"Line no "<<line_count<<": Token "<<"<"<<s<<">"<<" Lexeme "<<yytext<<" found\n\n";
}

{CONST_INT} {
    string s="CONST_INT";
    print(s);
    bool inserted=symbol_table->insert(yytext,"CONST_INT");
    if(inserted){
        symbol_table->printAllScopeTable();
    }
    // else{
    //     logout<<"Line no "<<line_count<<" Error: <CONST_INT> Lexeme "<<yytext<<" already exists in symbol table\n\n";
    // }
}

{CONST_FLOAT} {
    string s="CONST_FLOAT";
    print(s);
    bool inserted=symbol_table->insert(yytext,"CONST_FLOAT");
    if(inserted){
        symbol_table->printAllScopeTable();
    }
    // else{
    //     logout<<"Line no "<<line_count<<" Error: <CONST_FLOAT> Lexeme "<<yytext<<" already exists in symbol table\n\n";
    // }
}

{CONST_INT}[Ee][+-]?{CONST_FLOAT}+ {
    error_count++;
    logout<<"Error at line no "<<line_count<<": ill formed number "<<yytext<<"\n\n";
}

{CONST_FLOAT}(\.{CONST_FLOAT})+ {
    error_count++;
    logout<<"Error at line no "<<line_count<<": too many decimal points "<<yytext<<"\n";
}

{ADDOP} {
    string s="ADDOP";
    print(s);
}

{MULOP} {
    string s="MULOP";
    print(s);
}

{INCOP} {
    string s="INCOP";
    print(s);
}

{RELOP} {
    string s="RELOP";
    print(s);
}

{ASSIGNOP} {
    string s="ASSIGNOP";
    print(s);
}

{LOGICOP} {
    string s="LOGICOP";
    print(s);
}

{NOT} {
    string s="NOT";
    print(s);
}   

{LPAREN} {
    string s="LPAREN";
    print(s);
}

{RPAREN} {
    string s="RPAREN";
    print(s);
}

{LCURL} {
    string s="LCURL";
    print(s);
    symbol_table->enterScope(total_bucket);
}

{RCURL} {
    string s="RCURL";
    print(s);
    symbol_table->exitScope();
}

{LTHIRD} {
    string s="LTHIRD";
    print(s);
}

{RTHIRD} {
    string s="RTHIRD";
    print(s);
}

{COMMA} {
    string s="COMMA";
    print(s);
}

{SEMICOLON} {
    string s="SEMICOLON";
    print(s);
}

{ID} {
    tokenout<<"<ID, "<<yytext<<"> ";
    logout<<"Line no "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found\n\n";
    if(symbol_table->insert(yytext,"ID")){
        symbol_table->printAllScopeTable();
    }
}

{CONST_INT}{ID} {
    error_count++;
    logout<<"Error at line no "<<line_count<<": Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence "<<yytext<<"\n\n";
}

"\'\'" {
    error_count++;
    logout<<"Error at line no "<<line_count<<": Empty character constant error "<<yytext<<"\n\n";
}

[\']{CHARACTER}*{NEWLINE} {
    line_count++;
    error_count++;
    logout << "Error at line no " <<line_count << ": Unterminated chaaracter " << yytext << "\n\n";
}
[\']{SPECIAL_CHAR}*{NEWLINE} {
    line_count++;
    error_count++;
    logout << "Error at line no " << line_count << ": Unterminated character " << yytext << "\n\n";
}

[\']{CHARACTER}{CHARACTER}+[\'] {
    error_count++;
    logout << "Error at line no " << line_count << ": Multi character constant error  " << yytext << "\n\n";
}

[\']{CHARACTER}*[\'] {
    process_char();
}

"\/\/" {
    temp_line_count=0;
    temp_line=yytext;
    BEGIN singleComment;
}

[\"] {
    BEGIN stringState;
    temp_line="";
    temp_line_count=0;
    temp_line+=yytext;
    token="";
}

<stringState>\" {
    temp_line+=yytext;
    line_count+=temp_line_count;
    if(temp_line_count==0){
        tokenout<<"<STRING, "<<token<<"> ";
        logout<<"Line no "<<line_count<<": Token <STRING> Lexeme "<<temp_line<<" found --> <STRING, "<<token<<">\n\n";
    }
    else{
        tokenout<<"<STRING, "<<token<<"> ";
        logout<<"Line no "<<line_count<<": Token <STRING> Lexeme "<<temp_line<<" found --> <STRING, "<<token<<">\n\n";
    }
    BEGIN INITIAL;
}

<stringState>\\{NEWLINE} {
    temp_line_count++;
    temp_line+=yytext;
}

<stringState>{NEWLINE} {
    error_count++;
    logout<<"Error at line no "<<line_count<<": UNFINISHED_STRING "<<temp_line<<"\n\n";
    line_count+=temp_line_count;
    line_count++;
    BEGIN INITIAL;
}

<stringState>{SPECIAL_CHAR} {
    temp_line+=yytext;
    token+=special_char_parse(yytext);
}

<stringState>. {
    temp_line+=yytext;
    token+=yytext;
}

<stringState><<EOF>> {
    error_count++;
    line_count+=temp_line_count;
    logout<<"Error at line no "<<line_count<<": UNFINISHED_STRING "<<temp_line<<"\n\n";
    BEGIN INITIAL;
}

<singleComment>{NEWLINE} {
    line_count+=temp_line_count;
    logout<<"Line no "<<line_count<<": Token <COMMENT> Lexeme "<<temp_line<<" found\n\n";
    line_count++;
    BEGIN INITIAL;
}

<singleComment>\\{NEWLINE} {
    temp_line_count++;
    temp_line+=yytext;
}

<singleComment>. {
    temp_line+=yytext;
}

<singleComment><<EOF>> {
    line_count+=temp_line_count;
    logout<<"Line no "<<line_count<<": Token <COMMENT> Lexeme "<<temp_line<<" found\n\n";
    BEGIN INITIAL;
}

"/*" {
    temp_line_count=0;
    temp_line=yytext;
    BEGIN multiComment;
}

<multiComment>"\*\/" {
    temp_line+=yytext;
    line_count+=temp_line_count;
    logout<<"Line no "<<line_count<<": Token <COMMENT> Lexeme "<<temp_line<<" found\n\n";
    
    BEGIN INITIAL;
}

<multiComment>{NEWLINE} {
    temp_line_count++;
    temp_line+=yytext;
}

<multiComment>. {
    temp_line+=yytext;
}

<multiComment><<EOF>> {
    error_count++;
    logout<<"Error at line no "<<line_count<<": UNFINISHED COMMENT "<<temp_line<<"\n\n";
    line_count+=temp_line_count;
    BEGIN INITIAL;
}

. {
    line_starts=0;
    error_count++;
    logout<<"Error at line no "<<line_count<<": Unrecognized character "<<yytext<<"\n\n";
}

%%

int main(int argc,char *argv[]) {
	if(argc!=2){
		cout<<"please provide the input file name"<<endl;
		return 0;
	}
	FILE *fin = fopen(argv[1], "r");
	if(fin == NULL){
		cout<<"File not found"<<endl;
		return 0;
	}
	logout.open("2105081_log.txt");
    cout.rdbuf(logout.rdbuf());
	tokenout.open("2105081_token.txt");
    symbol_table=new SymbolTable(new ScopeTable(total_bucket,NULL));
	yyin=fin;
	yylex();
	fclose(yyin);
	symbol_table->printAllScopeTable();
	logout <<"Total lines: "<< line_count<<"\n";
	logout <<"Total errors: "<< error_count<<"\n";
    tokenout.close();
	logout.close();
	delete symbol_table;
	return 0;
}
