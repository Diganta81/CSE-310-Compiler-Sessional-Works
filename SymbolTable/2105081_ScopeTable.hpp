#include<iostream>
#include<string>
#include"2105081_hash.hpp"
#include"2105081_SymbolInfo.hpp"

using namespace std;

class ScopeTable
{
    int bucketSize;
    string id;
    SymbolInfo **hashTable;
    ScopeTable *parent;
    int numOfChildren;
    public:

        ScopeTable(int n,ScopeTable *Parent){
            this->bucketSize=n;
            hashTable=new SymbolInfo*[n];
            for(int i=0;i<n;i++){
                hashTable[i]=NULL;
            }
            if(Parent==NULL){
                parent=NULL;
                id="1";
                numOfChildren=0;
            }
            else{
                if(parent!=Parent){
                    Parent->numOfChildren++;
                }
                parent=Parent;
                this->id=parent->id+"."+to_string(parent->numOfChildren);
            }
        }

        void setId(string id){
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

        int getNumOfChildren(){
            return numOfChildren;
        }

        int getBucketNum(string Name){
            uint64_t num=Hash::sdbm_hash(Name);
            return num%bucketSize;
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

        bool Insert(string Name,string type){
            int index=getBucketNum(Name);
            SymbolInfo *curr=hashTable[index];
            int num=0;
            while(curr!=NULL){
                num++;
                if(curr->getName()==Name){
                    cout<<"found at "+to_string(index)+" position: "+to_string(num);
                    return false;
                }
                curr=curr->next;
            }
           curr->setNext(new SymbolInfo(Name,type));
           return true;
        }

        SymbolInfo* LookUp(string Name){
            int index=getBucketNum(Name);
            int num=0;
            SymbolInfo *curr=hashTable[index];
            while(curr!=NULL){
                num++;
                if(curr->getName()==Name){
                    cout<<"found at "+to_string(index)+" position: "+to_string(num);
                    return curr;
                }
                curr=curr->next;
            }
        }

        bool deleteSymbol(string Name){
            int index=getBucketNum(Name);
            SymbolInfo *curr=hashTable[index];
            SymbolInfo *prev=NULL;
            while(curr!=NULL){
                if(curr->getName()==Name){
                    if(prev==NULL){
                        SymbolInfo *temp=curr;
                        curr=curr->next;
                        delete temp;
                        return true;
                    }
                    else{
                        prev->next=curr->next;
                        delete curr;
                        return true;
                    }
                }
                prev=curr;
                curr=curr->next;
            }
            return false;
        }

        void print(){
            for(int i=0;i<bucketSize;i++){
                SymbolInfo* curr=hashTable[i];
                cout<<to_string(i+1)+" : ";
                while(curr!=NULL){
                    cout<<"--"<<curr->getName();
                    curr=curr->next;
                }
                cout<<endl;
            }
        }

        ~ScopeTable(){
            for(int i=0;i<bucketSize;i++){
                delete[] hashTable[i];
            }
            delete[] hashTable;
        }
};