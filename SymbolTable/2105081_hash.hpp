#include<iostream>
#include<string>
using namespace std;

class Hash
{
    public:
        static uint64_t sdbm_hash(string key_string)
	    {
	    	uint64_t hash_code=0;
	    	int len=key_string.length();
	    	for(int i=0;i<len;i++)
	    	{
	    		char ch=key_string[i];
	    		int c=ch;                               
	    		hash_code=c+(hash_code<<6)+(hash_code<<16)-hash_code;
	    	}
	    	return hash_code;
	    }
};