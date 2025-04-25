#include"2105081_symbol_table.hpp"
#include<sstream>

int main()
{
    freopen("2105081_report_input.txt","r",stdin);
    int n;
    cin>>n;
    getchar();
    int i=1;
    SymbolTable *symbolTable1=new SymbolTable(new ScopeTable(n,i,NULL,"sdbm"));
    SymbolTable *symbolTable2=new SymbolTable(new ScopeTable(n,i,NULL,"djb2"));
    SymbolTable *symbolTable3=new SymbolTable(new ScopeTable(n,i,NULL,"rs"));
    string command;
    i++;
    while(true){
        getline(cin,command);
        string word;
        istringstream istr(command);
        int t=0;
        while(istr>>word){
            t++;
        }
        istringstream str(command);
        string* arg=new string[t];
        int num=0;
        while (getline(str,word,' '))
        {
            arg[num++]=word;
        }
        if(arg[0]=="I"){
            if(num<3){
                cout<<"\tInvalid Argument"<<endl;
            }
            else if(num==3){
                symbolTable1->insert(arg[1],arg[2]);
                //cout<<1<<endl;
                symbolTable2->insert(arg[1],arg[2]);
                //cout<<2<<endl;
                symbolTable3->insert(arg[1],arg[2]);
                //cout<<3<<endl;
            }
            else{
                if(arg[2]=="FUNCTION"){
                    string type=arg[2]+","+arg[3]+"<==(";
                    for(int i=4;i<num;i++){
                        if(i==num-1){
                            type+=arg[i]+")";
                            continue;
                        }
                        type+=arg[i]+",";
                    }
                    symbolTable1->insert(arg[1],type);
                    symbolTable2->insert(arg[1],type);
                    symbolTable3->insert(arg[1],type);
                }
                else if(arg[2]=="STRUCT"){
                    string type=arg[2]+",{";
                    for(int i=3;i<num;i+=2){
                        if(i==num-2){
                            type+="("+arg[i]+","+arg[i+1]+")";
                            continue;
                        }
                        type+="("+arg[i]+","+arg[i+1]+"),";
                    }
                    type+="}";
                    symbolTable1->insert(arg[1],type);
                    symbolTable2->insert(arg[1],type);
                    symbolTable3->insert(arg[1],type);
                }
                else if(arg[2]=="UNION"){
                    string type=arg[2]+",{";
                    for(int i=3;i<num;i+=2){
                        if(i==num-2){
                            type+="("+arg[i]+","+arg[i+1]+")";
                            continue;
                        }
                        type+="("+arg[i]+","+arg[i+1]+"),";
                    }
                    type+="}";
                    symbolTable1->insert(arg[1],type);
                    symbolTable2->insert(arg[1],type);
                    symbolTable3->insert(arg[1],type);
                }
                else{
                    cout<<"\tInvalid Argument"<<endl;
                }
            }  
        }
        else if(arg[0]=="D"){
            if(num!=2){
                cout<<"\tNumber of parameters mismatch for the command D"<<endl;
            }
            else{
                symbolTable1->remove(arg[1]);
                symbolTable2->remove(arg[1]);
                symbolTable3->remove(arg[1]);
            }
        }
        else if(arg[0]=="S"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable1->enterScope(n,i);
                symbolTable2->enterScope(n,i);
                symbolTable3->enterScope(n,i);
                i++;
            }
        }
        else if(arg[0]=="E"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable1->exitScope();
                symbolTable2->exitScope();
                symbolTable3->exitScope();
            }
        }
        else if(arg[0]=="Q"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                delete[] arg;
                break;
            }
        }
        else{
            cout<<"\tInvalid command"<<endl;
        }
        delete[] arg;
    }
    freopen("output.txt","w",stdout);
    double sdbm_ratio=(double)symbolTable1->getCollisionCount()/n;
    double djb2_ratio=(double)symbolTable2->getCollisionCount()/n;
    double rs_ratio=(double)symbolTable3->getCollisionCount()/n;

    cout<<"SDBM Hash:"<<endl;
    cout<<"\tCollisions     : " <<symbolTable1->getCollisionCount()<<endl;
    cout<<"\tCollision ratio: " <<sdbm_ratio<<endl;

    cout<< "DJB2 Hash:"<<endl;
    cout<< "\tCollisions     : " <<symbolTable2->getCollisionCount()<< endl;
    cout<< "\tCollision ratio: " <<djb2_ratio<<endl;

    cout<< "RS Hash:"<<endl;
    cout<< "\tCollisions     : " <<symbolTable3->getCollisionCount()<< endl;
    cout<< "\tCollision ratio: " <<rs_ratio<<endl;

}