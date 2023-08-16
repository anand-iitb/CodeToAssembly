#include "type.hh"
#include "symbtab.hh"

pair<string, pair<int, vector<int>>> get_type(string type)
{
    pair<string, pair<int, vector<int>>> ret;
    ret.first = "";
    int i = 0;
    if (type[0] == 'v')
    {
        ret.first = "void";
        i += 4;
    }
    else if (type[0] == 'i')
    {
        ret.first = "int";
        i += 3;
    }
    else if (type[0] == 'f')
    {
        ret.first = "float";
        i += 5;
    }
    else if (type.substr(0, 6) == "struct")
    {
        ret.first = "struct";
        i += 6;
        int j = i;
        while (j < (int)type.length() && type[j] != '*' && type[j] != '[')
            j++;
        ret.first += type.substr(i, j - i);
        i = j;
    }
    else if (type[0] == 's')
    {
        ret.first = "string";
        i += 6;
    }
    ret.second.first = 0;
    ret.second.second = vector<int>();
    while (i < (int)type.length())
    {
        if (type[i] == '*')
        {
            ret.second.first++;
            i++;
        }
        else if (type[i] == '[')
        {
            int j = i + 1;
            while (j < (int)type.length() && type[j] != ']')
                j++;
            ret.second.second.push_back(stoi(type.substr(i + 1, j - i - 1)));
            i = j + 1;
        }
        else
            break;
    }
    return ret;
}

string print_type(string basictype, int pointer, vector<int> array, int address)
{
    string ret = "";
    ret += basictype;
    if(array.size()==1 && address==0)
    {
        array.pop_back();
        address++;
    }
    if (array.size() == 0 && address)
        address--, pointer++;
    for (int i = 0; i < pointer; i++)
        ret += "*";
    for (int i = 0; i < address; i++)
        ret += "(*)";
    for (int i = 0; i < (int)array.size(); i++)
        ret += "[" + to_string(array[i]) + "]";
    return ret;
}

string get_flabel()
{
    static int x = 0;
    string lb = to_string(x);
    lb = ".LC" + lb;
    x++;
    return lb;
}

string get_jlabel()
{
    static int x = 0;
    string lb = to_string(x);
    lb = ".L" + lb;
    x++;
    return lb;
}

vector<string> format_string(string x, string lb)
{
    vector<string> res;;
    res.push_back(lb + ":\n");
    res.push_back("    .string  "+x+"\n");
    return res;
}

void print_ins(vector<string> asmb)
{
    for( auto it = asmb.begin(); it != asmb.end(); it++)
    {
        cout << *it;
    }
}