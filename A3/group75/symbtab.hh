#include "type.hh"
class SymbolTable;

class Entry
{
public:
    string name;
    string varfun;
    string param_local;
    int size;
    string offset;
    string type;
    SymbolTable *symbtab;
    vector<string> param_list;
    Entry()
    {
    }
    Entry(string name, string varfun, string param_local, int size, string offset, string type)
    {
        this->name = name;
        this->varfun = varfun;
        this->param_local = param_local;
        this->size = size;
        this->offset = offset;
        this->type = type;
    }
    void print()
    {
        std::cout << "[\"" << name << "\",\"" << varfun << "\",\"" << param_local << "\"," << size << "," << offset << ",\"" << type << "\"]";
    }
};
class SymbolTable
{
public:
    std::map<string, Entry> Entries;
    SymbolTable &operator=(const SymbolTable &other)
    {
        Entries = other.Entries;
        return *this;
    }
    SymbolTable()
    {
    }
    SymbolTable(Entry e)
    {
        Entries[e.name] = e;
    }
    void printgst()
    {
        cout << "[";
        for (auto it = Entries.begin(); it != Entries.end(); it++)
        {
            it->second.print();
            if (next(it, 1) != Entries.end())
                cout << "," << endl;
        }
        cout << "]";
    }
    void print()
    {
        cout << "[";
        for (auto it = Entries.begin(); it != Entries.end(); it++)
        {
            it->second.print();
            if (next(it, 1) != Entries.end())
                cout << "," << endl;
        }
        cout << "]";
    }
    // define search function to return the entry of the symbol table
    Entry *search(string name)
    {
        if (Entries.find(name) != Entries.end())
            return &Entries[name];
        else
        {
            return NULL;
        }
    }
};
