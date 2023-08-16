#ifndef AST_HH
#define AST_HH
#include "ast.hh"
#include "symbtab.hh"
using namespace std;


extern vector<string> rstack;
extern vector<string> irstack;
extern SymbolTable gst, gstfun, gststruct;

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


void empty_astnode::gencode(vector<string> *ins, string func)
{
    return;
}

void seq_astnode::gencode(vector<string> *ins, string func)
{
    for(auto it = seq.begin(); it != seq.end(); it++)
    {
        (*it)->gencode(ins, func);
    }
    return;
}

void assignS_astnode::gencode(vector<string> *ins, string func)
{
    // cout << "Debug: ";
    // if(left->astnode_type==IDENTIFIER) cout << "identifier ast node " << ((identifier_astnode*)left)->name << endl;
    right->fall = true;
    right->gencode(ins, func);
    Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)left)->name);

    string reg = rstack.back();
    ins->push_back("    movl  "+reg+", "+id->offset+"(%ebp)\n");

    return;
}

void return_astnode::gencode(vector<string> *ins, string func)
{
    ret->gencode(ins, func);
    
    string reg = rstack.back();
    ins->push_back("    movl  "+reg+", %eax\n");
    ins->push_back("    jmp  .Lret" + func + "\n");
    return;
}

void proccall_astnode::gencode(vector<string> *ins, string func)
{
    int numargs = 0;
    string cfunc = ((identifier_astnode*)params[0])->name;
    if(cfunc=="printf")
        for( auto it = params.rbegin(); it !=params.rend()-1; ++it)
        {
            (*it)->gencode(ins, func);
            if((*it)->is_const)
                ins->push_back("    pushl  $" + to_string((*it)->const_val) + "\n");
            else if((*it)->is_strconst)
                ins->push_back("    pushl  $" + (*it)->strconst + "\n");
            else 
            {
                string reg  = rstack.back();
                ins->push_back("    pushl  " + reg + "\n");
            }
            numargs++;
        }
    else
        for( auto it = params.begin()+1; it !=params.end(); ++it)
        {
            (*it)->gencode(ins, func);
            if((*it)->is_const)
                ins->push_back("    pushl  $" + to_string((*it)->const_val) + "\n");
            else if((*it)->is_strconst)
                ins->push_back("    pushl  $" + (*it)->strconst + "\n");
            else 
            {
                string reg  = rstack.back();
                ins->push_back("    pushl  " + reg + "\n");
            }
            numargs++;
        }
    
    if(cfunc!="printf")
        ins->push_back("    subl  $4, %esp\n");
    ins->push_back("    call  " + cfunc + "\n");
    ins->push_back("    addl  $" + to_string(4*numargs) + ", %esp" + "\n");
    if(cfunc!="printf")
        ins->push_back("    addl  $4, %esp\n");

    if(label_l==1)
    {
        string reg = rstack.back();
        ins->push_back("    movl  %eax, "+reg+"\n");
    }
    
    return;
}

void if_astnode::gencode(vector<string> *ins, string func)
{
    cond->gencode(ins, func);
    string reg = rstack.back();
    string fl = get_jlabel();
    string el = get_jlabel();
    // string fl = get_jlabel();
    ins->push_back("    cmpl  $0, "+reg+"\n");
    ins->push_back("    je "+fl+"\n");
    then->gencode(ins, func);
    ins->push_back("    jmp "+el+"\n");
    ins->push_back(fl+":\n");
    els->gencode(ins,func);
    ins->push_back(el+":\n");    
    return;
}

void while_astnode::gencode(vector<string> *ins, string func)
{
    string stl = get_jlabel();
    string enl = get_jlabel();

    ins->push_back(stl+":\n");
    cond->gencode(ins, func);

    string reg = rstack.back();
    ins->push_back("    cmpl  $0, "+reg+"\n");
    ins->push_back("    je "+enl+"\n");

    stmt->gencode(ins, func);
    ins->push_back("    jmp "+stl+"\n");
    ins->push_back(enl+":\n");


    return;
}

