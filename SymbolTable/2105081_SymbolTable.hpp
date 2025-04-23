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
            ScopeTable* temp=current;
            current=current->getParent();
            delete temp;
        }
    }

    void enterScope(int n,int i){
        current=new ScopeTable(n,i,current);
    }

    void exitScope(){
        if(current->getParent()!=NULL){
            ScopeTable* temp=current;
            current=current->getParent();
            cout<<"ScopeTable# "<<temp->getId()<<" removed"<<endl;
            delete temp;
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
            temp=temp->getParent();
        }
        if(!temp->find(name)){
            cout<<"Not found"<<endl;;
            return NULL;
        }
        return temp->LookUp(name);
    }

    void printCurrentScopeTable(int i=0){
        current->print(i);
    }

    void printAllScopeTable(){
        ScopeTable* temp=current;
        int i=0;
        while(temp!=NULL){
            for(int j=0;j<i;j++){
                cout<<"\t";
            }
            cout<<"ScopeTable # "<<temp->getId()<<endl;
            temp->print(i);
            temp=temp->getParent();
            i++;
        }
    }
};