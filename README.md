# CSE-310 Compiler Sessional Works

This repository contains the implementation of various compiler design components developed as part of the CSE-310 Compiler Sessional course. The project demonstrates the complete pipeline of a C-like language compiler, from lexical analysis to intermediate code generation.

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Components](#components)
  - [1. Symbol Table](#1-symbol-table)
  - [2. Lexical Analyzer](#2-lexical-analyzer)
  - [3. Syntax and Semantic Analyzer](#3-syntax-and-semantic-analyzer)
  - [4. Intermediate Code Generation](#4-intermediate-code-generation)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Building and Running](#building-and-running)
- [Project Structure](#project-structure)
- [Author](#author)

## Overview

This project implements a multi-phase compiler for a C-like programming language. The compiler processes source code through several stages:

1. **Lexical Analysis**: Tokenizes the input source code
2. **Syntax Analysis**: Parses tokens using ANTLR4-generated parser
3. **Semantic Analysis**: Validates semantic rules and type checking
4. **Intermediate Code Generation**: Generates assembly code for 8086 architecture

Each component is implemented as a separate module with comprehensive logging and error handling capabilities.

## Repository Structure

```
CSE-310-Compiler-Sessional-Works/
├── SymbolTable/              # Symbol table implementation
├── lexicalAnalyzer/          # Lexical analyzer using Flex
├── syntax_semantic_analyzer/ # Parser and semantic analyzer using ANTLR4
└── itermediate_code_generation/ # Code generation phase
```

## Components

### 1. Symbol Table

**Location**: `SymbolTable/`

The symbol table is a fundamental data structure used throughout the compiler to store and manage identifiers (variables, functions, etc.) and their attributes.

**Key Features**:
- Hash-based symbol table implementation
- Scope management with nested scopes
- Multiple hash functions support (SDBM, DJB2, etc.)
- Efficient symbol lookup, insertion, and deletion

**Key Files**:
- `2105081_symbol_info.hpp` - Symbol information class
- `2105081_scope_table.hpp` - Scope table implementation
- `2105081_symbol_table.hpp` - Main symbol table structure
- `2105081_hash.hpp` - Hash function implementations
- `2105081_main.cpp` - Test driver program
- `2105081_report.cpp` - Report generation utility

**Hash Functions Supported**:
- SDBM Hash
- DJB2 Hash
- Custom hash implementations

**Input/Output**:
- Input: Command-based input for symbol operations (Insert, Lookup, Delete, Print, Enter/Exit Scope)
- Output: Detailed logs of operations and symbol table state

### 2. Lexical Analyzer

**Location**: `lexicalAnalyzer/`

The lexical analyzer (scanner) reads the source code and produces a stream of tokens for the parser.

**Key Features**:
- Implemented using Flex (Fast Lexical Analyzer)
- Recognizes keywords, identifiers, operators, literals, and comments
- Handles single-line and multi-line comments
- String and character literal processing with escape sequences
- Comprehensive error detection and reporting

**Key Files**:
- `2105081.l` - Flex specification file
- `2105081.cpp` - Generated lexer source (after compilation)
- Input files in `inputs/` directory
- Token and log outputs

**Token Categories**:
- Keywords: `if`, `else`, `for`, `while`, `int`, `float`, `char`, `void`, etc.
- Operators: Arithmetic, relational, logical, bitwise
- Delimiters: Braces, parentheses, semicolons
- Literals: Integer, float, character, string constants
- Identifiers: Variable and function names

**Error Handling**:
- Invalid character detection
- Malformed string/character literals
- Multi-character constants
- Empty character constants
- Unterminated strings and comments

### 3. Syntax and Semantic Analyzer

**Location**: `syntax_semantic_analyzer/`

This component performs syntax analysis (parsing) and semantic analysis using ANTLR4 (ANother Tool for Language Recognition).

**Key Features**:
- Context-free grammar for C-like language
- ANTLR4-based parser generation
- Abstract Syntax Tree (AST) construction
- Semantic rule validation
- Type checking and compatibility
- Function declaration and definition validation
- Variable scope checking

**Key Files**:
- `C2105081Lexer.g4` - Lexer grammar for ANTLR4
- `C2105081Parser.g4` - Parser grammar with semantic actions
- `2105081_main.cpp` - Main driver program
- Symbol table headers (reused from SymbolTable component)
- `antlr4-resources/` - ANTLR4 skeleton files and resources

**Grammar Features**:
- Variable declarations (int, float, char, void)
- Function declarations and definitions
- Statements: if-else, for, while, return
- Expressions: arithmetic, logical, relational
- Arrays and function calls
- Scope management

**Semantic Checks**:
- Type compatibility in assignments
- Function signature matching
- Variable declaration before use
- Return type validation
- Array bounds checking
- Multiple declaration detection

**Output**:
- `parserLog.txt` - Parse tree and symbol table
- `errorLog.txt` - Syntax and semantic errors
- `lexerLog.txt` - Lexical token stream

### 4. Intermediate Code Generation

**Location**: `itermediate_code_generation/`

The final phase generates assembly code for the 8086 architecture from the validated parse tree.

**Key Features**:
- 8086 assembly code generation
- Register allocation
- Code optimization
- Assembly instructions for:
  - Arithmetic operations
  - Logical operations
  - Control flow (jumps, conditional branches)
  - Function calls and returns
  - Memory operations

**Key Files**:
- `C2105081Lexer.g4` - Extended lexer grammar
- `C2105081Parser.g4` - Parser with code generation actions
- `2105081_main.cpp` - Main driver
- Symbol table components
- `Ctester.cpp` - Test utility

**Generated Code**:
- `Code.asm` - Generated assembly code
- `OptimizedCode.asm` - Optimized assembly code
- Data segment for variables
- Code segment for instructions
- Proper stack management

**Optimization Techniques**:
- Constant folding
- Dead code elimination
- Register optimization
- Peephole optimization

## Technologies Used

- **C++**: Primary programming language (C++11/14 standard)
- **Flex**: Fast Lexical Analyzer generator
- **ANTLR4**: Parser generator for language recognition
- **8086 Assembly**: Target architecture for code generation
- **Hash Tables**: For efficient symbol table implementation

## Prerequisites

To build and run the components, you need:

- **g++** (GCC 7.0 or higher)
- **flex** (Fast Lexical Analyzer)
- **ANTLR4** (Version 4.9 or higher)
  - ANTLR4 runtime for C++
  - Java Runtime Environment (for ANTLR4 tool)
- **Make** (optional, for build automation)

### Installing Dependencies

**On Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install g++ flex default-jre
```

**ANTLR4 Setup**:
```bash
# Download ANTLR4 jar
cd /usr/local/lib
sudo curl -O https://www.antlr.org/download/antlr-4.13.1-complete.jar

# Add to .bashrc or .bash_profile
export CLASSPATH=".:/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH"
alias antlr4='java -jar /usr/local/lib/antlr-4.13.1-complete.jar'

# Install ANTLR4 C++ runtime
# Follow instructions at: https://github.com/antlr/antlr4/tree/master/runtime/Cpp
```

## Building and Running

### 1. Symbol Table

```bash
cd SymbolTable
g++ -o symboltable 2105081_main.cpp
./symboltable sample_input.txt output.txt [hash_function]
# hash_function options: sdbm (default), djb2, etc.
```

### 2. Lexical Analyzer

```bash
cd lexicalAnalyzer
flex 2105081.l
g++ -o lexer lex.yy.c -lfl
./lexer inputs/input1.txt
# Output: 2105081_token.txt and 2105081_log.txt
```

### 3. Syntax and Semantic Analyzer

```bash
cd syntax_semantic_analyzer

# Generate parser and lexer from ANTLR4 grammar
antlr4 -Dlanguage=Cpp -visitor -no-listener C2105081Lexer.g4
antlr4 -Dlanguage=Cpp -visitor -no-listener C2105081Parser.g4

# Compile (adjust include paths for ANTLR4 runtime)
g++ -std=c++11 -I/usr/local/include/antlr4-runtime \
    2105081_main.cpp C2105081Lexer.cpp C2105081Parser.cpp \
    -L/usr/local/lib -lantlr4-runtime -o parser

# Run
./parser input/test.c
# Output in output/ directory: parserLog.txt, errorLog.txt, lexerLog.txt
```

### 4. Intermediate Code Generation

```bash
cd itermediate_code_generation

# Generate parser and lexer
antlr4 -Dlanguage=Cpp -visitor -no-listener C2105081Lexer.g4
antlr4 -Dlanguage=Cpp -visitor -no-listener C2105081Parser.g4

# Compile
g++ -std=c++11 -I/usr/local/include/antlr4-runtime \
    2105081_main.cpp C2105081Lexer.cpp C2105081Parser.cpp \
    -L/usr/local/lib -lantlr4-runtime -o codegen

# Run
./codegen input/program.c
# Output: output/Code.asm, output/OptimizedCode.asm
```

## Project Structure

### Symbol Table Files

```
SymbolTable/
├── 2105081_hash.hpp              # Hash function implementations
├── 2105081_symbol_info.hpp       # Symbol information class
├── 2105081_scope_table.hpp       # Scope table with hash table
├── 2105081_symbol_table.hpp      # Main symbol table
├── 2105081_main.cpp              # Test driver
├── 2105081_report.cpp            # Report generator
├── sample_input.txt              # Sample test input
├── sample_output.txt             # Expected output
└── Jan25_CSE310_Offine1SymbolTableSpec.pdf  # Specification
```

### Lexical Analyzer Files

```
lexicalAnalyzer/
├── 2105081.l                     # Flex specification
├── 2105081_symbol_table.hpp      # Symbol table integration
├── 2105081_*.hpp                 # Symbol table headers
├── inputs/                       # Test input files
│   ├── input1.txt
│   ├── input2.txt
│   └── input3.txt
└── Assignment 2 Specification.pdf # Specification document
```

### Syntax and Semantic Analyzer Files

```
syntax_semantic_analyzer/
├── C2105081Lexer.g4              # ANTLR4 lexer grammar
├── C2105081Parser.g4             # ANTLR4 parser grammar
├── 2105081_main.cpp              # Main driver
├── 2105081_*.h                   # Symbol table headers
├── antlr4-resources/             # ANTLR4 resources
│   ├── Expr.g4                   # Example grammar
│   └── antlr4-skeletons/         # C++/Java skeletons
└── jan25_cse310_offline3_syntax_semantic_spec.pdf
```

### Intermediate Code Generation Files

```
itermediate_code_generation/
├── C2105081Lexer.g4              # Extended lexer grammar
├── C2105081Parser.g4             # Parser with code generation
├── 2105081_main.cpp              # Main driver
├── 2105081_*.h                   # Symbol table headers
├── Ctester.cpp                   # Testing utility
├── input/                        # Test programs
└── output/                       # Generated assembly code
    ├── Code.asm                  # Generated code
    ├── OptimizedCode.asm         # Optimized code
    ├── parserLog.txt             # Parser output
    └── errorLog.txt              # Error log
```

## Input File Format

### Symbol Table Commands

```
<bucket_size>
I <symbol_name> <symbol_type>    # Insert symbol
L <symbol_name>                   # Lookup symbol
D <symbol_name>                   # Delete symbol
P <C|S|A>                        # Print (Current/All Scopes/All)
S                                 # Enter new scope
E                                 # Exit current scope
Q                                 # Quit
```

### Source Code (C-like Language)

```c
int main() {
    int x;
    float y;
    x = 5;
    y = 3.14;
    
    if (x > 0) {
        println(x);
    }
    
    return 0;
}
```

## Output Files

Each component generates specific output files:

1. **Symbol Table**: Operation logs and final symbol table state
2. **Lexical Analyzer**: Token list and lexical error log
3. **Parser**: Parse tree, symbol table, and syntax/semantic errors
4. **Code Generator**: Assembly code (.asm files)

## Error Handling

The compiler provides comprehensive error reporting:

- **Lexical Errors**: Invalid characters, malformed literals, unterminated strings
- **Syntax Errors**: Grammar violations, missing tokens, unexpected tokens
- **Semantic Errors**: Type mismatches, undeclared variables, scope violations

All errors include:
- Line number
- Error description
- Context information

## Student Information

**Student ID**: 2105081
**Course**: CSE-310 Compiler Sessional
**Department**: Computer Science and Engineering

## License

This project is developed as part of academic coursework. Please refer to your institution's academic integrity policies before using this code.

## Acknowledgments

- Course instructors and teaching assistants
- ANTLR4 development team
- Flex/Lex documentation and community

## References

- "Compilers: Principles, Techniques, and Tools" (Dragon Book) by Alf V. Aho et al.
- ANTLR4 Documentation: https://www.antlr.org/
- Flex Manual: https://github.com/westes/flex
- 8086 Assembly Reference: Intel Architecture Manual

---

For questions or issues, please contact through the course communication channels.