void for_astnode::gencode(vector<string> *ins, string func)
{
    string stl = get_jlabel();
    string enl = get_jlabel();

    init->gencode(ins, func);
    ins->push_back(stl+":\n");

    guard->gencode(ins, func);
    string reg = rstack.back();
    ins->push_back("    cmpl  $0, "+reg+"\n");
    ins->push_back("    je "+enl+"\n");

    body->gencode(ins, func);
    step->gencode(ins, func);

    ins->push_back("    jmp "+stl+"\n");
    ins->push_back(enl+":\n");

    return;
}

void op_binary_astnode::gencode(vector<string> *ins, string func)
{

    if(op=="AND_OP")
    {
        left->fall = true;
        right->fall = this->fall;
    }
    else if(op=="OR_OP")
    {
        left->fall = false;
        right->fall = true;
    }

    if(right->label_r==0)
    {
        left->gencode(ins, func);
        string reg = rstack.back();
        if(op=="PLUS_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    addl  " + id->offset + "(%ebp), " + reg + "\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    addl  $" + to_string(((intconst_astnode*)right)->value) + ", " + reg + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    addl  %eax, "+reg+"\n");
            }
        }
        else if(op=="MINUS_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    subl  " + id->offset + "(%ebp), " + reg + "\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    subl  $" + to_string(((intconst_astnode*)right)->value) + ", " + reg + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    subl  %eax, "+reg+"\n");
            }
        }
        else if(op=="MULT_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    imull  " + id->offset + "(%ebp), " + reg + "\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    imull  $" + to_string(((intconst_astnode*)right)->value) + ", " + reg + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    imull  %eax, "+reg+"\n");
            }
        }
        else if(op=="DIV_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    movl  " + id->offset + "(%ebp), %ecx\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    movl  $" + to_string(((intconst_astnode*)right)->value) + ", %ecx\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    movl  %eax, %ecx\n");
            }
            ins->push_back("    movl  "+reg+", %eax\n");
            ins->push_back("    cltd\n");
            ins->push_back("    idivl  %ecx\n");
            ins->push_back("    movl  %eax, "+reg+"\n");
        }

        if(op=="GT_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    setg %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LT_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    setl %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="GE_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    setge %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LE_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    setle %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="EQ_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    sete %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="NE_OP_INT")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    cmpl  "+ id->offset + "(%ebp), " + reg+"\n");
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    cmpl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg  + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    cmpl  %eax, "+reg+"\n");
            }
            ins->push_back("    setne %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }

        else if(op=="AND_OP")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    andl  " + id->offset + "(%ebp), " + reg + "\n");
                
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back( "    andl  $" + to_string(((intconst_astnode*)right)->value) + ", " + reg + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    andl  %eax, "+reg+"\n");
            }
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        
        }
        else if(op=="OR_OP")
        {
            if(right->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    orl  " + id->offset + "(%ebp), " + reg + "\n");
                
            }
            else if(right->astnode_type==INTCONST)
                ins->push_back("    orl  $" + to_string(((intconst_astnode*)right)->value) + ", " + reg + "\n");
            else if(right->astnode_type==PROCCALL || right->astnode_type==FUNCALL)
            {
                ins->push_back("    orl  %eax, "+reg+"\n");
            }
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        
        }


        
    }
    else if(left->label_l<right->label_r && left->label_l<3)
    {
        string reg1 = rstack.back(); rstack.pop_back();
        string reg2 = rstack.back(); rstack.pop_back();
        rstack.push_back(reg1); rstack.push_back(reg2);

        right->gencode(ins, func);
        string R = rstack.back(); rstack.pop_back();
        left->gencode(ins, func);

        string reg = rstack.back();
        string operands = R + ", " + reg + "\n";
        if(op=="PLUS_INT")
            ins->push_back("    addl  " + operands);
        else if(op=="MINUS_INT")
            ins->push_back("    subl  " + operands);
        else if(op=="MULT_INT")
            ins->push_back("    imull  " + operands);
        else if(op=="DIV_INT")
        {
            ins->push_back("    movl  "+reg+", %eax\n");
            ins->push_back("    cltd\n");
            ins->push_back("    idivl   "+R+"\n");
            ins->push_back("    movl  %eax, "+reg+"\n");
        }
        // operands =  reg + ", " + R + "\n";

        if(op=="GT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setg  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setl %al\n" );
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="GE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setge %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setle %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="EQ_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    sete %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="NE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setne %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }

        operands = R + ", " + reg + "\n";
        if(op=="AND_OP")
        {
            
            ins->push_back( "    andl  " + operands);
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="OR_OP")
        {
            
            ins->push_back( "    orl  " + operands);
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }

        rstack.pop_back();
        rstack.push_back(R);
        rstack.push_back(reg);
    }
    else if(left->label_l>=right->label_r && right->label_l<3)
    {
        left->gencode(ins, func);
        string R = rstack.back(); rstack.pop_back();
        right->gencode(ins, func);

        string reg = rstack.back();
        string operands = reg + ", " + R + "\n";
        if(op=="PLUS_INT")
            ins->push_back("    addl  " + operands);
        else if(op=="MINUS_INT")
            ins->push_back("    subl  " + operands);
        else if(op=="MULT_INT")
            ins->push_back("    imull  " + operands);
        else if(op=="DIV_INT")
        {
            ins->push_back("    movl  "+R+", %eax\n");
            ins->push_back("    cltd\n");
            ins->push_back("    idivl   "+reg+"\n");
            ins->push_back("    movl  %eax, "+R+"\n");
        }

        // operands = R + ", " + reg + "\n";
        if(op=="GT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setg  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="LT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setl  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="GE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setge  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="LE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setle  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="EQ_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    sete  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="NE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }

        operands = reg + ", " + R + "\n";
        if(op=="AND_OP")
        {
            
            ins->push_back( "    andl  " + operands);
            ins->push_back("    cmpl  $0, "+R+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }
        else if(op=="OR_OP")
        {
            
            ins->push_back( "    orl  " + operands);
            ins->push_back("    cmpl  $0, "+R+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+R+"\n");
        }

        rstack.push_back(R);
    }
    else if(left->label_l>=3 && right->label_r>=3)
    {
        right->gencode(ins, func);
        ins->push_back("    subl	$4, %esp\n");
        string reg = rstack.back();
        ins->push_back("    movl	"+reg+", (%esp)\n");
        left->gencode(ins, func);

        string operands = "(%esp), " + reg + "\n";
        if(op=="PLUS_INT")
            ins->push_back("    addl  " + operands);
        else if(op=="MINUS_INT")
            ins->push_back("    subl  " + operands);
        else if(op=="MULT_INT")
            ins->push_back("    imull  " + operands);
        else if(op=="DIV_INT")
        {
            ins->push_back("    movl  "+reg+", %eax\n");
            ins->push_back("    cltd\n");
            ins->push_back("    movl  (%esp), %ecx\n");
            ins->push_back("    idivl   %ecx\n");
            ins->push_back("    movl  %eax, "+reg+"\n");
        }

        // operands = reg + ", " + "(%esp)\n";
        if(op=="GT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setg %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LT_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setl %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="GE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setge %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="LE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setle %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="EQ_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    sete %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="NE_OP_INT")
        {
            ins->push_back("    cmpl  " + operands);
            ins->push_back("    setne %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }

        operands = "(%esp), " + reg + "\n";
        if(op=="AND_OP")
        {
            
            ins->push_back( "    andl  " + operands);
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        else if(op=="OR_OP")
        {
            
            ins->push_back( "    orl  " + operands);
            ins->push_back("    cmpl  $0, "+reg+"\n");
            ins->push_back("    setne  %al\n");
            ins->push_back("    movzbl  %al, "+reg+"\n");
        }
        ins->push_back("    addl	$4, %esp\n");
    }
    // cout << "Bin node: " << op << endl;
    return;
}

void op_unary_astnode::gencode(vector<string> *ins, string func)
{
    if(op=="NOT")
    {
        child->fall = !this->fall;
    }
    child->gencode(ins, func);
    // cout << op << "----0----------\n";
    if(op=="UMINUS")
    {
        string reg = rstack.back();
        if(child->label_l==0)
        {
            if(child->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    movl  "+ id->offset + "(%ebp)," + reg +"\n");
            }
            else if(child->astnode_type==INTCONST)
                ins->push_back( "    movl $" + to_string(((intconst_astnode*)right)->value) + ", " + reg +"\n");
            else if(child->astnode_type==PROCCALL || child->astnode_type==FUNCALL)
            {
                ins->push_back("    movl  %eax," + reg +"\n");
            }
        }
        ins->push_back("    negl  "+reg+"\n");
    }
    else if(op=="NOT")
    {
        string reg = rstack.back();
        string lbl = get_jlabel();
        string lbl2 = get_jlabel();
        if(child->label_l==0)
        {
            if(child->astnode_type==IDENTIFIER)
            {
                Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)right)->name);
                ins->push_back("    movl  "+ id->offset + "(%ebp), %eax\n");
            }
            else if(child->astnode_type==INTCONST)
                ins->push_back( "    movl $" + to_string(((intconst_astnode*)right)->value) + ", %eax\n");
            else if(child->astnode_type==PROCCALL || child->astnode_type==FUNCALL)
            {
                ;
            }
            ins->push_back("    cmpl  $0, %eax\n");
        }
        else
            ins->push_back("    cmpl  $0, "+reg+"\n");
        ins->push_back("    je  "+lbl+"\n");
        ins->push_back("    movl  $0, "+ reg+"\n");
        ins->push_back("    jmp  "+lbl2+"\n");
        ins->push_back(lbl+":\n");
        ins->push_back("    movl  $1, "+ reg+"\n");
        ins->push_back(lbl2+":\n");
    }
    return;
}

