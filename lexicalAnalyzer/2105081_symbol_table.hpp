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
            //cout<<"ScopeTable# "<<current->getId()<<" removed"<<endl;
            ScopeTable* temp=current;
            current=current->getParent();
            delete temp;
        }
    }

    void enterScope(int n){
        if(current!=NULL){
            current->incrementChildren();
        }
        else{
            current->setId(1);
        }
        current=new ScopeTable(n,current);
    }

    void exitScope(){
        if(current->getParent()!=NULL){
            ScopeTable* temp=current;
            current=current->getParent();
            //cout<<"ScopeTable# "<<temp->getId()<<" removed"<<endl;
            delete temp;
        }
        else{
            //cout<<"can not be deleted"<<endl;
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
        //cout<<"ScopeTable# "<<current->getId()<<endl;
        current->print(i);
    }

    void printAllScopeTable(){
        ScopeTable* temp=current;
        int i=0;
        while(temp!=NULL){
            // for(int j=0;j<i;j++){
            //     cout<<"\t";
            // }
            cout<<"ScopeTable # "<<temp->getId()<<endl;
            temp->print(i);
            temp=temp->getParent();
            i++;
        }
        cout<<endl;
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