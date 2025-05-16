#include<iostream>
#include<string>
using namespace std;

class Hash
{
    public:
        static unsigned int sdbmHash(const char *p,int num_buckets) {
 		unsigned int hash = 0;
 		auto *str = (unsigned char *) p;
 		int c{};
 		while ((c = *str++)) {
 			hash = c + (hash << 6) + (hash << 16) - hash;
 		}
 		return hash%num_buckets;
}


		// given in the pdf

		static unsigned int djb2_hash(string str,int num_buckets)
		{
			unsigned int hash_code=5381;
			int len=str.length();
			for(int i=0;i<len;i++)
			{
				char ch=str[i];
				int c=ch;                               
				hash_code=(((hash_code<<5)+hash_code)+c);
			}
			return hash_code%num_buckets;
		}

		// this hash function was taken from https://theartincode.stanis.me/008-djb2/

		static unsigned int rs_hash(string str,int num_buckets)
		{ 
			unsigned int b=378551;
			unsigned int a=63689;
			unsigned int hash=0;
			for (int i=0;i<str.length();++i) {
				hash=(hash*a+str[i])%num_buckets;
				a=a*b;
			}
			return hash%num_buckets;
		}

		// this hash function was taken from https://www.programmingalgorithms.com/algorithm/rs-hash/cpp/
};