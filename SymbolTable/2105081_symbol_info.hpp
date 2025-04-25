#include<iostream>
#include<string>
using namespace std;

class SymbolInfo
{
    private:
        string name;
        string type;
    public:
        SymbolInfo* next;
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