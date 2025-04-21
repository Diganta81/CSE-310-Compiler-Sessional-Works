#include<iostream>
#include<string>
#include"2105081_ScopeTable.hpp"

using namespace std;

class SymbolTable
{
    ScopeTable* current;
    public:
    SymbolTable(ScopeTable* curr){
        current=curr;
    }

    ~SymbolTable(){
        while(current!=NULL){
            ScopeTable* temp=current->getParent();
            delete current;
            current=temp;
        }
    }

    void enterScope(int n){
        current=new ScopeTable(n,current);
    }

    void exitScope(){
        if(current->getParent()!=NULL){
            ScopeTable* temp=current->getParent();
            delete temp;
            current=temp;
        }
        else{
            cout<<"can not be deleted"<<endl;
        }
    }

    bool insert(string name,string type){
        return current->Insert(name,type);
    }

    bool remove(string name){
        return current->deleteSymbol(name);
    }

    SymbolInfo* LookUp(string name){
        ScopeTable* temp=current;
        while(temp->getParent()!=NULL){
            if(temp->find(name)){
                return temp->LookUp(name);
            }
            temp=current->getParent();
        }
        if(!temp->find(name)){
            cout<<"Not found";
        }
        return temp->LookUp(name);
    }

    void printCurrentScopeTable(){
        current->print();
    }

    void printAllScopeTable(){
        ScopeTable* temp=current;
        while(temp!=NULL){
            temp->print();
            temp=temp->getParent();
        }
    }
};