#include"2105081_symbol_table.hpp"
#include<string>
#include<sstream>

int main(int argc, char* argv[])
{
    if(argc<2) {
        return 1;
    }
    freopen(argv[1],"r",stdin);
    freopen(argv[2],"w",stdout);
    int n;
    cin>>n;
    getchar();
    int i=1;
    string hash="";
    if(argc>3){
        hash=argv[3];
    }
    else{
        hash="sdbm";    
    }
    SymbolTable* symbolTable=new SymbolTable(new ScopeTable(n,i,NULL,hash));
    i++;
    string command;
    int count=1;
    while(true){
        getline(cin,command);
        cout<<"Cmd "<<count<<": "<<command<<endl;
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
            arg[num]=word;
            num++;
        }
        if(arg[0]=="I"){
            if(num<3){
                cout<<"\tInvalid Argument"<<endl;
            }
            else if(num==3){
                symbolTable->insert(arg[1],arg[2]);
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
                    symbolTable->insert(arg[1],type);
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
                    symbolTable->insert(arg[1],type);
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
                    symbolTable->insert(arg[1],type);
                }
                else{
                    cout<<"\tInvalid Argument"<<endl;
                }
            }  
        }
        else if(arg[0]=="L"){
            if(num!=2){
                cout<<"\tNumber of parameters mismatch for the command L"<<endl;
            }
            else{
                symbolTable->LookUp(arg[1]);
            }
        }
        else if(arg[0]=="D"){
            if(num!=2){
                cout<<"\tNumber of parameters mismatch for the command D"<<endl;
            }
            else{
                symbolTable->remove(arg[1]);
            }
        }
        else if(arg[0]=="P"){
            if(num!=2){
                cout<<"\tNumber of parameters mismatch for the command P"<<endl;
            }
            else{
                if(arg[1]=="C"){
                    symbolTable->printCurrentScopeTable();
                }
                else if(arg[1]=="A"){
                    symbolTable->printAllScopeTable();
                }
                else{
                    cout<<"\tNOT VALID"<<endl;
                }
            }
        }
        else if(arg[0]=="S"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable->enterScope(n,i);
                i++;
            }
        }
        else if(arg[0]=="E"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable->exitScope();
            }
        }
        else if(arg[0]=="Q"){
            if(num!=1){
                cout<<"\tNumber of parameters mismatch for the command S"<<endl;
            }
            else{
                delete[] arg;
                delete symbolTable;
                break;
            }
        }
        else{
            cout<<"\tInvalid command"<<endl;
        }
        count++;
        delete[] arg;
    }
}