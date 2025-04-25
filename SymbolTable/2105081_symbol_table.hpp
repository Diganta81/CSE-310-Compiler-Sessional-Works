#include<iostream>
#include<string>
#include"2105081_scope_table.hpp"

using namespace std;

class SymbolTable
{
    ScopeTable* current;
    int collisionCount;
    public:
    SymbolTable(ScopeTable* curr){
        current=curr;
        collisionCount=0;
    }

    ~SymbolTable(){
        while(current!=NULL){
            cout<<"\tScopeTable# "<<current->getId()<<" removed"<<endl;
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
            cout<<"\tScopeTable# "<<temp->getId()<<" removed"<<endl;
            delete temp;
        }
        else{
            cout<<"\tcan not be deleted"<<endl;
        }
    }

    bool insert(string name,string type){
        return current->Insert(name,type,collisionCount);
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
            cout<<"\t\'"<<name<<"\'"<<" not found in any of the ScopeTables"<<endl;
            return NULL;
        }
        return temp->LookUp(name);
    }

    void printCurrentScopeTable(int i=0){
        cout<<"\tScopeTable# "<<current->getId()<<endl;
        current->print(i);
    }

    void printAllScopeTable(){
        ScopeTable* temp=current;
        int i=0;
        while(temp!=NULL){
            for(int j=0;j<i;j++){
                cout<<"\t";
            }
            cout<<"\tScopeTable# "<<temp->getId()<<endl;
            temp->print(i);
            temp=temp->getParent();
            i++;
        }
    }

    int getCollisionCount(){
        // int count=0;
        // ScopeTable* temp=current;
        // while(temp!=NULL){
        //     count+=temp->getCollisionCount();
        //     temp=temp->getParent();
        // }
        // return count;
        return collisionCount;
    }
};