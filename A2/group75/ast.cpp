#ifndef AST_HH
#define AST_HH
#include "ast.hh"
using namespace std;

void empty_astnode::print(int blanks)
{
    cout << "\"empty\"" << endl;
}

void seq_astnode::print(int blanks)
{
    cout << "\"seq\": [" << endl;
    for (int i = 0; i < (int)(seq.size()); i++)
    {
        if (seq[i]->astnode_type == EMPTY)
            seq[i]->print(blanks);
        else
        {
            cout << "{" << endl;
            seq[i]->print(blanks);
            cout << "}" << endl;
        }
        if (i < (int)(seq.size()) - 1)
            cout << "," << endl;
    }
    cout << "]" << endl;
}

void assignS_astnode::print(int blanks)
{
    cout << "\"assignS\": {" << endl;
    cout << "\"left\": {" << endl;
    left->print(blanks);
    cout << "}," << endl;
    cout << "\"right\": {" << endl;
    right->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void return_astnode::print(int blanks)
{
    cout << "\"return\": {" << endl;
    ret->print(blanks);
    cout << "}" << endl;
}

void proccall_astnode::print(int blanks)
{
    cout << "\"proccall\": {" << endl;
    cout << "\"fname\": {" << endl;
    params[0]->print(blanks);
    cout << "}," << endl;
    cout << "\"params\": [" << endl;
    for (int i = 1; i < (int)(params.size()); i++)
    {
        cout << "{" << endl;
        params[i]->print(blanks);
        cout << "}" << endl;
        if (i < (int)(params.size()) - 1)
            cout << "," << endl;
    }
    cout << "]" << endl;
    cout << "}" << endl;
}

void if_astnode::print(int blanks)
{
    cout << "\"if\": {" << endl;
    cout << "\"cond\": {" << endl;
    cond->print(blanks);
    cout << "}," << endl;

    if (then->astnode_type == EMPTY)
    {
        cout << "\"then\":" << endl;
        then->print(blanks);
    }
    else
    {
        cout << "\"then\": {" << endl;
        then->print(blanks);
        cout << "}," << endl;
    }
    if (els->astnode_type == EMPTY)
    {
        cout << "\"else\":" << endl;
        els->print(blanks);
    }
    else
    {
        cout << "\"else\": {" << endl;
        els->print(blanks);
        cout << "}" << endl;
    }
    cout << "}" << endl;
}

void while_astnode::print(int blanks)
{
    cout << "\"while\": {" << endl;
    cout << "\"cond\": {" << endl;
    cond->print(blanks);
    cout << "}," << endl;
    if (stmt->astnode_type == EMPTY)
    {
        cout << "\"stmt\":" << endl;
        stmt->print(blanks);
    }
    else
    {
        cout << "\"stmt\": {" << endl;
        stmt->print(blanks);
        cout << "}" << endl;
    }
    cout << "}" << endl;
}

void for_astnode::print(int blanks)
{
    cout << "\"for\": {" << endl;
    cout << "\"init\": {" << endl;
    init->print(blanks);
    cout << "}," << endl;
    cout << "\"guard\": {" << endl;
    guard->print(blanks);
    cout << "}," << endl;
    cout << "\"step\": {" << endl;
    step->print(blanks);
    cout << "}," << endl;
    if (body->astnode_type == EMPTY)
    {
        cout << "\"body\":" << endl;
        body->print(blanks);
    }
    else
    {
        cout << "\"body\": {" << endl;
        body->print(blanks);
        cout << "}" << endl;
    }
    cout << "}" << endl;
}

void op_binary_astnode::print(int blanks)
{
    cout << "\"op_binary\": {" << endl;
    cout << "\"op\": \"" << op << "\"," << endl;
    cout << "\"left\": {" << endl;
    left->print(blanks);
    cout << "}," << endl;
    cout << "\"right\": {" << endl;
    right->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void op_unary_astnode::print(int blanks)
{
    cout << "\"op_unary\": {" << endl;
    cout << "\"op\": \"" << op << "\"," << endl;
    cout << "\"child\": {" << endl;
    child->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void assignE_astnode::print(int blanks)
{
    cout << "\"assignE\": {" << endl;
    cout << "\"left\": {" << endl;
    left->print(blanks);
    cout << "}," << endl;
    cout << "\"right\": {" << endl;
    right->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void funcall_astnode::print(int blanks)
{
    cout << "\"funcall\": {" << endl;
    cout << "\"fname\": {" << endl;
    params[0]->print(blanks);
    cout << "}," << endl;
    cout << "\"params\": [" << endl;
    for (int i = 1; i < (int)(params.size()); i++)
    {
        cout << "{" << endl;
        params[i]->print(blanks);
        cout << "}" << endl;
        if (i < (int)(params.size()) - 1)
            cout << "," << endl;
    }
    cout << "]" << endl;
    cout << "}" << endl;
}

void intconst_astnode::print(int blanks)
{
    cout << "\"intconst\": " << value << endl;
}

void floatconst_astnode::print(int blanks)
{
    cout << "\"floatconst\": " << value << endl;
}

void stringconst_astnode::print(int blanks)
{
    cout << "\"stringconst\":" << value << "" << endl;
}

void member_astnode::print(int blanks)
{
    cout << "\"member\": {" << endl;
    cout << "\"struct\": {" << endl;
    structname->print(blanks);
    cout << "}," << endl;
    cout << "\"field\": {" << endl;
    field->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void arrow_astnode::print(int blanks)
{
    cout << "\"arrow\": {" << endl;
    cout << "\"pointer\": {" << endl;
    pointer->print(blanks);
    cout << "}," << endl;
    cout << "\"field\": {" << endl;
    field->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}

void identifier_astnode::print(int blanks)
{
    cout << "\"identifier\": \"" << name << "\"" << endl;
}

void arrayref_astnode::print(int blanks)
{
    cout << "\"arrayref\": {" << endl;
    cout << "\"array\": {" << endl;
    array->print(blanks);
    cout << "}," << endl;
    cout << "\"index\": {" << endl;
    index->print(blanks);
    cout << "}" << endl;
    cout << "}" << endl;
}
#endif /* AST_HH */
