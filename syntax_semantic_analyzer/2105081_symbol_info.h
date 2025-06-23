#include "2105081_hash.h"

#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

class SymbolInfo
{
    private:
        string name;
        string type;
    public:
        SymbolInfo* next;
        string Idtype;
        bool isFunction = false;
        bool isArray = false;
        vector<string> paramTypes;
        string returnType;
        int paramCount = 0;
        int arraySize ;
        SymbolInfo(string name,string type,SymbolInfo* next=NULL){
            this->name=name;
            this->type=type;
            this->next=next;
        }
        ~SymbolInfo(){
            delete next;
        }
        void setName(string name){
            this->name=name;
        }
        void setType(string type){
            this->type=type;
        }
        void setNext(SymbolInfo* next){
            this->next=next;
        }
        string getName(){
            return this->name;
        }
        string getType(){
            return this->type;
        }
        SymbolInfo* getNext(){
            return this->next;
        }
};

#endif