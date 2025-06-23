parser grammar C8086Parser;

options {
    tokenVocab = C8086Lexer;
}

@parser::header {

    #include <fstream>
    #include <cstdlib>
    #include "C8086Lexer.h"
	#include "2105081_symbol_table.h"

    extern ofstream parserLogFile;
    extern ofstream errorFile;

    extern int syntaxErrorCount;
	extern vector<pair<string,string>> temp;
	extern vector<string> forargs;
}

@parser::members {
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
}


start : program
	{
		symbolTable->printAllScopeTable(parserLogFile);

        writeIntoparserLogFile("Total number of lines: " + to_string($program.stop->getLine()));
		writeIntoparserLogFile("Total number of errors: " + to_string(syntaxErrorCount));
		
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
     | func_definition {
		writeIntoparserLogFile("Line " + to_string($func_definition.stop->getLine()) + ": unit : func_definition\n");
		writeIntoparserLogFile($func_definition.name_Line + "\n");
		$name_Line = $func_definition.name_Line;
	  }
     ;
     
func_declaration  returns [string  name_Line]: type_specifier ID LPAREN pl=parameter_list RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($pl.stop->getLine()) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
			writeIntoparserLogFile($type_specifier.text + " " + $ID.text + "(" + $pl.text + ");\n");
			$name_Line = $type_specifier.text + " " + $ID.text + "(" + $pl.text + ");";
			// Insert function into symbol table
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
			sym->paramCount = 0; // No parameters
		}
		;
		 
