#ifndef TYPE_HH
#define TYPE_HH
#include <iostream>
#include <string>
#include <map>
#include <vector>
using namespace std;

enum type_specifier_enum
{
    INT,
    FLOAT,
    OK,
    VOID,
    ERROR,
    STRUCT,
    POINTER,
    VOID_POINTER,
    ARRAY
};
pair<string,pair<int,vector<int>>> get_type(string type);
string print_type(string type, int deref,vector<int> array,int address);

class type_specifier_class
{
public:
    string type;
    type_specifier_class()
    {
    }
};

class declarator_class
{
public:
    string identifier;
    int array_size;
    int pointer;
    string type;
    declarator_class()
    {
        pointer = 0;
    }
};

class declarator_list_class
{
public:
    vector<declarator_class *> declarator_list;
    declarator_list_class()
    {
    }
};

class declaration_class
{
public:
    type_specifier_class *type_specifier;
    declarator_list_class *declarator_list;
    declaration_class()
    {
    }
};


class declaration_list_class
{
public:
    vector<declaration_class *> declaration_list;
    declaration_list_class()
    {
    }
};

class parameter_declaration_class
{
public:
    type_specifier_class *type_specifier;
    declarator_class *declarator;
    parameter_declaration_class()
    {
    }
};

class parameter_list_class
{
public:
    vector<parameter_declaration_class *> parameter_list;
    parameter_list_class()
    {
    }
};

class fun_declarator_class
{
public:
    string fun_name;
    parameter_list_class *parameter_list;
    fun_declarator_class()
    {
    }
};

#endif
