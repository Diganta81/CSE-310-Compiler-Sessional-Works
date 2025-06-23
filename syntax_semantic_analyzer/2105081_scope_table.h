
#include"2105081_symbol_info.h"

#ifndef SCOPE_TABLE_H
#define SCOPE_TABLE_H

class ScopeTable
{
    int bucketSize;
    string id;
    int children;
    SymbolInfo **hashTable;
    ScopeTable *parent;
    string hash_name;
    public:

        ScopeTable(int n,ScopeTable *Parent,string hash_name="sdbm"){
            this->bucketSize=n;
            hashTable=new SymbolInfo*[n];
            this->children=0;
            for(int i=0;i<n;i++){
                hashTable[i]=NULL;
            }
            if(Parent==NULL){
                parent=NULL;
                id="1";
                this->hash_name=hash_name;
            }
            else{
                parent=Parent;
                this->id=parent->getId()+"."+to_string(parent->children);
                this->hash_name=Parent->hash_name;
            }
            //cout<<"\tScopeTable# "<<id<<" created"<<endl;
        }

        void incrementChildren(){
            this->children++;
        }

        void setId(int id){
            this->id=id;
        }

        string getId(){
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
                return Hash::sdbmHash(Name.c_str(),bucketSize);
            }
            else if(hash_name=="djb2"){
                return Hash::djb2_hash(Name.c_str(),bucketSize);
            }
            else if(hash_name=="rs"){
                return Hash::rs_hash(Name.c_str(),bucketSize);
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

        bool Insert(ofstream &fileout,string Name,string type,int& collisionCount){
            int index=getBucketNum(Name);
            SymbolInfo *findSymbol=hashTable[index];
            int i=0;
            while(findSymbol!=NULL){
                if(findSymbol->getName()==Name){
                    //fileout<<"< "<<Name<<" : "<<type<<" > "<<"already exists in ScopeTable# "<<id<<" at position "<<index<<", "<<i<<endl<<endl;
                    return false;
                }
                findSymbol=findSymbol->next;
                i++;
            }
            if(findSymbol==NULL){
                int index=getBucketNum(Name);
                int pos=1;
                if(hashTable[index]==NULL){
                    hashTable[index]=new SymbolInfo(Name,type);
                    //cout<<"\tInserted in ScopeTable# "<<id<< " at position "<<index+1<<", "<<pos<<endl;
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
                    //cout<<"\tInserted in ScopeTable# "<<id<< " at position "<<index+1<<", "<<pos<<endl;;
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
                    //cout<<"\t\'"<<Name<<"\'"<<" found in ScopeTable# "<<id<<" at position "<<index+1<<", "<<num<<endl;
                    return curr;
                }
                curr=curr->next;
            }
            //cout<<"\t\'"<<Name<<"\'"<<" not found in any of the scope table"<<endl;
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
                        //cout<<"\tDeleted "<<"\'"<<Name<<"\'"<<" from ScopeTable# "<<id<<" at position "<<index+1<<", "<<pos<<endl;
                        return true;
                    }
                    else{
                        prev->next=curr->next;
                        delete curr;
                        //cout<<"\tDeleted"<<"\' "<<Name<<"\'"<<" from ScopeTable# "<<id<<" at position "<<index+1<<", "<<pos<<endl;
                        return true;
                    }
                }
                prev=curr;
                curr=curr->next;
                pos++;
            }
            //cout<<"\tNot found in the current ScopeTable"<<endl;
            return false;
        }

        void print(ofstream &fileout,int k){ 
            for(int i=0;i<bucketSize;i++){
                SymbolInfo* curr=hashTable[i];
                // for(int j=0;j<k;j++){
                //     cout<<"\t";
                // }
                //cout<<to_string(i)+"--> ";
                SymbolInfo *temp=curr;
                if(curr!=NULL){
                    fileout<<to_string(i)+" --> ";
                }
                while(curr!=NULL){
                    fileout<<"< "<<curr->getName()<<" : "<<curr->getType()<<" >";
                    curr=curr->next;
                }
                if(temp!=NULL){
                    fileout<<endl;
                }
            }
        }

        ~ScopeTable(){
            for(int i=0;i<bucketSize;i++){
                delete hashTable[i];
            }
            delete[] hashTable;
        }
};

#endif // SCOPE_TABLE_H