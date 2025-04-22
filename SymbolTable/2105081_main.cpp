#include"2105081_SymbolTable.hpp"
#include <string>
#include <sstream>

int main()
{
    freopen("sample_input.txt", "r", stdin);
    //freopen("output.txt", "w", stdout);
    int n;
    cin >> n;
    cout<<n<<endl;
    getchar();
    SymbolTable *symbolTable = new SymbolTable(new ScopeTable(n, NULL));
    string command;
    int count = 1;
    while(true){
        getline(cin, command);
        cout << "Cmd " << count << ": " << command << "\n";
        int num = 0;
        string word, arg[10];
        istringstream iss(command);
        while (getline(iss, word, ' '))
        {
            arg[num++] = word;
        }
        if(arg[0]=="I"){
            if(num<3){
                cout<<"Invalid Argument"<<endl;
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
                    symbolTable->insert(arg[1],type);
                }
            }  
        }
        else if(arg[0]=="L"){
            if(num!=2){
                cout<<"Number of parameters mismatch for the command L"<<endl;
            }
            else{
                symbolTable->LookUp(arg[1]);
            }
        }
        else if(arg[0]=="D"){
            if(num!=2){
                cout<<"Number of parameters mismatch for the command D"<<endl;
            }
            else{
                symbolTable->remove(arg[1]);
            }
        }
        else if(arg[0]=="P"){
            if(num!=2){
                cout<<"Number of parameters mismatch for the command P"<<endl;
            }
            else{
                if(arg[1]=="C"){
                    symbolTable->printCurrentScopeTable();
                }
                else if(arg[2]=="A"){
                    symbolTable->printAllScopeTable();
                }
                else{
                    cout<<"NOT VALID"<<endl;
                }
            }
        }
        else if(arg[0]=="S"){
            if(num!=1){
                cout<<"Number of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable->enterScope(n);
            }
        }
        else if(arg[0]=="E"){
            if(num!=1){
                cout<<"Number of parameters mismatch for the command S"<<endl;
            }
            else{
                symbolTable->exitScope();
            }
        }
        else if(arg[0]=="Q"){
            if(num!=1){
                cout<<"Number of parameters mismatch for the command S"<<endl;
            }
            else{
                break;
            }
        }
        else{
            cout<<"Invalid command"<<endl;
        }
        count++;
    }
}