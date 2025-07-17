parser grammar C8086Parser;

options {
    tokenVocab = C8086Lexer;
}

@parser::header {

    #include <fstream>
    #include <cstdlib>
	#include <string>
    #include "C8086Lexer.h"
	#include "2105081_symbol_table.h"

    extern ofstream parserLogFile;
    extern ofstream errorFile;
	extern std::ofstream asmCodeFile;

    extern int syntaxErrorCount;
	extern vector<pair<string,string>> temp;
	extern vector<string> forargs;
	extern std::string cont;
	extern stack<string>hold;
}

@parser::members {
	int label = 0;
	void newLabel() {
		label++;
		asmCodeFile << "L" << label << ":" << std::endl;
	}
	SymbolTable* symbolTable = new SymbolTable(new ScopeTable(7,NULL));
    void writeIntoparserLogFile(const string message) {
        if (!parserLogFile) {
            cout << "Error opening parserLogFile.txt" << endl;
            return;
        }

        parserLogFile << message << endl;
        parserLogFile.flush();
    }

    void writeIntoErrorFile(const string message) {
        if (!errorFile) {
            cout << "Error opening errorFile.txt" << endl;
            return;
        }
        errorFile << message << endl;
        errorFile.flush();
    }

	void emit(const std::string &line) {
        asmCodeFile << line << std::endl;
    }
	
	bool isGlobal = true;

	string value = "";

	int value1=0;
	int value2=0;
	int spCount = 0;
	int count=0;
	int tempLabel=0;
	int stackCount = 0;
	int localVariableCount = 0;
	int funcCount=0;
	int Main = 0;
	vector<string>sizeofArray;
	
}


start : {
	cont="\
.MODEL SMALL\n\
.STACK 1000H\n\
.DATA\n\
NUMBER DB '00000$'\n";
emit(cont);
 	} program
	{
		symbolTable->printAllScopeTable(parserLogFile);

        writeIntoparserLogFile("Total number of lines: " + to_string($program.stop->getLine()));
		writeIntoparserLogFile("Total number of errors: " + to_string(syntaxErrorCount));
		newLabel();
		emit("    ADD SP, " + to_string(spCount * 2));
		emit("    POP BP");
		stackCount--;
		emit("    MOV AX, 4C00H");
		emit("    INT 21H");
		emit("main ENDP");
		
	}
	;

program returns [string  name_Line] : pg=program u=unit {
		writeIntoparserLogFile("Line " + to_string($unit.stop->getLine()) + ": program : program unit\n");
		$pg.name_Line = $pg.name_Line + "\n" + $u.name_Line;
		//writeIntoparserLogFile($pg.text);
		//writeIntoparserLogFile($u.name_Line + "\n\n");
		writeIntoparserLogFile($pg.name_Line + "\n");
		$name_Line = $pg.name_Line;

	  }
	
	| unit{
		writeIntoparserLogFile("Line " + to_string($unit.stop->getLine()) + ": program : unit\n");
		writeIntoparserLogFile($unit.name_Line + "\n");
		$name_Line= $unit.name_Line ;
	  }
	;
	
unit returns [string name_Line]: vd=var_declaration{
		writeIntoparserLogFile("Line " + to_string($vd.start->getLine()) + ": unit : var_declaration\n");
		$name_Line = $vd.name_Line;
		writeIntoparserLogFile($vd.name_Line + "\n");
	  }
     | fd=func_declaration{
		writeIntoparserLogFile("Line " + to_string($fd.start->getLine()) + ": unit : func_declaration\n");
		$name_Line = $fd.name_Line;
		writeIntoparserLogFile($fd.name_Line + "\n");
	  }
     | {
		if(funcCount==0){
		emit(".CODE");
		funcCount++;
	}
	 }func_definition {
		writeIntoparserLogFile("Line " + to_string($func_definition.stop->getLine()) + ": unit : func_definition\n");
		writeIntoparserLogFile($func_definition.name_Line + "\n");
		$name_Line = $func_definition.name_Line;
	  }
     ;
     
