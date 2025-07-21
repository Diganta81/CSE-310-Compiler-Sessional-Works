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
	extern std::ofstream optimizedCodeFile;

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

	void print(const std::string &line) {
        asmCodeFile << line << std::endl;
    }

	void print_output(){
		print("print_output proc  ;print what is in ax");
print("    push ax");
print("    push bx");
print("    push cx");
print("    push dx");
print("    push si");
print("    lea si,number");
print("    mov bx,10");
print("    add si,4");
print("    cmp ax,0");
print("    jnge negate");
print("    print:");
print("    xor dx,dx");
print("    div bx");
print("    mov [si],dl");
print("    add [si],'0'");
print("    dec si");
print("    cmp ax,0");
print("    jne print");
print("    inc si");
print("    lea dx,si");
print("    mov ah,9");
print("    int 21h");
print("    pop si");
print("    pop dx");
print("    pop cx");
print("    pop bx");
print("    pop ax");
print("    ret");
print("    negate:");
print("    push ax");
print("    mov ah,2");
print("    mov dl,'-'");
print("    int 21h");
print("    pop ax");
print("    neg ax");
print("    jmp print");
print("print_output endp");
	}

	void newLine(){
		print("new_line proc");
print("    push ax");
print("    push dx");
print("    mov ah,2");
print("    mov dl,0Dh");
print("    int 21h");
print("    mov ah,2");
print("    mov dl,0Ah");
print("    int 21h");
print("    pop dx");
print("    pop ax");
print("    ret");
print("new_line endp");
	}

	string trim(const string &str) {
    	int first=str.find_first_not_of(" \t\r\n");
    	int last=str.find_last_not_of(" \t\r\n");
    	return (first==string::npos) ? "" : str.substr(first,last-first+1);
	}
	
	vector<string> makeTokens(const string &line) {
    	stringstream ss(line);
    	string token;
    	vector<string> tokens;
    	while (ss >> token) {
        	token.erase(remove(token.begin(), token.end(), ','), token.end());
        	tokens.push_back(token); 
    	}
    	return tokens;
	}

	bool RedundantMOV(const string &line1, const string &line2) {
    	string t1= trim(line1);
    	string t2= trim(line2);
    	vector<string> temp1=makeTokens(t1);
    	vector<string> temp2=makeTokens(t2);
    	if(temp1.size()==3&&temp2.size()==3 && temp1[0]=="MOV" && temp2[0]=="MOV" && temp1[1]==temp2[2] && temp1[2]==temp2[1]) {
        	return true;
    	}
    	return false;
	}

	bool RedundantPushPop(const string &line1, const string &line2) {
        string t1= trim(line1);
        string t2= trim(line2);
        vector<string> temp1=makeTokens(t1);
        vector<string> temp2=makeTokens(t2);
        if(temp1.size()==2 && temp2.size()==2 && temp1[0]=="PUSH" && temp2[0]=="POP" && temp1[1]==temp2[1]) {
            return true;
        }
        return false;
    }

	bool NoOp(const string &line) {
        string t=trim(line);
        vector<string> tokens=makeTokens(t);
        if(tokens.size() != 3) {
            return false;
        }
        if(tokens[0] == "ADD" && tokens[1] == "AX" && tokens[2] == "0") {
            return true;
        }
        if(tokens[0] == "SUB" && tokens[1] == "AX" && tokens[2] == "0") {
            return true;
        }
        if(tokens[0] == "MUL" && tokens[1] == "AX" && tokens[2] == "1") {
            return true;
        }
        if(tokens[0] == "DIV" && tokens[1] == "AX" && tokens[2] == "1") {
            return true;
        }
        return false;
    
    }

	bool Label(const string &line) {
        string trimmed = trim(line);
        if(trimmed[trimmed.size() - 1]==':') {
            return true;
        }
        return false;
    }

	string replaceLabels(const string line, const unordered_map<string, string>labelMap) {
        vector<string> tokens=makeTokens(line);
        if (tokens.empty()) return line;
        string updatedLine=line;
        for (auto pair:labelMap) {
            string olds=pair.first;
            string news=pair.second;
            int pos=updatedLine.find(olds);
            if (pos != string::npos &&(pos == 0 || !isalnum(updatedLine[pos - 1])) &&(pos + olds.length() == updatedLine.length() || !isalnum(updatedLine[pos + olds.length()])))
            {
                updatedLine.replace(pos, olds.length(), news);
            }
        }
        return updatedLine;
    }

	void optimizeCode(){
		ifstream inputFile("output/Code.asm");
		
		vector<string> lines;
        string line;
        while (getline(inputFile,line)) {
            lines.push_back(line);
        }
        unordered_map<string, string> labelMap; 
        vector<string> changedLines;
        for (int i=0;i<lines.size(); ) {
            if (Label(lines[i])) {
                size_t j=i;
                vector<string> Group;
                while (j<lines.size() && Label(lines[j])) {
                    Group.push_back(trim(lines[j]));
                    j++; 
                }
                string l=Group.front();
                for (int k=1;k<Group.size();k++) {
                    string oldLabel=Group[k].substr(0,Group[k].length()-1);
                    string newLabel=l.substr(0,l.length()-1);
                    labelMap[oldLabel]=newLabel;
                }
                changedLines.push_back(l);
                i = j;
            } else {
                changedLines.push_back(lines[i]);
                i++;
            }
        }
        for (int i=0;i<changedLines.size();i++) {
            string curr=replaceLabels(changedLines[i],labelMap);
            if (i+1<changedLines.size()){
                string next=replaceLabels(changedLines[i+1],labelMap);
                if (RedundantMOV(curr, next)) {
                    optimizedCodeFile << curr << endl;
                    i++;
                    continue;
                }
                if (RedundantPushPop(curr, next)) {
                    i++;
                    continue;
                }
            }
            if (NoOp(curr)) {
                continue;
            }
            optimizedCodeFile<< curr << endl;
        }
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
print(cont);
 	} program
	{
		symbolTable->printAllScopeTable(parserLogFile);

        writeIntoparserLogFile("Total number of lines: " + to_string($program.stop->getLine()));
		writeIntoparserLogFile("Total number of errors: " + to_string(syntaxErrorCount));
		newLabel();
		print("    ADD SP, " + to_string(spCount * 2));
		print("    POP BP");
		stackCount--;
		print("    MOV AX, 4C00H");
		print("    INT 21H");
		print("main ENDP");
		newLine();
		print_output();
		print("END MAIN");
		optimizeCode();
		
		
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
		print(".CODE");
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
			temp.clear(); 
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
				print($ID.text + " PROC");
				print("    PUSH BP");
				stackCount++;
				print("    MOV BP, SP");
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
					print("    SUB SP, 2");
					print("    MOV AX, [BP+" + to_string(($pl.names.size()-i) * 2 + 2) + "]");
					
					print("	MOV [BP-" + to_string(($pl.names.size()-i) * 2) + "], AX");
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
			print("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
			print("    POP BP");
			stackCount--;
			print("    RET");
			print($ID.text + " ENDP");
			localVariableCount = 0;
			count=0;
			spCount = 0;
			
		}
		| ts=type_specifier ID{
		if ($ID.text == "main") {
            
            print("main PROC");
            print("    MOV AX, @DATA");
            print("    MOV DS, AX");
            print("    PUSH BP");
			stackCount++;
            print("    MOV BP, SP");
			Main = 1;
			
        }
		else{
			print($ID.text + " PROC");
			print("    PUSH BP");
			stackCount++;
			print("    MOV BP, SP");
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
				print("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
				print("    POP BP");
				stackCount--;
				print("    RET");
				print($ID.text + " ENDP");
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
					print(name.first + " DW " + size + " DUP 0000H");
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
					print(name.first + " DW " + "1 "  +"DUP " + "0000H ");
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
				print("    SUB SP, " + to_string(stoi(sizeofArray[0]) * 2));
				spCount += stoi(sizeofArray[0]);
				sizeofArray.erase(sizeofArray.begin());
			
			}
			else{
				symbolTable->insert(parserLogFile,name.first,name.second);
				SymbolInfo *sym=symbolTable->LookUp(name.first);
				sym->Idtype=$ts.type;
				print("    SUB SP, 2");
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
		print("L" + label1 + ":");
	  } expression_statement{
		print("    POP AX");
		stackCount--;
		print("    CMP AX, 0");
		print("    JE L" + label4);
		print("    JMP L" + label3);
		print("L" + label2 + ":");
	  } expression{
		
		print("    JMP L" + label1);
		print("L" + label3 + ":");
	  } RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
			writeIntoparserLogFile("for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "for(" + $expression_statement.text + $expression_statement.text + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			print("    JMP L" + label2);
			print("L" + label4 + ":");
		  }
	  |IF LPAREN expression RPAREN{
			print("    POP AX");
			stackCount--;
			print("    CMP AX, 1");
			
			string elseLabel =to_string(label+1);
			label++;
			print("    JNE L"+elseLabel);
			
			
	  } statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			
			print("L"+elseLabel+":");
		  }
	  | IF LPAREN expression RPAREN{
			print("    POP AX");
			stackCount--;
			print("    CMP AX, 1");
			
			string elseLabel =to_string(label+1);
			label++;
			string endLabel = to_string(label+1);
			label++;
			print("    JNE L"+elseLabel);
	  } statement{
		print("    JMP L"+endLabel);
		print("L"+elseLabel+":");
	  } ELSE s=statement {
			writeIntoparserLogFile("Line " + to_string($s.stop->getLine()) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n");
			writeIntoparserLogFile("if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}");
			$name_Line = "if(" + $expression.text + ") {\n" + $statement.name_Line + "\n} else {\n" + $s.name_Line + "\n}";
			print("L"+endLabel+":");

		  }
	  | WHILE{
			string label1=to_string(label+1);
			label++;
			string label2=to_string(label+1);
			label++;
	  } LPAREN{
		print("L" + label1 + ":");
	  } expression{
			//print(to_string(stackCount));
			if(stackCount==1){
				print("    PUSH AX");
				stackCount++;
			}
			print("    POP AX");
			stackCount--;
			print("    CMP AX, 0");
			print("    JE L" + label2);
	  } RPAREN statement {
			writeIntoparserLogFile("Line " + to_string($statement.stop->getLine()) + ": statement : WHILE LPAREN expression RPAREN statement\n");
			writeIntoparserLogFile("while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}");
			$name_Line = "while(" + $expression.text + ") {\n" + $statement.name_Line + "\n}";
			
			print("    JMP L" + label1);
			print("L" + label2 + ":");
		  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
			writeIntoparserLogFile("Line " + to_string($ID->getLine()) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
			writeIntoparserLogFile("println(" + $ID.text + ");\n");
			$name_Line = "println(" + $ID.text + ");\n";
			
			SymbolInfo *sym = symbolTable->LookUp($ID.text);
			if(sym->isGlobal) {
				newLabel();
				print("    MOV AX, " + $ID.text);
				print("    CALL print_output");
				print("    CALL new_line");
				
			}

			else{
				newLabel();
				print("    MOV AX, [BP - " + to_string(sym->offset) + "]");
				print("    CALL print_output");
				print("    CALL new_line");
				
			}
		  }
	  | RETURN e=expression SEMICOLON {
			writeIntoparserLogFile("Line " + to_string($e.stop->getLine()) + ": statement : RETURN expression SEMICOLON\n");
			writeIntoparserLogFile("return " + $e.text + ";\n");
			$name_Line = "return " + $e.text + ";\n";
			print("    POP AX");
			stackCount--;
			if(localVariableCount!=0 ){
				print("    ADD SP, " + to_string((localVariableCount+spCount) * 2) );
				print("    POP BP");
				stackCount--;
				print("    RET");
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
						print("    POP AX");
						print("    POP BX");
						print("    SHL BX, 1");
						print("    MOV "+varName+"[BX], AX"+"\t\t;Line:"+to_string($logic_expression.start->getLine()));
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						
						print("    POP AX");
						print("    POP BX");
						print("    SHL BX, 1");
						print("    SUB BX, "+to_string((spCount)*2));
						print("    MOV SI, BX\t\t;Line:"+to_string($logic_expression.start->getLine()));
						print("    MOV [BP+SI], AX");
					}
				}
				else{
				SymbolInfo *sym = symbolTable->LookUp($variable.text);
				if(sym->isGlobal) {
    				value = hold.top();
    				hold.pop();
					print("    POP AX");
					stackCount--;
    				print("    MOV " + $variable.text + ", AX"+"\t\t;Line:"+to_string($logic_expression.start->getLine()));
				}
				else if(!sym->isGlobal){
					print("    POP AX");
					stackCount--;
					print("    MOV [BP-" + to_string(sym->offset) + "], AX"+"\t\t;Line:"+to_string($logic_expression.start->getLine()));
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
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($ree.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, 0");
				print("    JE L" + to_string(label+2));
				print("    CMP DX, 0");
				print("    JE L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($ree.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($ree.start->getLine()));
				newLabel();
				print("    PUSH AX");
				stackCount++;
			}
			else if($LOGICOP.text=="||") {
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($ree.start->getLine()));
				print("    POP AX");	
				stackCount--;	
				print("    CMP AX, 1");
				print("    JE L" + to_string(label+1));
				print("    CMP DX, 1");
				print("    JE L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($ree.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($ree.start->getLine()));
				newLabel();
				print("    PUSH AX");
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
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, DX");
				print("    JLE L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				newLabel();
				print("    PUSH AX");
				stackCount++;
		  	}	
			else if($RELOP.text=="<") {
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, DX");
				print("    JL L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				newLabel();
				print("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text==">=") {
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, DX");
				print("    JGE L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				newLabel();
				print("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text==">") {
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, DX");
				print("    JG L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				newLabel();
				print("    PUSH AX");
				stackCount++;
			}
			else if($RELOP.text=="!=") {
				 print("    POP AX");
				 stackCount--;
				 print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				 print("    POP AX");
				 stackCount--;
				 print("    CMP AX, DX");
				 print("    JNE L" + to_string(label+1));
				 print("    JMP L" + to_string(label+2));
				 newLabel();
				 print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				 print("    JMP L" + to_string(label+2));
				 newLabel();
				 print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				 newLabel();
				 print("    PUSH AX");
				 stackCount++;	
			}
			else if($RELOP.text=="==") {
				print("    POP AX");
				stackCount--;
				print("    MOV DX, AX\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CMP AX, DX");
				print("    JE L" + to_string(label+1));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 1\t\t;Line:"+to_string($simple_expression.start->getLine()));
				print("    JMP L" + to_string(label+2));
				newLabel();
				print("    MOV AX, 0\t\t;Line:"+to_string($simple_expression.start->getLine()));
				newLabel();
				print("    PUSH AX");
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
			print("    POP AX");
			stackCount--;
			print("    MOV DX, AX\t\t;Line:"+to_string($t.start->getLine()));
			print("    POP AX");
			stackCount--;
			if($ADDOP.text=="+") {
				print("    ADD AX, DX\t\t;Line:"+to_string($t.start->getLine()));
				print("    PUSH AX");
				stackCount++;
				value1+=value2;
				hold.push(to_string(value1));
			}
			else if($ADDOP.text=="-") {
				print("    SUB AX, DX\t\t;Line:"+to_string($t.start->getLine()));
				print("    PUSH AX");
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
				print("    POP AX");
				stackCount--;
				print("    MOV CX,AX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CWD");
				print("    MUL CX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    PUSH AX");
				stackCount++;
			}
			else if($MULOP.text=="/") {
				print("    POP AX");
				stackCount--;
				print("    MOV CX,AX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CWD");
				print("    DIV CX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    PUSH AX");
				stackCount++;
			}
			else if($MULOP.text=="%") {
				print("    POP AX");
				stackCount--;
				print("    MOV CX,AX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    POP AX");
				stackCount--;
				print("    CWD");
				print("    DIV CX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    MOV AX, DX");
				print("    PUSH AX");
				stackCount++;
			}
	 };

unary_expression returns [string name_line] : ADDOP unary_expression {
			writeIntoparserLogFile("Line " + to_string($unary_expression.start->getLine()) + ": unary_expression : ADDOP unary_expression\n");
			writeIntoparserLogFile($ADDOP.text + $unary_expression.text + "\n");
			$name_line = $ADDOP.text + $unary_expression.text;
			if($ADDOP.text=="-") {
				print("    POP AX");
				stackCount--;
				print("    NEG AX\t\t;Line:"+to_string($unary_expression.start->getLine()));
				print("    PUSH AX");
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
						//print("    MOV AX, " + varName);
						print("    POP BX");
						stackCount--;
						print("    SHL BX, 1");
						
						print("    MOV AX, "+varName+ "[BX]\t\t;Line:"+to_string($variable.start->getLine()));
						print("    PUSH AX");
						stackCount++;
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						//print("    MOV AX, [BP - " + to_string(sym->offset) + "]");
						print("    POP BX");
						stackCount--;
						print("    SHL BX, 1");
						print("    SUB BX, "+ to_string((spCount) * 2));
						//print("    MOV AX, [AX]");
						print("    MOV SI, BX\t\t;Line:"+to_string($variable.start->getLine()));
						print("    MOV AX, [BP + SI]");
						print("    PUSH AX");
						stackCount++;
					}
				}
				
			}
			else{
			SymbolInfo *sym=symbolTable->LookUp($variable.text);
			if(sym->isGlobal){
				print("    MOV AX, " + $variable.text+ "\t\t;Line:"+to_string($variable.start->getLine()));
				print("    PUSH AX");
				stackCount++;
			}
			else if(!sym->isGlobal){
				print("    MOV AX, [BP - " + to_string(sym->offset) + "]\t\t;Line:"+to_string($variable.start->getLine()));
				print("    PUSH AX");
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
			// 			print("    MOV AX, " + temp);
			// 			print("    PUSH AX");
			// 		}
			// 		else if(!sym1->isGlobal) {
			// 			print("    MOV AX, [BP - " + to_string(sym1->offset) + "]");
			// 			print("    PUSH AX");
			// 		}
			// 		count++;
			// 	}

			// }
			print("    CALL " + $ID.text);
			print("    ADD SP, " + to_string(sym->paramCount * 2));

			print("    PUSH AX");
			stackCount++;
			if(sym->returnType == "void"){
				print("    POP AX");
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
			print("    MOV AX, " + $CONST_INT.text+ "\t\t;Line:"+to_string($CONST_INT->getLine()));
			print("    PUSH AX");
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
						//print("    MOV AX, " + varName);
						print("    POP BX");
						stackCount--;
						print("    SHL BX, 1");
						
						print("    MOV AX, "+varName+ "[BX]");
						print("    INC AX");
						print("    MOV "+varName+ "[BX], AX");
						print("    PUSH AX");
						stackCount++;
					}
					else{
						string index = $variable.text.substr(pos + 1, $variable.text.find(']') - pos - 1);
						//print("    MOV AX, [BP - " + to_string(sym->offset) + "]");
						print("    POP BX");
						stackCount--;
						print("    SHL BX, 1");
						print("    SUB BX, "+ to_string((spCount) * 2));
						//print("    MOV AX, [AX]");
						print("    MOV SI, BX");
						print("    MOV AX, [BP + SI]");
						print("    PUSH AX");
						stackCount++;
					}
				}
				
			}
			else{
		SymbolInfo *sym = symbolTable->LookUp($variable.text);
		if(sym->isGlobal) {
			print("    MOV AX, " + $variable.text);
			print("    PUSH AX");
			stackCount++;
			print("    INC AX");
			print("    MOV " + $variable.text + ", AX");	
			print("    POP AX");
			stackCount--;
			
			
		}
		else if(!sym->isGlobal) {
			print("    MOV AX, [BP - " + to_string(sym->offset) + "]");
			print("    PUSH AX");
			stackCount++;
			print("    INC AX");
			print("    MOV [BP - " + to_string(sym->offset) + "], AX");
			print("    POP AX");
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
			print("    MOV AX, " + $variable.text);
			print("    PUSH AX");
			stackCount++;
			print("    DEC AX");
			print("    MOV " + $variable.text + ", AX");	
			print("    POP AX");
			stackCount--;
		}
		else if(!sym->isGlobal) {
			print("    MOV AX, [BP - " + to_string(sym->offset) + "]");
			print("    PUSH AX");
			stackCount++;
			print("    DEC AX");
			print("    MOV [BP - " + to_string(sym->offset) + "], AX");
			print("    POP AX");
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