void assignE_astnode::gencode(vector<string> *ins, string func)
{
    right->fall = true;
    right->gencode(ins, func);
    Entry *id = gstfun.search(func)->symbtab->search(((identifier_astnode*)left)->name);

    string reg = rstack.back();
    ins->push_back("    movl  "+reg+", "+id->offset+"(%ebp)\n");

    return;
}

void funcall_astnode::gencode(vector<string> *ins, string func)
{
    int numargs = 0;
    string cfunc = ((identifier_astnode*)params[0])->name;
    if(cfunc=="printf")
        for( auto it = params.rbegin(); it !=params.rend()-1; ++it)
        {
            (*it)->gencode(ins, func);
            if((*it)->is_const)
                ins->push_back("    pushl  $" + to_string((*it)->const_val) + "\n");
            else if((*it)->is_strconst)
                ins->push_back("    pushl  $" + (*it)->strconst + "\n");
            else 
            {
                string reg  = rstack.back();
                ins->push_back("    pushl  " + reg + "\n");
            }
            numargs++;
        }
    else
        for( auto it = params.begin()+1; it !=params.end(); ++it)
        {
            (*it)->gencode(ins, func);
            if((*it)->is_const)
                ins->push_back("    pushl  $" + to_string((*it)->const_val) + "\n");
            else if((*it)->is_strconst)
                ins->push_back("    pushl  $" + (*it)->strconst + "\n");
            else 
            {
                
                string reg  = rstack.back();
                ins->push_back("    pushl  " + reg + "\n");
            }
            numargs++;
        }
    
    if(cfunc!="printf")
        ins->push_back("    subl  $4, %esp\n");
    ins->push_back("    call  " + cfunc + "\n");
    ins->push_back("    addl  $" + to_string(4*numargs) + ", %esp" + "\n");
    if(cfunc!="printf")
        ins->push_back("    addl  $4, %esp\n");

    if(label_l==1)
    {
        string reg = rstack.back();
        ins->push_back("    movl  %eax, "+reg+"\n");
    }
    
    return;
}

void intconst_astnode::gencode(vector<string> *ins, string func)
{
    if(label_l==1) 
    {
        string reg = rstack.back();
        string gen = "    movl  $" + to_string(value) + ", " + reg + "\n";
        ins->push_back(gen);
    }
    return;
}

void floatconst_astnode::gencode(vector<string> *ins, string func)
{
    return;
}

void stringconst_astnode::gencode(vector<string> *ins, string func)
{
    // cout << value << " : " << this->label_l << " : " << this->label_r << endl;
    return;
}

void identifier_astnode::gencode(vector<string> *ins, string func)
{
    if(label_l==1)
    {
        string reg = rstack.back();
        Entry *id = gstfun.search(func)->symbtab->search(name);
        string gen = "    movl  " + id->offset + "(%ebp), " + reg + "\n";
        ins->push_back(gen);
    }
    return;
}

void member_astnode::gencode(vector<string> *ins, string func)
{
    return;
}

void arrow_astnode::gencode(vector<string> *ins, string func)
{
    return;
}

void arrayref_astnode::gencode(vector<string> *ins, string func)
{
    return;
}






#endif /* AST_HH */