func_declaration  returns [string  name_Line]: type_specifier ID LPAREN pl=parameter_list RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($pl.stop->getLine()) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
			writeIntoparserLogFile($type_specifier.text + " " + $ID.text + "(" + $pl.text + ");\n");
			$name_Line = $type_specifier.text + " " + $ID.text + "(" + $pl.text + ");";
			
			symbolTable->insert(parserLogFile, $ID.text,"ID");
			SymbolInfo *sym = symbolTable->LookUp($ID.text);
			sym->isFunction = true;
			for (const auto& name : $pl.names) {
				sym->paramTypes.push_back(name.first);
			}
			sym->returnType = $type_specifier.type;
			sym->paramCount = $pl.count;
			$pl.names.clear(); 
			temp.clear(); // Clear temp to avoid memory leak
		}
		| ts=type_specifier ID LPAREN RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($ts.start->getLine()) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
			writeIntoparserLogFile($ts.text + " " + $ID.text + "();\n");
			$name_Line = $ts.text + " " + $ID.text + "();";
			symbolTable->insert(parserLogFile, $ID.text,"ID");
			SymbolInfo *sym = symbolTable->LookUp($ID.text);
			sym->isFunction = true;
			sym->returnType = $ts.type;
			sym->paramCount = 0; 
		}
		;
		 
