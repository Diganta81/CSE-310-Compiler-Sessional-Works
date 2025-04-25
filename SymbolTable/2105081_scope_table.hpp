#include<iostream>
#include<string>
#include"2105081_hash.hpp"
#include"2105081_symbol_info.hpp"

using namespace std;

class ScopeTable
{
    int bucketSize;
    int id;
    SymbolInfo **hashTable;
    ScopeTable *parent;
    string hash_name;
    public:

        ScopeTable(int n,int i,ScopeTable *Parent,string hash_name="sdbm"){
            this->bucketSize=n;
            hashTable=new SymbolInfo*[n];
            for(int i=0;i<n;i++){
                hashTable[i]=NULL;
            }
            if(Parent==NULL){
                parent=NULL;
                id=i;
                this->hash_name=hash_name;
            }
            else{
                parent=Parent;
                this->id=i;
                this->hash_name=Parent->hash_name;
            }
            cout<<"\tScopeTable# "<<id<<" created"<<endl;
        }

        void setId(int id){
            this->id=id;
        }

        int getId(){
            return this->id;
        }

        void setParent(ScopeTable *Parent){
            this->parent=Parent;
        }

        ScopeTable* getParent(){
            return parent;
        }

        unsigned int getBucketNum(string Name){
            if(hash_name=="sdbm"){
                return Hash::sdbm_hash(Name,bucketSize);
            }
            else if(hash_name=="djb2"){
                return Hash::djb2_hash(Name,bucketSize);
            }
            else if(hash_name=="rs"){
                return Hash::rs_hash(Name,bucketSize);
            }
            else{
                cout<<"\tInvalid hash function"<<endl;
                return -1;
            }
        }  

        bool find(string Name){
            int index=getBucketNum(Name);
            SymbolInfo *curr=hashTable[index];
            while(curr!=NULL){
                if(curr->getName()==Name){
                    return true;
                }
                curr=curr->next;
            }
           return false;
        }

        bool Insert(string Name,string type,int& collisionCount){
            int index=getBucketNum(Name);
            SymbolInfo *findSymbol=hashTable[index];
            while(findSymbol!=NULL){
                if(findSymbol->getName()==Name){
                    cout<<"\t\'"<<Name<<"\'"<<" already exists in the current ScopeTable"<<endl;
                    return findSymbol;
                }
                findSymbol=findSymbol->next;
            }
            if(findSymbol==NULL){
                int index=getBucketNum(Name);
                int pos=1;
                if(hashTable[index]==NULL){
                    hashTable[index]=new SymbolInfo(Name,type);
                    cout<<"\tInserted in ScopeTable# "<<id<< " at position "<<index+1<<", "<<pos<<endl;
                    return true;
                }
                else{
                    collisionCount++;
                    SymbolInfo *curr=hashTable[index];
                    SymbolInfo *prev=NULL;
                    while(curr!=NULL){
                        prev=curr;
                        curr=curr->next;
                        pos++;
                    }
                    prev->next=new SymbolInfo(Name,type);
                    cout<<"\tInserted in ScopeTable# "<<id<< " at position "<<index+1<<", "<<pos<<endl;;
                    return true;
                }
            }
            return false;
        }

        SymbolInfo* LookUp(string Name){
            int index=getBucketNum(Name);
            int num=0;
            SymbolInfo *curr=hashTable[index];
            while(curr!=NULL){
                num++;
                if(curr->getName()==Name){
                    cout<<"\t\'"<<Name<<"\'"<<" found in ScopeTable# "<<id<<" at position "<<index+1<<", "<<num<<endl;
                    return curr;
                }
                curr=curr->next;
            }
            cout<<"\t\'"<<Name<<"\'"<<" not found in any of the scope table"<<endl;
            return NULL;
        }

        bool deleteSymbol(string Name){
            int index=getBucketNum(Name);
            SymbolInfo *curr=hashTable[index];
            SymbolInfo *prev=NULL;
            int pos=1;
            while(curr!=NULL){
                if(curr->getName()==Name){
                    if(prev==NULL){
                        SymbolInfo *temp=curr;
                        hashTable[index]=curr->next;
                        delete temp;
                        cout<<"\tDeleted "<<"\'"<<Name<<"\'"<<" from ScopeTable# "<<id<<" at position "<<index+1<<", "<<pos<<endl;
                        return true;
                    }
                    else{
                        prev->next=curr->next;
                        delete curr;
                        cout<<"\tDeleted"<<"\' "<<Name<<"\'"<<" from ScopeTable# "<<id<<" at position "<<index+1<<", "<<pos<<endl;
                        return true;
                    }
                }
                prev=curr;
                curr=curr->next;
                pos++;
            }
            cout<<"\tNot found in the current ScopeTable"<<endl;
            return false;
        }

        void print(int k){ 
            for(int i=0;i<bucketSize;i++){
                SymbolInfo* curr=hashTable[i];
                for(int j=0;j<k;j++){
                    cout<<"\t";
                }
                cout<<"\t"<<to_string(i+1)+"--> ";
                while(curr!=NULL){
                    cout<<"<"<<curr->getName()<<","<<curr->getType()<<"> ";
                    curr=curr->next;
                }
                cout<<endl;
            }
        }

        ~ScopeTable(){
            for(int i=0;i<bucketSize;i++){
                delete hashTable[i];
            }
            delete[] hashTable;
        }
};