func_definition returns [string name_Line]: ts=type_specifier ID LPAREN pl=parameter_list{
			if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				if(!sym->isFunction) {
					writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+ "\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text + "\n");
				} 
				else if(sym->paramCount != $pl.count) {
					writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Total number of arguments mismatch with declaration in function " + $ID.text + "\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Total number of arguments mismatch with declaration in function " + $ID.text + "\n");
				}
				else if(sym->returnType != $ts.type) {
					writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Return type mismatch of "+ $ID.text+ "\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Return type mismatch of "+ $ID.text +"\n");
				}
			} else {
				symbolTable->insert(parserLogFile, $ID.text,"ID");
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				sym->isFunction = true;
				sym->returnType = $ts.type;
				sym->paramCount = $pl.count;
				
				for (const auto& name : $pl.names) {
					sym->paramTypes.push_back(name.first);
				}
			}
			$pl.names.clear();
			

		}	
		 RPAREN cs=compound_statement {

			if($ts.text=="void" && $cs.type!="void"){
				writeIntoErrorFile("Error at line "+to_string($cs.stop->getLine()) +": Cannot return value from function " + $ID.text + " with void return type\n");
				writeIntoparserLogFile("Error at line "+to_string($cs.stop->getLine()) +": Cannot return value from function  " + $ID.text + " with void return type\n");
				syntaxErrorCount++;
			}

			writeIntoparserLogFile("Line " + to_string($cs.stop->getLine()) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			writeIntoparserLogFile($ts.text + " " + $ID.text + "(" + $pl.name_Line + ")"+$cs.text + "\n");
			
			$name_Line = $ts.text + " " + $ID.text + "(" + $pl.name_Line + ")" + $cs.name_Line;
			// for (const auto& name : $pl.names) {
			// 	symbolTable->insert(parserLogFile, name.second, name.first);
			// }
			//symbolTable->exitScope();
		}
		| ts=type_specifier ID LPAREN{
		if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				
				if(sym->returnType != $ts.type) {
					writeIntoErrorFile("Error at Line "+to_string($ID->getLine()) +" Function " + $ID.text + " already declared with different return type");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at Line "+to_string($ID->getLine()) +" Function " + $ID.text + " already declared with different return type\n");
				}
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
		}
 		;				


parameter_list returns [vector<pair<string,string>> names,string name_Line,int count]: pl=parameter_list COMMA ts=type_specifier ID{
			
			$name_Line = $pl.text + "," + $ts.text + " " + $ID.text;
			$names = $pl.names;
			$count = $pl.count + 1;
			bool found = false;
			for(auto &name:temp){
				if(name.second == $ID.text) {
					found = true;
					break;
				}
			}
			if(found){
				//writeIntoparserLogFile("hello");
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+" in parameter"+ "\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+" in parameter"+ "\n");
			} else {
				$names.push_back(make_pair($ts.type, $ID.text));
				temp.push_back(make_pair($ts.text,$ID.text));
			}
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
			for (const auto& name : temp) {
				if(symbolTable->find_current(name.second)) {
					writeIntoErrorFile("Error at Line "+to_string($LCURL->getLine()) +" Multiple declaration of " + name.second);
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at Line "+to_string($LCURL->getLine()) +" Multiple declaration of " + name.second + "\n");
				}
				else{
					symbolTable->insert(parserLogFile, name.second, "ID");
					SymbolInfo *sym = symbolTable->LookUp(name.second);
					sym->Idtype=name.first;
					//writeIntoparserLogFile("Inserted variable: " + name.second + "\n");
				}
			}
			temp.clear(); // Clear temp to avoid memory leak 
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
			// for (const auto& name : temp) {
			// 	symbolTable->insert(parserLogFile, name, "ID");
			// } 
			// temp.clear(); // Clear temp to avoid memory leak
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
		if($ts.text=="void"){
			writeIntoparserLogFile("Error at line "+to_string($ts.start->getLine()) +": Variable type cannot be void\n");
			writeIntoErrorFile("Error at line "+to_string($ts.start->getLine()) +": Variable type cannot be void\n");
			syntaxErrorCount++;
		}
        $name_Line = $ts.text + " " + $dl.text + ";";
		writeIntoparserLogFile($ts.text+" "+$dl.text+";"+"\n");
		for (const auto& name : $dl.names) {
			if(name.second=="array") {
				symbolTable->insert(parserLogFile,name.first, "ID");
				SymbolInfo *sym=symbolTable->LookUp(name.first);
				sym->isArray=true;
				//writeIntoparserLogFile("Inserted array: " + name.first + "\n");
				sym->Idtype=$ts.type;
			
			}
			else{
				symbolTable->insert(parserLogFile,name.first,name.second);
				SymbolInfo *sym=symbolTable->LookUp(name.first);
				sym->Idtype=$ts.type;
				//writeIntoparserLogFile("Inserted variable: " + name.first + "\n");
			}
		}
		$dl.names.clear(); // Clear names to avoid memory leak
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
			if(symbolTable->find_current($id.text)) {
				writeIntoErrorFile("Error at line "+to_string($id->getLine()) +": Multiple declaration of " + $id.text+"\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($id->getLine()) +" Multiple declaration of " + $id.text + "\n");
			}
			else{
				$names.push_back({$id.text,"ID"});
			}
		  }
 		  | dl=declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
			writeIntoparserLogFile($dl.text+","+$ID.text + "[" + $CONST_INT.text + "]\n");
			$names = $dl.names;
			//$names.push_back({$ID.text,"array"} );
			if(symbolTable->find_current($ID.text)) {
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+"\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +" Multiple declaration of " + $ID.text + "\n");
			}
			else{
				$names.push_back({$ID.text,"array"} );
		  	}
		  }
 		  | ID{
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : ID\n");
			writeIntoparserLogFile($ID.text + "\n");
			//$names.push_back({$ID.text,"ID"});
			if(symbolTable->find_current($ID.text)) {
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+"\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text + "\n");
			}
			else{
				$names.push_back({$ID.text,"ID"} );
		  	}
		  }
 		  | ID LTHIRD CONST_INT RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
			writeIntoparserLogFile($ID.text + "[" + $CONST_INT.text + "]\n");
			//$names.push_back({$ID.text,"array"} );
			if(symbolTable->find_current($ID.text)) {
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+"\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Multiple declaration of " + $ID.text+"\n");
			}
			else{
				$names.push_back({$ID.text,"array"} );
		  	}
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
			$type = $statement.type;
		  }
	   | st=statements statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statements : statements statement\n");
			writeIntoparserLogFile($st.name_Line  + $statement.name_Line );
			$name_Line = $st.name_Line + $statement.name_Line;
			$type = $statement.type;
		  }
	   ;
	   