func_definition returns [string name_Line]: ts=type_specifier ID{
				emit($ID.text + " PROC");
				emit("    PUSH BP");
				stackCount++;
				emit("    MOV BP, SP");
} LPAREN pl=parameter_list{
				symbolTable->insert(parserLogFile, $ID.text,"ID");
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				sym->isFunction = true;
				sym->returnType = $ts.type;
				sym->paramCount = $pl.count;
				int i=0;
				
				for (const auto& name : $pl.names) {
					sym->paramTypes.push_back(name.second);
					localVariableCount++;
					emit("    SUB SP, 2");
					emit("    MOV AX, [BP+" + to_string(($pl.names.size()-i) * 2 + 2) + "]");
					
					emit("	MOV [BP-" + to_string(($pl.names.size()-i) * 2) + "], AX");
					i++;
					count++;
				}
			$pl.names.clear();
		}	
		 RPAREN cs=compound_statement {


			writeIntoparserLogFile("Line " + to_string($cs.stop->getLine()) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			writeIntoparserLogFile($ts.text + " " + $ID.text + "(" + $pl.name_Line + ")"+$cs.text + "\n");
			
			$name_Line = $ts.text + " " + $ID.text + "(" + $pl.name_Line + ")" + $cs.name_Line;
			newLabel();
			emit("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
			emit("    POP BP");
			stackCount--;
			emit("    RET");
			emit($ID.text + " ENDP");
			localVariableCount = 0;
			count=0;
			spCount = 0;
			
		}
		| ts=type_specifier ID{
		if ($ID.text == "main") {
            
            emit("main PROC");
            emit("    MOV AX, @DATA");
            emit("    MOV DS, AX");
            emit("    PUSH BP");
			stackCount++;
            emit("    MOV BP, SP");
			Main = 1;
			
        }
		else{
			emit($ID.text + " PROC");
			emit("    PUSH BP");
			stackCount++;
			emit("    MOV BP, SP");
		}
		}
		 LPAREN{
		if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				
				
			} else {
				symbolTable->insert(parserLogFile, $ID.text,"ID");
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				sym->isFunction = true;
				sym->returnType = $ts.type;
				
			}
			
			

		}	 RPAREN cs=compound_statement {
			
			writeIntoparserLogFile("Line " + to_string($cs.stop->getLine()) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
			writeIntoparserLogFile($ts.text + " " + $ID.text + "()" +$cs.name_Line + "\n" );
			
			$name_Line = $ts.text + " " + $ID.text + "()" + $cs.name_Line;
			if($ID.text != "main"){
				newLabel();
				emit("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
				emit("    POP BP");
				stackCount--;
				emit("    RET");
				emit($ID.text + " ENDP");
				localVariableCount = 0;
				
			}
			else{
				Main = 0;
			}
			spCount = 0;
		}
 		;				


parameter_list returns [vector<pair<string,string>> names,string name_Line,int count]: pl=parameter_list COMMA ts=type_specifier ID{
			
			
			$names = $pl.names;
			$count = $pl.count + 1;
			
			
				$names.push_back(make_pair($ts.type, $ID.text));
				temp.push_back(make_pair($ts.text,$ID.text));
			
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID\n");
			writeIntoparserLogFile($pl.text + "," + $ts.text + " " + $ID.text + "\n");
		}
		| pl=parameter_list COMMA ts=type_specifier{
			writeIntoparserLogFile("Line " + to_string($ts.start->getLine()) + ": parameter_list : parameter_list COMMA type_specifier\n");
			writeIntoparserLogFile($pl.text + "," + $ts.text + "\n");
			$name_Line = $pl.text + "," + $ts.text;
		}
 		| ts=type_specifier ID{
			writeIntoparserLogFile("Line " + to_string($ts.start->getLine()) + ": parameter_list : type_specifier ID\n");
			writeIntoparserLogFile($ts.text + " " + $ID.text + "\n");
			$name_Line = $ts.text + " " + $ID.text;
			$count = 1;
			$names.push_back(make_pair($ts.type, $ID.text));
			temp.push_back(make_pair($ts.type,$ID.text));
			
			
		}
		| type_specifier{
			writeIntoparserLogFile("Line " + to_string($type_specifier.start->getLine()) + ": parameter_list : type_specifier\n");
			writeIntoparserLogFile($type_specifier.text + "\n");
			$name_Line = $type_specifier.text;
		}
		|type_specifier ADDOP{
			writeIntoparserLogFile("Error at line " + to_string($ADDOP->getLine()) + ": syntax error, unexpected ADDOP, expecting RPAREN or COMMA\n");
			writeIntoErrorFile("Error at line " + to_string($ADDOP->getLine()) + ": syntax error, unexpected ADDOP, expecting RPAREN or COMMA\n");
	  		syntaxErrorCount++;
	   }
 		;

 		
compound_statement returns [string name_Line,string type]: LCURL{
        	symbolTable->enterScope(7); 
			int i=0;
			for (const auto& name : temp) {
				
					symbolTable->insert(parserLogFile, name.second, "ID");
					SymbolInfo *sym = symbolTable->LookUp(name.second);
					sym->Idtype=name.first;
					sym->offset = (temp.size()-i)*2;
					//writeIntoparserLogFile("Inserted variable: " + name.second + "\n");
					i++;
				
			}
			temp.clear();
			 
    	} statements RCURL{
			writeIntoparserLogFile("Line " + to_string($RCURL->getLine()) + ": compound_statement : LCURL statements RCURL\n");
			writeIntoparserLogFile("{\n" + $statements.name_Line + "\n}");
			$name_Line =  "{\n" + $statements.name_Line + "}" ;
			symbolTable->printAllScopeTable(parserLogFile);	
			symbolTable->exitScope();
			$type=$statements.type;
			
			
		}
 		| LCURL{
        	symbolTable->enterScope(7);
		}  RCURL{
			symbolTable->printAllScopeTable(parserLogFile);
        	symbolTable->exitScope();
			$type="void";
    	}
 		    ;
 		    
var_declaration returns [string name_Line]
    : ts=type_specifier dl=declaration_list sm=SEMICOLON {
        writeIntoparserLogFile("Line "+to_string($sm->getLine())+": "+ 
            string("var_declaration : type_specifier declaration_list ") +
            "SEMICOLON\n"
        );
		if(symbolTable->current->id=="1"){
			for(const auto& name : $dl.names){
				if(name.second=="array") {
					string size = sizeofArray[0];
					emit(name.first + " DW " + size + " DUP 0000H");
					symbolTable->insert(parserLogFile,name.first, name.second);
					SymbolInfo *sym=symbolTable->LookUp(name.first);
					sym->isArray=true;
					sym->Idtype=$ts.type;
					sizeofArray.erase(sizeofArray.begin());
					sym->isGlobal=true;
				}
				else{
					symbolTable->insert(parserLogFile,name.first,name.second);
					SymbolInfo *sym=symbolTable->LookUp(name.first);
					sym->Idtype =$ts.type;
					sym->isGlobal = true;
					emit(name.first + " DW " + "1 "  +"DUP " + "0000H ");
				}
			}
			
		}
		else{
			for (const auto& name : $dl.names) {
			if(name.second=="array") {
				symbolTable->insert(parserLogFile,name.first, "ID");
				SymbolInfo *sym=symbolTable->LookUp(name.first);
				sym->isArray=true;
				sym->Idtype=$ts.type;
				emit("    SUB SP, " + to_string(stoi(sizeofArray[0]) * 2));
				spCount += stoi(sizeofArray[0]);
				sizeofArray.erase(sizeofArray.begin());
			
			}
			else{
				symbolTable->insert(parserLogFile,name.first,name.second);
				SymbolInfo *sym=symbolTable->LookUp(name.first);
				sym->Idtype=$ts.type;
				emit("    SUB SP, 2");
				spCount++;
				
				sym->offset = (spCount+count) * 2; // Assuming each variable takes 2 bytes
			}
		}
		}
        $name_Line = $ts.text + " " + $dl.text + ";";
		writeIntoparserLogFile($ts.text+" "+$dl.text+";"+"\n");
		
		$dl.names.clear(); 
      }

    | ts=type_specifier de=declaration_list_err sm=SEMICOLON {
        writeIntoErrorFile(
            string("Line# ") + to_string($sm->getLine()) +
            " with error name: " + $de.error_name +
            " - Syntax error at declaration list of variable declaration"
        );

        syntaxErrorCount++;
      }
    ;

declaration_list_err returns [string error_name]: {
        $error_name = "Error in declaration list";
    };

 		 
type_specifier returns [string type] 	
        : INT {
			writeIntoparserLogFile("Line " + to_string($INT->getLine()) + ": type_specifier : INT\n");
			writeIntoparserLogFile("int\n");
			$type = "int";
        }
 		| FLOAT {
			writeIntoparserLogFile("Line " + to_string($FLOAT->getLine()) + ": type_specifier : FLOAT\n");
			writeIntoparserLogFile("float\n");
			$type = "float";
        }
 		| VOID {
			writeIntoparserLogFile("Line " + to_string($VOID->getLine()) + ": type_specifier : VOID\n");
			writeIntoparserLogFile("void\n");
			$type = "void";
        }
 		;
 		
declaration_list returns [vector<pair<string,string>> names] : dl=declaration_list COMMA id=ID{
			writeIntoparserLogFile("Line " + to_string($id->getLine()) + ": declaration_list : declaration_list COMMA ID\n");
			writeIntoparserLogFile($dl.text + "," + $id.text + "\n");
			$names = $dl.names;
			//$names.push_back({$id.text,"ID"});
			
				$names.push_back({$id.text,"ID"});
			
		  }
 		  | dl=declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
			writeIntoparserLogFile($dl.text+","+$ID.text + "[" + $CONST_INT.text + "]\n");
			$names = $dl.names;
			//$names.push_back({$ID.text,"array"} );
			
				$names.push_back({$ID.text,"array"} );
				sizeofArray.push_back($CONST_INT.text);
			
		  }
 		  | ID{
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : ID\n");
			writeIntoparserLogFile($ID.text + "\n");
			//$names.push_back({$ID.text,"ID"});
			
				$names.push_back({$ID.text,"ID"} );
		  	
		  }
 		  | ID LTHIRD CONST_INT RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
			writeIntoparserLogFile($ID.text + "[" + $CONST_INT.text + "]\n");
			$names.push_back({$ID.text,"array"} );
			sizeofArray.push_back($CONST_INT.text);
			
		  	
		  }
		  |declaration_list ADDOP ID {
			writeIntoparserLogFile("Error at line " + to_string($ADDOP->getLine()) + ": syntax error, unexpected ADDOP, expecting COMMA or SEMICOLON\n");
			writeIntoErrorFile("Error at line " + to_string($ADDOP->getLine()) + ": syntax error, unexpected ADDOP, expecting COMMA or SEMICOLON\n");
	  		syntaxErrorCount++;
	   	  }
 		  ;
 		  
statements returns [string name_Line,string type]: statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statements : statement\n");
			writeIntoparserLogFile($statement.name_Line +"\n");
			$name_Line = $statement.name_Line;
			
		  }
	   | st=statements statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statements : statements statement\n");
			writeIntoparserLogFile($st.name_Line  + $statement.name_Line );
			$name_Line = $st.name_Line + $statement.name_Line;
		  }
	   ;
	   
