#include "scanner.hh"
#include "parser.tab.hh"
#include <fstream>
#include <map>

using namespace std;

SymbolTable gst, gstfun, gststruct;
std::map<string, abstract_astnode *> ast;
std::map<string, SymbolTable *> predefined = {
    {"printf", new SymbolTable()},
    {"scanf", new SymbolTable()},
    {"mod", new SymbolTable()}
};

vector<string> rstack = {"%ebx", "%edi", "%esi"};
vector<string> irstack;

std::map<string, ASM> asmb;
ASM format_asm = { {"   .text\n    .section    .rodata\n"}, "null"};

int main(int argc, char **argv)
{
    using namespace std;
    fstream in_file, out_file;

    in_file.open(argv[1], ios::in);

    IPL::Scanner scanner(in_file);

    IPL::Parser parser(scanner);

#ifdef YYDEBUG
    parser.set_debug_level(1);
#endif
    parser.parse();
    // create gstfun with function entries only

    for (const auto &entry : gst.Entries)
    {
        if (entry.second.varfun == "fun")
            gstfun.Entries.insert({entry.first, entry.second});
    }
    // create gststruct with struct entries only

    for (const auto &entry : gst.Entries)
    {
        if (entry.second.varfun == "struct")
            gststruct.Entries.insert({entry.first, entry.second});
    }
    // start the JSON printing

    // cout << "{\"globalST\": " << endl;
    // gst.printgst();
    // cout << "," << endl;

    // cout << "  \"structs\": [" << endl;
    // for (auto it = gststruct.Entries.begin(); it != gststruct.Entries.end(); ++it)

    // {
    //     cout << "{" << endl;
    //     cout << "\"name\": "
    //          << "\"" << it->first << "\"," << endl;
    //     cout << "\"localST\": " << endl;
    //     it->second.symbtab->print();
    //     cout << "}" << endl;
    //     if (next(it, 1) != gststruct.Entries.end())
    //         cout << "," << endl;
    // }
    // cout << "]," << endl;
    // cout << "  \"functions\": [" << endl;

    // for (auto it = gstfun.Entries.begin(); it != gstfun.Entries.end(); ++it)

    // {
    //     cout << "{" << endl;
    //     cout << "\"name\": "
    //          << "\"" << it->first << "\"," << endl;
    //     cout << "\"localST\": " << endl;

    //     it->second.symbtab->print();
    //     cout << "," << endl;
    //     cout << "\"ast\": " << endl;
    //     cout << "{\n";
    //     ast[it->first]->print(0);
    //     cout << "\n}";
    //     cout << "}" << endl;
    //     if (next(it, 1) != gstfun.Entries.end())
    //         cout << "," << endl;
    // }
    // cout << "]" << endl;
    // cout << "}" << endl;


    cout << "   .file   \"" << argv[1] << "\"\n";
    if(format_asm.ins.size()>1) print_ins(format_asm.ins);

    for ( auto it = gstfun.Entries.begin(); it != gstfun.Entries.end(); ++it)
    {
        asmb[it->first] = {{""}, it->first};
        asmb[it->first].ins.push_back("    .text\n");
        asmb[it->first].ins.push_back("    .globl  "+it->first+"\n");
        asmb[it->first].ins.push_back("    .type  "+it->first+", @function\n");
        asmb[it->first].ins.push_back(it->first+":\n");
        asmb[it->first].ins.push_back("    pushl  %ebp\n");
        asmb[it->first].ins.push_back("    movl   %esp, %ebp\n");

        auto localTab = it->second.symbtab;
        int size  = 0;
        for( auto it = localTab->Entries.begin(); it != localTab->Entries.end(); it++)
        {
            if(it->second.param_local=="local") size += it->second.size;
        }

        asmb[it->first].ins.push_back("    subl   $" + to_string(size) + ", %esp\n");

        ast[it->first]->gencode(&asmb[it->first].ins, it->first);

        asmb[it->first].ins.push_back(".Lret"+it->first+":\n");
        asmb[it->first].ins.push_back("    addl   $" + to_string(size) + ", %esp\n");
        asmb[it->first].ins.push_back("    leave\n");
        asmb[it->first].ins.push_back("    ret\n");
        asmb[it->first].ins.push_back("    .size  " + it->first + ", .-" + it->first + "\n");

        print_ins(asmb[it->first].ins);
    }




    fclose(stdout);
}