statement returns [string name_Line,string type]: var_declaration {
			writeIntoparserLogFile("Line " + to_string($var_declaration.stop->getLine()) + ": statement : var_declaration\n");
			writeIntoparserLogFile($var_declaration.name_Line + "\n");
			$name_Line = $var_declaration.name_Line + "\n";
			$type="void";
		  }
	  | expression_statement {
			writeIntoparserLogFile("Line " + to_string($expression_statement.stop->getLine()) + ": statement : expression_statement\n");
			writeIntoparserLogFile($expression_statement.text + "\n");
			$name_Line = $expression_statement.text + "\n";
			$type="void";
		  }
	  | compound_statement{
			writeIntoparserLogFile("Line " + to_string($compound_statement.stop->getLine()) + ": statement : compound_statement\n");
   			writeIntoparserLogFile($compound_statement.name_Line + "\n");
			$name_Line = $compound_statement.name_Line;
			$type="void";
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
			writeIntoparserLogFile("for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			$type="void";
		  }
	  | IF LPAREN expression RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			$type="void";
		  }
	  | IF LPAREN expression RPAREN statement ELSE s=statement {
			writeIntoparserLogFile("Line " + to_string($s.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}";
			$type="void";
		  }
	  | WHILE LPAREN expression RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : WHILE LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			$type="void";
		  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
			writeIntoparserLogFile("println(" + $ID.text + ");\n");
			$name_Line = "println(" + $ID.text + ");\n";
			$type="void";
			if(!symbolTable->find($ID.text)){
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Undeclared variable " + $ID.text +"\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Undeclared variable " + $ID.text + "\n");
				$type = "error";
			}
			
		  }
	  | RETURN e=expression SEMICOLON {
			writeIntoparserLogFile("Line " + to_string($e.stop->getLine()) + ": statement : RETURN expression SEMICOLON\n");
			writeIntoparserLogFile("return " + $e.text + ";\n");
			$name_Line = "return " + $e.text + ";\n";
			$type=$e.text;
		  }
	  ;

expression_statement 	: SEMICOLON	{
			writeIntoparserLogFile("Line " + to_string($SEMICOLON->getLine()) + ": expression_statement : SEMICOLON\n");
			writeIntoparserLogFile(";\n");
	   		}			
			| expression SEMICOLON {
			writeIntoparserLogFile("Line " + to_string($expression.start->getLine()) + ": expression_statement : expression SEMICOLON\n");
			writeIntoparserLogFile($expression.text + ";\n");
		  }
			;
	  
variable returns [string name_line,string type] : ID {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": variable : ID\n");
			if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				if(sym->isArray) {
					writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Type mismatch, "+$ID.text+" is an array\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) + ": Type mismatch, "+$ID.text+" is an array\n");
					$type = "error";
				}
				else{
					$type = sym->Idtype;
				}	
			}
		
			 else {
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Undeclared variable " + $ID.text + "\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Undeclared variable " + $ID.text + "\n");
				$type = "error";
			}
			writeIntoparserLogFile($ID.text + "\n");
			$name_line = $ID.text;
		  }	
	 | ID LTHIRD expression RTHIRD {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": variable : ID LTHIRD expression RTHIRD\n");
			writeIntoparserLogFile($ID.text + "[" + $expression.text + "]\n");
			if($expression.type != "int") {
				writeIntoErrorFile("Error at line "+to_string($expression.start->getLine()) +": Expression inside third brackets not an integer\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($expression.start->getLine()) +": Expression inside third brackets not an integer\n");

			}
			if(symbolTable->find($ID.text)){
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				if(!sym->isArray) {
					writeIntoErrorFile("Error at line "+to_string($ID->getLine())+": "+$ID.text+" not an array\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) + ": "+$ID.text+" not an array\n");
				}
				$type = sym->Idtype;
				//writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +" Array index must be a constant integer");
			}
			$name_line = $ID.text + "[" + $expression.text + "]";
		  }
	 ;
	 
expression returns [string name_line,string type]: logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": expression : logic_expression\n");
			writeIntoparserLogFile($logic_expression.text + "\n");
			$type = $logic_expression.type; // Pass the type from logic_expression
			$name_line = $logic_expression.name_line;
		  }	
	   | variable ASSIGNOP logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": expression : variable ASSIGNOP logic_expression\n");
			writeIntoparserLogFile($variable.text + "=" + $logic_expression.text + "\n");
			//$type = $logic_expression.type; // Pass the type from logic_expression
			if($logic_expression.type=="error" || $variable.type=="error"){

			}
			else if($variable.type == "float" && $logic_expression.type !="void"){}
			else if($logic_expression.type == "void") {
	  				writeIntoErrorFile("Error at line "+to_string($logic_expression.start->getLine()) +": Void function used in expression" + "\n");
	  				syntaxErrorCount++;
	  				writeIntoparserLogFile("Error at line "+to_string($logic_expression.start->getLine()) +": Void function used in expression" +  "\n");
			}
			
			else if($variable.type != $logic_expression.type) {
				writeIntoErrorFile("Error at line "+to_string($logic_expression.start->getLine()) +": Type Mismatch"+ "\n") ;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($logic_expression.start->getLine()) +": Type Mismatch"+ "\n");
			}
			else if(symbolTable->find($variable.text)) {
				SymbolInfo *sym = symbolTable->LookUp($variable.text);

				if((sym->Idtype == "float") && ($logic_expression.type == "int" ||$logic_expression.type == "float")) {

				}

				else if(sym->Idtype != $logic_expression.type) {
					//writeIntoErrorFile(sym->getName() + " is of type  " + sym->Idtype + " but assigned value is of type " + $logic_expression.type);
					writeIntoErrorFile("Error at line "+to_string($logic_expression.start->getLine()) +": Type Mismatch" + "\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($logic_expression.start->getLine()) +": Type Mismatch" + "\n");
					
				}
			}
		  }	
	   ;
			