statement returns [string name_Line]: var_declaration {
			writeIntoparserLogFile("Line " + to_string($var_declaration.stop->getLine()) + ": statement : var_declaration\n");
			writeIntoparserLogFile($var_declaration.name_Line + "\n");
			$name_Line = $var_declaration.name_Line + "\n";
		  }
	  | expression_statement {
			writeIntoparserLogFile("Line " + to_string($expression_statement.stop->getLine()) + ": statement : expression_statement\n");
			writeIntoparserLogFile($expression_statement.text + "\n");
			$name_Line = $expression_statement.text + "\n";
		  }
	  | compound_statement{
			writeIntoparserLogFile("Line " + to_string($compound_statement.stop->getLine()) + ": statement : compound_statement\n");
   			writeIntoparserLogFile($compound_statement.name_Line + "\n");
			$name_Line = $compound_statement.name_Line;
	  }
	  | FOR{
		string label1=to_string(label+1);
		label++;
		string label2=to_string(label+1);
		label++;
		string label3=to_string(label+1);
		label++;
		string label4=to_string(label+1);
		label++;
	  } LPAREN expression_statement{
		emit("L" + label1 + ":");
	  } expression_statement{
		emit("    POP AX");
		stackCount--;
		emit("    CMP AX, 0");
		emit("    JE L" + label4);
		emit("    JMP L" + label3);
		emit("L" + label2 + ":");
	  } expression{
		
		emit("    JMP L" + label1);
		emit("L" + label3 + ":");
	  } RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
			writeIntoparserLogFile("for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			emit("    JMP L" + label2);
			emit("L" + label4 + ":");
		  }
	  |IF LPAREN expression RPAREN{
			emit("    POP AX");
			stackCount--;
			emit("    CMP AX, 1");
			
			string elseLabel =to_string(label+1);
			label++;
			emit("    JNE L"+elseLabel);
			
			
	  } statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			
			emit("L"+elseLabel+":");
		  }
	  | IF LPAREN expression RPAREN{
			emit("    POP AX");
			stackCount--;
			emit("    CMP AX, 1");
			
			string elseLabel =to_string(label+1);
			label++;
			string endLabel = to_string(label+1);
			label++;
			emit("    JNE L"+elseLabel);
	  } statement{
		emit("    JMP L"+endLabel);
		emit("L"+elseLabel+":");
	  } ELSE s=statement {
			writeIntoparserLogFile("Line " + to_string($s.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}";
			emit("L"+endLabel+":");

		  }
	  | WHILE{
			string label1=to_string(label+1);
			label++;
			string label2=to_string(label+1);
			label++;
	  } LPAREN{
		emit("L" + label1 + ":");
	  } expression{
			//emit(to_string(stackCount));
			if(stackCount==1){
				emit("    PUSH AX");
				stackCount++;
			}
			emit("    POP AX");
			stackCount--;
			emit("    CMP AX, 0");
			emit("    JE L" + label2);
	  } RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : WHILE LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			
			emit("    JMP L" + label1);
			emit("L" + label2 + ":");
		  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
			writeIntoparserLogFile("println(" + $ID.text + ");\n");
			$name_Line = "println(" + $ID.text + ");\n";
			
			SymbolInfo *sym = symbolTable->LookUp($ID.text);
			if(sym->isGlobal) {
				newLabel();
				emit("    MOV AX, " + $ID.text);
				emit("    CALL print_output");
				emit("    CALL new_line");
				
			}

			else{
				newLabel();
				emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
				emit("    CALL print_output");
				emit("    CALL new_line");
				
			}
		  }
	  | RETURN e=expression SEMICOLON {
			writeIntoparserLogFile("Line " + to_string($e.stop->getLine()) + ": statement : RETURN expression SEMICOLON\n");
			writeIntoparserLogFile("return " + $e.text + ";\n");
			$name_Line = "return " + $e.text + ";\n";
			emit("    POP AX");
			stackCount--;
			if(localVariableCount!=0 ){
				emit("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
				emit("    POP BP");
				stackCount--;
				emit("    RET");
			}
			//stackCount--;
			//spCount = 0;
		  }
	  ;

expression_statement 	: SEMICOLON	{
			writeIntoparserLogFile("Line " + to_string($SEMICOLON->getLine()) + ": expression_statement : SEMICOLON\n");
			writeIntoparserLogFile(";\n");
	   		}			
			| {newLabel();}expression SEMICOLON {
			
			writeIntoparserLogFile("Line " + to_string($expression.start->getLine()) + ": expression_statement : expression SEMICOLON\n");
			writeIntoparserLogFile($expression.text + ";\n");
		  }
			;
	   
variable returns [string name_line,string type] : ID {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": variable : ID\n");
			if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				
					
				
			} 
			writeIntoparserLogFile($ID.text + "\n");
			$name_line = $ID.text;
		  }	
	 | ID LTHIRD expression RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": variable : ID LTHIRD expression RTHIRD\n");
			writeIntoparserLogFile($ID.text + "[" + $expression.text + "]\n");
			
			$name_line = $ID.text + "[" + $expression.text + "]";
		  }
	 ;
	 
