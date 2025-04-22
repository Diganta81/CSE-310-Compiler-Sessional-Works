#include<iostream>
#include<string>
#include"2105081_hash.hpp"
#include"2105081_SymbolInfo.hpp"

using namespace std;

class ScopeTable
{
    int bucketSize;
    int id;
    SymbolInfo **hashTable;
    ScopeTable *parent;
    int numOfChildren;
    public:

        ScopeTable(int n,int i,ScopeTable *Parent){
            this->bucketSize=n;
            hashTable=new SymbolInfo*[n];
            for(int i=0;i<n;i++){
                hashTable[i]=NULL;
            }
            if(Parent==NULL){
                parent=NULL;
                id=i;
                numOfChildren=0;
            }
            else{
                if(parent!=Parent){
                    Parent->numOfChildren++;
                }
                parent=Parent;
                this->id=i;
            }
            cout<<"ScopeTable "<<id<<" created"<<endl;
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
            SymbolInfo *findSymbol=LookUp(Name);
            cout<<"1"<<endl;
            if(findSymbol==NULL){
                cout<<"2"<<endl;
                int index=getBucketNum(Name);
                int pos=1;
                if(hashTable[index]==NULL){
                    cout<<"3"<<endl;
                    hashTable[index]=new SymbolInfo(Name,type);
                    cout<<"inserted at pos: "<<pos<<endl;
                    return true;
                }
                else{
                    SymbolInfo *curr=hashTable[index];
                    while(curr->next!=NULL){
                        curr=curr->next;
                        pos++;
                    }
                    curr->next=new SymbolInfo(Name,type);
                    cout<<"inserted at pos: "<<pos<<endl;
                    return true;
                }
            }
            return false;
        }

        SymbolInfo* LookUp(string Name){
            cout<<Name<<" L 0"<<endl;
            int index=getBucketNum(Name);
            cout<<"L 1"<<endl;
            int num=0;
            SymbolInfo *curr=hashTable[index];
            cout<<"L 2"<<endl;
            while(curr!=NULL){
                num++;
                if(curr->getName()==Name){
                    cout<<"found at "+to_string(index)+" position: "+to_string(num);
                    return curr;
                }
                curr=curr->next;
            }
            cout<<"NOT found"<<endl;
            return NULL;
        }

        bool deleteSymbol(string Name){
            int index=getBucketNum(Name);
            SymbolInfo *curr=hashTable[index];
            SymbolInfo *prev=NULL;
            while(curr!=NULL){
                if(curr->getName()==Name){
                    if(prev==NULL){
                        SymbolInfo *temp=curr;
                        hashTable[index]=curr->next;
                        delete temp;
                        cout<<"Dleleted"<<endl;
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
            cout<<"Not FOund"<<endl;
            return false;
        }

        void print(int k){ 
            for(int i=0;i<bucketSize;i++){
                SymbolInfo* curr=hashTable[i];
                for(int j=0;j<k;j++){
                    cout<<"\t";
                }
                cout<<to_string(i+1)+"--> ";
                while(curr!=NULL){
                    cout<<"<"<<curr->getName()<<","<<curr->getType()<<">";
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