logic_expression returns [string name_line,string type]: rel_expression {
			writeIntoparserLogFile("Line " + to_string($rel_expression.start->getLine()) + ": logic_expression : rel_expression\n");
			writeIntoparserLogFile($rel_expression.text + "\n");
			$type = $rel_expression.type; 
			$name_line = $rel_expression.name_line;
		    
	
		  }
		 | re=rel_expression LOGICOP ree=rel_expression {
			writeIntoparserLogFile("Line " + to_string($ree.start->getLine()) + ": logic_expression : rel_expression LOGICOP rel_expression\n");
			writeIntoparserLogFile($re.text  + $LOGICOP.text  + $ree.text + "\n");
			$type = $rel_expression.type;
			$name_line = $re.name_line + " " + $LOGICOP.text + " " + $ree.name_line;
		  } 	
		 ;
			
rel_expression	returns [string name_line,string type]: simple_expression {
			writeIntoparserLogFile("Line " + to_string($simple_expression.start->getLine()) + ": rel_expression : simple_expression\n");
			writeIntoparserLogFile($simple_expression.text + "\n");
			$type = $simple_expression.type;
			$name_line = $simple_expression.name_line;
			
	
		  }
		| se=simple_expression RELOP sie=simple_expression {
			writeIntoparserLogFile("Line " + to_string($sie.start->getLine()) + ": rel_expression : simple_expression RELOP simple_expression\n");
			writeIntoparserLogFile($se.text + " " + $RELOP.text + " " + $sie.text + "\n");
			$type = $simple_expression.type; 
			$name_line = $se.name_line + " " + $RELOP.text + " " + $sie.name_line;
		  }	
		;
				
simple_expression returns [string name_line,string type]: term {
			writeIntoparserLogFile("Line " + to_string($term.start->getLine()) + ": simple_expression : term\n");
			writeIntoparserLogFile($term.text + "\n");
			$type = $term.type; 
			$name_line=$term.name_line;
			
		  }
		  | se=simple_expression ADDOP t=term {
			writeIntoparserLogFile("Line " + to_string($t.start->getLine()) + ": simple_expression : simple_expression ADDOP term\n");
			writeIntoparserLogFile($se.text  + $ADDOP.text + $t.text + "\n");
			$type = $term.type;
			$name_line = $se.name_line  + $ADDOP.text  + $t.name_line;
		  }
		  | simple_expression ADDOP ASSIGNOP {
			writeIntoparserLogFile("Error at line "+to_string($ASSIGNOP->getLine())+": syntax error, unexpected ASSIGNOP\n");
			writeIntoErrorFile("Error at line "+to_string($ASSIGNOP->getLine())+": syntax error, unexpected ASSIGNOP\n");
			syntaxErrorCount++;
			$type="error";
		  }
		  ;
					