expression returns [string name_line,string type]: logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": expression : logic_expression\n");
			writeIntoparserLogFile($logic_expression.text + "\n");
			$name_line = $logic_expression.name_line;
			
		  }	
	   | variable ASSIGNOP logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": expression : variable ASSIGNOP logic_expression\n");
			writeIntoparserLogFile($variable.text + "=" + $logic_expression.text + "\n");
			if (!hold.empty()) {
				size_t pos = $variable.text.find('[');
				
				if (pos != string::npos) {
					string varName = $variable.text.substr(0, pos);
					SymbolInfo *sym = symbolTable->LookUp(varName);
					if (sym->isGlobal) {
						emit("    POP AX");
						emit("    POP BX");
						emit("    SHL BX, 1");
						emit("    MOV "+varName+"[BX], AX");
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						
						emit("    POP AX");
						emit("    POP BX");
						emit("    SHL BX, 1");
						emit("    SUB BX, "+to_string((spCount)*2));
						emit("    MOV SI, BX");
						emit("    MOV [BP+SI], AX");
					}
				}
				else{
				SymbolInfo *sym = symbolTable->LookUp($variable.text);
				if(sym->isGlobal) {
    				value = hold.top();
    				hold.pop();
					emit("    POP AX");
					stackCount--;
    				emit("    MOV " + $variable.text + ", AX");
				}
				else if(!sym->isGlobal){
					emit("    POP AX");
					stackCount--;
					emit("    MOV [BP-" + to_string(sym->offset) + "], AX");
				}
				}
			}
			
		  }	
	   ;

