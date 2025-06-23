#include<iostream>
#include<string>
#include"2105081_scope_table.h"

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H




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
            //(*fileout)<<"ScopeTable# "<<current->getId()<<" removed"<<endl;
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
            //fileout<<"ScopeTable# "<<temp->getId()<<" removed"<<endl;
            delete temp;
        }
        else{
            //fileout<<"can not be deleted"<<endl;
        }
    }

    bool insert(ofstream &fileout,string name,string type){
        return current->Insert(fileout,name,type,collisionCount);
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
            //fileout<<"\t\'"<<name<<"\'"<<" not found in any of the ScopeTables"<<endl;
            return NULL;
        }
        return temp->LookUp(name);
    }

    bool find(string name){
        ScopeTable* temp=current;
        while(temp!=NULL){
            if(temp->find(name)){
                return true;
            }
            temp=temp->getParent();
        }
        return false;
    }

    bool find_current(string name){
        return current->find(name);
    }

    void printCurrentScopeTable(ofstream &fileout,int i=0){
        //fileout<<"ScopeTable# "<<current->getId()<<endl;
        current->print(fileout,i);
    }

    void printAllScopeTable(ofstream &fileout){
        ScopeTable* temp=current;
        int i=0;
        while(temp!=NULL){
            // for(int j=0;j<i;j++){
            //     fileout<<"\t";
            // }
            fileout<<"ScopeTable # "<<temp->getId()<<endl;
            temp->print(fileout,i);
            temp=temp->getParent();
            i++;
        }
        fileout<<endl;
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

#endif 