term returns [string name_line,string type] :	unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": term : unary_expression\n");
			writeIntoparserLogFile($unary_expression.text + "\n");
			$type = $unary_expression.type;
			$name_line=$unary_expression.name_line;
			
	}
     |  t=term MULOP unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": term : term MULOP unary_expression\n");
			writeIntoparserLogFile($t.text + $MULOP.text  + $unary_expression.text + "\n");

			if($t.type == "float" || $unary_expression.type == "float") {
				$type = "float";
			}
			else{
				$type="int";
			}

			if($MULOP.text=="%" && $unary_expression.text=="0"){
				writeIntoErrorFile("Error at Line "+to_string($unary_expression.start->getLine()) +": Modulus by Zero\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at Line "+to_string($unary_expression.start->getLine()) +": Modulus by Zero\n");
				$type="error";
			}

			else if( $MULOP.text=="/" && $unary_expression.text=="0"){
				writeIntoErrorFile("Error at Line "+to_string($unary_expression.start->getLine()) +": Non-Integer operand on modulus operator\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at Line "+to_string($unary_expression.start->getLine()) +": Non-Integer operand on modulus operator\n");
				$type="error";
			}

			else if($MULOP.text=="%" && $unary_expression.type=="float"){
				writeIntoErrorFile("Error at line "+to_string($unary_expression.start->getLine()) +": Non-Integer operand on modulus operator\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($unary_expression.start->getLine()) +": Non-Integer operand on modulus operator\n");
				$type="error";
			}
			
			else if($unary_expression.text=="0")
				   {
					writeIntoErrorFile("Error at line "+to_string($unary_expression.start->getLine()) +": Division by zero in expression\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($unary_expression.start->getLine()) +": Division by zero in expression\n");
					$type="error";
   			}
			// else if($unary_expression.type == "float"){
			// 	writeIntoErrorFile("Error at line "+to_string($unary_expression.start->getLine()) +": Float function used in expression\n");
			// 	syntaxErrorCount++;
			// 	writeIntoparserLogFile("Error at line "+to_string($unary_expression.start->getLine()) +": Float function used in expression\n");
			// 	$type="error";
			// }
			else if($t.type != $unary_expression.type) {
				if($unary_expression.type == "void"){
					writeIntoErrorFile("Error at line "+to_string($unary_expression.start->getLine()) +": Void function used in expression\n");
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($unary_expression.start->getLine()) +": Void function used in expression\n");
					$type="error";
				}
			}
			
			
          };

unary_expression returns [string name_line,string type] : ADDOP unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": unary_expression : ADDOP unary_expression\n");
			writeIntoparserLogFile($ADDOP.text + $unary_expression.text + "\n");
			$type = $unary_expression.type;
			$name_line = $ADDOP.text + $unary_expression.text;
		  } 
		 | NOT unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": unary_expression : NOT unary_expression\n");
			writeIntoparserLogFile("!" + $unary_expression.text + "\n");
			$name_line = "!" + $unary_expression.text;
			$type = $unary_expression.type;
		  }
		 | factor {
			writeIntoparserLogFile("Line " + to_string($factor.start->getLine()) + ": unary_expression : factor\n");
			writeIntoparserLogFile($factor.text + "\n");
			$type = $factor.type;
			$name_line = $factor.name_line;

			
		  }
		 ;
	