logic_expression returns [string name_line]: rel_expression {
			writeIntoparserLogFile("Line " + to_string($rel_expression.start->getLine()) + ": logic_expression : rel_expression\n");
			writeIntoparserLogFile($rel_expression.text + "\n");
			$name_line = $rel_expression.name_line;
		    
	
		  }
		 | re=rel_expression LOGICOP ree=rel_expression {
			writeIntoparserLogFile("Line " + to_string($ree.start->getLine()) + ": logic_expression : rel_expression LOGICOP rel_expression\n");
			writeIntoparserLogFile($re.text  + $LOGICOP.text  + $ree.text + "\n");
			$name_line = $re.name_line + " " + $LOGICOP.text + " " + $ree.name_line;
			if($LOGICOP.text=="&&") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, 0");
				emit("    JE L" + to_string(label+2));
				emit("    CMP DX, 0");
				emit("    JE L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
			else if($LOGICOP.text=="||") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");	
				stackCount--;	
				emit("    CMP AX, 1");
				emit("    JE L" + to_string(label+1));
				emit("    CMP DX, 1");
				emit("    JE L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
		}
		 ;

rel_expression	returns [string name_line]: simple_expression {
			writeIntoparserLogFile("Line " + to_string($simple_expression.start->getLine()) + ": rel_expression : simple_expression\n");
			writeIntoparserLogFile($simple_expression.text + "\n");
			$name_line = $simple_expression.name_line;
			
	
		  }
		| se=simple_expression RELOP sie=simple_expression {
			writeIntoparserLogFile("Line " + to_string($sie.start->getLine()) + ": rel_expression : simple_expression RELOP simple_expression\n");
			writeIntoparserLogFile($se.text + " " + $RELOP.text + " " + $sie.text + "\n");
			$name_line = $se.name_line + " " + $RELOP.text + " " + $sie.name_line;
			if($RELOP.text=="<=") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, DX");
				emit("    JLE L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
		  	}	
			else if($RELOP.text=="<") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, DX");
				emit("    JL L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text==">=") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, DX");
				emit("    JGE L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text==">") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, DX");
				emit("    JG L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text=="!=") {
				 emit("    POP AX");
				 stackCount--;
				 emit("    MOV DX, AX");
				 emit("    POP AX");
				 stackCount--;
				 emit("    CMP AX, DX");
				 emit("    JNE L" + to_string(label+1));
				 emit("    JMP L" + to_string(label+2));
				 newLabel();
				 emit("    MOV AX, 1");
				 emit("    JMP L" + to_string(label+2));
				 newLabel();
				 emit("    MOV AX, 0");
				 newLabel();
				 emit("    PUSH AX");
				 stackCount++;	
			}
			else if($RELOP.text=="==") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV DX, AX");
				emit("    POP AX");
				stackCount--;
				emit("    CMP AX, DX");
				emit("    JE L" + to_string(label+1));
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 1");
				emit("    JMP L" + to_string(label+2));
				newLabel();
				emit("    MOV AX, 0");
				newLabel();
				emit("    PUSH AX");
				stackCount++;
			}
		}

		;
				
simple_expression returns [string name_line]: term {
			writeIntoparserLogFile("Line " + to_string($term.start->getLine()) + ": simple_expression : term\n");
			writeIntoparserLogFile($term.text + "\n"); 
			$name_line=$term.name_line;
			
			
		  }
		  | se=simple_expression ADDOP t=term {
			writeIntoparserLogFile("Line " + to_string($t.start->getLine()) + ": simple_expression : simple_expression ADDOP term\n");
			writeIntoparserLogFile($se.text  + $ADDOP.text + $t.text + "\n");
			$name_line = $se.name_line  + $ADDOP.text  + $t.name_line;
			emit("    POP AX");
			stackCount--;
			emit("    MOV DX, AX");
			emit("    POP AX");
			stackCount--;
			if($ADDOP.text=="+") {
				emit("    ADD AX, DX");
				emit("    PUSH AX");
				stackCount++;
				value1+=value2;
				hold.push(to_string(value1));
			}
			else if($ADDOP.text=="-") {
				emit("    SUB AX, DX");
				emit("    PUSH AX");
				stackCount++;
				value1-=value2;
				hold.push(to_string(value1));
			}
		  }
		  ;
					
term returns [string name_line] :	unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": term : unary_expression\n");
			writeIntoparserLogFile($unary_expression.text + "\n");
			$name_line=$unary_expression.name_line;
			
	}
     |  t=term MULOP unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": term : term MULOP unary_expression\n");
			writeIntoparserLogFile($t.text + $MULOP.text  + $unary_expression.text + "\n");

			if($MULOP.text=="*") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV CX,AX");
				emit("    POP AX");
				stackCount--;
				emit("    CWD");
				emit("    MUL CX");
				emit("    PUSH AX");
				stackCount++;
			}
			else if($MULOP.text=="/") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV CX,AX");
				emit("    POP AX");
				stackCount--;
				emit("    CWD");
				emit("    DIV CX");
				emit("    PUSH AX");
				stackCount++;
			}
			else if($MULOP.text=="%") {
				emit("    POP AX");
				stackCount--;
				emit("    MOV CX,AX");
				emit("    POP AX");
				stackCount--;
				emit("    CWD");
				emit("    DIV CX");
				emit("    MOV AX, DX");
				emit("    PUSH AX");
				stackCount++;
			}
	 };

unary_expression returns [string name_line] : ADDOP unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": unary_expression : ADDOP unary_expression\n");
			writeIntoparserLogFile($ADDOP.text + $unary_expression.text + "\n");
			$name_line = $ADDOP.text + $unary_expression.text;
			if($ADDOP.text=="-") {
				emit("    POP AX");
				stackCount--;
				emit("    NEG AX");
				emit("    PUSH AX");
				stackCount++;
			}

		  } 
		 | NOT unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": unary_expression : NOT unary_expression\n");
			writeIntoparserLogFile("!" + $unary_expression.text + "\n");
			$name_line = "!" + $unary_expression.text;
		  }
		 | factor {
			writeIntoparserLogFile("Line " + to_string($factor.start->getLine()) + ": unary_expression : factor\n");
			writeIntoparserLogFile($factor.text + "\n");
			$name_line = $factor.name_line;

			
		  }
		 ;


	
factor returns [string name_line]	: variable {
			writeIntoparserLogFile("Line " + to_string($variable.start->getLine()) + ": factor : variable\n");
			writeIntoparserLogFile($variable.text + "\n");
			$name_line = $variable.name_line;
			size_t pos = $variable.text.find('[');
				
			if (pos != string::npos) {
				string varName = $variable.text.substr(0, pos);
				SymbolInfo *sym = symbolTable->LookUp(varName);
				if(sym->isArray) {
					if(sym->isGlobal) {
						//emit("    MOV AX, " + varName);
						emit("    POP BX");
						stackCount--;
						emit("    SHL BX, 1");
						
						emit("    MOV AX, "+varName+ "[BX]");
						emit("    PUSH AX");
						stackCount++;
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						//emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
						emit("    POP BX");
						stackCount--;
						emit("    SHL BX, 1");
						emit("    SUB BX, "+ to_string((spCount) * 2));
						//emit("    MOV AX, [AX]");
						emit("    MOV SI, BX");
						emit("    MOV AX, [BP + SI]");
						emit("    PUSH AX");
						stackCount++;
					}
				}
				
			}
			else{
			SymbolInfo *sym=symbolTable->LookUp($variable.text);
			if(sym->isGlobal){
				emit("    MOV AX, " + $variable.text);
				emit("    PUSH AX");
				stackCount++;
			}
			else if(!sym->isGlobal){
				emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
				emit("    PUSH AX");
				stackCount++;
			}
			}
		  }
	| ID LPAREN argument_list RPAREN {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": factor : ID LPAREN argument_list RPAREN\n");
			writeIntoparserLogFile($ID.text + "(" + $argument_list.text + ")\n");
			$name_line = $ID.text + "(" + $argument_list.text + ")";
			SymbolInfo *sym = symbolTable->LookUp($ID.text);
			int count = 0;
			//if(sym->isFunction) {
			// 	for(int i = 0;i<sym->paramCount;i++){
			// 		string temp=sym->paramTypes[i];
			// 		SymbolInfo *sym1 = symbolTable->LookUp(temp);
			// 		if(sym1->isGlobal) {
			// 			emit("    MOV AX, " + temp);
			// 			emit("    PUSH AX");
			// 		}
			// 		else if(!sym1->isGlobal) {
			// 			emit("    MOV AX, [BP - " + to_string(sym1->offset) + "]");
			// 			emit("    PUSH AX");
			// 		}
			// 		count++;
			// 	}

			// }
			emit("    CALL " + $ID.text);
			emit("    ADD SP, " + to_string(sym->paramCount * 2));

			emit("    PUSH AX");
			stackCount++;
			if(sym->returnType == "void"){
				emit("    POP AX");
				stackCount--;
			}
	}
	| LPAREN expression RPAREN {
			writeIntoparserLogFile("Line " + to_string($expression.start->getLine()) + ": factor : LPAREN expression RPAREN\n");
			writeIntoparserLogFile("(" + $expression.text + ")\n");
			$name_line = "(" + $expression.text + ")";
		  }
	| CONST_INT {
			writeIntoparserLogFile("Line " + to_string($CONST_INT->getLine()) + ": factor : CONST_INT\n");
			writeIntoparserLogFile($CONST_INT.text + "\n");
			$name_line = $CONST_INT.text;
			hold.push($CONST_INT.text);
			emit("    MOV AX, " + $CONST_INT.text);
			emit("    PUSH AX");
			stackCount++;
		  }
	| CONST_FLOAT {


			writeIntoparserLogFile("Line " + to_string($CONST_FLOAT->getLine()) + ": factor : CONST_FLOAT\n");
			writeIntoparserLogFile($CONST_FLOAT.text + "\n");
			$name_line = $CONST_FLOAT.text;

		  }
	| variable INCOP {
		writeIntoparserLogFile("Line " + to_string($INCOP->getLine()) + ": factor : variable INCOP\n");
		writeIntoparserLogFile($variable.text + "++\n");
		$name_line = $variable.text + "++";
		size_t pos = $variable.text.find('[');
				
			if (pos != string::npos) {
				string varName = $variable.text.substr(0, pos);
				SymbolInfo *sym = symbolTable->LookUp(varName);
				if(sym->isArray) {
					if(sym->isGlobal) {
						//emit("    MOV AX, " + varName);
						emit("    POP BX");
						stackCount--;
						emit("    SHL BX, 1");
						
						emit("    MOV AX, "+varName+ "[BX]");
						emit("    INC AX");
						emit("    MOV "+varName+ "[BX], AX");
						emit("    PUSH AX");
						stackCount++;
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						//emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
						emit("    POP BX");
						stackCount--;
						emit("    SHL BX, 1");
						emit("    SUB BX, "+ to_string((spCount) * 2));
						//emit("    MOV AX, [AX]");
						emit("    MOV SI, BX");
						emit("    MOV AX, [BP + SI]");
						emit("    PUSH AX");
						stackCount++;
					}
				}
				
			}
			else{
		SymbolInfo *sym = symbolTable->LookUp($variable.text);
		if(sym->isGlobal) {
			emit("    MOV AX, " + $variable.text);
			emit("    PUSH AX");
			stackCount++;
			emit("    INC AX");
			emit("    MOV " + $variable.text + ", AX");	
			emit("    POP AX");
			stackCount--;
			
			
		}
		else if(!sym->isGlobal) {
			emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
			emit("    PUSH AX");
			stackCount++;
			emit("    INC AX");
			emit("    MOV [BP - " + to_string(sym->offset) + "], AX");
			emit("    POP AX");
			stackCount--;
			
			
		}
			}
		
	}
	| variable DECOP{
		writeIntoparserLogFile("Line " + to_string($DECOP->getLine()) + ": factor : variable DECOP\n");
  		writeIntoparserLogFile($variable.text + "--\n");
		$name_line = $variable.text + "--";
		SymbolInfo *sym = symbolTable->LookUp($variable.text);
		if(sym->isGlobal) {
			emit("    MOV AX, " + $variable.text);
			emit("    PUSH AX");
			stackCount++;
			emit("    DEC AX");
			emit("    MOV " + $variable.text + ", AX");	
			emit("    POP AX");
			stackCount--;
		}
		else if(!sym->isGlobal) {
			emit("    MOV AX, [BP - " + to_string(sym->offset) + "]");
			emit("    PUSH AX");
			stackCount++;
			emit("    DEC AX");
			emit("    MOV [BP - " + to_string(sym->offset) + "], AX");
			emit("    POP AX");
			stackCount--;
		}

	}
	;
	
argument_list returns [string name_line] : a=arguments {
			writeIntoparserLogFile("Line " + to_string($a.start->getLine()) + ": argument_list : arguments\n");
			writeIntoparserLogFile($a.text + "\n");
			$name_line = $a.name_line;
		  }
			  |
			  ;
	
arguments returns [string name_line] : a=arguments COMMA logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": arguments : arguments COMMA logic_expression\n");
			writeIntoparserLogFile($a.text + "," + $logic_expression.text + "\n");
			$name_line = $a.text + "," + $logic_expression.text;
	      }
	      | logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": arguments : logic_expression\n");
			writeIntoparserLogFile($logic_expression.text + "\n");
			$name_line = $logic_expression.text; 
	      }
	      ;