factor returns [string name_line,string type]	: variable {
			writeIntoparserLogFile("Line " + to_string($variable.start->getLine()) + ": factor : variable\n");
			writeIntoparserLogFile($variable.text + "\n");
			$type = $variable.type;
			$name_line = $variable.name_line;
		  }
	| ID LPAREN argument_list RPAREN {
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": factor : ID LPAREN argument_list RPAREN\n");
			writeIntoparserLogFile($ID.text + "(" + $argument_list.text + ")\n");
			$name_line = $ID.text + "(" + $argument_list.text + ")";
			$type= $argument_list.type;
			if($ID.text == "scanf" || $ID.text == "printf") {
			} 

			else if($argument_list.type=="error"){
				
			}
			
			else if(!symbolTable->find($ID.text)){
				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Undefined function " + $ID.text + "\n");
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Undefined function " + $ID.text + "\n");
				$type = "error";
   	   		} 
			else{
				SymbolInfo *sym = symbolTable->LookUp($ID.text);
				if(sym->isFunction) {
					$type = sym->returnType;
	 				if(sym->paramCount != forargs.size()) {
	  					writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": Total number of arguments mismatch with declaration in function"+ " " + $ID.text + "\n");
	  					syntaxErrorCount++;
	  					writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": Total number of arguments mismatch with declaration in function"+ " " + $ID.text + "\n");
						$type="error";
	 				}
	 				else {
	  					for(int i=0;i<sym->paramCount;i++) {
	   						if(sym->paramTypes[i] != forargs[i]) {
								
								writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +": "+to_string(i+1)+"th argument mismatch in function "+$ID.text+"\n");
								syntaxErrorCount++;
		 						writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +": "+to_string(i+1)+"th argument mismatch in function "+$ID.text+"\n");
								$type="error";
								break;
	   						}
	  					}
	 				}
					
				} else {
	 				writeIntoErrorFile("Error at line "+to_string($ID->getLine()) +" " + $ID.text + " is not a function");
	 				syntaxErrorCount++;
	 				writeIntoparserLogFile("Error at line "+to_string($ID->getLine()) +" " + $ID.text + " is not a function\n");
				}
			}
			forargs.clear();
		}
	| LPAREN expression RPAREN {
			writeIntoparserLogFile("Line " + to_string($expression.start->getLine()) + ": factor : LPAREN expression RPAREN\n");
			writeIntoparserLogFile("(" + $expression.text + ")\n");
			$type = $expression.type;
			$name_line = "(" + $expression.text + ")";
		  }
	| CONST_INT {
			writeIntoparserLogFile("Line " + to_string($CONST_INT->getLine()) + ": factor : CONST_INT\n");
			writeIntoparserLogFile($CONST_INT.text + "\n");
			$type = "int";
			$name_line = $CONST_INT.text;
		  }
	| CONST_FLOAT {
			writeIntoparserLogFile("Line " + to_string($CONST_FLOAT->getLine()) + ": factor : CONST_FLOAT\n");
			writeIntoparserLogFile($CONST_FLOAT.text + "\n");
			$type = "float";
			$name_line = $CONST_FLOAT.text;

		  }
	| variable INCOP {
		writeIntoparserLogFile("Line " + to_string($INCOP->getLine()) + ": factor : variable INCOP\n");
		writeIntoparserLogFile($variable.text + "++\n");
		$name_line = $variable.text + "++";
		
	}
	| variable DECOP{
		writeIntoparserLogFile("Line " + to_string($DECOP->getLine()) + ": factor : variable DECOP\n");
  		writeIntoparserLogFile($variable.text + "--\n");
		$name_line = $variable.text + "--";
		
  
 	}	
	;
	
argument_list returns [string name_line,string type] : a=arguments {
			writeIntoparserLogFile("Line " + to_string($a.start->getLine()) + ": argument_list : arguments\n");
			writeIntoparserLogFile($a.text + "\n");
			$name_line = $a.name_line;
			$type = $a.type;
		  }
			  |
			  ;
	
arguments returns [string name_line,string type] : a=arguments COMMA logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": arguments : arguments COMMA logic_expression\n");
			writeIntoparserLogFile($a.text + "," + $logic_expression.text + "\n");
			$name_line = $a.text + "," + $logic_expression.text;
			$type = $a.type;
			if($logic_expression.type == "error"){
				$type = "error";
			}
			forargs.push_back($logic_expression.type);
	      }
	      | logic_expression {
			writeIntoparserLogFile("Line " + to_string($logic_expression.start->getLine()) + ": arguments : logic_expression\n");
			writeIntoparserLogFile($logic_expression.text + "\n");
			$name_line = $logic_expression.text;
			if($logic_expression.type =="error"){$type = "error";}
			forargs.push_back($logic_expression.type); 
	      }
	      ;

